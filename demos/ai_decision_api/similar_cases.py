from __future__ import annotations

import json
import math
import os
import time
import urllib.error
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from typing import Protocol

from settings import get_settings


@dataclass(frozen=True)
class NearestCase:
    case_id: str
    label: str
    similarity: float
    contribution: float


class SimilarCaseMatcher(Protocol):
    @property
    def enabled(self) -> bool: ...

    @property
    def model_name(self) -> str | None: ...

    def nearest(self, text: str) -> NearestCase | None: ...


class DisabledMatcher:
    @property
    def enabled(self) -> bool:
        return False

    @property
    def model_name(self) -> str | None:
        return None

    def nearest(self, text: str) -> NearestCase | None:
        return None


def get_matcher() -> SimilarCaseMatcher:
    settings = get_settings()
    if not settings.enable_similar_cases:
        return DisabledMatcher()

    try:
        if settings.similar_cases_provider == "hf":
            return HuggingFaceHostedMiniLMMatcher(
                model_name=settings.similar_cases_model,
                reference_cases_path=settings.reference_cases_path,
                api_key=os.environ.get("HUGGINGFACE_API_KEY", ""),
            )
        # Default "local" path needs optional heavy deps. In small cloud runtimes,
        # sentence-transformers often isn't installed (or can't be loaded safely).
        # If the user provided an HF key, automatically fall back to hosted embeddings.
        try:
            import sentence_transformers  # noqa: F401  # type: ignore[import-not-found]
        except Exception:
            api_key = os.environ.get("HUGGINGFACE_API_KEY", "")
            if api_key:
                return HuggingFaceHostedMiniLMMatcher(
                    model_name=settings.similar_cases_model,
                    reference_cases_path=settings.reference_cases_path,
                    api_key=api_key,
                )
            return DisabledMatcher()

        return MiniLMMatcher(
            model_name=settings.similar_cases_model,
            reference_cases_path=settings.reference_cases_path,
        )
    except Exception:
        # Never break the MVP if ML is unavailable.
        return DisabledMatcher()


def load_reference_cases(path: str) -> list[dict[str, str]]:
    p = Path(path)
    data = json.loads(p.read_text(encoding="utf-8"))
    assert isinstance(data, list)
    return [{"id": str(d["id"]), "text": str(d["text"]), "label": str(d["label"])} for d in data]


def _contribution_from_similarity(*, label: str, similarity: float) -> float:
    # MVP: tiny bounded adjustment.
    # - "risky" increases score up to +0.10
    # - "safe" decreases score down to -0.05
    if similarity < 0.55:
        return 0.0
    if label == "risky":
        return min(0.10, max(0.0, (similarity - 0.55) * 0.20))
    if label == "safe":
        return max(-0.05, min(0.0, -((similarity - 0.55) * 0.10)))
    return 0.0


@dataclass(frozen=True)
class FakeSimilarCaseMatcher:
    nearest_case: NearestCase | None

    @property
    def enabled(self) -> bool:
        return True

    @property
    def model_name(self) -> str | None:
        return "fake"

    def nearest(self, text: str) -> NearestCase | None:
        return self.nearest_case


class MiniLMMatcher:
    def __init__(self, *, model_name: str, reference_cases_path: str) -> None:
        self.model_name = model_name
        self._reference_cases_path = reference_cases_path
        self._model = None
        self._ref_vectors = None
        self._ref_meta: list[tuple[str, str]] | None = None

    @property
    def enabled(self) -> bool:
        return True

    def _lazy_init(self) -> None:
        if self._model is not None:
            return

        # Heavy deps are optional: only import when enabled.
        from sentence_transformers import SentenceTransformer  # type: ignore[import-not-found]

        self._model = SentenceTransformer(self.model_name)
        refs = load_reference_cases(self._reference_cases_path)
        self._ref_meta = [(r["id"], r["label"]) for r in refs]
        ref_texts = [r["text"] for r in refs]

        import numpy as np  # type: ignore[import-not-found]

        ref_vecs = self._model.encode(ref_texts, normalize_embeddings=True)
        self._ref_vectors = np.asarray(ref_vecs, dtype="float32")

    def nearest(self, text: str) -> NearestCase | None:
        self._lazy_init()

        assert self._model is not None
        assert self._ref_vectors is not None
        assert self._ref_meta is not None

        import numpy as np  # type: ignore[import-not-found]

        q = self._model.encode([text], normalize_embeddings=True)
        qv = np.asarray(q, dtype="float32")[0]
        sims = self._ref_vectors @ qv  # cosine similarity on normalized vectors
        idx = int(np.argmax(sims))
        similarity = float(sims[idx])
        case_id, label = self._ref_meta[idx]
        contribution = float(_contribution_from_similarity(label=label, similarity=similarity))
        return NearestCase(case_id=case_id, label=label, similarity=similarity, contribution=contribution)


class HuggingFaceHostedMiniLMMatcher:
    """
    Cloud-safe matcher: calls Hugging Face hosted feature-extraction.

    This avoids importing PyTorch / sentence-transformers in small cloud runtimes
    where the process may be OOM-killed during model load.
    """

    def __init__(self, *, model_name: str, reference_cases_path: str, api_key: str) -> None:
        if not api_key:
            raise ValueError("Missing HUGGINGFACE_API_KEY for hosted similar-case matcher.")
        self.model_name = model_name
        self._api_key = api_key
        self._reference_cases_path = reference_cases_path
        self._refs = load_reference_cases(self._reference_cases_path)
        # We use hosted sentence-similarity for MiniLM (no embeddings to cache).

    @property
    def enabled(self) -> bool:
        return True

    def _hf_sentence_similarities(self, *, source_sentence: str, sentences: list[str]) -> list[float]:
        """
        MiniLM on HF Inference is commonly served as a sentence-similarity pipeline.
        Payload shape:
          {"inputs": {"source_sentence": "...", "sentences": ["...", ...]}}

        Response shape:
          [0.12, 0.98, ...]  # similarity per sentence
        """
        url = f"https://router.huggingface.co/hf-inference/models/{self.model_name}"
        body = json.dumps(
            {"inputs": {"source_sentence": source_sentence, "sentences": sentences}},
            ensure_ascii=False,
        ).encode("utf-8")
        req = urllib.request.Request(
            url=url,
            method="POST",
            data=body,
            headers={
                "Authorization": f"Bearer {self._api_key}",
                "Content-Type": "application/json",
            },
        )
        data = self._request_with_retries(req)
        if not isinstance(data, list) or any(not isinstance(x, (int, float)) for x in data):
            raise ValueError("Unexpected hosted similarity response shape.")
        return [float(x) for x in data]

    def _request_with_retries(self, req: urllib.request.Request) -> object:
        # Hugging Face inference can return "model loading" for first request.
        # We keep retries tiny to avoid hanging the API.
        for attempt in range(3):
            try:
                with urllib.request.urlopen(req, timeout=45) as resp:  # noqa: S310 - trusted endpoint
                    raw = resp.read().decode("utf-8")
                payload = json.loads(raw)
                # If we got a structured "loading" response, wait briefly and retry.
                if isinstance(payload, dict) and "estimated_time" in payload:
                    wait_s = float(payload.get("estimated_time") or 0.0)
                    time.sleep(min(8.0, max(0.25, wait_s)))
                    continue
                return payload
            except urllib.error.HTTPError as e:
                # Read body for HF structured error messages.
                body = ""
                try:
                    body = e.read().decode("utf-8")
                except Exception:
                    body = ""
                if e.code in (429, 500, 502, 503, 504):
                    # Backoff a little and retry.
                    time.sleep(0.5 * (attempt + 1))
                    continue
                raise ValueError(f"Hosted embedding HTTP error {e.code}: {body}") from e
            except (urllib.error.URLError, TimeoutError):
                time.sleep(0.5 * (attempt + 1))
                continue
        raise ValueError("Hosted embedding request failed after retries.")

    def nearest(self, text: str) -> NearestCase | None:
        sentences = [r["text"] for r in self._refs]
        sims = self._hf_sentence_similarities(source_sentence=text, sentences=sentences)
        if not sims:
            return None

        best_idx = max(range(len(sims)), key=lambda i: sims[i])
        best_sim = float(sims[best_idx])
        best = self._refs[best_idx]
        best_id = best["id"]
        best_label = best["label"]
        contribution = float(_contribution_from_similarity(label=best_label, similarity=best_sim))
        return NearestCase(case_id=best_id, label=best_label, similarity=best_sim, contribution=contribution)

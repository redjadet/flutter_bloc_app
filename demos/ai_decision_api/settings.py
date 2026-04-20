from __future__ import annotations

from pathlib import Path

from pydantic_settings import BaseSettings

BASE_DIR = Path(__file__).resolve().parent


class Settings(BaseSettings):
    port: int = 8008
    sqlite_path: str = str(BASE_DIR / ".data" / "ai_decision_demo.sqlite3")
    allow_seed_on_startup: bool = True
    enable_similar_cases: bool = False
    similar_cases_provider: str = "local"  # "local" (sentence-transformers) or "hf" (hosted)
    similar_cases_model: str = "sentence-transformers/all-MiniLM-L6-v2"
    reference_cases_path: str = str(BASE_DIR / "reference_cases.json")


_settings: Settings | None = None


def get_settings() -> Settings:
    global _settings
    if _settings is None:
        _settings = Settings()
    return _settings

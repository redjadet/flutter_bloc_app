from __future__ import annotations

import os
from pathlib import Path

import pytest
from fastapi.testclient import TestClient


@pytest.fixture()
def client(tmp_path: Path):
    # Must run before `main` / `settings` are imported.
    db_path = tmp_path / "ai_decision_demo.sqlite3"
    os.environ["SQLITE_PATH"] = str(db_path)
    os.environ["ALLOW_SEED_ON_STARTUP"] = "1"
    os.environ["ENABLE_SIMILAR_CASES"] = "0"

    # Reset cached settings singleton if already imported in another test.
    import settings as settings_mod

    settings_mod._settings = None  # type: ignore[attr-defined]

    import main as main_mod

    with TestClient(main_mod.app) as c:
        yield c


@pytest.fixture()
def client_with_fake_matcher(tmp_path: Path):
    db_path = tmp_path / "ai_decision_demo.sqlite3"
    os.environ["SQLITE_PATH"] = str(db_path)
    os.environ["ALLOW_SEED_ON_STARTUP"] = "1"
    os.environ["ENABLE_SIMILAR_CASES"] = "1"

    import settings as settings_mod

    settings_mod._settings = None  # type: ignore[attr-defined]

    import main as main_mod
    from similar_cases import FakeSimilarCaseMatcher, NearestCase, get_matcher

    main_mod.app.dependency_overrides[get_matcher] = lambda: FakeSimilarCaseMatcher(
        nearest_case=NearestCase(
            case_id="case_ref_003",
            label="risky",
            similarity=0.81,
            contribution=0.07,
        )
    )

    with TestClient(main_mod.app) as c:
        yield c
    main_mod.app.dependency_overrides.clear()

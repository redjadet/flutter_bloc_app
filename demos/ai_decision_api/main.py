from __future__ import annotations

import uuid
from contextlib import asynccontextmanager

from fastapi import Depends, FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from decision_service import DecisionService
from schemas import (
    CaseSummary,
    CreateActionRequest,
    CreateActionResponse,
    CreateDecisionRequest,
    CreateDecisionResponse,
    GetCaseDetailResponse,
    GetCasesResponse,
    HealthResponse,
)
from seed_data import seed
from settings import get_settings
from similar_cases import SimilarCaseMatcher, get_matcher
from store import Store


@asynccontextmanager
async def lifespan(app: FastAPI):
    settings = get_settings()
    store = Store(sqlite_path=settings.sqlite_path)
    store.ensure_db()
    if settings.allow_seed_on_startup and store.count_cases() == 0:
        seed(store)
    app.state.store = store
    yield


app = FastAPI(title="AI Decision Workbench API", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # dev-only; MVP is local
    allow_methods=["*"],
    allow_headers=["*"],
)


def get_store() -> Store:
    return app.state.store


def get_service(
    store: Store = Depends(get_store),
    matcher: SimilarCaseMatcher = Depends(get_matcher),
) -> DecisionService:
    return DecisionService(store=store, matcher=matcher)


@app.get("/health", response_model=HealthResponse)
def health(matcher: SimilarCaseMatcher = Depends(get_matcher)) -> HealthResponse:
    return HealthResponse(similar_cases_enabled=bool(matcher.enabled), model=matcher.model_name)


@app.get("/cases", response_model=GetCasesResponse)
def list_cases(store: Store = Depends(get_store)) -> GetCasesResponse:
    cases = [CaseSummary(**row) for row in store.list_case_summaries()]
    return GetCasesResponse(cases=cases)


@app.get("/cases/{case_id}", response_model=GetCaseDetailResponse)
def get_case(case_id: str, store: Store = Depends(get_store)) -> GetCaseDetailResponse:
    detail = store.get_case_detail(case_id=case_id)
    if detail is None:
        raise HTTPException(status_code=404, detail="case_not_found")
    return GetCaseDetailResponse(
        case=detail["case"],
        applicant=detail["applicant"],
        business=detail["business"],
        loan=detail["loan"],
        risk_signals=detail["risk_signals"],
        latest_decision=detail["latest_decision"],
        actions=detail["actions"],
    )


@app.post("/cases/{case_id}/decision", response_model=CreateDecisionResponse)
def create_decision(
    case_id: str,
    body: CreateDecisionRequest,
    service: DecisionService = Depends(get_service),
) -> CreateDecisionResponse:
    try:
        out = service.create_decision(case_id=case_id, operator_note=body.operator_note)
    except KeyError:
        raise HTTPException(status_code=404, detail="case_not_found")
    return CreateDecisionResponse(**out)


@app.post("/cases/{case_id}/actions", response_model=CreateActionResponse)
def create_action(
    case_id: str,
    body: CreateActionRequest,
    store: Store = Depends(get_store),
) -> CreateActionResponse:
    detail = store.get_case_detail(case_id=case_id)
    if detail is None:
        raise HTTPException(status_code=404, detail="case_not_found")
    # action_type is validated via Pydantic literal, so safe to store.
    action_id = f"act_{uuid.uuid4().hex[:8]}"
    created = store.insert_action(
        action_id=action_id,
        case_id=case_id,
        action_type=body.action_type,
        note=body.note,
    )
    return CreateActionResponse(**created)

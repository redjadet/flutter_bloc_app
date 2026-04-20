from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class Applicant:
    id: str
    name: str
    personal_credit_score: int
    prior_defaults: int


@dataclass(frozen=True)
class Business:
    id: str
    applicant_id: str
    name: str
    industry: str
    monthly_revenue: float
    age_months: int


@dataclass(frozen=True)
class LoanApplication:
    id: str
    applicant_id: str
    business_id: str
    amount: float
    purpose: str
    status: str
    created_at: str

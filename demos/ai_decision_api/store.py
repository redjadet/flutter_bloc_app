from __future__ import annotations

import json
import os
import sqlite3
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Optional


def now_iso() -> str:
    return datetime.now(tz=timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


@dataclass(frozen=True)
class Store:
    sqlite_path: str

    def _connect(self) -> sqlite3.Connection:
        conn = sqlite3.connect(self.sqlite_path)
        conn.row_factory = sqlite3.Row
        return conn

    def ensure_db(self) -> None:
        Path(self.sqlite_path).parent.mkdir(parents=True, exist_ok=True)
        with self._connect() as conn:
            conn.execute(
                """
                create table if not exists applicants(
                  id text primary key,
                  name text not null,
                  personal_credit_score integer not null,
                  prior_defaults integer not null
                )
                """
            )
            conn.execute(
                """
                create table if not exists businesses(
                  id text primary key,
                  applicant_id text not null,
                  name text not null,
                  industry text not null,
                  monthly_revenue real not null,
                  age_months integer not null
                )
                """
            )
            conn.execute(
                """
                create table if not exists loan_applications(
                  id text primary key,
                  applicant_id text not null,
                  business_id text not null,
                  amount real not null,
                  purpose text not null,
                  status text not null,
                  created_at text not null
                )
                """
            )
            conn.execute(
                """
                create table if not exists risk_signals(
                  id text primary key,
                  case_id text not null,
                  key text not null,
                  label text not null,
                  value text not null,
                  severity text not null
                )
                """
            )
            conn.execute(
                """
                create table if not exists decisions(
                  id text primary key,
                  case_id text not null,
                  risk_score real not null,
                  risk_band text not null,
                  recommended_action text not null,
                  rationale text not null,
                  signals_json text not null,
                  proof_json text not null,
                  meta_json text not null,
                  created_at text not null
                )
                """
            )
            conn.execute(
                """
                create table if not exists actions(
                  id text primary key,
                  case_id text not null,
                  action_type text not null,
                  note text not null,
                  created_at text not null
                )
                """
            )

    def reset(self) -> None:
        if os.path.exists(self.sqlite_path):
            os.remove(self.sqlite_path)
        self.ensure_db()

    def count_cases(self) -> int:
        with self._connect() as conn:
            row = conn.execute("select count(*) as c from loan_applications").fetchone()
            return int(row["c"])

    def list_case_summaries(self) -> list[dict[str, Any]]:
        with self._connect() as conn:
            rows = conn.execute(
                """
                select
                  la.id as id,
                  a.name as applicant_name,
                  b.name as business_name,
                  la.amount as amount,
                  la.status as status,
                  (
                    select d.risk_band
                    from decisions d
                    where d.case_id = la.id
                    order by d.created_at desc
                    limit 1
                  ) as last_decision_band
                from loan_applications la
                join applicants a on a.id = la.applicant_id
                join businesses b on b.id = la.business_id
                order by la.created_at desc
                """
            ).fetchall()
            return [dict(r) for r in rows]

    def get_case_detail(self, *, case_id: str) -> Optional[dict[str, Any]]:
        with self._connect() as conn:
            case = conn.execute(
                "select * from loan_applications where id = ?",
                (case_id,),
            ).fetchone()
            if case is None:
                return None
            applicant = conn.execute(
                "select * from applicants where id = ?",
                (case["applicant_id"],),
            ).fetchone()
            business = conn.execute(
                "select * from businesses where id = ?",
                (case["business_id"],),
            ).fetchone()
            signals = conn.execute(
                "select key, label, value, severity from risk_signals where case_id = ? order by severity desc, key asc",
                (case_id,),
            ).fetchall()
            latest_decision = conn.execute(
                "select * from decisions where case_id = ? order by created_at desc limit 1",
                (case_id,),
            ).fetchone()
            actions = conn.execute(
                "select * from actions where case_id = ? order by created_at desc",
                (case_id,),
            ).fetchall()

            latest: dict[str, Any] | None = None
            if latest_decision is not None:
                latest = dict(latest_decision)
                latest["signals"] = json.loads(str(latest.pop("signals_json")))
                latest["proof"] = json.loads(str(latest.pop("proof_json")))
                latest["meta"] = json.loads(str(latest.pop("meta_json")))

            out: dict[str, Any] = {
                "case": {"id": case["id"], "status": case["status"], "created_at": case["created_at"]},
                "applicant": dict(applicant) if applicant else None,
                "business": dict(business) if business else None,
                "loan": {"amount": case["amount"], "purpose": case["purpose"]},
                "risk_signals": [dict(r) for r in signals],
                "latest_decision": latest,
                "actions": [dict(r) for r in actions],
            }
            return out

    def insert_action(self, *, action_id: str, case_id: str, action_type: str, note: str) -> dict[str, Any]:
        created_at = now_iso()
        with self._connect() as conn:
            conn.execute(
                "insert into actions(id, case_id, action_type, note, created_at) values(?, ?, ?, ?, ?)",
                (action_id, case_id, action_type, note, created_at),
            )
        return {
            "id": action_id,
            "case_id": case_id,
            "action_type": action_type,
            "note": note,
            "created_at": created_at,
        }

    def insert_decision(
        self,
        *,
        decision_id: str,
        case_id: str,
        risk_score: float,
        risk_band: str,
        recommended_action: str,
        rationale: str,
        signals: dict[str, Any],
        proof: dict[str, Any],
        meta: dict[str, Any],
    ) -> dict[str, Any]:
        created_at = now_iso()
        with self._connect() as conn:
            conn.execute(
                """
                insert into decisions(
                  id, case_id, risk_score, risk_band, recommended_action, rationale,
                  signals_json, proof_json, meta_json, created_at
                )
                values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    decision_id,
                    case_id,
                    float(risk_score),
                    risk_band,
                    recommended_action,
                    rationale,
                    json.dumps(signals, ensure_ascii=False),
                    json.dumps(proof, ensure_ascii=False),
                    json.dumps(meta, ensure_ascii=False),
                    created_at,
                ),
            )
        return {
            "id": decision_id,
            "case_id": case_id,
            "risk_score": risk_score,
            "risk_band": risk_band,
            "recommended_action": recommended_action,
            "rationale": rationale,
            "signals": signals,
            "proof": proof,
            "meta": {**meta, "created_at": created_at},
        }

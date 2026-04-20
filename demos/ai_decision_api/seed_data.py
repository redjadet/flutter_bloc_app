from __future__ import annotations

import argparse

from settings import get_settings
from store import Store, now_iso


def seed(store: Store) -> None:
    # Applicants
    applicants = [
        ("app_low_001", "Deniz Kaya", 735, 0),
        ("app_med_001", "Ece Demir", 665, 0),
        ("app_high_001", "Aylin Yilmaz", 610, 1),
        ("app_high_002", "Mert Aslan", 580, 2),
        ("app_med_002", "Selin Aksoy", 690, 0),
        ("app_low_002", "Can Arslan", 760, 0),
    ]

    businesses = [
        ("biz_low_001", "app_low_001", "Golden Crust Bakery", "food", 18000.0, 72),
        ("biz_med_001", "app_med_001", "FixRight Repairs", "services", 9000.0, 30),
        ("biz_high_001", "app_high_001", "Aylin Market", "retail", 4000.0, 18),
        ("biz_high_002", "app_high_002", "Aslan Contracting", "construction", 6500.0, 14),
        ("biz_med_002", "app_med_002", "Seasonal Cafe", "food", 7000.0, 26),
        ("biz_low_002", "app_low_002", "Clinic Supply Co", "health", 30000.0, 96),
    ]

    cases = [
        ("case_low_001", "app_low_001", "biz_low_001", 12000.0, "Equipment upgrade", "new"),
        ("case_med_001", "app_med_001", "biz_med_001", 22000.0, "New van purchase", "new"),
        ("case_high_001", "app_high_001", "biz_high_001", 15000.0, "Inventory expansion", "new"),
        ("case_high_002", "app_high_002", "biz_high_002", 25000.0, "Working capital", "new"),
        ("case_med_002", "app_med_002", "biz_med_002", 18000.0, "Renovation", "new"),
        ("case_low_002", "app_low_002", "biz_low_002", 20000.0, "Bulk supplier order", "new"),
    ]

    risk_signals = [
        ("sig_001", "case_low_001", "stable_revenue", "Stable revenue", "18000", "low"),
        ("sig_002", "case_low_001", "long_history", "Business age (months)", "72", "low"),
        ("sig_003", "case_med_001", "medium_credit", "Credit score", "665", "medium"),
        ("sig_004", "case_med_001", "growth_stage", "Business age (months)", "30", "medium"),
        ("sig_005", "case_high_001", "prior_default", "Prior defaults", "1", "high"),
        ("sig_006", "case_high_001", "low_revenue", "Monthly revenue", "4000", "high"),
        ("sig_007", "case_high_002", "prior_defaults", "Prior defaults", "2", "high"),
        ("sig_008", "case_high_002", "young_business", "Business age (months)", "14", "high"),
        ("sig_009", "case_med_002", "seasonal_income", "Seasonality noted", "true", "medium"),
        ("sig_010", "case_med_002", "moderate_revenue", "Monthly revenue", "7000", "medium"),
        ("sig_011", "case_low_002", "excellent_credit", "Credit score", "760", "low"),
        ("sig_012", "case_low_002", "strong_revenue", "Monthly revenue", "30000", "low"),
    ]

    store.ensure_db()
    with store._connect() as conn:  # noqa: SLF001 - demo store internal is ok
        conn.executemany(
            "insert into applicants(id, name, personal_credit_score, prior_defaults) values(?, ?, ?, ?)",
            applicants,
        )
        conn.executemany(
            "insert into businesses(id, applicant_id, name, industry, monthly_revenue, age_months) values(?, ?, ?, ?, ?, ?)",
            businesses,
        )
        conn.executemany(
            "insert into loan_applications(id, applicant_id, business_id, amount, purpose, status, created_at) values(?, ?, ?, ?, ?, ?, ?)",
            [(cid, aid, bid, amt, purpose, status, now_iso()) for (cid, aid, bid, amt, purpose, status) in cases],
        )
        conn.executemany(
            "insert into risk_signals(id, case_id, key, label, value, severity) values(?, ?, ?, ?, ?, ?)",
            risk_signals,
        )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--reset", action="store_true", help="Delete and rebuild the demo DB.")
    parser.add_argument("--sqlite-path", default=None)
    args = parser.parse_args()

    store = Store(sqlite_path=args.sqlite_path or get_settings().sqlite_path)
    if args.reset:
        store.reset()
    else:
        store.ensure_db()
    if store.count_cases() == 0:
        seed(store)


if __name__ == "__main__":
    main()

def f() -> None:
    try:
        raise RuntimeError("boom")
    except Exception:
        pass

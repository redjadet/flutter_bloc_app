#!/usr/bin/env bash
# Validate AIDLC Lite tracker sections and T2 run bundles.
# Findings: path:line:rule-id:message
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tool/check_aidlc_artifacts.sh [--paths PATH...] [--host HOST] [--self-test]
                                      [--discover] [--quiet]

Validate AIDLC artifacts (schema v1). With no args, scans tasks/codex and
tasks/cursor for ## AIDLC sections and full run bundles.

Options:
  --paths PATH...   Files or fixture directories to validate
  --host HOST       Limit scan to tasks/HOST (codex|cursor)
  --self-test       Run tool/fixtures/aidlc_artifacts cases
  --discover        Log AIDLC runs (read-only; never creates). Exit 0 always
                    unless --quiet (then exit 1 when none found).
  --quiet           With --discover: suppress lines; exit 0 if any run exists
  -h, --help        Show help
EOF
}

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

declare -a paths=()
host_filter=""
self_test=0
discover=0
quiet=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --host)
      host_filter="${2:-}"
      if [[ -z "$host_filter" ]]; then
        echo "usage-error|--host requires a value" >&2
        exit 2
      fi
      shift 2
      ;;
    --self-test)
      self_test=1
      shift
      ;;
    --discover)
      discover=1
      shift
      ;;
    --quiet)
      quiet=1
      shift
      ;;
    --paths)
      shift
      while [[ $# -gt 0 && "$1" != --* ]]; do
        paths+=("$1")
        shift
      done
      ;;
    *)
      echo "usage-error|unknown arg: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

export AIDLC_REPO_ROOT="$repo_root"
export AIDLC_HOST_FILTER="$host_filter"
export AIDLC_SELF_TEST="$self_test"
export AIDLC_DISCOVER="$discover"
export AIDLC_QUIET="$quiet"
if ((${#paths[@]})); then
  AIDLC_PATHS="$(printf '%s
' "${paths[@]}")"
else
  AIDLC_PATHS=""
fi
export AIDLC_PATHS
python3 <<'PY'
import os
import re
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    print(
        "check_aidlc_artifacts: PyYAML required. Install with: "
        "python3 -m pip install -r tool/requirements-aidlc.txt",
        file=sys.stderr,
    )
    sys.exit(2)

REPO = Path(os.environ["AIDLC_REPO_ROOT"])
HOST_FILTER = os.environ.get("AIDLC_HOST_FILTER") or ""
SELF_TEST = os.environ.get("AIDLC_SELF_TEST") == "1"
DISCOVER = os.environ.get("AIDLC_DISCOVER") == "1"
QUIET = os.environ.get("AIDLC_QUIET") == "1"
EXTRA_PATHS = [Path(p) for p in os.environ.get("AIDLC_PATHS", "").splitlines() if p.strip()]

KNOWN_EXTENSIONS = [
    "user_story",
    "architecture",
    "testing",
    "security",
    "resilience",
    "ui_platform",
    "operations",
    "documentation",
    "property_based_testing",
]
RUN_STATUS = {"active", "blocked", "superseded", "complete"}
STAGES = {"inception", "construction", "operation"}
TASK_TYPES = {"docs", "feature", "bugfix", "refactor", "operations"}
RISKS = {"low", "medium", "high", "unknown"}
EXT_STATUS = {"selected", "skipped"}
ACTIONS = {
    "approve",
    "continue",
    "invalidate",
    "block",
    "resume",
    "validate",
    "complete",
    "supersede",
    "create",
    "revise",
}
EVENT_REQUIRED = ("id", "gate", "action", "actor", "timestamp", "reason")

findings: list[tuple[str, int, str, str]] = []


def emit(path: Path, line: int, rule: str, message: str) -> None:
    rel = path if path.is_absolute() else REPO / path
    try:
        display = str(rel.resolve().relative_to(REPO))
    except Exception:
        display = str(path)
    findings.append((display, line, rule, message))
    print(f"{display}:{line}:{rule}:{message}")


def extract_yaml_fence(text: str, heading: str = "## AIDLC") -> tuple[str | None, int]:
    lines = text.splitlines()
    start = None
    for i, line in enumerate(lines):
        if line.strip() == heading:
            start = i
            break
    if start is None:
        return None, 0
    fence_start = None
    for i in range(start + 1, len(lines)):
        if lines[i].strip().startswith("```"):
            fence_start = i
            break
        if lines[i].startswith("## "):
            break
    if fence_start is None:
        return None, start + 1
    body: list[str] = []
    for i in range(fence_start + 1, len(lines)):
        if lines[i].strip().startswith("```"):
            return "\n".join(body), fence_start + 2
        body.append(lines[i])
    return None, fence_start + 1


def load_mapping(text: str) -> dict:
    data = yaml.safe_load(text) or {}
    if not isinstance(data, dict):
        return {}
    return data


def parse_event_num(eid: str) -> int | None:
    m = re.fullmatch(r"E(\d+)", str(eid))
    return int(m.group(1)) if m else None


def validate_extensions(path: Path, line: int, data: dict) -> None:
    exts = data.get("extensions")
    if not isinstance(exts, dict):
        emit(path, line, "AIDLC004", "extensions map missing")
        return
    for key in KNOWN_EXTENSIONS:
        entry = exts.get(key)
        if not isinstance(entry, dict):
            emit(path, line, "AIDLC004", f"extension {key} missing object")
            continue
        status = entry.get("status")
        reason = entry.get("reason")
        if status not in EXT_STATUS:
            emit(path, line, "AIDLC004", f"extension {key} missing/invalid status")
        if not isinstance(reason, str) or not reason.strip():
            emit(path, line, "AIDLC004", f"extension {key} missing reason")


def validate_gate_events(path: Path, line: int, events: object, *, require_gates_for_complete: bool) -> None:
    if events is None:
        events = []
    if not isinstance(events, list):
        emit(path, line, "AIDLC014", "gate_events must be a list")
        return
    seen_ids: list[int] = []
    by_gate: dict[str, set[str]] = {}
    has_validate = False
    has_invalidate = False
    has_revise = False
    for ev in events:
        if not isinstance(ev, dict):
            emit(path, line, "AIDLC014", "gate_events entry must be a mapping")
            continue
        missing = [k for k in EVENT_REQUIRED if k not in ev or ev.get(k) in (None, "")]
        if missing:
            emit(path, line, "AIDLC014", f"gate_events missing fields: {','.join(missing)}")
            continue
        action = str(ev.get("action"))
        if action not in ACTIONS:
            emit(path, line, "AIDLC002", f"unknown gate action: {action}")
        num = parse_event_num(str(ev.get("id")))
        if num is None:
            emit(path, line, "AIDLC011", f"bad event id: {ev.get('id')}")
        else:
            if seen_ids and num <= seen_ids[-1]:
                emit(path, line, "AIDLC011", f"non-monotonic event id: {ev.get('id')}")
            if num in seen_ids:
                emit(path, line, "AIDLC011", f"duplicate event id: {ev.get('id')}")
            seen_ids.append(num)
        gate = str(ev.get("gate"))
        by_gate.setdefault(gate, set()).add(action)
        if action == "validate":
            has_validate = True
        if action == "invalidate":
            has_invalidate = True
        if action == "revise":
            has_revise = True

    for gate, actions in by_gate.items():
        if "approve" in actions and "continue" not in actions and require_gates_for_complete:
            emit(path, line, "AIDLC005", f"gate {gate} has approve without continue")
        if "continue" in actions and "approve" not in actions:
            emit(path, line, "AIDLC006", f"gate {gate} has continue without approve")

    if has_revise and not has_invalidate:
        emit(path, line, "AIDLC007", "revise/scope change without invalidate")

    if require_gates_for_complete and not has_validate and not data_has_proof_pointer(events):
        # proof checked by caller via AIDLC008 using data
        pass


def data_has_proof_pointer(events: list) -> bool:
    return any(isinstance(e, dict) and e.get("action") == "validate" for e in events)


def validate_state(path: Path, line: int, data: dict, *, bundle_dir: Path | None = None) -> str | None:
    """Return run_status if parsed."""
    if "aidlc_schema_version" not in data:
        emit(path, line, "AIDLC001", "missing aidlc_schema_version")
    elif data.get("aidlc_schema_version") != 1:
        emit(path, line, "AIDLC001", f"unsupported schema version: {data.get('aidlc_schema_version')}")

    mode = data.get("mode")
    if mode not in {"lite", "full"}:
        emit(path, line, "AIDLC002", f"unknown mode: {mode}")

    run_status = data.get("run_status")
    if run_status not in RUN_STATUS:
        emit(path, line, "AIDLC002", f"unknown run_status: {run_status}")

    stage = data.get("current_stage")
    if stage not in STAGES:
        emit(path, line, "AIDLC002", f"unknown current_stage: {stage}")

    task_type = data.get("task_type")
    if task_type not in TASK_TYPES:
        emit(path, line, "AIDLC002", f"unknown task_type: {task_type}")

    risk = data.get("risk")
    if risk not in RISKS:
        emit(path, line, "AIDLC002", f"unknown risk: {risk}")
    if risk == "unknown" and (stage == "construction" or run_status == "complete"):
        emit(path, line, "AIDLC003", "unknown risk not allowed in construction/complete")

    if data.get("operation") == "not_applicable":
        reason = data.get("operation_reason")
        if not isinstance(reason, str) or not reason.strip():
            emit(path, line, "AIDLC009", "operation not_applicable missing operation_reason")
    if stage == "operation" and data.get("operation") == "not_applicable":
        emit(path, line, "AIDLC009", "current_stage operation conflicts with not_applicable")
    if stage == "operation" and data.get("operation") not in (None, "not_applicable"):
        # require explicit authority recorded as continue on an operation gate
        events = data.get("gate_events") or []
        op_ok = False
        if isinstance(events, list):
            for ev in events:
                if isinstance(ev, dict) and ev.get("gate") == "operation_authority" and ev.get("action") == "continue":
                    op_ok = True
        if not op_ok:
            emit(path, line, "AIDLC009", "operation stage without operation_authority continue")

    if run_status == "blocked":
        for field in ("blocker", "blocker_owner", "unblock_condition"):
            val = data.get(field)
            if not isinstance(val, str) or not val.strip():
                emit(path, line, "AIDLC013", f"blocked missing {field}")

    validate_extensions(path, line, data)

    events = data.get("gate_events")
    require_complete_gates = run_status == "complete" or stage in {"construction", "operation"}
    # For construction start, allow empty until gates recorded; fixtures target explicit cases.
    if isinstance(events, list) and events:
        validate_gate_events(path, line, events, require_gates_for_complete=True)
    elif require_complete_gates and run_status == "complete":
        emit(path, line, "AIDLC008", "complete without gate_events/proof")

    if run_status == "complete":
        proof = data.get("proof_pointer")
        has_validate = False
        if isinstance(events, list):
            has_validate = any(isinstance(e, dict) and e.get("action") == "validate" for e in events)
        if not has_validate and not (isinstance(proof, str) and proof.strip()):
            emit(path, line, "AIDLC008", "complete without validate event or proof_pointer")

    if mode == "full":
        run_id = data.get("run_id")
        if not isinstance(run_id, str) or not run_id.strip():
            emit(path, line, "AIDLC010", "full mode missing run_id")
        elif bundle_dir is None:
            # tracker pointer only; bundle validated separately when discovered
            pass
        else:
            for name in ("aidlc-state.md", "questions.md", "audit.md", "artifacts.md"):
                if not (bundle_dir / name).is_file():
                    emit(path, line, "AIDLC010", f"full mode missing {name}")

    if data.get("material_change") is True:
        events = data.get("gate_events") or []
        has_inv = isinstance(events, list) and any(
            isinstance(e, dict) and e.get("action") == "invalidate" for e in events
        )
        if not has_inv:
            emit(path, line, "AIDLC007", "material_change without invalidate")

    return run_status if isinstance(run_status, str) else None


def validate_todo(path: Path) -> str | None:
    text = path.read_text(encoding="utf-8")
    if "## AIDLC" not in text:
        return None
    raw, line = extract_yaml_fence(text)
    if raw is None:
        emit(path, line or 1, "AIDLC001", "AIDLC section missing YAML fence")
        return None
    try:
        data = load_mapping(raw)
    except yaml.YAMLError as exc:
        emit(path, line, "AIDLC002", f"YAML parse error: {exc}")
        return None
    bundle = None
    if data.get("mode") == "full" and isinstance(data.get("run_id"), str):
        host = path.parent.name
        bundle = REPO / "tasks" / host / "aidlc" / data["run_id"]
        if not bundle.is_dir():
            # fixture layouts may nest differently
            sibling = path.parent / "aidlc" / data["run_id"]
            if sibling.is_dir():
                bundle = sibling
    return validate_state(path, line, data, bundle_dir=bundle)


def validate_bundle(bundle: Path) -> str | None:
    state_path = bundle / "aidlc-state.md"
    if not state_path.is_file():
        emit(bundle, 1, "AIDLC010", "full mode missing aidlc-state.md")
        return None
    text = state_path.read_text(encoding="utf-8")
    # allow full-file YAML or fenced
    raw = None
    line = 1
    if "```" in text:
        raw, line = extract_yaml_fence(text, heading="## AIDLC")
        if raw is None:
            # try first fence
            m = re.search(r"```(?:yaml)?\n(.*?)```", text, re.S)
            if m:
                raw = m.group(1)
                line = text[: m.start()].count("\n") + 1
    if raw is None:
        raw = text
    try:
        data = load_mapping(raw)
    except yaml.YAMLError as exc:
        emit(state_path, line, "AIDLC002", f"YAML parse error: {exc}")
        return None
    if "mode" not in data:
        data["mode"] = "full"
    if "run_id" not in data:
        data["run_id"] = bundle.name
    status = validate_state(state_path, line, data, bundle_dir=bundle)
    for name in ("questions.md", "audit.md", "artifacts.md"):
        if not (bundle / name).is_file():
            emit(bundle / name, 1, "AIDLC010", f"full mode missing {name}")
    validate_bundle_companions(bundle, status)
    return status


def collect_targets() -> list[Path]:
    targets: list[Path] = []
    if EXTRA_PATHS:
        for p in EXTRA_PATHS:
            path = p if p.is_absolute() else REPO / p
            targets.append(path)
        return targets
    hosts = [HOST_FILTER] if HOST_FILTER else ["codex", "cursor"]
    for host in hosts:
        todo = REPO / "tasks" / host / "todo.md"
        if todo.is_file():
            targets.append(todo)
        aidlc_root = REPO / "tasks" / host / "aidlc"
        if aidlc_root.is_dir():
            for child in sorted(aidlc_root.iterdir()):
                if child.is_dir():
                    targets.append(child)
    return targets


def _parse_run_fields(data: dict) -> tuple[str, str, str]:
    status = data.get("run_status")
    mode = data.get("mode")
    stage = data.get("current_stage")
    return (
        status if isinstance(status, str) else "unknown",
        mode if isinstance(mode, str) else "unknown",
        stage if isinstance(stage, str) else "unknown",
    )


def iter_runs_for_host(host: str, root: Path | None = None) -> list[tuple[Path, str, str, str]]:
    """Return (path, run_status, mode, current_stage) for each AIDLC run."""
    base = root or (REPO / "tasks" / host)
    found: list[tuple[Path, str, str, str]] = []
    todo = base / "todo.md"
    if todo.is_file():
        text = todo.read_text(encoding="utf-8")
        if "## AIDLC" in text:
            raw, _ = extract_yaml_fence(text)
            if raw:
                try:
                    data = load_mapping(raw)
                    status, mode, stage = _parse_run_fields(data)
                    found.append((todo, status, mode, stage))
                except yaml.YAMLError:
                    found.append((todo, "unparseable", "unknown", "unknown"))
    aidlc_root = base / "aidlc"
    if aidlc_root.is_dir():
        for child in sorted(aidlc_root.iterdir()):
            state = child / "aidlc-state.md"
            if not state.is_file():
                continue
            text = state.read_text(encoding="utf-8")
            m = re.search(r"```(?:yaml)?\n(.*?)```", text, re.S)
            raw = m.group(1) if m else text
            try:
                data = load_mapping(raw)
                status, mode, stage = _parse_run_fields(data)
                found.append((state, status, mode, stage))
            except yaml.YAMLError:
                found.append((state, "unparseable", "unknown", "unknown"))
    return found


def _load_run_meta(path: Path) -> dict:
    try:
        text = path.read_text(encoding="utf-8")
    except OSError:
        return {}
    raw = None
    if path.name == "todo.md":
        raw, _ = extract_yaml_fence(text)
    else:
        if "```" in text:
            m = re.search(r"```(?:yaml)?\n(.*?)```", text, re.S)
            raw = m.group(1) if m else None
        if raw is None:
            raw = text
    if not raw:
        return {}
    try:
        data = load_mapping(raw)
    except yaml.YAMLError:
        return {}
    return data if isinstance(data, dict) else {}


def _run_identity(path: Path, mode: str, data: dict | None = None) -> str:
    data = data or _load_run_meta(path)
    run_id = data.get("run_id")
    if mode == "full" and isinstance(run_id, str) and run_id.strip():
        return f"full:{run_id.strip()}"
    if path.name == "aidlc-state.md":
        return f"full:{path.parent.name}"
    if path.name == "todo.md":
        if data.get("mode") == "full" and isinstance(data.get("run_id"), str):
            return f"full:{data['run_id'].strip()}"
        return "lite:tracker"
    return f"path:{path}"


def active_statuses_for_host(host: str, root: Path | None = None) -> list[tuple[Path, str]]:
    """Unique active runs per host. Full tracker+bundle share one identity."""
    by_id: dict[str, Path] = {}
    for path, status, mode, _stage in iter_runs_for_host(host, root=root):
        if status != "active":
            continue
        data = _load_run_meta(path)
        identity = _run_identity(path, mode if mode != "unknown" else str(data.get("mode") or ""), data)
        existing = by_id.get(identity)
        # Prefer aidlc-state.md as the canonical active path for full runs.
        if existing is None or path.name == "aidlc-state.md":
            by_id[identity] = path
    return [(path, "active") for path in by_id.values()]


def _monotonic_ids(nums: list[int], path: Path, rule: str, label: str) -> None:
    seen: set[int] = set()
    last = 0
    for n in nums:
        if n in seen:
            emit(path, 1, rule, f"duplicate {label} id: {n:03d}")
        if last and n <= last:
            emit(path, 1, rule, f"non-monotonic {label} id: {n:03d}")
        seen.add(n)
        last = n


def validate_questions_md(path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    ids = [int(m) for m in re.findall(r"\bQ(\d{3})\b", text)]
    content_lines = [
        ln.strip()
        for ln in text.splitlines()
        if ln.strip() and not ln.strip().startswith("#")
    ]
    if content_lines and not ids:
        emit(path, 1, "AIDLC010", "questions.md has content without Q### ids")
    _monotonic_ids(ids, path, "AIDLC011", "question")


def validate_audit_md(path: Path, *, require_events: bool) -> None:
    text = path.read_text(encoding="utf-8")
    # Prefer fenced YAML event list when present.
    m = re.search(r"```(?:yaml)?\n(.*?)```", text, re.S)
    if m:
        try:
            data = yaml.safe_load(m.group(1)) or []
        except yaml.YAMLError as exc:
            emit(path, 1, "AIDLC002", f"audit YAML parse error: {exc}")
            return
        if not isinstance(data, list):
            emit(path, 1, "AIDLC014", "audit.md YAML must be a list of events")
            return
        validate_gate_events(path, 1, data, require_gates_for_complete=False)
        if require_events and not data:
            emit(path, 1, "AIDLC010", "complete full run requires audit events")
        return
    ids = [int(x) for x in re.findall(r"\bE(\d{3})\b", text)]
    content_lines = [
        ln.strip()
        for ln in text.splitlines()
        if ln.strip() and not ln.strip().startswith("#")
    ]
    if content_lines and not ids:
        emit(path, 1, "AIDLC010", "audit.md has content without E### ids")
    _monotonic_ids(ids, path, "AIDLC011", "audit")
    if require_events and not ids:
        emit(path, 1, "AIDLC010", "complete full run requires audit events")


def validate_artifacts_md(path: Path, *, require_pointers: bool) -> None:
    text = path.read_text(encoding="utf-8")
    pointers = [
        ln.strip().lstrip("-").strip()
        for ln in text.splitlines()
        if ln.strip() and not ln.strip().startswith("#")
    ]
    pointers = [p for p in pointers if "/" in p or p.endswith(".md") or p.endswith(".sh")]
    content_lines = [
        ln.strip()
        for ln in text.splitlines()
        if ln.strip() and not ln.strip().startswith("#")
    ]
    if content_lines and not pointers:
        emit(path, 1, "AIDLC010", "artifacts.md has content without path pointers")
    if require_pointers and not pointers:
        emit(path, 1, "AIDLC008", "complete full run missing artifact pointers")


def validate_bundle_companions(bundle: Path, run_status: str | None) -> None:
    require = run_status == "complete"
    q = bundle / "questions.md"
    a = bundle / "audit.md"
    art = bundle / "artifacts.md"
    if q.is_file():
        validate_questions_md(q)
    if a.is_file():
        validate_audit_md(a, require_events=require)
    if art.is_file():
        validate_artifacts_md(art, require_pointers=require)


def run_discover() -> int:
    hosts = [HOST_FILTER] if HOST_FILTER else ["codex", "cursor"]
    count = 0
    for host in hosts:
        for path, status, mode, stage in iter_runs_for_host(host):
            count += 1
            if QUIET:
                continue
            rel = path
            try:
                rel = path.relative_to(REPO)
            except ValueError:
                pass
            print(
                f"aidlc|discover|host={host}|path={rel}|mode={mode}"
                f"|run_status={status}|stage={stage}"
            )
    if count == 0 and not QUIET:
        print("aidlc|discover|none")
    if QUIET:
        return 0 if count > 0 else 1
    return 0


def check_active_rule(scan_roots: list[Path]) -> None:
    # Group by host directory name under tasks/
    by_host: dict[str, list[tuple[Path, str]]] = {}
    for root in scan_roots:
        # fixture host roots look like .../invalid_second_active_run/cursor
        if root.name in {"codex", "cursor"}:
            host = root.name
            for item in active_statuses_for_host(host, root=root):
                by_host.setdefault(host, []).append(item)
        elif (root / "todo.md").exists() or (root / "aidlc").exists():
            host = root.name
            for item in active_statuses_for_host(host, root=root):
                by_host.setdefault(host, []).append(item)
    for host, items in by_host.items():
        if len(items) > 1:
            path = items[1][0]
            emit(path, 1, "AIDLC012", f"more than one active run for host {host}")


def run_self_test() -> int:
    fixtures = REPO / "tool" / "fixtures" / "aidlc_artifacts"
    if not fixtures.is_dir():
        print("self-test missing fixtures dir", file=sys.stderr)
        return 1
    expected = {
        "valid_lite": None,
        "valid_full_complete": None,
        "invalid_missing_risk": "AIDLC004",  # actually missing risk field -> AIDLC002
        "invalid_unknown_risk_construction": "AIDLC003",
        "invalid_approval_without_continue": "AIDLC005",
        "invalid_scope_change_without_invalidation": "AIDLC007",
        "invalid_complete_without_proof": "AIDLC008",
        "invalid_operation_without_authority": "AIDLC009",
        "invalid_second_active_run": "AIDLC012",
        "invalid_gate_event_missing_fields": "AIDLC014",
        "invalid_blocked_missing_blocker_fields": "AIDLC013",
    }
    # Fix mapping for missing risk
    expected["invalid_missing_risk"] = "AIDLC002"
    failed = 0
    global findings
    for name, rule in expected.items():
        case_dir = fixtures / name
        findings = []
        # clear prints by capturing differently - emit still prints; use subprocess style
        # Instead re-run validation collecting findings without prior prints: temporarily silence
        print(f"self-test|{name}|begin")
        findings.clear()
        # monkeypatch emit to still record
        targets = []
        todo = case_dir / "todo.md"
        if todo.is_file():
            validate_todo(todo)
        # nested host layout for second active
        for host in ("codex", "cursor"):
            host_dir = case_dir / host
            if host_dir.is_dir():
                t = host_dir / "todo.md"
                if t.is_file():
                    validate_todo(t)
                aidlc = host_dir / "aidlc"
                if aidlc.is_dir():
                    for child in aidlc.iterdir():
                        if child.is_dir():
                            validate_bundle(child)
                check_active_rule([host_dir])
        aidlc = case_dir / "aidlc"
        if aidlc.is_dir():
            for child in aidlc.iterdir():
                if child.is_dir():
                    validate_bundle(child)
        if (case_dir / "todo.md").is_file() and (case_dir / "aidlc").is_dir():
            # full complete fixture
            pass
        check_active_rule([case_dir])
        rules_hit = {f[2] for f in findings}
        if rule is None:
            if findings:
                print(f"self-test|{name}|FAIL|expected pass got {sorted(rules_hit)}", file=sys.stderr)
                failed = 1
            else:
                print(f"self-test|{name}|pass")
        else:
            if rule not in rules_hit:
                print(f"self-test|{name}|FAIL|expected {rule} got {sorted(rules_hit)}", file=sys.stderr)
                failed = 1
            else:
                print(f"self-test|{name}|pass|{rule}")
    return failed


def main() -> int:
    global findings
    if SELF_TEST:
        # self-test manages findings per case; avoid double-print pollution by
        # running validations with a quiet collector.
        return run_self_test_quiet()
    if DISCOVER:
        return run_discover()

    findings = []
    targets = collect_targets()
    host_roots: list[Path] = []
    for target in targets:
        if target.is_file() and target.name == "todo.md":
            validate_todo(target)
            host_roots.append(target.parent)
        elif target.is_dir():
            if (target / "aidlc-state.md").is_file():
                validate_bundle(target)
            elif (target / "todo.md").is_file() or (target / "aidlc").is_dir():
                todo = target / "todo.md"
                if todo.is_file():
                    validate_todo(todo)
                aidlc = target / "aidlc"
                if aidlc.is_dir():
                    for child in sorted(aidlc.iterdir()):
                        if child.is_dir():
                            validate_bundle(child)
                host_roots.append(target)
            else:
                # fixture root with nested host
                for host in ("codex", "cursor"):
                    host_dir = target / host
                    if host_dir.is_dir():
                        host_roots.append(host_dir)
                        t = host_dir / "todo.md"
                        if t.is_file():
                            validate_todo(t)
                        aidlc = host_dir / "aidlc"
                        if aidlc.is_dir():
                            for child in sorted(aidlc.iterdir()):
                                if child.is_dir():
                                    validate_bundle(child)
    if host_roots:
        check_active_rule(host_roots)
    elif not HOST_FILTER:
        for host in ("codex", "cursor"):
            check_active_rule([REPO / "tasks" / host])

    if findings:
        return 1
    print("check_aidlc_artifacts|ok")
    return 0


def run_self_test_quiet() -> int:
    """Self-test without relying on printed emit during unexpected passes."""
    fixtures = REPO / "tool" / "fixtures" / "aidlc_artifacts"
    expected = {
        "valid_lite": None,
        "valid_full_complete": None,
        "valid_full_active": None,
        "invalid_missing_risk": "AIDLC002",
        "invalid_unknown_risk_construction": "AIDLC003",
        "invalid_approval_without_continue": "AIDLC005",
        "invalid_scope_change_without_invalidation": "AIDLC007",
        "invalid_complete_without_proof": "AIDLC008",
        "invalid_operation_without_authority": "AIDLC009",
        "invalid_second_active_run": "AIDLC012",
        "invalid_gate_event_missing_fields": "AIDLC014",
        "invalid_blocked_missing_blocker_fields": "AIDLC013",
        "invalid_audit_prose": "AIDLC010",
    }
    failed = 0
    global findings
    real_emit = emit

    def silent_emit(path, line, rule, message):
        findings.append((str(path), line, rule, message))

    # patch
    import types
    g = globals()
    # replace emit used by validators
    def emit_patch(path, line, rule, message):
        findings.append((str(path), line, rule, message))

    # Assign into module-level used by functions - they close over emit by name lookup global
    g["emit"] = emit_patch

    for name, rule in expected.items():
        case_dir = fixtures / name
        findings = []
        if not case_dir.is_dir():
            print(f"self-test|{name}|FAIL|missing fixture", file=sys.stderr)
            failed = 1
            continue
        todo = case_dir / "todo.md"
        if todo.is_file():
            validate_todo(todo)
        aidlc = case_dir / "aidlc"
        if aidlc.is_dir():
            for child in sorted(aidlc.iterdir()):
                if child.is_dir():
                    validate_bundle(child)
        for host in ("codex", "cursor"):
            host_dir = case_dir / host
            if not host_dir.is_dir():
                continue
            t = host_dir / "todo.md"
            if t.is_file():
                validate_todo(t)
            ha = host_dir / "aidlc"
            if ha.is_dir():
                for child in sorted(ha.iterdir()):
                    if child.is_dir():
                        validate_bundle(child)
            check_active_rule([host_dir])
        check_active_rule([case_dir])
        rules_hit = {f[2] for f in findings}
        if rule is None:
            if findings:
                print(f"self-test|{name}|FAIL|expected pass got {sorted(rules_hit)}", file=sys.stderr)
                for f in findings:
                    print(f"  {f}", file=sys.stderr)
                failed = 1
            else:
                print(f"self-test|{name}|pass")
        else:
            if rule not in rules_hit:
                print(f"self-test|{name}|FAIL|expected {rule} got {sorted(rules_hit)}", file=sys.stderr)
                failed = 1
            else:
                print(f"self-test|{name}|pass|{rule}")
    g["emit"] = real_emit
    return failed


if __name__ == "__main__":
    sys.exit(main())
PY

# Todo list feature — current contract

Offline-first todo demo under `apps/mobile/lib/features/todo_list/`.

## Behavior

- Local-first CRUD via Hive; remote sync via Firebase Realtime Database when
  configured.
- Pending queue + background sync through shared offline-first stack.
- Manual order / filters live in presentation + domain helpers — see feature
  code, not this doc, for field-level detail.

## Owners

| Concern | Doc / path |
| --- | --- |
| Adopt offline-first | [`offline_first/adoption_guide.md`](../offline_first/adoption_guide.md) |
| Don’t overwrite newer local | [`offline_first/dont_overwrite_guide.md`](../offline_first/dont_overwrite_guide.md) |
| RTDB security rules | [`todo_list_firebase_security_rules.md`](../todo_list_firebase_security_rules.md) |
| Feature layout | [`architecture/feature_structure_contract.md`](../architecture/feature_structure_contract.md) |

## Validation

```bash
./bin/router_feature_validate --paths apps/mobile/lib/features/todo_list
bash tool/check_offline_first_remote_merge.sh
```

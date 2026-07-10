# Maintainability follow-up G — ai_decision typed Maps

**Date:** 2026-07-10  
**Seam:** Rank 5 / ai_decision P5

## Change

Replace wire-shaped `Map` bags on domain models with typed value objects
(`AiDecisionApplicant`, `Business`, `Loan`, `RiskSignal`, `ActionRecord`,
`Proof` + nested rule/threshold/similar-case). DTO mappers own JSON parsing;
`inputSnapshot` / `extras` remain maps only where UI is open-ended.

## Proof

```bash
flutter test test/features/ai_decision_demo/
```

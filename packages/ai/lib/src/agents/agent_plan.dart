/// Planned agent step before execution.
class AgentPlanStep {
  const AgentPlanStep({required this.description, this.toolName});

  final String description;
  final String? toolName;
}

class AgentPlan {
  const AgentPlan({required this.steps});

  final List<AgentPlanStep> steps;
}

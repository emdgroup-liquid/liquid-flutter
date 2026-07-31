enum LdAgentTaskStatus {
  pending,
  inProgress,
  done,
  failed,
}

/// A single step in the agent's current plan (task panel), not transcript history.
class LdAgentTask {
  final String id;
  final String label;
  final LdAgentTaskStatus status;

  const LdAgentTask({
    required this.id,
    required this.label,
    this.status = LdAgentTaskStatus.pending,
  });
}

enum WorkspaceMemberStatus {
  pending,
  accepted;

  static WorkspaceMemberStatus fromString(String status) {
    switch (status) {
      case 'PENDING':
        return WorkspaceMemberStatus.pending;
      case 'ACCEPTED':
        return WorkspaceMemberStatus.accepted;
      default:
        throw Exception('Invalid Member Status');
    }
  }

  static String toStringWorkspaceMemberStatus(
      WorkspaceMemberStatus permission) {
    return permission.toString().split('.').last.toUpperCase();
  }
}

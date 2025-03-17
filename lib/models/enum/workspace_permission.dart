enum WorkspacePermission {
  owner,
  editor,
  viewer;

  static WorkspacePermission fromString(String permission) {
    switch (permission) {
      case 'OWNER':
        return WorkspacePermission.owner;
      case 'EDITOR':
        return WorkspacePermission.editor;
      case 'VIEWER':
        return WorkspacePermission.viewer;
      default:
        throw Exception('Invalid WorkspacePermission');
    }
  }

  static String toStringWorkspacePermission(WorkspacePermission permission) {
    return permission.toString().split('.').last.toUpperCase();
  }
}

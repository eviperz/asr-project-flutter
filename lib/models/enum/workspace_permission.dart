enum WorkspacePermission {
  owner,
  editor,
  viewer,
}

void checkPermission(WorkspacePermission permission) {
  switch (permission) {
    case WorkspacePermission.owner:
      print("User has full control.");
      break;
    case WorkspacePermission.editor:
      print("User can edit content.");
      break;
    case WorkspacePermission.viewer:
      print("User has read-only access.");
      break;
  }
}

String permissionToString(WorkspacePermission permission) {
  return permission
      .toString()
      .split('.')
      .last
      .toUpperCase(); // Returns "owner", "admin", etc.
}

WorkspacePermission stringToPermission(String value) {
  return WorkspacePermission.values.firstWhere(
    (e) => e.toString().split('.').last == value.toLowerCase(),
  );
}

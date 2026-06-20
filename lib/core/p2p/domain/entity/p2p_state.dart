class P2pPeer {
  final String id;
  final String firstName;
  final String? lastName;
  final String? avatarUrl;

  const P2pPeer({
    required this.id,
    required this.firstName,
    this.lastName,
    this.avatarUrl,
  });

  String get displayName => lastName != null && lastName!.isNotEmpty
      ? '$firstName $lastName'
      : firstName;

  String get initials =>
      firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';
}

sealed class P2pState {
  const P2pState();
}

class P2pIdle extends P2pState {
  const P2pIdle();
}

class P2pSearching extends P2pState {
  const P2pSearching();
}

class P2pMatched extends P2pState {
  final String sessionId;
  final P2pRole role;
  final P2pPeer peer;

  const P2pMatched({
    required this.sessionId,
    required this.role,
    required this.peer,
  });
}

class P2pConnecting extends P2pState {
  final P2pRole role;
  final P2pPeer peer;

  const P2pConnecting({required this.role, required this.peer});
}

class P2pConnected extends P2pState {
  final P2pPeer peer;

  const P2pConnected({required this.peer});
}

class P2pEnded extends P2pState {
  final P2pEndReason reason;

  const P2pEnded(this.reason);
}

class P2pError extends P2pState {
  final String message;

  const P2pError(this.message);
}

enum P2pRole { caller, callee }

enum P2pEndReason {
  leave,
  partnerLeft,
  partnerDisconnected,
  cancelled,
  replaced,
  error,
}

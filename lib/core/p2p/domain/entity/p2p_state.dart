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

  const P2pMatched({required this.sessionId, required this.role});
}

class P2pConnecting extends P2pState {
  final P2pRole role;

  const P2pConnecting({required this.role});
}

class P2pConnected extends P2pState {
  const P2pConnected();
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

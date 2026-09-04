enum QuraniFailureKind {
  validation,
  notFound,
  conflict,
  storage,
  security,
  externalAction,
  unexpected,
}

final class QuraniFailure {
  const QuraniFailure.validation({this.context, this.cause})
    : kind = QuraniFailureKind.validation;

  const QuraniFailure.notFound({this.context, this.cause})
    : kind = QuraniFailureKind.notFound;

  const QuraniFailure.conflict({this.context, this.cause})
    : kind = QuraniFailureKind.conflict;

  const QuraniFailure.storage({this.context, this.cause})
    : kind = QuraniFailureKind.storage;

  const QuraniFailure.security({this.context, this.cause})
    : kind = QuraniFailureKind.security;

  const QuraniFailure.externalAction({this.context, this.cause})
    : kind = QuraniFailureKind.externalAction;

  const QuraniFailure.unexpected({this.context, this.cause})
    : kind = QuraniFailureKind.unexpected;

  final QuraniFailureKind kind;

  /// Optional technical context for diagnostics or higher-layer mapping.
  ///
  /// This is not localized UI copy and must not be treated as a user-facing
  /// error message by itself.
  final String? context;

  /// Optional original cause retained for diagnostics/mapping.
  ///
  /// Higher layers should not expose [cause] directly to the user.
  final Object? cause;
}

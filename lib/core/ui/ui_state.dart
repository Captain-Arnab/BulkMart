sealed class UiState<T> {
  const UiState();
}

class UiLoading<T> extends UiState<T> {
  const UiLoading();
}

class UiSuccess<T> extends UiState<T> {
  const UiSuccess(this.data);
  final T data;
}

class UiError<T> extends UiState<T> {
  const UiError(this.message);
  final String message;
}

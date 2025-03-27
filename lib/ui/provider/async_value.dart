class AsyncValue<T> {
  final T? _data;
  final Object? _error;
  final bool _isLoading;

  AsyncValue.loading()
      : _isLoading = true,
        _data = null,
        _error = null;

  AsyncValue.success(T data)
      : _isLoading = false,
        _data = data,
        _error = null;

  AsyncValue.error(Object error)
      : _isLoading = false,
        _data = null,
        _error = error;

  bool get isLoading => _isLoading;
  T? get data => _data;
  Object? get error => _error;

  void when({
    required Function() loading,
    required Function(T data) success,
    required Function(Object error) error,
  }) {
    if (_isLoading) {
      loading();
    } else if (_error != null) {
    } else {
      success(_data as T);
    }
  }
}

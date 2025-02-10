class SnackbarMessage {
  String message;
  String state;

  SnackbarMessage({
    this.message = '',
    this.state = '',
  });

  bool get isEmpty => message.isEmpty && state.isEmpty;
  bool get isNotEmpty => !isEmpty;

  void clear() {
    message = '';
    state = '';
  }
}
class SnackbarMessage {
  String title;
  String message;
  String state;

  SnackbarMessage({
    this.title = '',
    this.message = '',
    this.state = '',
  });

  bool get isEmpty => message.isEmpty && state.isEmpty;
  bool get isNotEmpty => !isEmpty;

  void clear() {
    title = '';
    message = '';
    state = '';
  }
}
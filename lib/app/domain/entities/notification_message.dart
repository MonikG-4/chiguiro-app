class NotificationMessage {
  final String title;
  final String body;
  final Map<String, dynamic>? data;

  NotificationMessage({
    required this.title,
    required this.body,
    this.data,
  });

  @override
  String toString() {
    return 'NotificationMessage(title: $title, body: $body, data: $data)';
  }
}
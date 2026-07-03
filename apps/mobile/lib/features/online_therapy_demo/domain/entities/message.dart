enum MessageDeliveryStatus {
  queued,
  sent,
  failed,
}

class Message {
  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.body,
    required this.sentAt,
    required this.deliveryStatus,
    required this.retryCount,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String body;
  final DateTime sentAt;
  final MessageDeliveryStatus deliveryStatus;
  final int retryCount;
}

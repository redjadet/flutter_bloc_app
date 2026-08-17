enum MessageDeliveryStatus {
  queued,
  sent,
  failed,
}

class const Message({
  required final String id,
  required final String conversationId,
  required final String senderId,
  required final String body,
  required final DateTime sentAt,
  required final MessageDeliveryStatus deliveryStatus,
  required final int retryCount,
});

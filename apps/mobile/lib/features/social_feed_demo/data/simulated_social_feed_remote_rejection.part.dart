part of 'simulated_social_feed_remote_data_source.dart';

class SocialFeedRemoteRejection implements Exception {
  SocialFeedRemoteRejection({required this.canonical});
  final SocialFeedPost canonical;
}

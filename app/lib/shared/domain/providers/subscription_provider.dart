import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SubscriptionPlan { free, premium }

final subscriptionProvider = StateProvider<SubscriptionPlan>((ref) {
  return SubscriptionPlan.free;
});

final isPremiumProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionProvider) == SubscriptionPlan.premium;
});

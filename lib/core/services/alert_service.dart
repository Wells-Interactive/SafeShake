class AlertService {
  Future<void> triggerAlert({required bool testMode}) async {
    if (testMode) {
      // Simulate the complete alert flow. Never send a real alert.
      return;
    }

    // TODO: route through the platform-appropriate delivery mechanism.
    // Android and iOS capabilities/policies differ for automated SMS.
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth;

  BiometricService({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  /// Check if hardware supports biometrics or device credentials
  Future<bool> isDeviceSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (e) {
      debugPrint('Biometric isDeviceSupported error: $e');
      return false;
    }
  }

  /// Check if biometric hardware can be checked
  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (e) {
      debugPrint('Biometric canCheckBiometrics error: $e');
      return false;
    }
  }

  /// Check if biometric authentication can actually be performed on this device
  Future<bool> canAuthenticate() async {
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return supported || canCheck;
    } catch (e) {
      debugPrint('Biometric canAuthenticate error: $e');
      return false;
    }
  }

  /// Get list of available enrolled biometric types (fingerprint, face, etc.)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Biometric getAvailableBiometrics error: $e');
      return [];
    }
  }

  /// Authenticate using biometrics (Android BiometricPrompt / Windows Hello)
  Future<bool> authenticate({
    required String localizedReason,
    bool biometricOnly = false,
  }) async {
    try {
      final canAuth = await canAuthenticate();
      if (!canAuth) {
        debugPrint('BiometricService: Device cannot authenticate with biometrics');
        return false;
      }

      return await _auth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: biometricOnly,
      );
    } on PlatformException catch (e) {
      debugPrint('Biometric PlatformException: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Biometric unexpected error: $e');
      return false;
    }
  }

  /// Cancel any pending authentication prompt
  Future<bool> cancelAuthentication() async {
    try {
      return await _auth.stopAuthentication();
    } catch (e) {
      debugPrint('Biometric stopAuthentication error: $e');
      return false;
    }
  }
}

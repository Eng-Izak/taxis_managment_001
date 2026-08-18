import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:nsd/nsd.dart' as nsd;

class DiscoveredServerInfo {
  final String name;
  final String host;
  final int port;
  final List<String> addresses;

  const DiscoveredServerInfo({
    required this.name,
    required this.host,
    required this.port,
    required this.addresses,
  });

  String? get primaryIp => addresses.isNotEmpty ? addresses.first : (host.isNotEmpty ? host : null);

  @override
  String toString() => 'DiscoveredServerInfo(name: $name, host: $host, port: $port, addresses: $addresses)';
}

class ServiceDiscoveryManager {
  static const String serviceType = '_sync._tcp';
  static const int defaultPort = 8080;
  static const String defaultServiceName = 'SadatTaxiSync';

  nsd.Registration? _registration;
  nsd.Discovery? _discovery;

  final _discoveredServersController = StreamController<List<DiscoveredServerInfo>>.broadcast();
  final Map<String, DiscoveredServerInfo> _discoveredMap = {};

  Stream<List<DiscoveredServerInfo>> get discoveredServersStream => _discoveredServersController.stream;
  List<DiscoveredServerInfo> get currentDiscoveredServers => _discoveredMap.values.toList();

  bool get isRegistered => _registration != null;
  bool get isDiscovering => _discovery != null;

  /// Registers the mDNS service advertisement (primarily used on Windows / Desktop Server)
  Future<bool> registerServer({
    String name = defaultServiceName,
    int port = defaultPort,
  }) async {
    if (_registration != null) {
      debugPrint('[ServiceDiscoveryManager] Already registered as $name');
      return true;
    }

    try {
      debugPrint('[ServiceDiscoveryManager] Registering mDNS service $serviceType on port $port...');
      final service = nsd.Service(
        name: name,
        type: serviceType,
        port: port,
      );

      _registration = await nsd.register(service);
      debugPrint('[ServiceDiscoveryManager] Successfully registered mDNS service ${service.name}');
      return true;
    } catch (e, stack) {
      debugPrint('[ServiceDiscoveryManager] Registration failed: $e\n$stack');
      return false;
    }
  }

  /// Unregisters the mDNS service advertisement
  Future<void> unregisterServer() async {
    if (_registration == null) return;
    try {
      debugPrint('[ServiceDiscoveryManager] Unregistering mDNS service...');
      await nsd.unregister(_registration!);
      _registration = null;
      debugPrint('[ServiceDiscoveryManager] Unregistered mDNS service successfully');
    } catch (e) {
      debugPrint('[ServiceDiscoveryManager] Unregister warning: $e');
      _registration = null;
    }
  }

  /// Starts discovery of Windows servers on the local network (used by Android Client)
  Future<bool> startDiscovery() async {
    if (_discovery != null) {
      debugPrint('[ServiceDiscoveryManager] Discovery already active');
      return true;
    }

    try {
      _discoveredMap.clear();
      _discoveredServersController.add([]);

      debugPrint('[ServiceDiscoveryManager] Starting mDNS discovery for $serviceType...');
      _discovery = await nsd.startDiscovery(
        serviceType,
        ipLookupType: nsd.IpLookupType.any,
      );

      _discovery!.addServiceListener((service, status) {
        final serviceName = service.name ?? 'Unknown';
        final port = service.port ?? defaultPort;
        final host = service.host ?? '';
        final addresses = service.addresses?.map((a) => a.address).toList() ?? [];

        if (status == nsd.ServiceStatus.found) {
          debugPrint('[ServiceDiscoveryManager] Discovered service: $serviceName at $host:$port ($addresses)');
          final info = DiscoveredServerInfo(
            name: serviceName,
            host: host,
            port: port,
            addresses: addresses,
          );
          _discoveredMap[serviceName] = info;
          _discoveredServersController.add(_discoveredMap.values.toList());
        } else if (status == nsd.ServiceStatus.lost) {
          debugPrint('[ServiceDiscoveryManager] Lost service: $serviceName');
          _discoveredMap.remove(serviceName);
          _discoveredServersController.add(_discoveredMap.values.toList());
        }
      });

      return true;
    } catch (e, stack) {
      debugPrint('[ServiceDiscoveryManager] Discovery error: $e\n$stack');
      return false;
    }
  }

  /// Stops ongoing mDNS service discovery
  Future<void> stopDiscovery() async {
    if (_discovery == null) return;
    try {
      debugPrint('[ServiceDiscoveryManager] Stopping mDNS discovery...');
      await nsd.stopDiscovery(_discovery!);
      _discovery = null;
    } catch (e) {
      debugPrint('[ServiceDiscoveryManager] Stop discovery warning: $e');
      _discovery = null;
    }
  }

  /// Disposes both advertising and discovery resources
  Future<void> dispose() async {
    await unregisterServer();
    await stopDiscovery();
    await _discoveredServersController.close();
  }
}

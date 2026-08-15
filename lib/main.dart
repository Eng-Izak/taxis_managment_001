import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/finance_app.dart';
import 'app/app_bloc_observer.dart';
import 'core/dependency_injection/di.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Bloc Observer for state monitoring
  Bloc.observer = AppBlocObserver();

  // Setup Dependency Injection (GetIt)
  await setupDependencyInjection();

  runApp(const FinanceApp());
}

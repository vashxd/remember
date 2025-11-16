import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/themes/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'presentation/providers/medicamento_provider.dart';
import 'presentation/pages/home/home_page.dart';

void main() {
  runApp(const LembreteMedicamentosApp());
}

class LembreteMedicamentosApp extends StatelessWidget {
  const LembreteMedicamentosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MedicamentoProvider(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        home: const HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

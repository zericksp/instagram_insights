// lib/main.dart (VERSÃO CORRIGIDA)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ✅ IMPORTANTE: AuthProvider deve estar AQUI
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        
        // Se tiver outros providers, adicione aqui:
        // ChangeNotifierProvider(create: (context) => OutroProvider()),
      ],
      child: MaterialApp(
        title: 'Instagram Insights',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        // ✅ IMPORTANTE: SplashScreen deve estar DENTRO do MultiProvider
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
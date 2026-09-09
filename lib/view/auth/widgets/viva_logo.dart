
// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart'; 
/// Logo do VIVA exibida nas telas de autenticação.
/// [compact] = true → versão menor para a tela de cadastro (sem tagline).
class VivaLogo extends StatelessWidget {
  final bool compact;
 
  const VivaLogo({super.key, this.compact = false});
 

  @override
  Widget build(BuildContext context) {
    final logoSize = compact ? 96.0 : 140.0;
 
    return Image.asset(
      'assets/images/viva_logo.png',
      width: logoSize,
      height: logoSize,
      fit: BoxFit.contain,
      // Fallback caso o asset ainda não esteja registrado
      errorBuilder: (_, __, ___) => _FallbackLogo(compact: compact),
    );
  }
}
 
/// Exibido somente se o asset PNG não for encontrado.
class _FallbackLogo extends StatelessWidget {
  final bool compact;
  const _FallbackLogo({required this.compact});
 
  @override
  Widget build(BuildContext context) {
    final size = compact ? 72.0 : 100.0;
    return SizedBox(
      width: size,
      height: size,
      child: const Center(
        child: Text('VIVA',
            style: TextStyle(
              color: Color(0xFF22C55E),
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 6,
            )),
      ),
    );
  }
}
 
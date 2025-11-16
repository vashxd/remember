/// Campo de texto reutilizável
///
/// Componente atômico para inputs de texto com validação.
/// Tamanho grande e espaçamento adequado para acessibilidade.
///
/// Autor: Sistema
/// Data: 2025-11-14
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CampoTexto extends StatelessWidget {
  final String rotulo;
  final String? dica;
  final TextEditingController? controlador;
  final String? Function(String?)? validador;
  final TextInputType? tipoTeclado;
  final List<TextInputFormatter>? formatadores;
  final bool obscureText;
  final bool habilitado;
  final int? maxLinhas;
  final int? minLinhas;
  final IconData? iconePrefixo;
  final IconData? iconeSufixo;
  final VoidCallback? aoClicarSufixo;
  final void Function(String)? aoMudar;
  final String? textoInicial;
  final int? maxCaracteres;

  const CampoTexto({
    super.key,
    required this.rotulo,
    this.dica,
    this.controlador,
    this.validador,
    this.tipoTeclado,
    this.formatadores,
    this.obscureText = false,
    this.habilitado = true,
    this.maxLinhas = 1,
    this.minLinhas,
    this.iconePrefixo,
    this.iconeSufixo,
    this.aoClicarSufixo,
    this.aoMudar,
    this.textoInicial,
    this.maxCaracteres,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controlador,
      initialValue: controlador == null ? textoInicial : null,
      decoration: InputDecoration(
        labelText: rotulo,
        hintText: dica,
        prefixIcon: iconePrefixo != null
            ? Icon(iconePrefixo, size: 28)
            : null,
        suffixIcon: iconeSufixo != null
            ? IconButton(
                icon: Icon(iconeSufixo, size: 28),
                onPressed: aoClicarSufixo,
              )
            : null,
        counterText: maxCaracteres != null ? '' : null,
      ),
      validator: validador,
      keyboardType: tipoTeclado,
      inputFormatters: formatadores,
      obscureText: obscureText,
      enabled: habilitado,
      maxLines: maxLinhas,
      minLines: minLinhas,
      onChanged: aoMudar,
      maxLength: maxCaracteres,
      style: const TextStyle(
        fontSize: 18,
        height: 1.5,
      ),
    );
  }
}

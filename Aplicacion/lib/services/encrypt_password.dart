import 'dart:convert';
import 'package:crypto/crypto.dart';

String encryptPassword(String password) {
  final bytes = utf8.encode(password); // Convierte la contraseña a bytes
  final digest = sha256.convert(bytes); // Realiza el hash SHA256
  return digest.toString(); // Convierte el resultado a una cadena hexadecimal
}
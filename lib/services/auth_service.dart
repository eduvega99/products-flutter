import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class AuthService extends ChangeNotifier {
  
  final String _baseUrl = 'identitytoolkit.googleapis.com';
  final String _firebaseToken = 'AIzaSyA1s65P-rN3E4SFeFwTDVzKB2JhnfltAbQ';

  final storage = new FlutterSecureStorage();

  final errors = {
    'EMAIL_NOT_FOUND'  : 'No se ha encontrado ninguna cuenta con este correo. Por favor, revise sus credenciales',
    'INVALID_PASSWORD' : 'La contraseña no es correcta, Por favor, revise sus credenciales',
    'USER_DISABLED'    : 'Esta cuenta ha sido desabilitada por un administrador. Póngase en contacto con el servicio',
    'EMAIL_EXISTS'     : 'Ya existe una cuenta con esta dirección de correo. Intente iniciar sesión.',
    'TOO_MANY_ATTEMPTS_TRY_LATER' : 'Hemos bloqueado todas las solicitudes de este dispositivo debido a una actividad inusual. Vuelve a intentarlo más tarde.'
  };



  // Only return if there is any error
  Future<String?> createUser(String email, String password) async {
    
    final Map<String, dynamic> authData = {
      'email':    email,
      'password': password,
      'returnSecureToken' : true
    };

    final uri = Uri.https(_baseUrl, '/v1/accounts:signUp', {
      'key': _firebaseToken
    });

    final response = await http.post(uri, body: json.encode(authData));
    final Map<String, dynamic> decodedResponse = jsonDecode(response.body);

    if (!decodedResponse.containsKey('idToken')) {
      String errorCode = decodedResponse['error']['message'];
      return errors[errorCode] ?? 'Error desconocido';
    }
    
    // TODO: Guardar token en lugar seguro
    await storage.write(key: 'token', value: decodedResponse['idToken']);
    return null;
  }

  Future<String?> login(String? email, String? password) async {
    final Map<String, dynamic> authData = {
      'email'    : email,
      'password' : password,
      'returnSecureToken' : true 
    };

    final uri = Uri.https(_baseUrl, '/v1/accounts:signInWithPassword', {
      'key': _firebaseToken
    });

    final response = await http.post(uri, body: json.encode(authData));
    final Map<String, dynamic> decodedResponse = jsonDecode(response.body);

    if (!decodedResponse.containsKey('idToken')) {
      String errorCode = decodedResponse['error']['message'];
      return errors[errorCode] ?? 'Error desconocido';
    }
    
    await storage.write(key: 'token', value: decodedResponse['idToken']);
    return null;
  }

  Future logout() async {
    await storage.delete(key: 'token');
    return;
  }

  Future<String> readToken() async {
    return await storage.read(key: 'token') ?? '';
  }


}
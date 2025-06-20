//Lógica pra llamar a los endpoints de login/registro
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // La URL base de tu backend. Si lo ejecutas localmente, podría ser esta.
  // ¡Asegúrate de que sea la URL correcta de tu servidor en Render!
  final String _baseUrl = "https://fastapi-idiomas.onrender.com";

  Future<String> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/token');

    // El backend espera los datos en formato de formulario, no JSON.
    // Esto es por el `OAuth2PasswordRequestForm` que se usa en el endpoint /token.
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        'username': email, // El formulario espera 'username', no 'email'
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String token = responseData['access_token'];
      return token;
    } else {
      // Si el login falla, el backend devuelve un error.
      // Aquí lanzamos una excepción para que la UI pueda manejarla.
      final Map<String, dynamic> errorData = json.decode(response.body);
      throw Exception(errorData['detail'] ?? 'Error al iniciar sesión');
    }
  }

  Future<void> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    // El backend espera una petición POST a /users
    final url = Uri.parse('$_baseUrl/users');

    // Analizando el backend (routers/user.py), este endpoint espera un JSON.
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'nombre': nombre,
        'email': email,
        // El backend espera un campo llamado 'hashed_password', aunque en realidad
        // es él quien se encarga de hashear. Le enviamos el password en texto plano.
        'hashed_password': password,
      }),
    );

    if (response.statusCode == 200) {
      // El usuario se creó con éxito. No necesitamos devolver nada.
      return;
    } else {
      // Si el registro falla (ej. email ya existe), lanzamos una excepción.
      final Map<String, dynamic> errorData = json.decode(response.body);
      throw Exception(errorData['detail'] ?? 'Error al registrar el usuario');
    }
  }
}

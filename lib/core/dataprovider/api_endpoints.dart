class ApiEndpoints {
  static const String _devUrl = 'http://10.0.2.2:5000';
  // static const String _devUrl = 'http://192.168.1.4:5000';

  // static const String _prodUrl = '';
  static const String baseUrl = _devUrl;

  static const String loginApi = '$baseUrl/api/v1/auth/login';
  static const String registerApi = '$baseUrl/api/v1/auth/register';
}

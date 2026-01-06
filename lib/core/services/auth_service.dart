import 'package:roamly_app/core/dataprovider/api_endpoints.dart';
import 'package:roamly_app/core/dataprovider/api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService.instance;

  //login api call
  Future<Map<String, dynamic>> login({required String body}) async {
    final response = await _apiService.httpPost(
      url: ApiEndpoints.loginApi,
      body: body,
      isWithoutToken: true,
    );
    return response;
  }

  // Register API call
  Future<Map<String, dynamic>> register({required String body}) async {
    final response = await _apiService.httpPost(
      url: ApiEndpoints.registerApi,
      body: body,
      isWithoutToken: true,
    );

    return response;
  }
}

import '../../../core/api/api_client.dart';
import '../../../core/models/user_profile.dart';

class ProfileApi {
  final ApiClient _client;
  ProfileApi(this._client);

  Future<UserProfile> getProfile() async {
    final data = await _client.get('/profile');
    return UserProfile.fromJson(data as Map<String, dynamic>);
  }

  Future<UserProfile> updateProfile(Map<String, dynamic> updates) async {
    final data = await _client.patch('/profile', body: updates);
    return UserProfile.fromJson(data as Map<String, dynamic>);
  }
}

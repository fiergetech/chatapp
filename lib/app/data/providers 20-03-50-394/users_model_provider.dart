import 'package:get/get.dart';

import '../models/users_model.dart';

class UsersModelProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.defaultDecoder = (map) {
      if (map is Map<String, dynamic>) return UsersModel.fromJson(map);
      if (map is List)
        return map.map((item) => UsersModel.fromJson(item)).toList();
    };
    httpClient.baseUrl = 'YOUR-API-URL';
  }

  Future<UsersModel?> getUsersModel(int id) async {
    final response = await get('usersmodel/$id');
    return response.body;
  }

  Future<Response<UsersModel>> postUsersModel(UsersModel usersmodel) async =>
      await post('usersmodel', usersmodel);
  Future<Response> deleteUsersModel(int id) async =>
      await delete('usersmodel/$id');
}

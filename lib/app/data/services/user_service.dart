import 'package:basesource/app/data/models/user_models.dart';
import 'package:dio/dio.dart';

class UserService {
  Dio dio = Dio();

  Future<List<UserModel>> getInfo(int page) async {
    Response strRes = await dio
        .get('https://agrichapp.herokuapp.com/members?_page=$page&_limit=10');

    if (strRes.statusCode == 200) {
      page++;
      List<dynamic> result = strRes.data;
      List<UserModel> resultJson = result.map((json) {
        return UserModel.fromJson(json);
      }).toList();
      return resultJson;
    } else {
      throw Exception('Failed');
    }
  }
}

import 'package:basesource/app/data/models/user_models.dart';
import 'package:basesource/app/data/services/user_service.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController
    with
        GetSingleTickerProviderStateMixin,
        StateMixin<List<UserModel>>,
        ScrollMixin {
  int page = 1;

  @override
  void onInit() {
    getList();
    super.onInit();
  }

  Future<void> getList() async {
    try {
      page = 1;
      final res = await UserService().getInfo(page);
      change(res, status: RxStatus.success());
    } catch (e) {
      change(state, status: RxStatus.error(e.toString()));
    }
  }

  @override
  Future<void> onEndScroll() async {
    page++;
    change(state!, status: RxStatus.loadingMore());
    final res = await UserService().getInfo(page);
    change([...state!, ...res], status: RxStatus.success());
  }

  @override
  Future<void> onTopScroll() async {
  }
}

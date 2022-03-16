import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../widgets/list_user.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(children: [
        const Expanded(
          child: MemberList(),
        ),
        controller.obx(
          (state) {
            if (controller.status.isLoadingMore) {
              return const CircularProgressIndicator();
            }
            return const SizedBox();
          },
          onLoading: const SizedBox(),
        )
      ]),
    ));
  }
}

class MemberList extends GetView<ProfileController> {
  const MemberList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.getList,
      child: controller.obx(
        (state) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: controller.scroll,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          child: Wrap(
            children: state!.map((e) => ListUser(member: e)).toList(),
          ),
        ),
        onLoading: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

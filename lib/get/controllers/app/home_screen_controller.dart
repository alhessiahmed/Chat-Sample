import 'package:chat_sample/firebase/fb_firestore_users_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/state_manager.dart';

class HomeScreenController extends GetxController with WidgetsBindingObserver {
  final numOfOnlineUsers = 0.obs;
  final isLoggingOut = false.obs;
  final counterMessagingRequests = 0.obs;

  @override
  void onInit() {
    WidgetsBinding.instance.addObserver(this);
    FbFireStoreUsersController().updateMyOnlineStatus(true);
    super.onInit();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await FbFireStoreUsersController().updateMyOnlineStatus(true);
    } else {
      await FbFireStoreUsersController().updateMyOnlineStatus(false);
    }
    super.didChangeAppLifecycleState(state);
  }
}

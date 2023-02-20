import 'package:chat_sample/core/routes/routes_manager.dart';
import 'package:chat_sample/core/utils/my_data.dart';
import 'package:chat_sample/core/utils/time_date_send.dart';
import 'package:chat_sample/core/widgets/loading_widget.dart';
import 'package:chat_sample/core/widgets/no_data_widget.dart';
import 'package:chat_sample/firebase/fb_firestore_chats_controller.dart';
import 'package:chat_sample/firebase/fb_firestore_users_controller.dart';
import 'package:chat_sample/models/chat.dart';
import 'package:chat_sample/models/chat_user.dart';
import 'package:chat_sample/screens/app/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:chat_sample/core/constants/colors_manager.dart';
import 'package:chat_sample/get/controllers/app/home_screen_controller.dart';

class MessageRequestsScreen extends GetView<HomeScreenController> {
  const MessageRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messaging Requests'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 30.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.forum_rounded),
                Padding(
                  padding: EdgeInsets.all(15.sp),
                  child: Text(
                    'Messaging requests from other Type Users',
                    style: TextStyle(
                      fontSize: 25.sp,
                    ),
                  ),
                ),
                Transform(
                    alignment: AlignmentDirectional.center,
                    transform: Matrix4.rotationY(3.14),
                    child: const Icon(Icons.forum_rounded)),
              ],
            ),
            SizedBox(height: 30.h),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Chat>>(
                  stream: FbFireStoreChatsController()
                      .fetchChats(ChatStatus.waiting.name),
                  builder: (context, snapshot) {
                    return snapshot.hasData && snapshot.data!.docs.isNotEmpty
                        ? ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              final chat = snapshot.data!.docs[index].data();
                              controller.counterMessagingRequests.value =
                                  snapshot.data!.docs.length;
                              if (controller.counterMessagingRequests.value !=
                                  0) {
                                if (chat.createdBy != myID) {
                                  return Column(
                                    children: [
                                      FutureBuilder<ChatUser>(
                                          future: FbFireStoreUsersController()
                                              .readPeerData(chat.getPeerId())
                                              .first
                                              .then<ChatUser>((query) =>
                                                  query.docs.first.data()),
                                          builder: (context, snapshot) {
                                            return snapshot.hasData
                                                ? ListTile(
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    minVerticalPadding: 0,
                                                    horizontalTitleGap: 40.w,
                                                    title: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          snapshot.data!.name,
                                                          style: TextStyle(
                                                            fontSize: 25.sp,
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              timeSend(chat
                                                                  .createdAt),
                                                              style: TextStyle(
                                                                color: ColorsManager
                                                                    .hintColor,
                                                                fontSize: 18.sp,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width: 10.w),
                                                            Icon(
                                                              Icons
                                                                  .schedule_rounded,
                                                              size: 22.r,
                                                              color:
                                                                  ColorsManager
                                                                      .hintColor,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    leading: CircleAvatar(
                                                      backgroundColor:
                                                          ColorsManager.white,
                                                      backgroundImage: snapshot
                                                                  .data!
                                                                  .image !=
                                                              null
                                                          ? NetworkImage(
                                                              snapshot
                                                                  .data!.image!)
                                                          : const AssetImage(
                                                                  'assets/images/avatar.png')
                                                              as ImageProvider,
                                                      radius: 40.r,
                                                    ),
                                                  )
                                                : Container();
                                          }),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () async {
                                              await _performChatStatus(
                                                  ChatStatus.accepted.name,
                                                  chat);
                                            },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    ColorsManager.success,
                                                fixedSize:
                                                    Size(Get.width / 4, 60.h)),
                                            child: const Text('Accept'),
                                          ),
                                          SizedBox(width: 20.w),
                                          OutlinedButton(
                                            onPressed: () async {
                                              await _performChatStatus(
                                                  ChatStatus.rejected.name,
                                                  chat);
                                              await _performChatStatus(
                                                  ChatStatus.accepted.name,
                                                  chat);
                                            },
                                            child: const Text('Reject'),
                                          ),
                                        ],
                                      ),
                                      const Divider(
                                        color: ColorsManager.dividerColor,
                                        thickness: 2,
                                      ),
                                    ],
                                  );
                                } else {
                                  controller.counterMessagingRequests.value--;
                                  return Container();
                                }
                              } else {
                                return const NoDataWidget(
                                  message: 'No Messages Requests yet!!',
                                );
                              }
                            },
                          )
                        : snapshot.connectionState == ConnectionState.waiting
                            ? const LoadingWidget()
                            : const NoDataWidget(
                                message: 'No Messages Requests yet!!',
                              );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _performChatStatus(String status, Chat chat) async {
    if (status == ChatStatus.accepted.name) {
      bool success = await FbFireStoreChatsController()
          .updateChatStatus(ChatStatus.accepted.name, chat.id);
      if (success) {
        Get.to(() => ChatScreen(chat: chat));
        return true;
      }
      return false;
    } else {
      return await FbFireStoreChatsController().deleteChat(chat.id);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../data/models/user_models.dart';
import 'tag_widget.dart';

class ListUser extends StatelessWidget {
  const ListUser({required this.member, Key? key}) : super(key: key);
  final UserModel member;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          member.isPremium == false
              ? const Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: TagWidget('本人書類確認済み'),
                  ),
                )
              : const SizedBox(height: 24),
          Row(
            children: [
              CircleAvatar(
                radius: 40.0,
                backgroundImage: NetworkImage(member.avatar),
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 5,
                          child: member.name.text
                              .maxLines(1)
                              .overflow(TextOverflow.ellipsis)
                              .size(14)
                              .black
                              .bold
                              .make(),
                        ),
                        Flexible(
                          child: '${member.age}'.text.size(10).gray400.make(),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: member.job.text.maxLines(1).size(10).make(),
                        ),
                        Flexible(
                          child: member.position.text
                              .maxLines(1)
                              .overflow(TextOverflow.ellipsis)
                              .size(10)
                              .gray400
                              .make(),
                        ),
                      ],
                    ),
                    member.company.text.maxLines(1).size(10).gray400.make(),
                    member.address.text
                        .maxLines(1)
                        .overflow(TextOverflow.ellipsis)
                        .size(10)
                        .make(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 0.3,
                  color: Colors.red,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: member.bio.text
                  .maxLines(2)
                  .overflow(TextOverflow.ellipsis)
                  .size(13)
                  .bold
                  .make()
                  .box
                  .alignCenterLeft
                  .px8
                  .make()),
        ],
      ),
    );
  }
}

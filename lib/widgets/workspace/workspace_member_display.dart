import 'package:asr_project/models/user.dart';
import 'package:asr_project/widgets/profile_image.dart';
import 'package:flutter/material.dart';

class WorkspaceMemberDisplay extends StatelessWidget {
  const WorkspaceMemberDisplay({
    super.key,
    required this.memberWithoutOwner,
    required this.owner,
  });

  final List<User> memberWithoutOwner;
  final User owner;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(
        width: 105,
        child: Stack(
          children: [
            if (memberWithoutOwner.length > 1)
              Positioned(
                left: 60,
                child: Container(
                  padding: EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(24.0)),
                  child: ProfileImage(
                    profile: memberWithoutOwner[1].profile,
                  ),
                ),
              ),
            if (memberWithoutOwner.isNotEmpty)
              Positioned(
                left: 30,
                child: Container(
                  padding: EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(24.0)),
                  child: ProfileImage(
                    profile: memberWithoutOwner[0].profile,
                  ),
                ),
              ),
            Container(
              padding: EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(24.0)),
              child: ProfileImage(
                profile: owner.profile,
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        width: 8.0,
      ),
      if (memberWithoutOwner.length > 2)
        Text("+ ${memberWithoutOwner.length - 2}")
    ]);
  }
}

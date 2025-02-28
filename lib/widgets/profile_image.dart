import 'package:flutter/material.dart';

class ProfileImage extends StatelessWidget {
  final Image? profile;
  final double? size;

  const ProfileImage({
    super.key,
    this.profile,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size ?? 35,
      height: size ?? 35,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: profile ??
          Image.asset(
            "assets/images/default-profile.png",
            fit: BoxFit.cover,
          ),
    );
  }
}

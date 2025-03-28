import 'package:flutter/material.dart';

class ProfileImage extends StatelessWidget {
  final Image? profile;
  final double? size;
  final bool? isLoading;

  const ProfileImage({
    super.key,
    this.profile,
    this.size,
    this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: (size ?? 35) / 2,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      backgroundImage: profile?.image ??
          const AssetImage("assets/images/default-profile.png"),
      child: isLoading == null || isLoading == false
          ? null
          : const CircularProgressIndicator.adaptive(),
    );
  }
}

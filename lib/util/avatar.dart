import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nood_food/common/loader.dart';

class Avatar extends StatefulWidget {
  final String? avatarUrl;
  final double radius;
  const Avatar({super.key, this.avatarUrl, required this.radius});

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: widget.radius,
      child: widget.avatarUrl == null
          ? const Icon(Icons.person_outlined, size: 40)
          : CachedNetworkImage(
              imageUrl: widget.avatarUrl!,
              placeholder: (context, val) => const Loader(),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.person_outlined),
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
            ),
    );
  }
}

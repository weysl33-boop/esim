import 'package:flutter/material.dart';
import 'package:esim/core/utils/dimensions.dart';
import 'package:esim/core/utils/my_color.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.radius = 12,
    this.backgroundColor = MyColor.colorWhite,
    this.borderColor,
    this.borderWidth = 1,
    this.showBorder = false,
    this.gradient,

    // Shadow
    this.enableShadow = true,
    this.shadow,
  });

  final Widget child;
  final VoidCallback? onTap;

  final double? width;
  final double? height;

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  final double radius;
  final double borderWidth;

  final Color backgroundColor;
  final Color? borderColor;

  final bool showBorder;

  final Gradient? gradient;

  /// Shadow control
  final bool enableShadow;
  final BoxShadow? shadow;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        color: MyColor.transparentColor,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            width: width,
            height: height,
            padding: padding ?? const EdgeInsets.all(Dimensions.space16),
            decoration: BoxDecoration(
              color: gradient == null ? backgroundColor : null,
              gradient: gradient,
              borderRadius: BorderRadius.circular(radius),
              border: showBorder && borderColor != null
                  ? Border.all(
                      color: borderColor!,
                      width: borderWidth,
                    )
                  : null,
              boxShadow: enableShadow
                  ? [
                      shadow ??
                          BoxShadow(
                            color: MyColor.secondaryColor950.withValues(alpha: .08),
                            blurRadius: 4,
                            spreadRadius: 4,
                            offset: const Offset(0, 6),
                          ),
                    ]
                  : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

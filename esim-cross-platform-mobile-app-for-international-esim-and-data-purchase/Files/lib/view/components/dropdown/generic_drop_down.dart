import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:esim/core/utils/dimensions.dart';
import 'package:esim/core/utils/style.dart';
import '../../../../../core/utils/my_color.dart';

class GenericDropdown<T> extends StatefulWidget {
  final String? title;
  final T? selectedValue;
  final List<T>? list;
  final ValueChanged<T?>? onChanged;
  final double paddingLeft, paddingTop, paddingBottom;
  final double titleSpace;
  final double paddingRight;
  final double radius;
  final bool isShowTitle;
  final Color? bgColor;
  final Color? dropdownColor;
  final TextStyle? titleStyle;
  final Color? iconEnabledColor;
  final String Function(T) displayItem;

  const GenericDropdown({
    super.key,
    this.isShowTitle = true,
    this.titleSpace = 10,
    this.title,
    this.paddingLeft = 10,
    this.paddingRight = 10,
    this.paddingTop = 5,
    this.paddingBottom = 5,
    this.radius = Dimensions.defaultRadius,
    this.titleStyle,
    this.dropdownColor,
    this.selectedValue,
    this.list,
    this.bgColor,
    this.iconEnabledColor,
    this.onChanged,
    required this.displayItem,
  });

  @override
  State<GenericDropdown<T>> createState() => _GenericDropdownState<T>();
}

class _GenericDropdownState<T> extends State<GenericDropdown<T>> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isShowTitle) Text((widget.title ?? "").tr, style: widget.titleStyle ?? regularDefault.copyWith(color: MyColor.getLabelTextColor())),
        if (widget.isShowTitle) SizedBox(height: widget.titleSpace),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(color: widget.bgColor ?? MyColor.getScreenBgSecondaryColor(), borderRadius: BorderRadius.all(Radius.circular(widget.radius))),
          child: Padding(
            padding: EdgeInsets.only(
              left: widget.paddingLeft,
              right: widget.paddingRight,
              bottom: widget.paddingBottom,
              top: widget.paddingTop,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                isExpanded: true,
                menuMaxHeight: 300,
                hint: Text(
                  (widget.selectedValue != null ? widget.displayItem(widget.selectedValue as T) : '').tr,
                  style: regularDefault.copyWith(color: MyColor.getLabelTextColor()),
                ),
                // value: widget.selectedValue ??
                //     (widget.list?.isNotEmpty == true
                //         ? widget.list!.first
                //         : null),
                value: (widget.list?.contains(widget.selectedValue) ?? false) ? widget.selectedValue : null,
                dropdownColor: widget.dropdownColor ?? MyColor.getScreenBgSecondaryColor(),
                iconEnabledColor: widget.iconEnabledColor ?? MyColor.primaryColor,
                onChanged: (value) {
                  setState(() {
                    isExpanded = false;
                  });
                  widget.onChanged?.call(value);
                },
                items: widget.list?.map(
                  (value) {
                    return DropdownMenuItem<T>(
                      value: value,
                      child: Text(
                        widget.displayItem(value).tr,
                        style: regularDefault.copyWith(color: MyColor.getLabelTextColor()),
                      ),
                    );
                  },
                ).toList(),
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

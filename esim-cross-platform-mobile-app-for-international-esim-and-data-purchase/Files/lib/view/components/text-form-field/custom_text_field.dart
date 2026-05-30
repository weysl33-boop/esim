import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:esim/core/utils/dimensions.dart';
import 'package:esim/core/utils/my_color.dart';
import 'package:esim/core/utils/my_strings.dart';
import 'package:esim/core/utils/style.dart';
import 'package:esim/view/components/text/label_text_with_instructions.dart';

class CustomTextField extends StatefulWidget {
  final String? instructions;
  final String? labelText;
  final String? hintText;
  final Function? onChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final FormFieldValidator? validator;
  final TextInputType? textInputType;
  final bool isEnable;
  final bool isPassword;
  final TextStyle? hintStyle;
  final bool isShowSuffixIcon;
  final bool isIcon;
  final bool isSearchField;
  final VoidCallback? onSuffixTap;
  final bool isSearch;
  final bool isCountryPicker;
  final TextInputAction inputAction;
  final bool needOutlineBorder;
  final bool readOnly;
  final bool needRequiredSign;
  final int maxLines;
  final bool animatedLabel;
  final Color? fillColor;
  final Color? searchIconColor;
  final bool isRequired;
  final List<TextInputFormatter>? inputFormatters;
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    this.instructions,
    this.hintStyle,
    this.labelText,
    this.readOnly = false,
    this.fillColor = MyColor.colorWhite,
    this.searchIconColor = MyColor.colorWhite,
    required this.onChanged,
    this.hintText,
    this.controller,
    this.focusNode,
    this.nextFocus,
    this.validator,
    this.textInputType,
    this.isEnable = true,
    this.isPassword = false,
    this.isSearchField = false,
    this.isShowSuffixIcon = false,
    this.isIcon = false,
    this.onSuffixTap,
    this.isSearch = false,
    this.isCountryPicker = false,
    this.inputAction = TextInputAction.next,
    this.needOutlineBorder = false,
    this.needRequiredSign = false,
    this.maxLines = 1,
    this.animatedLabel = false,
    this.isRequired = false,
    this.inputFormatters,
    this.onTap,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return widget.needOutlineBorder
        ? widget.animatedLabel
            ? _buildAnimatedLabelField()
            : _buildStyledTextField()
        : _buildUnderlineTextField();
  }

  Widget _buildStyledTextField() {
    return widget.isSearchField
        ? Container(
            decoration: BoxDecoration(
              color: widget.fillColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: MyColor.colorBlack.withValues(alpha: .05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: MyStrings.whereAreWeTraveling,
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                  size: 22,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label Section
              if (widget.labelText != null) ...[
                LabelTextInstruction(
                  text: widget.labelText.toString().tr,
                  isRequired: widget.isRequired,
                  instructions: widget.instructions,
                ),
                const SizedBox(height: Dimensions.textToTextSpace),
              ],
              // The Styled TextField Container
              TextFormField(
                maxLines: widget.maxLines,
                readOnly: widget.readOnly,
                style: regularDefault.copyWith(
                  color: MyColor.getPrimaryTextColor(),
                  fontSize: 15,
                ),
                cursorColor: MyColor.getPrimaryColor(),
                controller: widget.controller,
                autofocus: false,
                textInputAction: widget.inputAction,
                enabled: widget.isEnable,
                focusNode: widget.focusNode,
                validator: widget.validator,
                keyboardType: widget.textInputType,
                obscureText: widget.isPassword ? obscureText : false,
                inputFormatters: widget.inputFormatters,
                decoration: InputDecoration(
                  errorStyle: regularDefault.copyWith(
                    color: MyColor.colorRed,
                    fontSize: 12,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  hintText: widget.hintText?.tr ?? '',
                  hintStyle: regularDefault.copyWith(
                    color: MyColor.getTextFieldHintColor().withValues(alpha: 0.5),
                    fontSize: 15,
                  ),
                  fillColor: widget.fillColor ?? MyColor.textFieldFillColor.withValues(alpha: .4),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: MyColor.getPrimaryColor().withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.redAccent,
                      width: 1,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.redAccent,
                      width: 1.5,
                    ),
                  ),
                  suffixIcon: widget.isShowSuffixIcon
                      ? widget.isPassword
                          ? IconButton(
                              icon: Icon(
                                obscureText ? Icons.visibility_off : Icons.visibility,
                                color: const Color(0xFF99A4AE),
                                size: 20,
                              ),
                              onPressed: _toggle,
                            )
                          : widget.isIcon
                              ? IconButton(
                                  onPressed: widget.onSuffixTap,
                                  icon: Icon(
                                    widget.isSearch
                                        ? Icons.search_outlined
                                        : widget.isCountryPicker
                                            ? Icons.arrow_drop_down_outlined
                                            : Icons.camera_alt_outlined,
                                    size: 22,
                                    color: MyColor.getPrimaryColor(),
                                  ),
                                )
                              : null
                      : null,
                ),
                onFieldSubmitted: (text) => widget.nextFocus != null ? FocusScope.of(context).requestFocus(widget.nextFocus) : null,
                onChanged: (text) => widget.onChanged!(text),
                onTap: widget.onTap,
              ),
            ],
          );
  }

  Widget _buildAnimatedLabelField() {
    return TextFormField(
      maxLines: widget.maxLines,
      readOnly: widget.readOnly,
      style: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
      cursorColor: MyColor.getPrimaryTextColor(),
      controller: widget.controller,
      autofocus: false,
      textInputAction: widget.inputAction,
      enabled: widget.isEnable,
      focusNode: widget.focusNode,
      validator: widget.validator,
      keyboardType: widget.textInputType,
      obscureText: widget.isPassword ? obscureText : false,
      decoration: InputDecoration(
        errorStyle: regularLarge.copyWith(color: MyColor.colorRed),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelText: widget.labelText?.tr ?? '',
        labelStyle: regularDefault.copyWith(
          color: MyColor.getLabelTextColor().withValues(alpha: 0.6),
          fontSize: 14,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: widget.fillColor ?? const Color(0xFFE8EBED),
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(width: 1, color: MyColor.colorRed),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 1.5, color: MyColor.getPrimaryColor()),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
        suffixIcon: widget.isShowSuffixIcon
            ? widget.isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: MyColor.getTextFieldHintColor(),
                      size: 22,
                    ),
                    onPressed: _toggle,
                  )
                : widget.isIcon
                    ? IconButton(
                        onPressed: widget.onSuffixTap,
                        icon: Icon(
                          widget.isSearch
                              ? Icons.search_outlined
                              : widget.isCountryPicker
                                  ? Icons.arrow_drop_down_outlined
                                  : Icons.camera_alt_outlined,
                          size: 22,
                          color: MyColor.getPrimaryColor(),
                        ),
                      )
                    : null
            : null,
      ),
      inputFormatters: widget.inputFormatters,
      onFieldSubmitted: (text) => widget.nextFocus != null ? FocusScope.of(context).requestFocus(widget.nextFocus) : null,
      onChanged: (text) => widget.onChanged!(text),
      onTap: widget.onTap,
    );
  }

  Widget _buildUnderlineTextField() {
    return Column(
      children: [
        widget.isSearchField
            ? Container(
                decoration: BoxDecoration(
                  color: widget.fillColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: MyColor.colorBlack.withValues(alpha: .05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  onTap: widget.onTap,
                  readOnly: widget.readOnly,
                  decoration: InputDecoration(
                    hintText: MyStrings.whereAreWeTraveling,
                    hintStyle: widget.hintStyle ??
                        TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                        ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: widget.searchIconColor ?? Colors.grey[400],
                      size: 22,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                ),
              )
            : TextFormField(
                maxLines: widget.maxLines,
                readOnly: widget.readOnly,
                style: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
                cursorColor: MyColor.getTextFieldHintColor(),
                controller: widget.controller,
                autofocus: false,
                textInputAction: widget.inputAction,
                enabled: widget.isEnable,
                focusNode: widget.focusNode,
                validator: widget.validator,
                keyboardType: widget.textInputType,
                obscureText: widget.isPassword ? obscureText : false,
                inputFormatters: widget.inputFormatters,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(top: 5, left: 0, right: 0, bottom: 5),
                  labelText: widget.labelText?.tr,
                  labelStyle: regularDefault.copyWith(color: MyColor.getLabelTextColor()),
                  fillColor: MyColor.transparentColor,
                  filled: true,
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(width: 0.8, color: MyColor.getTextFieldDisableBorder()),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(width: 0.8, color: MyColor.getTextFieldEnableBorder()),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(width: 0.8, color: MyColor.getTextFieldDisableBorder()),
                  ),
                  suffixIcon: widget.isShowSuffixIcon
                      ? widget.isPassword
                          ? IconButton(
                              icon: Icon(
                                obscureText ? Icons.visibility_off : Icons.visibility,
                                color: MyColor.getTextFieldHintColor(),
                                size: 20,
                              ),
                              onPressed: _toggle,
                            )
                          : widget.isIcon
                              ? IconButton(
                                  onPressed: widget.onSuffixTap,
                                  icon: Icon(
                                    widget.isSearch
                                        ? Icons.search_outlined
                                        : widget.isCountryPicker
                                            ? Icons.arrow_drop_down_outlined
                                            : Icons.camera_alt_outlined,
                                    size: 25,
                                    color: widget.searchIconColor ?? MyColor.getPrimaryColor(),
                                  ),
                                )
                              : null
                      : null,
                ),
                onFieldSubmitted: (text) => widget.nextFocus != null ? FocusScope.of(context).requestFocus(widget.nextFocus) : null,
                onChanged: (text) => widget.onChanged!(text),
                onTap: widget.onTap,
              ),
      ],
    );
  }

  void _toggle() {
    setState(() {
      obscureText = !obscureText;
    });
  }
}

// Project imports:
import '../../imports.dart';

class AppTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final bool? obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isDense;
  final double verticalPadding;
  final double horizontalPadding;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final int errorMaxLines;
  final TextInputType? textInputType;
  final List<TextInputFormatter>? textInputFormatter;
  final Color? hintTextColor;
  final Color? textColor;
  final Color? labelColor;
  final bool shouldShowVisiblity;
  final Function()? onVisibilityTap;
  final bool enabled;
  final double? hinTextLetterSpacing;
  final Function(String)? onChanged;
  final Color? disableFontColor;
  final double labelTextSpacing;
  final FocusNode? focusNode;
  final String? errorText;
  final bool labelIsRequired;
  final double radius;
  final FontWeight? labelFontWeight;
  final double borderWidth;
  final FontWeight? textFontWeight;
  final Function(PointerDownEvent)? onTapOutside;
  final String? Function(String?)? validator;
  final Color? backgroundColor;
  final double? textSize;
  final double? labelTextSize;
  final double labelPaddingBottom;
  final double? errorTextSize;
  final Color? borderColor;
  final Color? focusBorderColor;
  final AutovalidateMode? autovalidateMode;
  final bool enabledClearText;
  final Widget? labelSuffixChild;
  final bool enabledEmailOtp;
  final GlobalKey<FormState>? formKey;
  final Color? obscureTextDisabledColor;
  final Color? obscureTextEnabledColor;
  final Function()? onEditingComplete;
  final TextInputAction? textInputAction;
  final bool maxMinLinesEnabled;
  final bool readOnly;

  const AppTextFormField({
    super.key,
    this.focusNode,
    this.controller,
    this.labelText,
    this.hintText,
    this.obscureText,
    this.prefixIcon,
    this.suffixIcon,
    this.isDense = true,
    this.verticalPadding = 10,
    this.horizontalPadding = 18,
    this.minLines,
    this.maxLines,
    this.maxLength,
    this.errorMaxLines = 2,
    this.textInputType = TextInputType.text,
    this.textInputFormatter,
    this.hintTextColor,
    this.textColor,
    this.labelColor,
    this.shouldShowVisiblity = false,
    this.onVisibilityTap,
    this.enabled = true,
    this.hinTextLetterSpacing,
    this.onChanged,
    this.disableFontColor,
    this.labelTextSpacing = 0.0,
    this.errorText,
    this.labelIsRequired = false,
    this.radius = 8,
    this.labelFontWeight,
    this.borderWidth = 1.0,
    this.textFontWeight,
    this.onTapOutside,
    this.validator,
    this.backgroundColor,
    this.textSize,
    this.labelTextSize,
    this.labelPaddingBottom = 0.0,
    this.errorTextSize = kFont13,
    this.borderColor,
    this.focusBorderColor,
    this.autovalidateMode,
    this.enabledClearText = true,
    this.labelSuffixChild,
    this.enabledEmailOtp = false,
    this.obscureTextDisabledColor,
    this.obscureTextEnabledColor,
    this.formKey,
    this.onEditingComplete,
    this.textInputAction,
    this.maxMinLinesEnabled = false,
    this.readOnly = false,
  });

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  bool? obscureText;
  int resentIn = 60;
  int resentInOriginal = 60;
  Timer? timer;
  bool canResentNow = true;
  late FocusNode _focusNode;
  late TextEditingController _textController;

  void _handleFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.obscureText != null) {
      obscureText = widget.obscureText!;
    }

    _focusNode = widget.focusNode ?? FocusNode();
    _textController = widget.controller ?? TextEditingController();

    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    timer?.cancel();

    _focusNode.removeListener(_handleFocusChange);

    if (widget.focusNode == null) {
      _focusNode.dispose();
    }

    if (widget.controller == null) {
      _textController.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: widget.labelText != null ? 5 : widget.labelPaddingBottom,
          ).r,
          child: Row(
            children: [
              if (widget.labelText != null)
                Expanded(
                  child: AppText(
                    widget.labelText ?? "",
                    isRequired: widget.labelIsRequired,
                    fontWeight: widget.labelFontWeight ?? FontWeight.w600,
                    color: widget.labelColor ?? AppColors.labelColor,
                    fontSize: widget.labelTextSize ?? kFont13,
                  ),
                ),
              if (widget.labelSuffixChild != null) widget.labelSuffixChild!,
            ],
          ),
        ),
        _buildTextFormField(context),
      ],
    );
  }

  Widget _buildTextFormField(BuildContext context) {
    final List<Widget> suffixChildren = [];

    if (widget.enabledClearText &&
        _focusNode.hasFocus &&
        _textController.text.isNotEmpty) {
      suffixChildren.add(
        InkWellWrapper(
          onTap: () {
            _textController.clear();
            widget.onChanged?.call(_textController.text);
            setState(() {});
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8).r,
            child: Icon(
              MdiIcons.closeCircle,
              size: 18,
              color: AppColors.greyColor,
            ),
          ),
        ),
      );
    }

    if (obscureText != null) {
      suffixChildren.add(
        InkWellWrapper(
          onTap: () {
            obscureText = !obscureText!;
            setState(() {});
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8).r,
            child: Icon(
              obscureText! ? Icons.visibility_off : Icons.visibility,
              color:
                  (obscureText!
                      ? widget.obscureTextDisabledColor
                      : widget.obscureTextEnabledColor) ??
                  AppColors.primaryColor,
              size: 24,
            ),
          ),
        ),
      );
    }

    if (widget.suffixIcon != null) {
      suffixChildren.add(widget.suffixIcon!);
    }

    if (widget.enabledEmailOtp) {
      suffixChildren.add(
        InkWellWrapper(
          onTap: () {
            if (widget.formKey != null) {
              actionResendCode();
            } else {
              printLog("Formkey is missing");
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 5).r,
            child: AppText(
              canResentNow ? context.tr(AppStrings.sendCode) : "$resentIn",
              color: AppColors.primaryColor,
            ),
          ),
        ),
      );
    }

    if (suffixChildren.isNotEmpty) {
      suffixChildren.add(10.widthSpace);
    }

    return TextFormField(
      onTapOutside: widget.onTapOutside,
      readOnly: widget.readOnly,
      textInputAction: widget.textInputAction,
      onEditingComplete: widget.onEditingComplete,
      enabled: widget.enabled,
      controller: _textController,
      focusNode: _focusNode,
      obscureText: obscureText ?? false,
      maxLines: widget.maxLines ?? 1,
      minLines: widget.minLines ?? 1,
      maxLength: widget.maxLength,
      autovalidateMode:
          widget.autovalidateMode ?? AutovalidateMode.onUserInteraction,
      keyboardType: widget.textInputType,
      inputFormatters: widget.textInputFormatter ?? [],
      style: TextStyle(
        color: widget.textColor ?? AppColors.primaryTextColor,
        fontSize: widget.textSize ?? kFont13.sp,
        fontWeight: widget.textFontWeight ?? FontWeight.normal,
      ),
      onChanged: (val) {
        widget.onChanged?.call(val);
        setState(() {});
      },
      decoration: InputDecoration(
        fillColor: widget.enabled
            ? (widget.backgroundColor ?? AppColors.containerBgColor)
            : AppColors.dividerColor,
        filled: true,
        hoverColor: Colors.transparent,
        errorText: widget.errorText,
        errorMaxLines: widget.errorMaxLines,
        errorStyle: TextStyle(
          color: AppColors.redColor,
          fontSize: widget.errorTextSize ?? widget.textSize ?? kFont13.sp,
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.redColor,
            width: widget.borderWidth,
          ),
          borderRadius: BorderRadius.circular(widget.radius).r,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.redColor,
            width: widget.borderWidth,
          ),
          borderRadius: BorderRadius.circular(widget.radius).r,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: widget.borderColor ?? AppColors.greyLightColor,
            width: widget.borderWidth,
          ),
          borderRadius: BorderRadius.circular(widget.radius).r,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: widget.focusBorderColor ?? AppColors.primaryColor,
            width: widget.borderWidth,
          ),
          borderRadius: BorderRadius.circular(widget.radius).r,
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: widget.borderColor ?? AppColors.greyLightColor,
            width: 0,
          ),
          borderRadius: BorderRadius.circular(widget.radius).r,
        ),
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: widget.hintTextColor ?? AppColors.hintColor.wOpacity(0.7),
          fontSize: widget.textSize ?? kFont13.sp,
          letterSpacing: widget.hinTextLetterSpacing ?? 0,
        ),
        prefixIcon: widget.prefixIcon,
        prefixIconConstraints: const BoxConstraints(minWidth: 2, minHeight: 2),
        suffixIcon: suffixChildren.isNotEmpty
            ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: suffixChildren,
              )
            : null,
        contentPadding: EdgeInsets.symmetric(
          horizontal: widget.horizontalPadding,
          vertical: widget.verticalPadding,
        ).r,
        isDense: widget.isDense,
      ),
      validator: widget.validator,
    );
  }

  void startResentCountDown() {
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) => setState(() {
        if (resentIn < 2) {
          allowResent();
        } else {
          resentIn = resentIn - 1;
        }
      }),
    );
  }

  void allowResent() {
    canResentNow = true;
    timer?.cancel();
  }

  void actionResendCode() async {
    if (!canResentNow) return;

    // await ApiService.api.emailSendOtp(
    //   showLoader: true,
    //   email: _textController.text,
    //   onSuccess: (_) {
    //     resetTimer();
    //   },
    // );
  }

  void resetTimer() {
    resentIn = resentInOriginal;
    canResentNow = false;
    startResentCountDown();
    setState(() {});
  }
}

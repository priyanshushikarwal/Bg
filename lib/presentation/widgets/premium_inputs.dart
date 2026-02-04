import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/date_utils.dart';

/// Custom text field with premium styling
class PremiumTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool readOnly;
  final int maxLines;
  final EdgeInsetsGeometry? padding;

  const PremiumTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.padding,
  });

  @override
  State<PremiumTextField> createState() => _PremiumTextFieldState();
}

class _PremiumTextFieldState extends State<PremiumTextField> {
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: AppDimensions.animationFast),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
            border: Border.all(
              color: _isFocused ? AppColors.primaryPurple : AppColors.border,
              width: _isFocused ? 2 : 1,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppColors.primaryPurple.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            autofocus: widget.autofocus,
            readOnly: widget.readOnly,
            maxLines: widget.maxLines,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? AppColors.primaryPurple
                          : AppColors.textMuted,
                      size: 20,
                    )
                  : null,
              suffixIcon: widget.suffix,
              contentPadding:
                  widget.padding ??
                  const EdgeInsets.symmetric(
                    horizontal: AppDimensions.inputPaddingH,
                    vertical: AppDimensions.inputPaddingV,
                  ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

/// Search bar with premium styling
class PremiumSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final String hint;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final double? width;

  const PremiumSearchBar({
    super.key,
    this.controller,
    this.hint = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.width,
  });

  @override
  State<PremiumSearchBar> createState() => _PremiumSearchBarState();
}

class _PremiumSearchBarState extends State<PremiumSearchBar> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? 400,
      child: PremiumTextField(
        controller: _controller,
        hint: widget.hint,
        prefixIcon: Icons.search_rounded,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        suffix: _hasText
            ? IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                onPressed: () {
                  _controller.clear();
                  widget.onClear?.call();
                  widget.onChanged?.call('');
                },
              )
            : null,
      ),
    );
  }
}

/// Dropdown with premium styling
class PremiumDropdown<T> extends StatefulWidget {
  final String? label;
  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final double? width;

  const PremiumDropdown({
    super.key,
    this.label,
    required this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.width,
  });

  @override
  State<PremiumDropdown<T>> createState() => _PremiumDropdownState<T>();
}

class _PremiumDropdownState<T> extends State<PremiumDropdown<T>> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: AppDimensions.animationFast),
          width: widget.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
            border: Border.all(
              color: _isOpen ? AppColors.primaryPurple : AppColors.border,
              width: _isOpen ? 2 : 1,
            ),
            boxShadow: _isOpen
                ? [
                    BoxShadow(
                      color: AppColors.primaryPurple.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: DropdownButtonFormField<T>(
            value: widget.value,
            items: widget.items,
            onChanged: widget.onChanged,
            onTap: () => setState(() => _isOpen = true),
            hint: Text(
              widget.hint,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            icon: AnimatedRotation(
              turns: _isOpen ? 0.5 : 0,
              duration: const Duration(
                milliseconds: AppDimensions.animationFast,
              ),
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textMuted,
              ),
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.inputPaddingH,
                vertical: AppDimensions.inputPaddingV,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
      ],
    );
  }
}

/// Date picker field with premium styling
class PremiumDateField extends StatefulWidget {
  final String? label;
  final String hint;
  final DateTime? value;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final void Function(DateTime)? onChanged;
  final double? width;

  const PremiumDateField({
    super.key,
    this.label,
    required this.hint,
    this.value,
    this.firstDate,
    this.lastDate,
    this.onChanged,
    this.width,
  });

  @override
  State<PremiumDateField> createState() => _PremiumDateFieldState();
}

class _PremiumDateFieldState extends State<PremiumDateField> {
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.value ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(2000),
      lastDate: widget.lastDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      widget.onChanged?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          child: Container(
            width: widget.width,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.inputPaddingH,
              vertical: AppDimensions.inputPaddingV,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.value != null
                        ? DateFormatterUtils.formatToShort(widget.value!)
                        : widget.hint,
                    style: TextStyle(
                      color: widget.value != null
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A premium text field designed specifically for manual date entry
/// It automatically formats the input into 'dd-mm-yy' on blur
class PremiumManualDateField extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String hint;
  final String? Function(String?)? validator;
  final void Function(DateTime?)? onDateChanged;
  final double? width;

  const PremiumManualDateField({
    super.key,
    required this.controller,
    this.label,
    this.hint = 'DD-MM-YY',
    this.validator,
    this.onDateChanged,
    this.width,
  });

  @override
  State<PremiumManualDateField> createState() => _PremiumManualDateFieldState();
}

class _PremiumManualDateFieldState extends State<PremiumManualDateField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _formatInput();
    }
  }

  void _formatInput() {
    final text = widget.controller.text;
    if (text.isEmpty) return;

    final normalized = DateFormatterUtils.normalizeDateString(text);
    if (normalized != null) {
      widget.controller.text = normalized;
      final date = DateFormatterUtils.parseFlexible(normalized);
      widget.onDateChanged?.call(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: PremiumTextField(
        controller: widget.controller,
        label: widget.label,
        hint: widget.hint,
        focusNode: _focusNode,
        keyboardType: TextInputType.datetime,
        prefixIcon: Icons.calendar_month_rounded,
        validator: widget.validator,
        onSubmitted: (_) => _formatInput(),
      ),
    );
  }
}

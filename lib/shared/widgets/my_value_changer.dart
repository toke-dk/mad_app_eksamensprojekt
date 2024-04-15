import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

InputDecoration kMyInputDecoration = InputDecoration(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)));

class RangeFormatter extends TextInputFormatter {
  final int? minValue;
  final int? maxValue;

  RangeFormatter({required this.minValue, required this.maxValue});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    double newValueAsDouble = double.parse(newValue.text);
    if (minValue != null && newValueAsDouble < minValue!) {
      return oldValue;
    } else if (maxValue != null && newValueAsDouble > maxValue!) {
      return oldValue;
    } else {
      return newValue;
    }
  }
}

class MyValueChanger extends StatefulWidget {
  const MyValueChanger({
    super.key,
    required this.handleValueChange,
    this.maxValue,
    this.minValue = 1,
    this.hintText,
    required this.value,
  });

  final Function(int newVal) handleValueChange;
  final int? maxValue;
  final int? minValue;
  final String? hintText;
  final int value;

  @override
  State<MyValueChanger> createState() => _MyValueChangerState();
}

class _MyValueChangerState extends State<MyValueChanger> {
  void _handleGoalValueDecrement(String textValue) {
    final int? intValue = int.tryParse(textValue);
    int? changedValue;

    if (intValue == null || intValue <= 0) {
      changedValue = 0;
    } else {
      changedValue = intValue - 1;
    }
    widget.handleValueChange(changedValue);
    _controller.text = changedValue.toString();
  }

  void _handleGoalValueIncrement(String textValue) {
    final int? intValue = int.tryParse(textValue);
    int? changedValue;

    if (intValue == null ||
        (widget.maxValue != null && intValue >= widget.maxValue!))
      return;
    else if (intValue < 0) {
      changedValue = 1;
    } else {
      changedValue = intValue + 1;
    }
    widget.handleValueChange(changedValue);
    _controller.text = changedValue.toString();
  }

  TextEditingController _controller = TextEditingController();

  // make this correct
  bool get isAddEnabled {
    final int? intValue = int.tryParse(_controller.text);
    if (intValue == null || widget.maxValue == null) return true;
    if (intValue + 1 <= widget.maxValue!) return true;
    return false;
  }

  bool get isSubtractEnabled {
    final int? intValue = int.tryParse(_controller.text);
    if (intValue == null || widget.minValue == null) return true;
    if (intValue - 1 >= widget.minValue!) return true;
    return false;
  }

  @override
  void initState() {
    _controller = TextEditingController(text: widget.value.toString());
    super.initState();
  }

  final double height = 60;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      child: Column(
        children: [
          widget.hintText != null
              ? Center(
              child: Text(
                widget.hintText!,
                style: Theme.of(context).textTheme.labelMedium,
              ))
              : SizedBox.shrink(),
          SizedBox(
            height: 3,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: _ChangeValueIcon(
                    height: height,
                    subtract: true,
                    onPressed: isSubtractEnabled
                        ? () => _handleGoalValueDecrement(_controller.text)
                        : null),
              ),
              Flexible(
                flex: 2,
                child: Container(
                  alignment: Alignment.center,
                  height: height,
                  child: TextField(
                    expands: true,
                    maxLines: null,
                    decoration: kMyInputDecoration.copyWith(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        filled: true,
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                        isDense: true),
                    onChanged: (String newString) {
                      if (int.tryParse(newString) == null) return;
                      widget.handleValueChange(int.parse(newString));
                    },
                    controller: _controller,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      RangeFormatter(
                          minValue: widget.minValue, maxValue: widget.maxValue)
                    ],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Expanded(
                child: _ChangeValueIcon(
                    height: height,
                    subtract: false,
                    onPressed: isAddEnabled
                        ? () => _handleGoalValueIncrement(_controller.text)
                        : null),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChangeValueIcon extends StatelessWidget {
  const _ChangeValueIcon(
      {super.key, this.subtract = false, this.onPressed, required this.height});

  final bool subtract;
  final Function()? onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).colorScheme.primary;

    return Container(
      width: 30,
      height: height,
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          border: Border.all(color: color)),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: InkWell(
            onTap: () => onPressed != null ? onPressed!() : () {},
            child: Icon(subtract ? Icons.remove : Icons.add)),
      ),
    );
  }
}

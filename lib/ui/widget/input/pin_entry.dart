import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinEntry extends StatefulWidget {
  final String lastPin;
  final int fields;
  final onChange;
  final onSubmit;
  final double fieldWidth;
  final double fontSize;
  final isTextObscure;
  final showFieldAsBox;

  PinEntry(
      {this.lastPin,
        this.fields: 4,
        this.onChange,
        this.onSubmit,
        this.fieldWidth: 40.0,
        this.fontSize: 20.0,
        this.isTextObscure: false,
        this.showFieldAsBox: false})
      : assert(fields > 0);

  @override
  State createState() {
    return PinEntryState();
  }
}

class PinEntryState extends State<PinEntry> {
  List<String> _pin;
  List<FocusNode> _focusNodes;
  List<TextEditingController> _textControllers;

  Widget _textFields = Container();

  @override
  void initState() {
    super.initState();
    _pin = List<String>(widget.fields);
    _focusNodes = List<FocusNode>(widget.fields);
    _textControllers = List<TextEditingController>(widget.fields);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        if (widget.lastPin != null) {
          for (var i = 0; i < widget.lastPin.length; i++) {
            _pin[i] = widget.lastPin[i];
          }
        }
        _textFields = generateTextFields(context);
      });
    });
  }

  @override
  void dispose() {
    _textControllers.forEach((TextEditingController t) => t.dispose());
    super.dispose();
  }

  Widget generateTextFields(BuildContext context) {
    List<Widget> textFields = List.generate(widget.fields, (int i) {
      return buildTextField(i, context);
    });

    if (_pin.first != null) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    }

    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        verticalDirection: VerticalDirection.down,
        children: textFields
    );
  }

  void clearTextFields() {
    _textControllers.forEach(
            (TextEditingController tEditController) => tEditController.clear());
    _pin.clear();
  }

  Widget buildTextField(int i, BuildContext context) {
    if (_focusNodes[i] == null) {
      _focusNodes[i] = FocusNode();
    }
    if (_textControllers[i] == null) {
      _textControllers[i] = TextEditingController();
      if (widget.lastPin != null ) {
        _textControllers[i].text = widget.lastPin[i];
      }
    }

    _focusNodes[i].addListener(() {
      if (_focusNodes[i].hasFocus) {}
    });

    final String lastDigit = _textControllers[i].text;

    return Container(
      width: widget.fieldWidth,
      height: widget.fieldWidth,
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      child: TextField(
        controller: _textControllers[i],
        keyboardType: TextInputType.number,
        textAlignVertical: TextAlignVertical.center,
        textAlign: TextAlign.center,
        autofocus: i == 0,
        maxLength: 1,
        showCursor: false,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontSize: widget.fontSize
        ),
        focusNode: _focusNodes[i],
        obscureText: widget.isTextObscure,
        decoration: InputDecoration(
            hintText: 'ー',
            hintStyle: TextStyle(
                color: Colors.black54, fontWeight: FontWeight.normal
            ),
            counterText: '',
//            border: widget.showFieldAsBox ? _outlineBorder() : InputBorder.none,
            enabledBorder: widget.showFieldAsBox
                ? _outlineBorder(color: lastDigit.isEmpty? Colors.black12 : Colors.lightBlue)
                : InputBorder.none,
            focusedBorder: _outlineBorder(),
            contentPadding: EdgeInsets.all(10),
        ),
        onChanged: (String str) {
          setState(() => _pin[i] = str);
          if (i + 1 != widget.fields) {
            _focusNodes[i].unfocus();
            if (lastDigit != null && _pin[i] == '') {
              FocusScope.of(context).requestFocus(_focusNodes[i - 1]);
            } else {
              FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
            }
          } else {
            _focusNodes[i].unfocus();
            if (lastDigit != null && _pin[i] == '') {
              FocusScope.of(context).requestFocus(_focusNodes[i - 1]);
            }
          }
          widget.onChange(_pin.join());
          if (_pin.every((String digit) => digit != null && digit != '')) {
            widget.onSubmit(_pin.join());
          }
        },
        onSubmitted: (String str) {
          if (_pin.every((String digit) => digit != null && digit != '')) {
            widget.onSubmit(_pin.join());
          }
        },
      ),
    );
  }

  _outlineBorder({double width = 3.0, Color color = Colors.blue}) {
    return OutlineInputBorder(
        borderSide: BorderSide(width: width, color: color)
    );
  }

  @override
  Widget build(BuildContext context) {
    return _textFields;
  }
}
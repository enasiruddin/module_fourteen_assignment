import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

Widget TextFieldDecoraiton({key,controller,readOnly,labelText,hintText, onTap,focusNode,enabled,keyboardType,onChanged,validator}){
  readOnly==null? readOnly=false: null;
  return TextFormField(
      key: key,
      controller: controller,
      enabled: enabled,
      focusNode: focusNode,
      readOnly: readOnly,
      keyboardType: keyboardType,
      textAlign: TextAlign.center,
      onTap: onTap,
      onChanged: onChanged,
      validator: validator,
      maxLines: null,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
      ),
  );
}
import 'package:flutter/material.dart';

Widget circularLogo(String img){
  return Container(
    height: 50,
    width: 50,
    decoration: BoxDecoration(
      shape: BoxShape.circle, 
      border: Border.all(color: Colors.white),
    ),
    child: Center(
      child: Container(
        height: 30,
        width: 30,
        decoration: const BoxDecoration(
            shape: BoxShape.circle
        ),
        child: Image.asset(img),
      ),
    ),
  );
}

Widget customButton({required Color color, required String text,required Color txtColor}){
  return Container(
    height: 50,
    width: 400,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20)
    ),
    child: Center(child: Text(text,style: TextStyle(fontSize: 24,fontWeight: FontWeight.w500, color: txtColor),)),
  );
}
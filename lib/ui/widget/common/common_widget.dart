import 'package:flutter/material.dart';
import 'package:o2o/data/loadingstate/LoadingState.dart';
import 'package:o2o/ui/widget/common/app_colors.dart';

class CommonWidget {
  static Container buildDialogHeader(BuildContext context, String title, {double fontSize = 16.0}) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: AppColors.blueGradient),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(5),
            topRight: Radius.circular(5),
          )),
      child: Text(
        title,
        style: TextStyle(
            color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  static Widget buildProgressIndicator(LoadingState loadingState) {
    return Opacity(
      opacity: loadingState == LoadingState.LOADING ? 1.0 : 00,
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  static Container line({
    double width = 36,
    double height = 3,
    Color color = Colors.lightBlue,
    double padding = 3
  }) {
    return Container(
      width: width,
      height: height,
      margin: EdgeInsets.symmetric(horizontal: padding),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(
            Radius.circular(height)
        ),
      ),
    );
  }

  static Container circularText(
    String text, {
    Color textColor = Colors.white,
    double fontSize = 14,
    Color circleColor = Colors.lightBlue,
//    Color circleColorStart = Colors.blueAccent,
//    Color circleColorEnd = Colors.lightBlue,
    double radius = -1,
  }) {
    return Container(
      width: radius == -1? fontSize * 1.6 : radius * 2,
      height: radius == -1? fontSize * 1.6 : radius * 2,
      decoration: BoxDecoration(
        color: circleColor,
//        gradient: LinearGradient(colors: AppColors.blueGradient),
        borderRadius: BorderRadius.all(
            Radius.circular(radius == -1? fontSize * 1.8 : radius,)
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  static Text _boldTextBuilder(String text, double size) {
    return Text(
      text,
      style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.bold,
          color: Colors.white,
      ),
    );
  }

  static Container sectionDateBuilder(int month, int day, String dayStr) {
    return Container(
      height: 36,
      color: AppColors.color48C1E5,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          _boldTextBuilder(month.toString(), 20),
          Padding(
            padding: EdgeInsets.only(right: 5),
            child: _boldTextBuilder('月', 12),
          ),
          _boldTextBuilder(day.toString(), 20),
          Padding(
            padding: EdgeInsets.only(right: 5),
            child: _boldTextBuilder('日', 12),
          ),
          _boldTextBuilder('($dayStr)', 16),
        ],
      ),
    );
  }

  static Container sectionTimeBuilder(String hour, String min) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: AppColors.blueGradient)
      ),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      child: Row(
        children: <Widget>[
          _boldTextBuilder('$hour:$min', 20),
          Padding(
            padding: EdgeInsets.only(left: 5, top: 5),
            child: _boldTextBuilder('発送分', 12),
          ),
        ],
      ),
    );
  }
}

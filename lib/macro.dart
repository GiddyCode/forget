import 'package:flutter/material.dart';
import 'model.dart';

double screenWidth(BuildContext context){
  return MediaQuery.of(context).size.width;
}

double screenHeight(BuildContext context){
  return MediaQuery.of(context).size.height;
}

IconData iconDataOfFilter(TaskType type){
  switch(type){
    case TaskType.unassigned:
      return Icons.not_listed_location;
    case TaskType.nextMove:
      return Icons.play_arrow;
    case TaskType.plan:
      return Icons.calendar_today;
    case TaskType.wait:
      return Icons.access_time;
  }
}

String stringOfFilter(TaskType type){
  switch(type){
    case TaskType.unassigned:
      return 'unassigned';
    case TaskType.nextMove:
      return 'next move';
    case TaskType.plan:
      return 'plan';
    case TaskType.wait:
      return 'wait';
  }
}

GestureTapCallback showTodoSnackBar(BuildContext context){
  return ()=> Scaffold.of(context)
      .showSnackBar(SnackBar(content: Text('TODO',textAlign: TextAlign.center), duration: Duration(milliseconds: 200)));
}
import 'package:flutter/material.dart';
import 'model.dart';
import 'macro.dart';

class TaskCell extends StatelessWidget {
  TaskCell(
      {Key key,
      this.task,
      this.clicked,
      this.doneAction,
      this.deleteAction,
      this.showingIn})
      : super(key: key);
  Task task;
  GestureTapCallback clicked;
  VoidCallback doneAction;
  VoidCallback deleteAction;
  TaskCellShowingIn showingIn;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
        key: ObjectKey(task),
        onDismissed: (DismissDirection direction) {
          if (direction == DismissDirection.endToStart) {
            deleteAction();
          } else {
            doneAction();
          }
        },
        secondaryBackground: Container(
          alignment: AlignmentDirectional.center,
          child: ListTile(
              trailing: Icon(
            Icons.clear,
            color: Colors.red,
          )),
        ),
        background: Container(
          alignment: AlignmentDirectional.center,
          child: ListTile(leading: Icon(Icons.done, color: Colors.green)),
        ),
        child: Container(
          margin: EdgeInsets.fromLTRB(12, 4, 12, 4),
          decoration: ShapeDecoration(
              color: Colors.white,
              shadows: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey[300],
                    offset: Offset(1, 2),
                    blurRadius: 2)
              ],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
          alignment: Alignment.center,
          child: ListTile(
              isThreeLine: true,
              title: Text(task.text, maxLines: 1),
              subtitle: Text(showingIn == TaskCellShowingIn.project
                  ? ''
                  : task.project_text ?? '', maxLines: 1),
              leading: Icon(iconDataOfFilter(TaskType.values[task.taskType]), color: task.priorityColor()),
              onTap: clicked),
        ));
  }
}

class ProjectCell extends StatelessWidget {
  ProjectCell({Key key, this.project, this.clicked, this.deleteAction})
      : super(key: key);
  Project project;
  GestureTapCallback clicked;
  VoidCallback deleteAction;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
        direction: DismissDirection.endToStart,
        key: ObjectKey(project),
        onDismissed: (direction) {
          deleteAction();
        },
        background: Container(
          alignment: AlignmentDirectional.center,
          child: ListTile(trailing: Icon(Icons.clear, color: Colors.red)),
        ),
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.fromLTRB(12, 4, 12, 4),
          decoration: ShapeDecoration(
              color: Colors.white,
              shadows: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey[300],
                    offset: Offset(1, 2),
                    blurRadius: 2)
              ],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
          child: ListTile(
              isThreeLine: true,
              title: Text(
                project.text,
                style: TextStyle(fontSize: 20),
                  maxLines: 1
              ),
              subtitle: Text('${project.numOfTasks} tasks'),
              onTap: clicked),
        ));
  }
}

class FilterCell extends StatelessWidget {
  FilterCell({Key key, this.filter, this.numOfTasks, this.clicked})
      : super(key: key);
  TaskType filter;
  int numOfTasks;
  GestureTapCallback clicked;

  @override
  Widget build(BuildContext context) {
    final double cellWidth = (screenWidth(context) - 12 * 3) / 2;
    return GestureDetector(
      onTap: clicked,
      child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.fromLTRB(12, 4, 0, 4),
          width: cellWidth,
          decoration: ShapeDecoration(
              color: Colors.white,
              shadows: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey[300],
                    offset: Offset(1, 2),
                    blurRadius: 2)
              ],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
          child: Padding(
            padding: const EdgeInsets.only(left: 13.0),
            child: Row(
              children: <Widget>[
                Icon(iconDataOfFilter(filter)),
                Padding(
                  padding: const EdgeInsets.only(left: 13.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(stringOfFilter(filter),
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      Text('${numOfTasks} tasks',
                          style: TextStyle(fontWeight: FontWeight.w100))
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }
}
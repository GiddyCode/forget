import 'package:flutter/material.dart';
import 'model.dart';
import 'task_detail_page.dart';
import 'cells.dart';

class ProjectDetailPage extends StatefulWidget {
  ProjectDetailPage({Key key, this.project_text, this.project_id})
      : super(key: key);
  String project_text;
  int project_id;

  @override
  State<StatefulWidget> createState() {
    return _ProjectDetailPageState();
  }
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  List<Task> taskList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _renovate_tasklist();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: PreferredSize(
            child: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.grey[200],
                brightness: Brightness.light,
                iconTheme: IconThemeData(color: Colors.black),
                elevation: 0,
                centerTitle: false,
                title: ActionChip(
                    onPressed: () => Navigator.pop(context),
                    backgroundColor: Colors.blue,
                    elevation: 6,
                    avatar: CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                    label: Text(
                      widget.project_text,
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ))),
            preferredSize: Size.fromHeight(60)),
        body: taskList.length == 0
            ? Center(child: Text('add your first task'))
            : _tableView(),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.deepOrange,
          onPressed: _add_task,
          child: Icon(Icons.add, color: Colors.white),
        ));
  }

  // 构建列表
  Widget _tableView() {
    Widget listView = Flexible(
      child: ListView.builder(
          itemBuilder: (context, index) {
            return TaskCell(
              task: taskList[index],
              clicked: _update_task_callback(index),
              doneAction: () {},
              deleteAction: _delete_task_callback(index),
              showingIn: TaskCellShowingIn.project,
            );
          },
          itemExtent: 72,
          itemCount: taskList.length),
    );
    return listView;
  }

  //获取task数据并更新widgetState
  _renovate_tasklist() {
    DBOperation.retrieveTasksInProject(widget.project_id).then((value) {
      taskList = value;
      for (Task task in taskList) {
        task.project_text = widget.project_text;
      }
      print('tasks---------------');
      for (Task task in taskList) {
        print('${task.id}, ' +
            '${task.priority}' +
            ', ' +
            task.text +
            ', ' +
            '${task.projectID}');
      }
      setState(() {});
    });
  }

  _add_task() {
    DBOperation.retrieveLabels().then((labelList) {
      Navigator.push(
          context,
          PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
            return TaskDetailPage(
              task: Task(
                  projectID: widget.project_id,
                  project_text: widget.project_text),
              labelList: labelList,
            );
          }, transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: const Offset(0.0, 0.0),
              ).animate(animation),
              child: child,
            );
          })).then((value) async {
        if (value == null) {
          return;
        }
        if (value[0].text == null || value[0].text.isEmpty) {
          return;
        }
        await DBOperation.insertTask(value[0], value[1]);
        _renovate_tasklist();
      });
    });
  }

  //taskcell点击回调
  GestureTapCallback _update_task_callback(int index) {
    return () {
      DBOperation.retrieveLabels(taskID: taskList[index].id).then((labelList){
        Navigator.push(
            context,
            PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) {
                  return TaskDetailPage(task: taskList[index], labelList: labelList,);
                }, transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
                ) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: const Offset(0.0, 0.0),
                ).animate(animation),
                child: child,
              );
            })).then((value) async {
          if (value == null) {
            return;
          }
          if (value[0].text == null || value[0].text.isEmpty) {
            return;
          }
          await DBOperation.updateTask(value[0], value[1]);
          ;
          _renovate_tasklist();
        });
      });
    };
  }

  //taskcell左滑回调
  VoidCallback _delete_task_callback(int index) {
    return () async {
      await DBOperation.deleteTask(taskList[index].id);
      _renovate_tasklist();
    };
  }
}

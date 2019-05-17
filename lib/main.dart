import 'package:flutter/material.dart';
import 'task_detail_page.dart';
import 'model.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'project_detail_page.dart';
import 'cells.dart';
import 'macro.dart';
import 'customize_button.dart';
import 'dart:math';

void main() {
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
//      showSemanticsDebugger: true,
      title: 'forget',
      home: HomePage(),
//        localizationsDelegates: const [
//          S.delegate,
//          GlobalMaterialLocalizations.delegate,
//          GlobalWidgetsLocalizations.delegate
//        ],
//        supportedLocales: S.delegate.supportedLocales
    );
  }
}

// 主页
class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  List<Task> taskList = [];
  List<Project> projectList = [];
  bool isShowingTask = true;

  Animation _animation;
  Animation _animation2;
  Animation _animation3;
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _renovate_tasklist();
    _renovate_projectList();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animation = ColorTween(begin: Colors.deepOrange, end: Colors.blue)
        .animate(_animationController);
    _animation2 =
        Tween<double>(begin: 0, end: pi).animate(_animationController);
    _animation3 = TweenSequence<Offset>(<TweenSequenceItem<Offset>>[
      TweenSequenceItem(
          tween: Tween<Offset>(begin: Offset(0, 0), end: Offset(-0, 0)),
          weight: 0.5),
      TweenSequenceItem(
          tween: Tween<Offset>(begin: Offset(-0, 0), end: Offset(0, 0)),
          weight: 0.5),
    ]).animate(_animationController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: PreferredSize(
            child: AppBar(
                backgroundColor: Colors.transparent,
                brightness: Brightness.light,
                elevation: 0,
                centerTitle: false,
                actions: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: Colors.black,
                    ),
                    onPressed: _delete_label,
                  )
                ],
                title: AnimatedChip(
                  rotationAnimation: _animation2,
                  colorAnimation: _animation,
                  offsetAnimation: _animation3,
                  text: isShowingTask ? 'Task' : 'Overview',
                  onPressed: () {
                    isShowingTask = !isShowingTask;
                    isShowingTask
                        ? _animationController.reverse()
                        : _animationController.forward();
                    setState(() {});
                  },
                )),
            preferredSize: Size.fromHeight(60)),
        body: (taskList.length == 0 && isShowingTask)
            ? Center(child: Text('add your first task')) //列表为空时的占位符
            : _tableView(),
        floatingActionButton: AnimatedBuilder(
            animation: _animation,
            child: FloatingActionButton(
              backgroundColor: isShowingTask ? Colors.deepOrange : Colors.blue,
              onPressed: isShowingTask ? _add_task : _add_project,
              child: Icon(Icons.add, color: Colors.white),
            ),
            builder: (context, child) {
              return FloatingActionButton(
                backgroundColor: _animation.value,
                onPressed: isShowingTask ? _add_task : _add_project,
                child: Icon(Icons.add, color: Colors.white),
              );
            }));
  }

  // 构建列表
  ListView _tableView() {
    ListView listView = ListView.builder(
        itemBuilder: (context, index) {
          if (!isShowingTask && index == 0) {
            return Row(
              children: <Widget>[
                FilterCell(
                    filter: TaskType.unassigned,
                    numOfTasks: 0,
                    clicked: showTodoSnackBar(context)),
                FilterCell(
                    filter: TaskType.nextMove, numOfTasks: 0, clicked: showTodoSnackBar(context))
              ],
            );
          }
          if (!isShowingTask && index == 1) {
            return Row(
              children: <Widget>[
                FilterCell(
                    filter: TaskType.plan, numOfTasks: 0, clicked: showTodoSnackBar(context)),
                FilterCell(
                    filter: TaskType.wait, numOfTasks: 0, clicked: showTodoSnackBar(context))
              ],
            );
          }
//          if (!isShowingTask && index == 2){
//            return FilterCell(filter: TaskType.plan,numOfTasks: 0);
//          }
//          if (!isShowingTask && index == 3){
//            return FilterCell(filter: TaskType.wait,numOfTasks: 0);
//          }
          return isShowingTask
              ? TaskCell(
                  task: taskList[index],
                  clicked: _update_task_callback(index),
                  doneAction: () {},
                  deleteAction: _delete_task_callback(index),
                  showingIn: TaskCellShowingIn.tasks,
                )
              : ProjectCell(
                  project: projectList[index - 2],
                  clicked: _click_project_callback(index - 2),
                  deleteAction: _delete_project_callback(index - 2));
        },
        itemExtent: 72,
        itemCount: isShowingTask ? taskList.length : projectList.length + 2);
    return listView;
  }

  //获取task数据并更新widgetState
  _renovate_tasklist() {
    DBOperation.retrieveTasks().then((value) {
      taskList = value;
      print('tasks---------------');
      for (Task task in taskList) {
        print('${task.id}, ' +
            '${task.priority}' +
            ', ' +
            task.text +
            ', ' +
            '${task.projectID}, '
                '${task.project_text}');
      }
      setState(() {});
    });
  }

  //获取project数据并更新widgetState
  _renovate_projectList() {
    DBOperation.retrieveProjects().then((value) {
      projectList = value;
      print('projects---------------');
      for (Project project in projectList) {
        print('${project.id}, ' + project.text);
      }
      setState(() {});
    });
  }

  //taskcell点击回调
  GestureTapCallback _update_task_callback(int index) {
    return () {
      DBOperation.retrieveLabels(taskID: taskList[index].id).then((labelList) {
        Navigator.push(
            context,
            PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) {
              return TaskDetailPage(
                  task: taskList[index], labelList: labelList);
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
          _renovate_tasklist();
          _renovate_projectList();
        });
      });
    };
  }

  //taskcell左滑回调
  VoidCallback _delete_task_callback(int index) {
    return () async {
      await DBOperation.deleteTask(taskList[index].id);
      _renovate_tasklist();
      _renovate_projectList();
    };
  }

  //projectcell点击回调
  GestureTapCallback _click_project_callback(int index) {
    return () {
      Navigator.push(
          context,
          PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
            return ProjectDetailPage(
                project_text: projectList[index].text,
                project_id: projectList[index].id);
          }, transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            return FadeTransition(
//position: Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0)).animate(animation),
              opacity: Tween<double>(begin: 0, end: 1).animate(animation),
              child: child,
            );
          })).then((value) {
        _renovate_tasklist();
        _renovate_projectList();
      });
    };
  }

  //projectcell左滑回调
  VoidCallback _delete_project_callback(int index) {
    return () async {
      await DBOperation.deleteProject(projectList[index].id);
      _renovate_projectList();
      _renovate_tasklist();
    };
  }

  //新建task
  _add_task() {
    DBOperation.retrieveLabels().then((labelList) {
      Navigator.push(
          context,
          PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
            return TaskDetailPage(
              task: Task(),
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
        _renovate_projectList();
      });
    });
  }

  //新建project
  _add_project() {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            backgroundColor: Colors.blue[50],
            title: const Text('add project'),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            children: <Widget>[
              Container(
                  margin: EdgeInsets.only(left: 24, right: 24),
                  child: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                        hintText: 'input your project here.',
                        border: InputBorder.none),
                    onSubmitted: (str) {
                      Navigator.pop(context, str);
                    },
                  ))
            ],
          );
        }).then((value) async {
      if (value == null || value.toString().isEmpty) {
        return;
      }
      Project newproject = Project(text: value);
      await DBOperation.insertProject(newproject);
      _renovate_projectList();
    });
  }

  _delete_label() {
    DBOperation.retrieveLabels().then((labelList) {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return DeleteLabelsWidget(labelList: labelList);
          }).then((value) {
        _renovate_tasklist();
      });
    });
  }
}

class DeleteLabelsWidget extends StatefulWidget {
  DeleteLabelsWidget({Key key, this.labelList}) : super(key: key);
  List<Label> labelList;

  @override
  _DeleteLabelsWidgetState createState() => _DeleteLabelsWidgetState();
}

class _DeleteLabelsWidgetState extends State<DeleteLabelsWidget> {
  List<Label> labelList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    labelList = widget.labelList;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Delete Label', style: TextStyle(fontSize: 24)),
          Flexible(
            child: ListView(
              children: labelList
                  .map((label) => ListTile(
                        title: Text(label.text),
                        trailing: IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Colors.black,
                            ),
                            onPressed: () async {
                              await DBOperation.deleteLabel(label.id);
                              labelList.remove(label);
                              setState(() {});
                            }),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

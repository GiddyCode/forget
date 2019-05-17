import 'package:flutter/material.dart';
import 'model.dart';
import 'macro.dart';
import 'package:flutter/cupertino.dart';

class TaskDetailPage extends StatefulWidget {
  TaskDetailPage({Key key, this.task, this.labelList}) : super(key: key);
  Task task;
  List<Label> labelList;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TaskDetailPageState();
  }
}

class _TaskDetailPageState extends State<TaskDetailPage>
    with TickerProviderStateMixin {
  Task task;
  List<Label> labelList;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    task = Task.copyfrom(widget.task);
    labelList = widget.labelList;
    _focusNode.addListener(_focusNodeListener);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_focusNodeListener); // 页面消失时必须取消这个listener！！
    super.dispose();
  }

  Future<Null> _focusNodeListener() async {
//    if (_focusNode.hasFocus) {
//      print('TextField got the focus');
//    } else {
//      print('TextField lost the focus');
//    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _textcontroller =
        TextEditingController.fromValue(TextEditingValue(
            text: task.text,
            selection: TextSelection.fromPosition(TextPosition(
                affinity: TextAffinity.downstream, offset: task.text.length))));

    return Scaffold(
//        color: Colors.deepOrange[50],
        body: ListView(
          children: <Widget>[
            SizedBox(height: 18),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                margin: EdgeInsets.only(right: 18),
                child: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _focusNode.unfocus();
                      Navigator.pop(context, null);
                    }),
              ),
            ), // back button
            Padding(
                padding: EdgeInsets.only(left: 30, right: 30),
                child: TextField(
                  style: TextStyle(fontSize: 20, locale: Locale('zh', 'CH')),
                  maxLines: null,
                  focusNode: _focusNode,
                  autofocus: task.id == null,
                  onChanged: (str) {
                    task.text = str;
                  },
                  keyboardType: TextInputType.multiline,
                  controller: _textcontroller,
                  decoration: InputDecoration(
                      hintText: 'input your task here.',
                      border: InputBorder.none),
                )), // text field
            Container(
              alignment: AlignmentDirectional.centerStart,
              padding: EdgeInsets.only(left: 18, right: 18),
              child: Builder(
                builder: (context) {
                  return Wrap(
                    spacing: 8,
                    children: _wrap_widgets(),
                  );
                },
              ),
            ) // task operation
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.deepOrange,
          onPressed: () {
            _focusNode.unfocus();
            Navigator.pop(context, [task, this.labelList]);
          },
          child: Icon(Icons.done, color: Colors.white),
        ));
  }

  _chooseProject(BuildContext context) {
    DBOperation.retrieveProjects().then((projectList) {
      showModalBottomSheet<Project>(
          context: context,
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Choose Project', style: TextStyle(fontSize: 24)),
                  Flexible(
                    child: ListView(
                      children: (projectList + [Project(id: 0)])
                          .map((project) => ListTile(
                        trailing: task.projectID == project.id
                            ? Icon(Icons.check)
                            : null,
                        title: Text(
                          project.text ?? 'none',
                          style: TextStyle(fontSize: 16),
                        ),
                        onTap: () {
                          Navigator.pop(context, project);
                        },
                      ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            );
          }).then((project) {
        if (project == null) {
          return;
        }
        task.projectID = project.id;
        task.project_text = project.text;
        setState(() {});
      });
    });
  }

  _assignTask(BuildContext context) {
    showModalBottomSheet<TaskType>(
        context: context,
        builder: (BuildContext context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 18.0, top: 18),
                child: Text('Assign Task', style: TextStyle(fontSize: 24)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: TaskType.values
                    .map((type) {
                      return FlatButton.icon(
                          onPressed: () => Navigator.pop(context, type),
                          icon: Icon(iconDataOfFilter(type)),
                          label: Text(stringOfFilter(type)));
                    })
                    .toList()
                    .sublist(1),
              ),
            ],
          );
        }).then((type) {
      if (type == null) {
        return;
      }
      task.taskType = type.index;
      setState(() {});
    });
  }


  _chooseLabels(BuildContext context) {
    showModalBottomSheet<List<Label>>(
        context: context,
        builder: (BuildContext context) {
          return ChooseLabelsWidget(labelList: labelList, context: context);
        }).then((newlabelList) {
      setState(() {});
    });
  }

  Color _priority_color(int p) {
    switch (p) {
      case 1:
        return Colors.grey;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
    }
  }

  _change_priority() {
    switch (task.priority) {
      case 1:
        task.priority = 2;
        break;
      case 2:
        task.priority = 3;
        break;
      case 3:
        task.priority = 1;
    }
    setState(() {});
  }

  List<Widget> _wrap_widgets() {
    List<Widget> widgetList = <Widget>[
      _actionChip(_change_priority, Icons.lens,
          _priority_color(task.priority), 'priority'),
      _actionChip(() {_assignTask(context);},
          iconDataOfFilter(TaskType.values[task.taskType]),
          Colors.deepOrange,
          stringOfFilter(TaskType.values[task.taskType])),
      _actionChip(() {_chooseProject(context);}, Icons.assignment, Colors.blue,
          task.project_text ?? 'project')
    ];


    if(labelList.where((label)=>label.isSelected).length == 0){
      widgetList.add(_actionChip(() {_chooseLabels(context);}, Icons.label, Colors.green, 'labels'));
    }

    for (Label label in labelList.where((label)=>label.isSelected)){
      widgetList.add(_actionChip(() {_chooseLabels(context);}, Icons.label, Colors.green, label.text));
    }
    return widgetList;
  }

  Widget _actionChip(
      VoidCallback onPressed, IconData icon, Color color, String text) {
    return ActionChip(
//      elevation: 6,
      avatar: CircleAvatar(
        backgroundColor: color,
        child: Icon(icon, color: Colors.grey[350], size: 15),
      ),
      label: Text(
        text,
        style: TextStyle(fontSize: 15),
      ),
      onPressed: onPressed,
    );
  }
}




class ChooseLabelsWidget extends StatefulWidget{
  ChooseLabelsWidget({Key key, this.labelList, this.context}) : super(key: key);

  List<Label> labelList;
  BuildContext context;
  @override
  State<StatefulWidget> createState() => _ChooseLabelsWidgetState();
}

class _ChooseLabelsWidgetState extends State<ChooseLabelsWidget>{
  List<Label> labelList;

  @override
  void initState() {
    // TODO: implement initState
    labelList = widget.labelList;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Choose Labels', style: TextStyle(fontSize: 24)),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: labelList.map((label){
              return FilterChip(
                label: Text(label.text, style: TextStyle(color: label.isSelected ? Colors.white: Colors.black),),
                backgroundColor: label.isSelected ? Colors.green : null,
                onSelected: (b){label.isSelected = !label.isSelected; setState(() {});},

              );
            }).followedBy([FilterChip(
              label: Icon(Icons.add),
              onSelected: (b){_add_label();},
            )]).toList(),
          )
        ],
      ),
    );
  }

  _add_label() {
    showDialog<String>(
        context: widget.context,
        builder: (BuildContext context) {
          return SimpleDialog(
            backgroundColor: Colors.green[50],
            title: const Text('add label'),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            children: <Widget>[
              Container(
                  margin: EdgeInsets.only(left: 24, right: 24),
                  child: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                        hintText: 'input your label here.',
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
      Label newLabel = Label(text: value);
      int labelID = await DBOperation.insertLabel(newLabel);
      labelList.add(Label(id: labelID, text: value));
      setState(() {});
    });
  }
}


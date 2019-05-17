import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class Task {
  int id;
  int priority;
  String text;
  int projectID;
  String project_text;
  int taskType;
  List<String> labels_text;

  Color priorityColor() {
    switch (this.priority) {
      case 1:
        return Colors.grey;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'priority': priority,
      'text': text,
      'projectID': projectID,
      'taskType': taskType
    };
  } //供新增数据使用

  Task(
      {this.id,
      this.priority = 1,
      this.text = '',
      this.projectID = 0,
      this.project_text,
      this.taskType = 0,
      this.labels_text = const []});

  Task.copyfrom(Task task) {
    this.id = task.id;
    this.priority = task.priority;
    this.text = task.text;
    this.projectID = task.projectID;
    this.project_text = task.project_text;
    this.taskType = task.taskType;
    this.labels_text = List.generate(task.labels_text.length, (i)=>task.labels_text[i]);
  }
}

class Project {
  int id;
  String text;
  int numOfTasks;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
    };
  }

  Project({this.id, this.text, this.numOfTasks});
}

class Label {
  int id;
  String text;
  bool isSelected;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
    };
  }

  Label({this.id, this.text, this.isSelected = false});

  Label.copyfrom(Label label) {
    this.id = label.id;
    this.text = label.text;
    this.isSelected = label.isSelected;
  }
}

class TaskLabel {
  int id;
  int taskID;
  int labelID;

  Map<String, dynamic> toMap() {
    return {'id': id, 'taskID': taskID, 'labelID': labelID};
  }

  TaskLabel({this.id, this.taskID, this.labelID});
}

enum TaskType { unassigned, nextMove, plan, wait }
enum TaskCellShowingIn { tasks, project, label, filter }

class DBOperation {
  static Future<Database> _getDatabase() async {
    return await openDatabase(
        join(await getDatabasesPath(), 'forget_database.db'),
        onCreate: (db, version) async {
      await db.execute(
          "CREATE TABLE projects(id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT);");
      await db.execute(
          "CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT,"
          " priority INTEGER, text TEXT, projectID INTEGER, taskType INTEGER);");
      await db.execute(
          "CREATE TABLE labels(id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT);");
      await db.execute(
          "CREATE TABLE tasklabels(id INTEGER PRIMARY KEY AUTOINCREMENT, "
          "taskID INTEGER, labelID INTEGER);");
    }, version: 1);
  }

  //task
  static Future<void> insertTask(Task task, List<Label> labelList) async {
    assert(task.id == null);
    final Database db = await _getDatabase();

    int newTaskID = await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );


    for (Label label in labelList) {
      if(label.isSelected){
        await db.insert('taskLabels',
          {'id': null, 'taskID': newTaskID, 'labelID': label.id},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }

  static Future<List<Task>> retrieveTasks() async {
    final Database db = await _getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    final List<Map<String, dynamic>> projectMaps = await db.query('projects');
    final List<Map<String, dynamic>> taskLabelMaps = await db.query('taskLabels');
    final List<Map<String, dynamic>> allLabelMaps = await db.query('labels');

    List<Task> taskList = [];
    for (Map map in maps) {
      final projects = projectMaps.where((m) => m['id'] == map['projectID']);
      final project_text = projects.isEmpty ? null : projects.first['text'];

      //通过map['id']求出对应的label的List<Map>
      final List<Map> labelMaps = taskLabelMaps.where((m)=>m['taskID']==map['id']).toList();
      //提取出labelMaps中的label的id
      List<int> labelIDList = List.generate(labelMaps.length, (i)=>labelMaps[i]['labelID']);

      List<String> labels_text = [];
      for (int labelID in labelIDList){
        final labels = allLabelMaps.where((m) => m['id'] == labelID);
        if(labels.isEmpty){
          continue;
        }else{
          labels_text.add(labels.first['text']);
        }
      }

      taskList.add(
        Task(
            id: map['id'],
            priority: map['priority'],
            text: map['text'],
            projectID: map['projectID'],
            project_text: project_text,
            taskType: map['taskType'],
        labels_text: labels_text),
      );
    }
    return taskList;
  }

  static Future<List<Task>> retrieveTasksInProject(int projectID) async {
    final Database db = await _getDatabase();
    final List<Map<String, dynamic>> maps =
        await db.query('tasks', where: 'projectID = ?', whereArgs: [projectID]);
    final List<Map<String, dynamic>> taskLabelMaps = await db.query('taskLabels');
    final List<Map<String, dynamic>> allLabelMaps = await db.query('labels');
    List<Task> taskList = [];

    for (Map map in maps) {
      //通过map['id']求出对应的label的List<Map>
      final List<Map> labelMaps = taskLabelMaps.where((m)=>m['taskID']==map['id']).toList();
      //提取出labelMaps中的label的id
      List<int> labelIDList = List.generate(labelMaps.length, (i)=>labelMaps[i]['labelID']);

      List<String> labels_text = [];
      for (int labelID in labelIDList){
        final labels = allLabelMaps.where((m) => m['id'] == labelID);
        if(labels.isEmpty){
          continue;
        }else{
          labels_text.add(labels.first['text']);
        }
      }

      taskList.add(
        Task(
            id: map['id'],
            priority: map['priority'],
            text: map['text'],
            projectID: map['projectID'],
            taskType: map['taskType'],
            labels_text: labels_text),
      );
    }
    return taskList;
  }

  static Future<void> updateTask(Task task, List<Label> labelList) async {
    assert(task.id != null);
    final db = await _getDatabase();
    final List<Map<String, dynamic>> taskLabelMaps =
    await db.query('tasklabels', where: 'taskID = ?', whereArgs: [task.id]);
    final List<int> currentLabelIDList = List.generate(taskLabelMaps.length, (i)=>taskLabelMaps[i]['labelID']);
    await db.update(
      'tasks',
      task.toMap(),
      where: "id = ?",
      whereArgs: [task.id],
    );

    for (Label label in labelList) {
      if(label.isSelected && !currentLabelIDList.contains(label.id)){
        await db.insert('taskLabels',
          {'id': null, 'taskID': task.id, 'labelID': label.id},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      if(!label.isSelected && currentLabelIDList.contains(label.id)){
        await db.delete('tasklabels', where: 'taskID = ? AND labelID = ?', whereArgs: [task.id, label.id]);
      }
    }
  }

  static Future<void> deleteTask(int id) async {
    final Database db = await _getDatabase();
    await db.delete('tasklabels', where: 'taskID = ?', whereArgs: [id]);
    await db.delete(
      'tasks',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  //project
  static Future<void> insertProject(Project project) async {
    assert(project.id == null);
    final Database db = await _getDatabase();
    await db.insert(
      'projects',
      project.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Project>> retrieveProjects() async {
    final Database db = await _getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('projects');
    final List<Map<String, dynamic>> taskMaps = await db.query('tasks');

    List<Project> projectList = [];

    for (Map map in maps) {
      final tasks = taskMaps.where((t) => t['projectID'] == map['id']);
      final int numOfTasks = tasks.length;
      projectList.add(
          Project(id: map['id'], text: map['text'], numOfTasks: numOfTasks));
    }
    return projectList;
  }

  static Future<void> updateProject(Project project) async {
    assert(project.id != null);
    final db = await _getDatabase();
    await db.update(
      'projects',
      project.toMap(),
      where: "id = ?",
      whereArgs: [project.id],
    );
  }

  static Future<void> deleteProject(int id) async {
    final Database db = await _getDatabase();

    final List<Map<String, dynamic>> taskMap = await db.query(
      'tasks',
      where: "projectID = ?",
      whereArgs: [id],
    );
    List<int> taskList = List.generate(taskMap.length, (i) {
      return taskMap[i]['id'];
    });

    for (int i in taskList) {
      await db.delete('tasklabels', where: 'taskID = ?', whereArgs: [i]);
    }
    await db.delete(
      'tasks',
      where: "projectID = ?",
      whereArgs: [id],
    );
    await db.delete(
      'projects',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  //label
  static Future<int> insertLabel(Label label) async {
    assert(label.id == null);
    final Database db = await _getDatabase();
    final int id = await db.insert(
      'labels',
      label.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  static Future<List<Label>> retrieveLabels({int taskID = 0}) async {
    final Database db = await _getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('labels');
    final List<Map<String, dynamic>> taskLabelMaps =
        await db.query('tasklabels', where: 'taskID = ?', whereArgs: [taskID]);
    return List.generate(maps.length, (i) {
      bool isSelected = taskLabelMaps.any((m) {
        return m['labelID'] == maps[i]['id'];
      });
      return Label(
          id: maps[i]['id'], text: maps[i]['text'], isSelected: isSelected);
    });
  }

  static Future<void> updateLabel(Label label) async {
    assert(label.id != null);
    final db = await _getDatabase();
    await db.update(
      'labels',
      label.toMap(),
      where: "id = ?",
      whereArgs: [label.id],
    );
  }

  static Future<void> deleteLabel(int id) async {
    final Database db = await _getDatabase();
    await db.delete('tasklabels', where: 'labelID = ?', whereArgs: [id]);
    await db.delete(
      'labels',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}

// ------------------------------------------------

//Task currentTask = Task(-1, '', '');

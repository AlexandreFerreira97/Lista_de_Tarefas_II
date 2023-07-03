import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _toDoController = TextEditingController();

  List _toDoList = [];

  late Map<String, dynamic> _lastRemoved;
  late int _lastRemovedPos;

  @override
  void initState(){
    super.initState();

    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data!);
      });
    });
  }

  void _addToDo(){
      setState(() {
        Map<String, dynamic> newToDo = Map();
        newToDo['title'] = _toDoController;
        _toDoController.text = '';
        newToDo['ok'] = false;
        _toDoList.add(newToDo);
        _saveData();
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tarefas'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _toDoController,
                    decoration: const InputDecoration(
                      labelText: 'Nova Tarefa',
                      labelStyle: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _addToDo,
                  style: ElevatedButton.styleFrom(
                    primary: const Color(0xFF448AFF),
                    padding: const EdgeInsets.only(
                        left: 30.0, top: 12.0, right: 30.0, bottom: 12.0),
                  ),
                  child: const Text('ADD'),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 10.0),
              itemCount: _toDoList.length,
              itemBuilder: buildItem
            ),
          ),
        ],
      ),
    );
  }

Widget buildItem(BuildContext context, int index) {
  return Dismissible(
    key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
    background: Container(
      color: Colors.red,
      child: const Align(
        alignment: Alignment(-0.9,0.0),
        child: Icon(Icons.delete,color: Colors.white,),
      ),
    ),
    direction: DismissDirection.startToEnd,
    child: CheckboxListTile(title: Text(_toDoList[index]['title']),
      value: _toDoList[index]['ok'],
      secondary: CircleAvatar(
        child: Icon(
            _toDoList[index]['ok'] ? Icons.check : Icons.error),
      ),
      onChanged: (bool? value) {
        setState(() {
          _toDoList[index]['ok'] = value;
          _saveData();
        });
      },
    ),
    onDismissed: (direction) {
      setState(() {
        _lastRemoved = Map.from(_toDoList[index]);
        _lastRemovedPos = index;
        _toDoList.removeAt(index);

        _saveData();
        
        final snack = SnackBar(
            content: Text('Tarefa ${_lastRemoved['title']} removida.'),
            action: SnackBarAction(label: 'Desfazer',
              onPressed:() {
                setState(() {
                  _toDoList.insert(_lastRemovedPos, _lastRemoved);
                  _saveData();
                });
              }
            ),
          duration: const Duration(seconds: 2),
        );
       Scaffold.of(context).showSnackBar(snack);
      });
    },
  );
}

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/data.json');
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String?> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}

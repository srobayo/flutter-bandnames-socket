import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/soket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    // Band(id: '1', name: 'Metálica', votes: 5),
    // Band(id: '2', name: 'Queen', votes: 1),
    // Band(id: '3', name: 'Héroes del Silencio', votes: 2),
    // Band(id: '4', name: 'Jhon Von Jovi', votes: 5),
  ];

  @override
  void initState() {
    /// ponermos listen: false porque no necesitamos dibujar nada
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    // final socketService = Provider.of<SocketService>(context, listen: false);
    // socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        actions: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: socketService.serverStatus == ServerStatus.Online
                ? Icon(Icons.check_circle, color: Colors.blue[300])
                : const Icon(Icons.offline_bolt, color: Colors.red),
          )
        ],
        title: const Text(
          'BandNames',
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: Column(
        children: <Widget>[
          if (bands.isNotEmpty) _showGraph(),
          Expanded(
            /// toma todo el espacio que quede en base a la columna (padre)
            child: Container(
              child: ListView.builder(
                itemCount: bands.length,
                // itemBuilder: (context, i) => _bandTitle(bands[i])
                itemBuilder: (BuildContext context, int index) {
                  return _bandTile(bands[index]);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBand,
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,

      /// llamar el borrado en el server
      onDismissed: (_) =>
          socketService.socket.emit('delete-band', {'id': band.id}),
      background: Container(
        padding: const EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Delete Band',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      child: ListTile(
          leading: CircleAvatar(
            child: Text(
              band.name.substring(0, 2),
            ),
            backgroundColor: Colors.blue[100],
          ),
          title: Text(band.name),
          trailing: Text(
            '${band.votes}',
            style: const TextStyle(fontSize: 20),
          ),
          onTap: () {
            socketService.socket.emit('vote-band', {'id': band.id});
          }),
    );
  }

  addNewBand() {
    final textController = TextEditingController();
    if (Platform.isAndroid) {
      // AndroidMode
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('New band name: '),
          content: TextField(
            controller: textController,
          ),
          actions: <Widget>[
            MaterialButton(
              child: const Text('Add'),
              elevation: 5,
              textColor: Colors.blue,
              onPressed: () => addBandToList(textController.text),
            ),
          ],
        ),
      );
    } // Android_Dialog
    showCupertinoDialog(
      context: context,
      builder: (_) {
        return CupertinoAlertDialog(
          title: const Text('New band name'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Add'),
              onPressed: () => addBandToList(textController.text),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Disniss'),
              onPressed: () => addBandToList(textController.text),
            ),
          ],
        );
      },
    );
  }

  void addBandToList(String name) {
    print('at addBandToList: $name');
    if (name.length > 1) {
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.socket.emit('add-band', {'name': name});
    }
    Navigator.pop(context);
  }

  /// Mostrar gráfica
  Widget _showGraph() {
    // final dataMap = <String, double>{
    //   "Flutter": 5,
    //   "React": 3,
    //   "Xamarin": 2,
    //   "Ionic": 2,
    // };

    final colorList = <Color>[
      const Color(0xfffdcb6e),
      const Color(0xff0984e3),
      const Color(0xfffd79a8),
      const Color(0xffe17055),
      const Color(0xff6c5ce7),
      const Color(0xffe75cd4),
    ];

    Map<String, double> dataMap = Map();

    for (var band in bands) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    }

    return Container(
      padding: const EdgeInsets.only(top: 10),
      width: double.infinity,
      height: 180,
      child: PieChart(
        dataMap: dataMap,
        animationDuration: const Duration(microseconds: 800),
        colorList: colorList,
        initialAngleInDegree: 0,
        chartType: ChartType.ring,
      ),
    );
  }
} // end_class_state

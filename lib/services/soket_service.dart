import 'package:flutter/cupertino.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  IO.Socket? _socket; // = IO.io('http://192.168.100.23:3000');
  ServerStatus get serverStatus => _serverStatus;
  IO.Socket get socket => _socket!;
  Function get emit => _socket!.emit;

  SocketService() {
    _initConfig();
  }

  void _initConfig() {
    print('SocketServer ==> _initConfig');
    _socket = IO.io(
        'http://192.168.100.23:3000',
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .enableAutoConnect() // enable auto-connection
            .setExtraHeaders({'foo': 'bar'}) // optional
            .build());
    _socket!.connect();

    _socket!.on('connect', (_) {
      print('connected');
      _serverStatus = ServerStatus.Online;
      notifyListeners();
    });

    _socket!.on('disconnect', (_) {
      print('disconnect');
      _serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

    // socket.on('nuevo-mensaje', (payload) {
    //   print('nuevo-mensaje');
    //   print('nombre:  ' + payload['nombre']);
    //   print('mensaje: ' + payload['mensaje']);
    //   print(payload.containsKey('mensaje2')
    //       ? payload['mensaje2']
    //       : 'No hay mensaje que mostrar');
    // });
  }
} //end_class

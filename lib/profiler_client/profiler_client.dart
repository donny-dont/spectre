
typedef void CaptureCallback(List events);
typedef void CaptureControlCallback(int command, String requester);

class ProfilerClient {
  static final int TypeUserApplication = 0x1;
  static final int TypeProfilerApplication = 0x2;

  static final int StartCapture = 0x1;
  static final int StopCapture = 0x2;
  WebSocket socket;
  String _name;
  CaptureCallback _onCapture;
  CaptureControlCallback _onCaptureControl;
  int _type;
  
  String get name() => _name;
  
  ProfilerClient(this._name, this._onCapture, this._onCaptureControl, this._type) {
    
  }
  
  bool get connected() {
    if (socket == null) {
      return false;
    }
    return socket.readyState == WebSocket.OPEN;
  }
  
  void _onMessage(messageEvent) {
    //print('Got ${messageEvent.data}');
    Map message = JSON.parse(messageEvent.data);
    String command = message['command'];
    if (command == 'identify') {
      var response = {
                      'command':'identity',
                      'name':name,
                      'type':_type
      };
      socket.send(JSON.stringify(response));
      return;
    }
    if (command == 'startCapture') {
      _onCaptureControl(StartCapture, message['requester']);
      return;
    }
    if (command == 'stopCapture') {
      _onCaptureControl(StopCapture, message['requester']);
      return;
    }
    if (command == 'deliverCapture') {
      print('payload = ${message['payload']}');
      _onCapture(message['payload']);
      return;
    }
  }
  
  void connect(String url) {
    socket = new WebSocket(url);
    socket.on.message.add(_onMessage);
  }
  
  void startCapture(String target) {
    print('startCapture $target');
    var response = {
                    'command':'startCapture',
                    'target':target
    };
    socket.send(JSON.stringify(response));
  }
  
  void stopCapture(String target) {
    print('stopCapture $target');
    var response = {
                    'command':'stopCapture',
                    'target':target
    };
    socket.send(JSON.stringify(response));
  }
  
  void deliverCapture(String target, List capture) {
    print('deliverCapture $target');
    var response = {
                    'command':'deliverCapture',
                    'target':target,
                    'payload':capture,
    };
    socket.send(JSON.stringify(response));
  }
}

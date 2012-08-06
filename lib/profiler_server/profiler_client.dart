/*

  Copyright (C) 2012 John McCutchan <john@johnmccutchan.com>

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.

*/

class _ProfilerClient implements Hashable {
  static final int TypeUninitialized = 0x0;
  static final int TypeUserApplication = 0x1;
  static final int TypeProfilerApplication = 0x2;
  
  ProfilerServer server;
  int type;
  String name;
  WebSocketConnection connection;
  
  int hashCode() => connection.hashCode();
  bool equals(_ProfilerClient b) => connection == b.connection;
  
  _ProfilerClient(this.connection, this.server) {
    name = 'Unnamed';
    type = TypeUninitialized;
    connection.onClosed = _onClosed;
    connection.onError = _onError;
    connection.onMessage = _onMessage;
  }
  
  void identifyClient() {
    var request = {
                   'command': 'identify'
    };
    connection.send(JSON.stringify(request));
  }
  
  void _onClosed(int status, String reason) {
    print('closed');
    server._clientClose(this);
  }
  
  void _onError(e) {
    print('error');
    server._clientClose(this);
  }
  
  void _onMessage(String messageString) {
    print('$messageString');
    Map message = JSON.parse(messageString);
    if (type == TypeUninitialized) {
      if (message['command'] == 'identity') {
        name = message['name'];
        type = message['type'];
      }
      return;
    }
    String command = message['command'];
    switch (command) {
      case 'deliverCapture':
      {
        String target = message['target'];
        String payload = message['payload'];
        server._dispatch(target, payload);
      }
      break;
      case 'startCapture':
      {
        String target = message['target'];
        var request = {
                       'command': 'startCapture',
                       'requester': name
        };
        server._dispatch(target, JSON.stringify(request));
      }
      break;
      case 'stopCapture':
      {
        String target = message['target'];
        var request = {
                       'command': 'stopCapture',
                       'requester': name
        };
        server._dispatch(target, JSON.stringify(request));
      }
      break;
    }
  }
}

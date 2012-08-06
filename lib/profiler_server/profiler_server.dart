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

class ProfilerServer {
  HttpServer server;
  WebSocketHandler webSocketHandler;
  Set<_ProfilerClient> clients;
  
  ProfilerServer() {
    server = new HttpServer();
    webSocketHandler = new WebSocketHandler();
    webSocketHandler.onOpen = _connectionOpened;
    server.defaultRequestHandler = webSocketHandler.onRequest;
    clients = new Set<_ProfilerClient>();
  }
  
  void _connectionOpened(WebSocketConnection connection) {
    print('got connection');
    _ProfilerClient client = new _ProfilerClient(connection, this);
    clients.add(client);
    client.identifyClient();
  }
  
  void listen(String host, int port) {
    server.listen(host, port);
  }
  
  _ProfilerClient findClientWithName(String name) {
    for (_ProfilerClient client in clients) {
      if (client.name == name) {
        return client;
      }
    }
    return null;
  }
  
  void _clientClose(_ProfilerClient client) {
    clients.remove(client);
  }
  
  void _dispatch(String name, String message) {
    _ProfilerClient client = findClientWithName(name);
    if (client == null) {
      return;
    }
    client.connection.send(message);
  }
}

#import('../lib/profiler_server.dart');

class ProfServe {
  ProfilerServer server;
  
  ProfServe() {
    server = new ProfilerServer();
  }
  
  void run(String hostname, int port) {
    server.listen(hostname, port);
  }
}

void main() {
  ProfServe ps = new ProfServe();
  String host = '127.0.0.1';
  int port = 8087;
  print('Waiting on $host $port');
  ps.run(host, port);
}
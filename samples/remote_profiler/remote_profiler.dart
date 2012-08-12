#import('dart:html');
#import('../../lib/profiler.dart');
#import('../../lib/profiler_client.dart');
#import('../../lib/profiler_gui.dart');

class RemoteProfiler {
  ProfilerClient profilerClient;
  ProfilerTree profilerTree;
  int _timer;
  
  RemoteProfiler() {
    profilerClient = new ProfilerClient('RemoteProfiler', onCapture, onCaptureControl, ProfilerClient.TypeProfilerApplication);
    profilerTree = new ProfilerTree();
    _timer = 0;
  }
  
  void onCapture(List data) {
    profilerTree.resetStatistics();
    profilerTree.processRemoteEvents(data);
    refreshProfiler();
  }
  
  void onCaptureControl(int command, String requester) {
    print('control $command from $requester');
  }
  
  void refreshProfiler() {
    final String divName = '#TableView';
    DivElement d = document.query(divName);
    d.nodes.clear();
    Element gui = ProfilerTreeListGUI.buildTree(profilerTree);
    if (gui != null) {
      d.nodes.add(gui);
    }
  }
  
  void updateStatus(String message) {
    // the HTML library defines a global "document" variable
    document.query('#DartStatus').innerHTML = message;
  }
  
  void _enableButtons() {
    document.query("#StartCapture").on.click.add((Event event) {
      profilerClient.startCapture('Javeline');
    });
    document.query("#StopCapture").on.click.add((Event event) {
      profilerClient.stopCapture('Javeline');
    });
    document.query("#AutoCapture").on.click.add((Event event) {
      if (_timer != 0) {
        window.clearInterval(_timer);
        _timer = 0;
        document.query("#AutoCapture").classes.remove('ButtonOn');
        document.query("#AutoCapture").classes.add('ButtonOff');
      } else {
        document.query("#AutoCapture").classes.remove('ButtonOff');
        document.query("#AutoCapture").classes.add('ButtonOn');
        _timer = window.setInterval(() {
          profilerClient.stopCapture('Javeline');
          profilerClient.startCapture('Javeline');
        }, 500);
      }
    });
  }
  void run() {
    updateStatus('Dart is running!');
    profilerClient.connect('ws://127.0.0.1:8087/');
    _enableButtons();
  }
}

void main() {
  RemoteProfiler rp = new RemoteProfiler();
  rp.run();
}
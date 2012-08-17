#import('dart:html');
#import('../../lib/profiler.dart');
#import('../../lib/profiler_client.dart');
#import('../../lib/profiler_gui.dart');

class _TimelineRange {
  int start;
  int end;
  _TimelineRange(this.start, this.end);
  String get width() => '${end - start}px';
}

class _TimelineMarker implements Hashable {
  String name;
  List<_TimelineRange> range;
  int hashCode() => name.hashCode();
  bool equals(_TimelineMarker b) => name == b.name;
  _TimelineMarker(this.name) {
    range = new List<_TimelineRange>();
  }
}

class TimelineControl {
  DivElement _rootDiv;
  num _baseTime;
  Map<String, _TimelineMarker> _markers;
  List<_TimelineMarker> _markerStack;
  List<int> _markerTimeStack;
  
  TimelineControl(String divId) {
    _rootDiv = document.query(divId);
    _markers = new Map<String, _TimelineMarker>();
    _markerStack = new List<_TimelineMarker>();
    _markerTimeStack = new List<int>();
  }
  
  void parseEvents(List<Map> events) {
    for (Map event in events) {
      int code = event['event'];
      String name = event['name'];
      num now = event['now'];
      if (_baseTime == null) {
        _baseTime = now;
      }
      if (code == 1) {
        // Push
        _TimelineMarker currentMarker = _markers[name];
        if (currentMarker == null) {
          // First time
          currentMarker = new _TimelineMarker(name);
          _markers[name] = currentMarker;
        }
        _markerTimeStack.addLast(now);
        _markerStack.addLast(currentMarker);
      } else if (code == 2) {
        // Pop
        int pushTime = _markerTimeStack.removeLast();
        _TimelineMarker currentMarker = _markerStack.removeLast();
        _TimelineRange range = new _TimelineRange(pushTime - _baseTime, now - _baseTime);
        print('${range.width}');
        currentMarker.range.addLast(range);
      }
    }
    print('${_markerTimeStack.length} ${_markerStack.length}');
    print('${_markers.length}');
  }
  
  DivElement makeViewRow(String name) {
    DivElement r = new DivElement();
    DivElement p = new DivElement();
    DivElement tl = new DivElement();
    p.innerHTML = '<p>$name</p>';
    p.classes.add('TimelineLabel');
    tl.classes.add('TimelineRanges');
    r.nodes.add(p);
    r.nodes.add(tl);
    return r;
  }
  
  DivElement makeViewTimelineRange(_TimelineRange tlRange, int left) {
    DivElement range = new DivElement();
    range.classes.add('TimelineRange');
    range.style.width = '${tlRange.end - tlRange.start}px';
    range.style.height = '10px';
    range.style.left = '${left}px';
    return range;
  }
  
  void refreshView() {
    _rootDiv.nodes.clear();
    _markers.forEach((String name, _TimelineMarker marker) {
      DivElement row = makeViewRow(name);
      DivElement ranges = row.nodes[1];
      int left = 0;
      marker.range.forEach((_TimelineRange tlRange) {
        left += tlRange.start;
        DivElement range = makeViewTimelineRange(tlRange, left-tlRange.start);
        ranges.nodes.add(range);
      });
      _rootDiv.nodes.add(row);
    });
  }
}

class RemoteProfiler {
  ProfilerClient profilerClient;
  ProfilerTree profilerTree;
  int _timer;
  List _bakedEvents;
  TimelineControl _control;
  
  RemoteProfiler() {
    profilerClient = new ProfilerClient('RemoteProfiler', onCapture, onCaptureControl, ProfilerClient.TypeProfilerApplication);
    profilerTree = new ProfilerTree();
    _timer = 0;
    _bakedEvents = [{"event":1,"name":"DebugDrawManager.update","now":1344434405023558},{"event":1,"name":"lines","now":1344434405023586},{"event":1,"name":"depth enabled","now":1344434405023602},{"event":1,"name":"update","now":1344434405023616},{"event":2,"name":null,"now":1344434405023977},{"event":2,"name":null,"now":1344434405023992},{"event":1,"name":"depth disabled","now":1344434405024005},{"event":1,"name":"update","now":1344434405024018},{"event":2,"name":null,"now":1344434405024031},{"event":2,"name":null,"now":1344434405024044},{"event":2,"name":null,"now":1344434405024056},{"event":2,"name":null,"now":1344434405024077},{"event":1,"name":"DebugDrawManager.prepareForRender","now":1344434405024855},{"event":2,"name":null,"now":1344434405026105},{"event":1,"name":"DebugDrawManager.render","now":1344434405026122},{"event":2,"name":null,"now":1344434405026848},{"event":1,"name":"DebugDrawManager.update","now":1344434405038184},{"event":1,"name":"lines","now":1344434405038213},{"event":1,"name":"depth enabled","now":1344434405038227},{"event":1,"name":"update","now":1344434405038242},{"event":2,"name":null,"now":1344434405038585},{"event":2,"name":null,"now":1344434405038612},{"event":1,"name":"depth disabled","now":1344434405038626},{"event":1,"name":"update","now":1344434405038640},{"event":2,"name":null,"now":1344434405038655},{"event":2,"name":null,"now":1344434405038667},{"event":2,"name":null,"now":1344434405038680},{"event":2,"name":null,"now":1344434405038705},{"event":1,"name":"DebugDrawManager.prepareForRender","now":1344434405039603},{"event":2,"name":null,"now":1344434405041016},{"event":1,"name":"DebugDrawManager.render","now":1344434405041049},{"event":2,"name":null,"now":1344434405042510},{"event":1,"name":"DebugDrawManager.update","now":1344434405051959},{"event":1,"name":"lines","now":1344434405051986},{"event":1,"name":"depth enabled","now":1344434405052001},{"event":1,"name":"update","now":1344434405052016},{"event":2,"name":null,"now":1344434405052361},{"event":2,"name":null,"now":1344434405052380},{"event":1,"name":"depth disabled","now":1344434405052394},{"event":1,"name":"update","now":1344434405052408},{"event":2,"name":null,"now":1344434405052423},{"event":2,"name":null,"now":1344434405052437},{"event":2,"name":null,"now":1344434405052451},{"event":2,"name":null,"now":1344434405052475},{"event":1,"name":"DebugDrawManager.prepareForRender","now":1344434405053325},{"event":2,"name":null,"now":1344434405054730},{"event":1,"name":"DebugDrawManager.render","now":1344434405054759},{"event":2,"name":null,"now":1344434405055643}];
    _control = new TimelineControl("#TimelineView");
    _control.parseEvents(_bakedEvents);
    _control.refreshView();
  }
  
  void onCapture(List data) {
    profilerTree.resetStatistics();
    print('$data');
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
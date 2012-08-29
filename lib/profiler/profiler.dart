class ProfilerEvent {
  static final int Enter = 0x1;
  static final int Exit = 0x2;
  static final int FrameStart = 0x3;
  static final int FrameEnd = 0x4;
  int event;
  String name;
  int now;
  
  ProfilerEvent(this.event, this.name, this.now);
  
  Map serialize() {
    var response = {
                    'event':event,
                    'name':name,
                    'now':now,
    };
    return response;
  }
}

class Profiler {
  static init() {
    events = new Queue<ProfilerEvent>();
    frameCounter = 0;
  }
  
  static int frameCounter;
  static Queue<ProfilerEvent> events;
  
  static enter(String name) {
    ProfilerEvent event = new ProfilerEvent(ProfilerEvent.Enter, name, 0);
    events.add(event);
  }
  
  static exit() {
    ProfilerEvent event = new ProfilerEvent(ProfilerEvent.Exit, null, 0);
    events.add(event);
  }
  
  static frameStart() {
    ProfilerEvent event = new ProfilerEvent(ProfilerEvent.FrameStart, 'Frame $frameCounter', 0);
    events.add(event);
  }
  
  static frameEnd() {
    ProfilerEvent event = new ProfilerEvent(ProfilerEvent.FrameEnd, 'Frame $frameCounter', 0);
    events.add(event);
    frameCounter++;
  }
  
  static List makeCapture() {
    List<Map> capture = new List<Map>();
    for (ProfilerEvent pe in events) {
      capture.add(pe.serialize());
    }
    return capture;
  }
  
  static clear() {
    events.clear();
  }
}
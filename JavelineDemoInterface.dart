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

class JavelineDemoStatus {
  static final int DemoStatusOKAY = 0;
  static final int DemoStatusError = 1;
  JavelineDemoStatus(this.code, this.text);
  int code;
  String text;
}

interface JavelineDemoInterface {
  bool get shouldQuit();
  
  Future<JavelineDemoStatus> startup();
  Future<JavelineDemoStatus> shutdown();
  
  void run();
  
  void update(num time, num dt);
  
  void keyboardEventHandler(KeyboardEvent event, bool down);
  void mouseMoveEventHandler(MouseEvent event);
  void mouseButtonEventHandler(MouseEvent event, bool down);
}

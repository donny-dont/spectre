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

class JavelineMouseButtonCodes {
  static final int MouseButtonLeft = 0;
  static final int MouseButtonMid = 1;
  static final int MouseButtonRight = 2;
  
  static final int NumMouseButtonCodes = 3;
}

class JavelineMouse {
  List<bool> _buttons;
  int _accumDX;
  int _accumDY;
  int _X;
  int _Y;
  
  JavelineMouse() {
    _accumDX = 0;
    _accumDY = 0;
    _X = 0;
    _Y = 0;
    _buttons = new List<bool>(JavelineMouseButtonCodes.NumMouseButtonCodes);
    for (int i = 0; i < JavelineMouseButtonCodes.NumMouseButtonCodes; i++) {
      _buttons[i] = false;
    }
  }
  
  bool pressed(int mouseButtonCode) {
    return _buttons[mouseButtonCode];
  }
  
  mouseButtonEvent(MouseEvent event, bool down) {
    _buttons[event.button] = down;
  }
  
  mouseMoveEvent(MouseEvent event) {
    _accumDX += event.webkitMovementX;
    _accumDY += event.webkitMovementY;
    _X = event.screenX;
    _Y = event.screenY;
  }
  
  int get accumulatedDX() => _accumDX;
  int get accumulatedDY() => _accumDY;
  
  int get X() => _X;
  int get Y() => _Y;
  
  void resetAccumulator() {
    _accumDX = 0;
    _accumDY = 0;
  }
}
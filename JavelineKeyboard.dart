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

class JavelineKeyCodes {
  static final int KeyTab = 9;
  
  static final int KeyShift = 16;
  static final int KeyControl = 17;
  static final int KeyAlt = 18;
  
  static final int KeySpace = 32;
  static final int KeyPageUp = 33;
  static final int KeyPageDown = 34;
  static final int KeyEnd = 35;
  static final int KeyHome = 36;
  static final int KeyLeft = 37;
  static final int KeyUp = 38;
  static final int KeyRight = 39;
  static final int KeyDown = 40;
  
  static final int Key0 = 48;
  static final int Key1 = 49;
  static final int Key2 = 50;
  static final int Key3 = 51;
  static final int Key4 = 52;
  static final int Key5 = 53;
  static final int Key6 = 54;
  static final int Key7 = 55;
  static final int Key8 = 56;
  static final int Key9 = 57;
  
  static final int KeyA = 65;
  static final int KeyB = 66;
  static final int KeyC = 67;
  static final int KeyD = 68;
  static final int KeyE = 69;
  static final int KeyF = 70;
  static final int KeyG = 71;
  static final int KeyH = 72;
  static final int KeyI = 73;
  static final int KeyJ = 74;
  static final int KeyK = 75;
  static final int KeyL = 76;
  static final int KeyM = 77;
  static final int KeyN = 78;
  static final int KeyO = 79;
  static final int KeyP = 80;
  static final int KeyQ = 81;
  static final int KeyR = 82;
  static final int KeyS = 83;
  static final int KeyT = 84;
  static final int KeyU = 85;
  static final int KeyV = 86;
  static final int KeyW = 87;
  static final int KeyX = 88;
  static final int KeyY = 89;
  static final int KeyZ = 90;
}

class JavelineKeyboard {
  Map<int, bool> keyboardState;
  
  JavelineKeyboard() {
    keyboardState = new Map<int, bool>();
  }
  
  bool pressed(int keycode) {
    bool r = keyboardState[keycode];
    if (r == null) {
      // Never seen
      return false;
    }
    return r;
  }
  
  void keyboardEvent(KeyboardEvent event, bool down) {
    keyboardState[event.keyCode] = down;
  }
}

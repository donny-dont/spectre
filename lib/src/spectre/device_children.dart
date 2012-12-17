part of spectre;

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

/// A resource created by a device
/// All resources have a [name]

class DeviceChild implements Hashable {
  static final int StatusDirty = 0x1;
  static final int StatusReady = 0x2;

  String name;
  GraphicsDevice device;
  int _status;
  DeviceChild fallback;

  String toString() => name;

  void set dirty(bool r) {
    if (r) {
      _status |= StatusDirty;
    } else {
      _status &= ~StatusDirty;
    }
  }
  bool get dirty => (_status & StatusDirty) != 0;
  void set ready(bool r) {
    if (r) {
      _status |= StatusReady;
    } else {
      _status &= ~StatusReady;
    }
  }
  bool get ready => (_status & StatusReady) != 0;

  DeviceChild._internal(this.name, this.device) {
    _status = 0;
    ready = true;
    dirty = false;
  }

  int get hashCode {
    return name.hashCode;
  }

  bool equals(DeviceChild b) => name == b.name && device == b.device;

  void _createDeviceState() {
  }
  void _destroyDeviceState() {
  }
}




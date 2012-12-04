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

/// Rendering viewport
/// Create using [Device.createViewport]
/// Set using [ImmediateContext.setViewport]
class Viewport extends DeviceChild {
  int x;
  int y;
  int width;
  int height;

  Viewport(String name, GraphicsDevice device) : super._internal(name, device) {
    x = 0;
    y = 0;
    width = 640;
    height = 480;
  }

  void _createDeviceState() {
  }

  void _configDeviceState(Map props) {
    if (props != null) {
      dynamic o;
      o = props['x'];
      x = o != null ? o : x;
      o = props['y'];
      y = o != null ? o : y;
      o = props['width'];
      width = o != null ? o : width;
      o = props['height'];
      height = o != null ? o : height;
    }
  }

  void _destroyDeviceState() {
  }
}

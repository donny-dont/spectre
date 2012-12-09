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

/// RasterizerState controls how the GPU rasterizer functions including primitive culling and width of rasterized lines
/// Create using [Device.createRasterizerState]
/// Set using [ImmediateContext.setRasterizerState]
class RasterizerState extends DeviceChild {
  static const int CullFront = WebGLRenderingContext.FRONT;
  static const int CullBack = WebGLRenderingContext.BACK;
  static const int CullFrontAndBack = WebGLRenderingContext.FRONT_AND_BACK;
  static const int FrontCW = WebGLRenderingContext.CW;
  static const int FrontCCW = WebGLRenderingContext.CCW;

  bool cullEnabled;
  int cullMode;
  int cullFrontFace;

  num lineWidth;

  RasterizerState(String name, GraphicsDevice device) : super._internal(name, device) {
    cullEnabled = false;
    cullMode = CullBack;
    cullFrontFace = FrontCCW;
    lineWidth = 1.0;
  }

  void _createDeviceState() {

  }

  dynamic filter(dynamic o) {
    if (o is String) {
      var table = {
       "CullFront": WebGLRenderingContext.FRONT,
       "CullBack": WebGLRenderingContext.BACK,
       "CullFrontAndBack": WebGLRenderingContext.FRONT_AND_BACK,
       "FrontCW": WebGLRenderingContext.CW,
       "FrontCCW": WebGLRenderingContext.CCW,
      };
      return table[o];
    }
    return o;
  }
  void _configDeviceState(Map props) {
    if (props != null) {
      dynamic o;

      o = props['cullEnabled'];
      cullEnabled = o != null ? filter(o) : cullEnabled;
      o = props['cullMode'];
      cullMode = o != null ? filter(o) : cullMode;
      o = props['cullFrontFace'];
      cullFrontFace = o != null ? filter(o) : cullFrontFace;
      o = props['lineWidth'];
      lineWidth = o != null ? filter(o) : lineWidth;
    }
  }

  void _destroyDeviceState() {

  }
}

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

/// DepthState controls depth testing and writing to a depth buffer
/// Create using [Device.createDepthState]
/// Set using [ImmediateContext.setDepthState]
class DepthState extends DeviceChild {
  static const int DepthComparisonOpNever = WebGLRenderingContext.NEVER;
  static const int DepthComparisonOpAlways = WebGLRenderingContext.ALWAYS;
  static const int DepthComparisonOpEqual = WebGLRenderingContext.EQUAL;
  static const int DepthComparisonOpNotEqual = WebGLRenderingContext.NOTEQUAL;

  static const int DepthComparisonOpLess = WebGLRenderingContext.LESS;
  static const int DepthComparisonOpLessEqual = WebGLRenderingContext.LEQUAL;
  static const int DepthComparisonOpGreaterEqual = WebGLRenderingContext.GEQUAL;
  static const int DepthComparisonOpGreater = WebGLRenderingContext.GREATER;

  bool depthTestEnabled = false;
  bool depthWriteEnabled = false;
  bool polygonOffsetEnabled = false;

  num depthNearVal = 0.0;
  num depthFarVal = 1.0;
  num polygonOffsetFactor = 0.0;
  num polygonOffsetUnits = 0.0;

  int depthComparisonOp = DepthComparisonOpAlways;

  DepthState(String name, GraphicsDevice device)
      : super._internal(name, device);

  dynamic filter(dynamic o) {
    if (o is String) {
      Map table = {
        "DepthComparisonOpNever": WebGLRenderingContext.NEVER,
        "DepthComparisonOpAlways": WebGLRenderingContext.ALWAYS,
        "DepthComparisonOpEqual": WebGLRenderingContext.EQUAL,
        "DepthComparisonOpNotEqual": WebGLRenderingContext.NOTEQUAL,
        "DepthComparisonOpLess": WebGLRenderingContext.LESS,
        "DepthComparisonOpLessEqual": WebGLRenderingContext.LEQUAL,
        "DepthComparisonOpGreaterEqual": WebGLRenderingContext.GEQUAL,
        "DepthComparisonOpGreater": WebGLRenderingContext.GREATER,
      };
      return table[o];
    }
    return o;
  }
}

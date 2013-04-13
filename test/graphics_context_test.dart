/*
  Copyright (C) 2013 Spectre Authors

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

library graphics_context_test;

import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:spectre/spectre.dart';
import 'mock_graphics_device.dart';
import 'mock_webgl_rendering_context.dart';
import 'dart:html';
import 'dart:web_gl' as WebGL;

part 'graphics_context_buffer_test.dart';
part 'graphics_context_state_test.dart';

//---------------------------------------------------------------------
// Test entry point
//---------------------------------------------------------------------

void main() {
  test('construction', () {
    MockWebGLRenderingContext gl = new MockWebGLRenderingContext();
    MockGraphicsDevice graphicsDevice = new MockGraphicsDevice(gl);
    GraphicsContext graphicsContext = new GraphicsContext(graphicsDevice);

    // Make sure reset was called
    verifyInitialPipelineState(graphicsDevice, gl);
  });

  // Buffer tests
  testIndexBuffer();

  // State tests
  testViewport();
  testBlendState();
  testDepthState();
  testRasterizerState();
}

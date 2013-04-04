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

library mock_graphics_device;

import 'dart:html';
import 'dart:web_gl' as WebGL;
import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:spectre/spectre.dart';
import 'mock_webgl_rendering_context.dart';

/// Mock implementation of [GraphicsDeviceCapabilities].
class MockGraphicsDeviceCapabilities extends Mock implements GraphicsDeviceCapabilities {
  /// Creates an instance of [MockGraphicsDeviceCapabilities].
  ///
  /// The value [hasExtensions] is used to turn on/off all extensions.
  MockGraphicsDeviceCapabilities(bool hasExtensions) {
    double maxAnisotropyLevel = (hasExtensions) ? 16.0 : 1.0;

    when(callsTo('get maxAnisotropyLevel')).alwaysReturn(maxAnisotropyLevel);
  }
}

/// Mock implementation of [GraphicsDevice].
class MockGraphicsDevice extends Mock implements GraphicsDevice {
  GraphicsDeviceCapabilities _capabilities;
  WebGL.RenderingContext _gl;

  /// Initializes an instance of [MockGraphicsDevice].
  ///
  /// Allows the [WebGLRenderingContext] to be explictly set. This would be
  /// used to pass in a [MockWebGLRenderingContext] that can later be queried for
  /// information.
  MockGraphicsDevice(WebGL.RenderingContext gl, [hasExtensions = true])
    : _gl = gl
    , _capabilities = new MockGraphicsDeviceCapabilities(hasExtensions);

  /// Initializes an instance of [MockGraphicsDevice].
  ///
  /// Creates an instance using [MockWebGLRenderingContext] and [MockGraphicsDeviceCapabilities]
  /// with all extensions enabled.
  MockGraphicsDevice.useMock()
    : _gl = new MockWebGLRenderingContext()
    , _capabilities = new MockGraphicsDeviceCapabilities(true);

  WebGL.RenderingContext get gl => _gl;
  GraphicsDeviceCapabilities get capabilities => _capabilities;
}

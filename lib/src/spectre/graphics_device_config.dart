/*
  Copyright (C) 2013 John McCutchan

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

part of spectre;

/// Specifies the configuration of the [GraphicsDevice].
///
/// When creating a [WebGL.RenderingContext] there are various options that can
/// be passed in to specify the configuration. These options can only be
/// specified when the [GraphicsDevice] is created. Afterwards they cannot be
/// modified.
///
/// It should be noted that the underlying WebGL implementation takes these
/// values as a suggestion. If the underlying hardware does not support the
/// configuration it will be ignored. After creating the [GraphicsDevice] the
/// [GraphicsDeviceCapabilities] should be queried directly.
///
///     GraphicsDeviceConfig config = new GraphicsDeviceConfig();
///     config.stencilBuffer = true;
///
///     GraphicsDevice device = new GraphicsDevice(surface, config);
///     print('Has stencil ${device.capabilities.stencilBuffer}');
class GraphicsDeviceConfig {
  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// Whether a stencil buffer should be used.
  bool _stencilBuffer = false;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /// Creates an instance of the [GraphicsDeviceConfig] class.
  ///
  /// The default values of [WebGL.ContextAttributes] are used.
  ///
  ///    GraphicsDeviceConfig config = new GraphicsDeviceConfig();
  ///    config.stencil = false;
  GraphicsDeviceConfig();

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// Whether a stencil buffer should be created.
  bool get stencilBuffer => _stencilBuffer;
  set stencilBuffer(bool value) { _stencilBuffer = value; }
}

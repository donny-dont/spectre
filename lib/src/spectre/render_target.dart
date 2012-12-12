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

/** A [RenderTarget] controls where color, depth, and stencil data is output
 * to by the GPU.
 *
 * NOTE: To output into the system provided render target see
 * [RenderTarget.systemRenderTarget]
 */
class RenderTarget extends DeviceChild {
  final int _target = WebGLRenderingContext.FRAMEBUFFER;
  final int _target_param = WebGLRenderingContext.FRAMEBUFFER_BINDING;

  WebGLFramebuffer _buffer;
  DeviceChild _colorTarget;
  DeviceChild _depthTarget;
  DeviceChild get colorTarget => _colorTarget;
  DeviceChild get depthTarget => _depthTarget;
  DeviceChild get stencilTarget => null;

  static RenderTarget _systemRenderTarget;
  /** System provided rendering target */
  static RenderTarget get systemRenderTarget => _systemRenderTarget;

  bool _renderable = false;
  /** Is the render target valid and renderable? */
  bool get renderable => _renderable;

  RenderTarget(String name, GraphicsDevice device) :
    super._internal(name, device) {
  }

  void _createDeviceState() {
    super._createDeviceState();
    _buffer = device.gl.createFramebuffer();
  }

  void _configDeviceState(Map props) {
    if (props == null) {
      return;
    }
    DeviceChild colorHandle = props['color0'] != null ? props['color0'] : null;
    DeviceChild depthHandle = props['depth'] != null ? props['depth'] : null;
    DeviceChild stencilHandle = props['stencil'] != null ? props['stencil'] : null;
    if (stencilHandle != null) {
      spectreLog.Error('No support for stencil buffers yet.');
    }

    colorTarget = colorHandle;
    depthTarget = depthHandle;

    _updateStatus();
  }

  void _destroyDeviceState() {
    if (_buffer != null) {
      device.gl.deleteFramebuffer(_buffer);
      _buffer = null;
    }
    _renderable = false;
    super._destroyDeviceState();
  }

  void _updateStatus() {
    WebGLFramebuffer oldBind = device.gl.getParameter(_target_param);
    device.gl.bindFramebuffer(_target, _buffer);
    int fbStatus = device.gl.checkFramebufferStatus(_target);
    _renderable = fbStatus == WebGLRenderingContext.FRAMEBUFFER_COMPLETE;
    device.gl.bindFramebuffer(_target, oldBind);
  }

  /** Set color buffer output to be [color0].
   *
   * null indicates the system provided color buffer.
   * [Texture2D] is supported.
   * [RenderBuffer] is supported.
   */
  set colorTarget(dynamic color0) {
    WebGLFramebuffer oldBind = device.gl.getParameter(_target_param);
    device.gl.bindFramebuffer(_target, _buffer);
    if (color0 == null) {
      _colorTarget = null;
      device.gl.framebufferRenderbuffer(_target,
                                        WebGLRenderingContext.COLOR_ATTACHMENT0,
                                        WebGLRenderingContext.RENDERBUFFER,
                                        null);
      device.gl.bindFramebuffer(WebGLRenderingContext.FRAMEBUFFER, oldBind);
      return;
    }
    if (color0 is RenderBuffer) {
      RenderBuffer rb = color0 as RenderBuffer;
      _colorTarget = rb;
      device.gl.framebufferRenderbuffer(_target,
                                        WebGLRenderingContext.COLOR_ATTACHMENT0,
                                        WebGLRenderingContext.RENDERBUFFER,
                                        rb._buffer);
    } else if (color0 is Texture2D) {
      Texture2D t2d = color0   as Texture2D;
      _colorTarget = t2d;
      device.gl.framebufferTexture2D(_target,
                                     WebGLRenderingContext.COLOR_ATTACHMENT0,
                                     WebGLRenderingContext.TEXTURE_2D,
                                     t2d._buffer, 0);
    } else {
      throw new FallthroughError();
    }
    _updateStatus();
    device.gl.bindFramebuffer(_target, oldBind);
  }

  /** Set depth buffer output to be [depth].
   *
   * null indicates the system provided depth buffer.
   * [Texture2D] is supported.
   * [RenderBuffer] is supported.
   */
  set depthTarget(dynamic depth) {
    WebGLFramebuffer oldBind = device.gl.getParameter(_target_param);
    device.gl.bindFramebuffer(_target, _buffer);
    if (depth == null) {
      _depthTarget = null;
      device.gl.framebufferRenderbuffer(_target,
                                        WebGLRenderingContext.DEPTH_ATTACHMENT,
                                        WebGLRenderingContext.RENDERBUFFER,
                                        null);
      device.gl.bindFramebuffer(WebGLRenderingContext.FRAMEBUFFER, oldBind);
      return;
    }
    if (depth is RenderBuffer) {
      RenderBuffer rb = depth as RenderBuffer;
      _depthTarget = rb;
      device.gl.framebufferRenderbuffer(_target,
                                        WebGLRenderingContext.DEPTH_ATTACHMENT,
                                        WebGLRenderingContext.RENDERBUFFER,
                                        rb._buffer);
    } else if (depth is Texture2D) {
      Texture2D t2d = depth as Texture2D;
      _depthTarget = t2d;
      device.gl.framebufferTexture2D(_target,
                                     WebGLRenderingContext.DEPTH_ATTACHMENT,
                                     WebGLRenderingContext.TEXTURE_2D,
                                     t2d._buffer, 0);
    } else {
      throw new FallthroughError();
    }
    _updateStatus();
    device.gl.bindFramebuffer(_target, oldBind);
  }
}

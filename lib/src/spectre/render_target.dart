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

/** A [RenderTarget] configures the final output stage of the GPU pipeline.
 * Color, depth, and stencil outputs are specified here.
 *
 * NOTE: The system provided RenderTarget can be access via
 * [Device.systemProvidedRenderTarget].
 */
class RenderTarget extends DeviceChild {
  static final int _target = WebGLRenderingContext.FRAMEBUFFER;
  static final int _target_param = WebGLRenderingContext.FRAMEBUFFER_BINDING;

  WebGLFramebuffer _buffer;
  DeviceChild _colorTarget;
  DeviceChild _depthTarget;
  DeviceChild get colorTarget => _colorTarget;
  DeviceChild get depthTarget => _depthTarget;
  DeviceChild get stencilTarget => null;

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
    if (props['SystemProvided'] == true) {
      device.gl.deleteFramebuffer(_buffer);
      _buffer = null;
      return;
    }
    DeviceChild colorHandle = props['color0'] != null ? props['color0'] : null;
    DeviceChild depthHandle = props['depth'] != null ? props['depth'] : null;
    DeviceChild stencilHandle = props['stencil'] != null ? props['stencil'] : null;
    if (stencilHandle != null) {
      spectreLog.Error('No support for stencil buffers yet.');
    }

    attachColorTarget(colorHandle);
    attachDepthTarget(depthHandle);

    WebGLFramebuffer oldBind = device.gl.getParameter(_target_param);
    device.gl.bindFramebuffer(_target, _buffer);
    int fbStatus = device.gl.checkFramebufferStatus(_target);
    if (fbStatus != WebGLRenderingContext.FRAMEBUFFER_COMPLETE) {
      spectreLog.Error('RenderTarget $name incomplete status = $fbStatus');
    } else {
      spectreLog.Info('RenderTarget $name complete.');
    }
    device.gl.bindFramebuffer(_target, oldBind);
  }

  void attachColorTarget(dynamic colorTexture) {
    WebGLFramebuffer oldBind = device.gl.getParameter(_target_param);
    device.gl.bindFramebuffer(_target, _buffer);
    if (colorTexture == null) {
      _colorTarget = null;
      device.gl.framebufferRenderbuffer(_target,
                                        WebGLRenderingContext.COLOR_ATTACHMENT0,
                                        WebGLRenderingContext.RENDERBUFFER,
                                        null);
      device.gl.bindFramebuffer(WebGLRenderingContext.FRAMEBUFFER, oldBind);
      return;
    }
    if (colorTexture is RenderBuffer) {
      RenderBuffer rb = colorTexture as RenderBuffer;
      _colorTarget = rb;
      device.gl.framebufferRenderbuffer(_target,
                                        WebGLRenderingContext.COLOR_ATTACHMENT0,
                                        WebGLRenderingContext.RENDERBUFFER,
                                        rb._buffer);
    } else if (colorTexture is Texture2D) {
      Texture2D t2d = colorTexture as Texture2D;
      _colorTarget = t2d;
      device.gl.framebufferTexture2D(_target,
                                     WebGLRenderingContext.COLOR_ATTACHMENT0,
                                     WebGLRenderingContext.TEXTURE_2D,
                                     t2d._buffer, 0);
    } else {
      spectreLog.Error('attachColorTarget invalid target type.');
      assert(false);
    }
    device.gl.bindFramebuffer(_target, oldBind);
  }

  void attachDepthTarget(dynamic depthTexture) {
    WebGLFramebuffer oldBind = device.gl.getParameter(_target_param);
    device.gl.bindFramebuffer(_target, _buffer);
    if (depthTexture == null) {
      _depthTarget = null;
      device.gl.framebufferRenderbuffer(_target,
                                        WebGLRenderingContext.DEPTH_ATTACHMENT,
                                        WebGLRenderingContext.RENDERBUFFER,
                                        null);
      device.gl.bindFramebuffer(WebGLRenderingContext.FRAMEBUFFER, oldBind);
      return;
    }
    if (depthTexture is RenderBuffer) {
      RenderBuffer rb = depthTexture as RenderBuffer;
      _depthTarget = rb;
      device.gl.framebufferRenderbuffer(_target,
                                        WebGLRenderingContext.DEPTH_ATTACHMENT,
                                        WebGLRenderingContext.RENDERBUFFER,
                                        rb._buffer);
    } else if (depthTexture is Texture2D) {
      Texture2D t2d = depthTexture as Texture2D;
      _depthTarget = t2d;
      device.gl.framebufferTexture2D(_target,
                                     WebGLRenderingContext.DEPTH_ATTACHMENT,
                                     WebGLRenderingContext.TEXTURE_2D,
                                     t2d._buffer, 0);
    } else {
      spectreLog.Error('attachDepthTarget invalid target type.');
      assert(false);
    }
    device.gl.bindFramebuffer(_target, oldBind);
  }

  void _destroyDeviceState() {
    if (_buffer != null) {
      device.gl.deleteFramebuffer(_buffer);
    }
    super._destroyDeviceState();
  }
}

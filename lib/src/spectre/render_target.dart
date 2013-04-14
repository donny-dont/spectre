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

part of spectre;

/** A [RenderTarget] specifies the buffers where color, depth, and stencil
 * are written to during a draw call.
 *
 * NOTE: To output into the system provided render target see
 * [RenderTarget.systemRenderTarget]
 */
class RenderTarget extends GraphicsResource {
  final int _bindTarget = WebGL.FRAMEBUFFER;
  final int _bindingParam = WebGL.FRAMEBUFFER_BINDING;

  WebGL.Framebuffer _deviceFramebuffer;
  GraphicsResource _colorTarget;
  GraphicsResource _depthTarget;
  GraphicsResource get colorTarget => _colorTarget;
  GraphicsResource get depthTarget => _depthTarget;
  GraphicsResource get stencilTarget => null;

  static RenderTarget _systemRenderTarget;
  /** System provided rendering target */
  static RenderTarget get systemRenderTarget => _systemRenderTarget;

  bool _renderable = false;
  /** Is the render target valid and renderable? */
  bool get isRenderable => _renderable;

  RenderTarget(String name, GraphicsDevice device) :
    super._internal(name, device) {
    _deviceFramebuffer = device.gl.createFramebuffer();
  }

  RenderTarget.systemTarget(String name, GraphicsDevice device) :
    super._internal(name, device) {
    _renderable = true;
  }

  void finalize() {
    super.finalize();
    device.gl.deleteFramebuffer(_deviceFramebuffer);
    _deviceFramebuffer = null;
    _renderable = false;
  }


  /** Bind this texture and return the previously bound framebuffer. */
  WebGL.Framebuffer _pushBind() {
    WebGL.Framebuffer oldBind = device.gl.getParameter(_bindingParam);
    device.gl.bindFramebuffer(_bindTarget, _deviceFramebuffer);
    return oldBind;
  }


  /** Rebind [oldBind] */
  void _popBind(WebGL.Framebuffer oldBind) {
    device.gl.bindFramebuffer(_bindTarget, oldBind);
  }


  void _bind() {
    device.gl.bindFramebuffer(_bindTarget, _deviceFramebuffer);
  }


  void _updateStatus() {
    var oldBind = _pushBind();
    int fbStatus = device.gl.checkFramebufferStatus(_bindTarget);
    _renderable = fbStatus == WebGL.FRAMEBUFFER_COMPLETE;
    _popBind(oldBind);
  }


  /** Set color target to be [colorBuffer].
   *
   * A color buffer must be a [Texture2D] or [RenderBuffer].
   *
   * A null color buffer indicates the system provided color buffer.
   */
  set colorTarget(dynamic colorBuffer) {
    var oldBind = _pushBind();
    if (colorBuffer == null) {
      _colorTarget = null;
      device.gl.framebufferRenderbuffer(_bindTarget,
                                        WebGL.COLOR_ATTACHMENT0,
                                        WebGL.RENDERBUFFER,
                                        null);
      device.gl.bindFramebuffer(WebGL.FRAMEBUFFER, oldBind);
      _updateStatus();
      _popBind(oldBind);
      return;
    }
    if (colorBuffer is RenderBuffer) {
      RenderBuffer rb = colorBuffer as RenderBuffer;
      _colorTarget = rb;
      device.gl.framebufferRenderbuffer(_bindTarget,
                                        WebGL.COLOR_ATTACHMENT0,
                                        WebGL.RENDERBUFFER,
                                        rb._buffer);
    } else if (colorBuffer is Texture2D) {
      Texture2D t2d = colorBuffer as Texture2D;
      _colorTarget = t2d;
      device.gl.framebufferTexture2D(_bindTarget,
                                     WebGL.COLOR_ATTACHMENT0,
                                     t2d._textureTarget,
                                     t2d._deviceTexture, 0);
    } else {
      throw new FallThroughError();
    }
    _updateStatus();
    _popBind(oldBind);
  }

  /** Set depth buffer output to be [depth].
   *
   * null indicates the system provided depth buffer.
   *
   * The depth buffer can be a [Texture2D] or [RenderBuffer].
   */
  /** Set depth target to be [depthBuffer].
   *
   * A depth buffer must be a [Texture2D] or [RenderBuffer].
   *
   * A null depth buffer indicates the system provided depth buffer.
   */
  set depthTarget(dynamic depthBuffer) {
    var oldBind = _pushBind();
    if (depthBuffer == null) {
      _depthTarget = null;
      device.gl.framebufferRenderbuffer(_bindTarget,
                                        WebGL.DEPTH_ATTACHMENT,
                                        WebGL.RENDERBUFFER,
                                        null);
      device.gl.bindFramebuffer(WebGL.FRAMEBUFFER, oldBind);
      _updateStatus();
      _popBind(oldBind);
      return;
    }
    if (depthBuffer is RenderBuffer) {
      RenderBuffer rb = depthBuffer as RenderBuffer;
      _depthTarget = rb;
      device.gl.framebufferRenderbuffer(_bindTarget,
                                        WebGL.DEPTH_ATTACHMENT,
                                        WebGL.RENDERBUFFER,
                                        rb._buffer);
    } else if (depthBuffer is Texture2D) {
      Texture2D t2d = depthBuffer as Texture2D;
      _depthTarget = t2d;
      device.gl.framebufferTexture2D(_bindTarget,
                                     WebGL.DEPTH_ATTACHMENT,
                                     t2d._textureTarget,
                                     t2d._deviceTexture, 0);
    } else {
      throw new FallThroughError();
    }
    _updateStatus();
    _popBind(oldBind);
  }
}

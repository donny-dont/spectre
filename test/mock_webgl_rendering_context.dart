part of graphics_context_test;

class MockGraphicsDevice extends Mock implements GraphicsDevice {
  WebGLRenderingContext gl;
  MockGraphicsDevice(WebGLRenderingContext this.gl);
}

class MockWebGLRenderingContext extends Mock implements WebGLRenderingContext {
  MockWebGLRenderingContext() {
    when(callsTo('enable')).alwaysReturn(null);
    when(callsTo('disable')).alwaysReturn(null);

    // BlendState calls
    when(callsTo('blendFuncSeparate')).alwaysReturn(null);
    when(callsTo('blendEquationSeparate')).alwaysReturn(null);
    when(callsTo('colorMask')).alwaysReturn(null);
    when(callsTo('blendColor')).alwaysReturn(null);

    // RasterizerState calls
    when(callsTo('cullFace')).alwaysReturn(null);
    when(callsTo('frontFace')).alwaysReturn(null);
    when(callsTo('polygonOffset')).alwaysReturn(null);
  }
}

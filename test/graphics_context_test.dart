library graphics_context_test;

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

import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:spectre/spectre.dart';
import 'dart:html';

part 'mock_webgl_rendering_context.dart';

//---------------------------------------------------------------------
// GraphicsContext testing utility functions
//---------------------------------------------------------------------

void verifyInitialPipelineState(MockWebGLRenderingContext gl) {
  int calls = 0;

  calls += verifyInitialViewport(gl);
  calls += verifyInitialBlendState(gl);
  calls += verifyInitialDepthState(gl);
  calls += verifyInitialRasterizerState(gl);

  // Number of GL calls in GraphicsContext._initializeState
  expect(gl.log.logs.length, calls);
}

//---------------------------------------------------------------------
// Viewport testing utility functions
//---------------------------------------------------------------------

int verifyInitialViewport(MockWebGLRenderingContext gl) {
  Viewport viewport = new Viewport('Viewport', null);

  // Make sure initial Viewport was used
  gl.getLogs(callsTo('viewport')).verify(happenedOnce);
  gl.getLogs(callsTo('depthRange', viewport.minDepth, viewport.maxDepth)).verify(happenedOnce);

  return 2;
}

//---------------------------------------------------------------------
// BlendState testing utility functions
//---------------------------------------------------------------------

void copyBlendState(BlendState original, BlendState copy) {
  copy.enabled = original.enabled;

  copy.alphaBlendOperation   = original.alphaBlendOperation;
  copy.alphaDestinationBlend = original.alphaDestinationBlend;
  copy.alphaSourceBlend      = original.alphaSourceBlend;
  copy.colorBlendOperation   = original.colorBlendOperation;
  copy.colorDestinationBlend = original.colorDestinationBlend;
  copy.colorSourceBlend      = original.colorSourceBlend;

  copy.blendFactorRed   = original.blendFactorRed;
  copy.blendFactorGreen = original.blendFactorGreen;
  copy.blendFactorBlue  = original.blendFactorBlue;
  copy.blendFactorAlpha = original.blendFactorAlpha;

  copy.writeRenderTargetRed   = original.writeRenderTargetRed;
  copy.writeRenderTargetGreen = original.writeRenderTargetGreen;
  copy.writeRenderTargetBlue  = original.writeRenderTargetBlue;
  copy.writeRenderTargetAlpha = original.writeRenderTargetAlpha;
}

int verifyInitialBlendState(MockWebGLRenderingContext gl) {
  BlendState blendState = new BlendState.opaque('InitialBlendState', null);

  // Make sure BlendState.opaque was used
  gl.getLogs(callsTo('disable', WebGLRenderingContext.BLEND)).verify(happenedOnce);

  gl.getLogs(
    callsTo(
      'colorMask',
      blendState.writeRenderTargetRed,
      blendState.writeRenderTargetGreen,
      blendState.writeRenderTargetBlue,
      blendState.writeRenderTargetAlpha
    )
  ).verify(happenedOnce);

  gl.getLogs(
    callsTo(
      'blendFuncSeparate',
      blendState.colorSourceBlend,
      blendState.colorDestinationBlend,
      blendState.alphaSourceBlend,
      blendState.alphaDestinationBlend
    )
  ).verify(happenedOnce);

  gl.getLogs(
    callsTo(
      'blendEquationSeparate',
      blendState.colorBlendOperation,
      blendState.alphaBlendOperation
    )
  ).verify(happenedOnce);

  gl.getLogs(
    callsTo(
      'blendColor',
      blendState.blendFactorRed,
      blendState.blendFactorGreen,
      blendState.blendFactorBlue,
      blendState.blendFactorAlpha
    )
  ).verify(happenedOnce);

  return 5;
}

int verifyBlendState(MockWebGLRenderingContext gl, BlendState blendState, BlendState blendStateLast, [bool copyState = true]) {
  LogEntryList logEntries;

  // Check to see if enabled/disabled was called
  if (blendState.enabled != blendStateLast.enabled) {
    if (blendState.enabled){
      gl.getLogs(callsTo('disable')).verify(neverHappened);

      logEntries = gl.getLogs(callsTo('enable'));
    } else {
      gl.getLogs(callsTo('enable')).verify(neverHappened);

      logEntries = gl.getLogs(callsTo('disable'));
    }

    logEntries.verify(happenedOnce);
    expect(logEntries.first.args[0], WebGLRenderingContext.BLEND);
  }

  // Check to see if colorMask was called
  Matcher colorMaskMatcher =
    ((blendState.writeRenderTargetRed   != blendStateLast.writeRenderTargetRed)   ||
     (blendState.writeRenderTargetGreen != blendStateLast.writeRenderTargetGreen) ||
     (blendState.writeRenderTargetBlue  != blendStateLast.writeRenderTargetBlue)  ||
     (blendState.writeRenderTargetAlpha != blendStateLast.writeRenderTargetAlpha))
    ? happenedOnce
    : neverHappened;

  logEntries = gl.getLogs(callsTo('colorMask'));
  logEntries.verify(colorMaskMatcher);

  if (colorMaskMatcher == happenedOnce) {
    List args = logEntries.first.args;

    expect(args[0], blendState.writeRenderTargetRed);
    expect(args[1], blendState.writeRenderTargetGreen);
    expect(args[2], blendState.writeRenderTargetBlue);
    expect(args[3], blendState.writeRenderTargetAlpha);
  }

  // Check the methods that will only be called if the BlendState is enabled
  if (blendState.enabled) {
    // Check to see if blendFuncSeparate was called
    Matcher blendFuncSeparateMatcher =
      ((blendState.colorSourceBlend      != blendStateLast.colorSourceBlend)      ||
       (blendState.colorDestinationBlend != blendStateLast.colorDestinationBlend) ||
       (blendState.alphaSourceBlend      != blendStateLast.alphaSourceBlend)      ||
       (blendState.alphaDestinationBlend != blendStateLast.alphaDestinationBlend))
      ? happenedOnce
      : neverHappened;

    logEntries = gl.getLogs(callsTo('blendFuncSeparate'));
    logEntries.verify(blendFuncSeparateMatcher);

    if (blendFuncSeparateMatcher == happenedOnce) {
      List args = logEntries.first.args;

      expect(args[0], blendState.colorSourceBlend);
      expect(args[1], blendState.colorDestinationBlend);
      expect(args[2], blendState.alphaSourceBlend);
      expect(args[3], blendState.alphaDestinationBlend);
    }

    // Check to see if blendEquationSeparate was called
    Matcher blendEquationSeparateMatcher =
      ((blendState.colorBlendOperation != blendStateLast.colorBlendOperation) ||
       (blendState.alphaBlendOperation != blendStateLast.alphaBlendOperation))
      ? happenedOnce
      : neverHappened;

    logEntries = gl.getLogs(callsTo('blendEquationSeparate'));
    logEntries.verify(blendEquationSeparateMatcher);

    if (blendEquationSeparateMatcher == happenedOnce) {
      List args = logEntries.first.args;

      expect(args[0], blendState.colorBlendOperation);
      expect(args[1], blendState.alphaBlendOperation);
    }

    // Check to see if blendColor was called
    Matcher blendFactorMatcher =
      ((blendState.blendFactorRed   != blendStateLast.blendFactorRed)   ||
       (blendState.blendFactorGreen != blendStateLast.blendFactorGreen) ||
       (blendState.blendFactorBlue  != blendStateLast.blendFactorBlue)  ||
       (blendState.blendFactorAlpha != blendStateLast.blendFactorAlpha))
      ? happenedOnce
      : neverHappened;

    logEntries = gl.getLogs(callsTo('blendColor'));
    logEntries.verify(blendFactorMatcher);

    if (blendFactorMatcher == happenedOnce) {
      List args = logEntries.first.args;

      expect(args[0], blendState.blendFactorRed);
      expect(args[1], blendState.blendFactorGreen);
      expect(args[2], blendState.blendFactorBlue);
      expect(args[3], blendState.blendFactorAlpha);
    }
  }

  // Copy the state if requested
  if (copyState) {
    copyBlendState(blendState, blendStateLast);
  }

  // Clear the log
  int numEntries = gl.log.logs.length;
  gl.clearLogs();

  // Return the number of entries
  return numEntries;
}

void testBlendStateTransitions(bool blendEnabled) {
  MockWebGLRenderingContext gl = new MockWebGLRenderingContext();
  MockGraphicsDevice graphicsDevice = new MockGraphicsDevice(gl);
  GraphicsContext graphicsContext = new GraphicsContext(graphicsDevice);

  // Passing null will reset the values
  graphicsContext.setBlendState(null);
  verifyInitialBlendState(gl);

  gl.clearLogs();

  // Create the initial blend state
  BlendState blendState = new BlendState('BlendState', null);

  blendState.enabled = blendEnabled;
  blendState.alphaBlendOperation = BlendOperation.ReverseSubtract;
  blendState.alphaDestinationBlend = Blend.BlendFactor;
  blendState.alphaSourceBlend = Blend.BlendFactor;
  blendState.colorBlendOperation = BlendOperation.ReverseSubtract;
  blendState.colorDestinationBlend = Blend.InverseBlendFactor;
  blendState.colorSourceBlend = Blend.InverseBlendFactor;
  blendState.blendFactorRed   = 0.0;
  blendState.blendFactorGreen = 0.0;
  blendState.blendFactorBlue  = 0.0;
  blendState.blendFactorAlpha = 0.0;
  blendState.writeRenderTargetRed   = false;
  blendState.writeRenderTargetGreen = false;
  blendState.writeRenderTargetBlue  = false;
  blendState.writeRenderTargetAlpha = false;

  graphicsContext.setBlendState(blendState);
  int numEntries;

  if (blendState.enabled) {
    gl.getLogs(callsTo('enable')).verify(happenedOnce);
    gl.getLogs(callsTo('blendFuncSeparate')).verify(happenedOnce);
    gl.getLogs(callsTo('blendEquationSeparate')).verify(happenedOnce);
    gl.getLogs(callsTo('colorMask')).verify(happenedOnce);
    gl.getLogs(callsTo('blendColor')).verify(happenedOnce);

    // All methods should be called
    numEntries = 5;
  } else {
    gl.getLogs(callsTo('colorMask')).verify(happenedOnce);

    // Just colorMask should be called
    numEntries = 1;
  }

  expect(gl.log.logs.length, numEntries);

  gl.clearLogs();

  // Create another BlendState to provide a comparison
  BlendState blendStateLast = new BlendState('BlendStateLast', null);
  copyBlendState(blendState, blendStateLast);

  // Set the same state values again
  // This should result in zero calls
  graphicsContext.setBlendState(blendState);
  expect(verifyBlendState(gl, blendState, blendStateLast), 0);

  // Change the write target values
  // These are always written whether blending is enabled or disabled
  blendState.writeRenderTargetRed = !blendState.writeRenderTargetRed;
  graphicsContext.setBlendState(blendState);
  expect(verifyBlendState(gl, blendState, blendStateLast), 1);

  blendState.writeRenderTargetGreen = !blendState.writeRenderTargetGreen;
  graphicsContext.setBlendState(blendState);
  expect(verifyBlendState(gl, blendState, blendStateLast), 1);

  blendState.writeRenderTargetBlue = !blendState.writeRenderTargetBlue;
  graphicsContext.setBlendState(blendState);
  expect(verifyBlendState(gl, blendState, blendStateLast), 1);

  blendState.writeRenderTargetAlpha = !blendState.writeRenderTargetAlpha;
  graphicsContext.setBlendState(blendState);
  expect(verifyBlendState(gl, blendState, blendStateLast), 1);

  // Calls are ignored if the blending is disabled
  numEntries = (blendEnabled) ? 1 : 0;

  // Change the blend operation values
  blendState.alphaBlendOperation = BlendOperation.Subtract;
  graphicsContext.setBlendState(blendState);
  expect(verifyBlendState(gl, blendState, blendStateLast, blendEnabled), numEntries);

  blendState.colorBlendOperation = BlendOperation.Subtract;
  graphicsContext.setBlendState(blendState);
  expect(verifyBlendState(gl, blendState, blendStateLast, blendEnabled), numEntries);

  // Change the blend values
  blendState.alphaDestinationBlend = Blend.InverseBlendFactor;
  graphicsContext.setBlendState(blendState);
  expect(verifyBlendState(gl, blendState, blendStateLast, blendEnabled), numEntries);

  blendState.alphaSourceBlend = Blend.InverseBlendFactor;
  graphicsContext.setBlendState(blendState);
  expect(verifyBlendState(gl, blendState, blendStateLast, blendEnabled), numEntries);

  blendState.colorDestinationBlend = Blend.BlendFactor;
  graphicsContext.setBlendState(blendState);
  expect(verifyBlendState(gl, blendState, blendStateLast, blendEnabled), numEntries);

  blendState.colorSourceBlend = Blend.BlendFactor;
  graphicsContext.setBlendState(blendState);
  expect(verifyBlendState(gl, blendState, blendStateLast, blendEnabled), numEntries);

  // Change the blend factor values
  blendState.blendFactorRed   = 0.1;
  graphicsContext.setBlendState(blendState);
  expect(verifyBlendState(gl, blendState, blendStateLast, blendEnabled), numEntries);

  blendState.blendFactorGreen = 0.2;
  graphicsContext.setBlendState(blendState);
  expect(verifyBlendState(gl, blendState, blendStateLast, blendEnabled), numEntries);

  blendState.blendFactorBlue  = 0.3;
  graphicsContext.setBlendState(blendState);
  expect(verifyBlendState(gl, blendState, blendStateLast, blendEnabled), numEntries);

  blendState.blendFactorAlpha = 0.4;
  graphicsContext.setBlendState(blendState);
  expect(verifyBlendState(gl, blendState, blendStateLast, blendEnabled), numEntries);

  // Toggle the enabled value
  blendState.enabled = !blendEnabled;
  graphicsContext.setBlendState(blendState);

  if (blendState.enabled) {
    gl.getLogs(callsTo('enable')).verify(happenedOnce);
    gl.getLogs(callsTo('blendFuncSeparate')).verify(happenedOnce);
    gl.getLogs(callsTo('blendEquationSeparate')).verify(happenedOnce);
    gl.getLogs(callsTo('blendColor')).verify(happenedOnce);

    // All methods minus colorMask should be called
    numEntries = 4;
  } else {
    gl.getLogs(callsTo('disable')).verify(happenedOnce);

    // Just disable should be called
    numEntries = 1;
  }

  expect(gl.log.logs.length, numEntries);
}

void testBlendState() {
  test('setBlendState', () {
    testBlendStateTransitions(true);
    testBlendStateTransitions(false);
  });
}

//---------------------------------------------------------------------
// DepthState testing utility functions
//---------------------------------------------------------------------

void copyDepthState(DepthState original, DepthState copy) {
  copy.depthBufferEnabled      = original.depthBufferEnabled;
  copy.depthBufferWriteEnabled = original.depthBufferWriteEnabled;
  copy.depthBufferFunction     = original.depthBufferFunction;
}

int verifyInitialDepthState(MockWebGLRenderingContext gl) {
  DepthState depthState = new DepthState.depthWrite('InitialDepthState', null);

  // Make sure DepthState.cullClockwise was used
  gl.getLogs(callsTo('enable', WebGLRenderingContext.DEPTH_TEST)).verify(happenedOnce);

  gl.getLogs(callsTo('depthFunc', depthState.depthBufferFunction)).verify(happenedOnce);
  gl.getLogs(callsTo('depthMask', depthState.depthBufferWriteEnabled)).verify(happenedOnce);

  return 3;
}

int verifyDepthState(MockWebGLRenderingContext gl, DepthState depthState, DepthState depthStateLast, [bool copyState = true]) {
  // Check to see if the depth buffer was enabled/disabled
  if (depthState.depthBufferEnabled != depthStateLast.depthBufferEnabled) {
    if (depthState.depthBufferEnabled) {
      gl.getLogs(callsTo('enable', WebGLRenderingContext.DEPTH_TEST)).verify(happenedOnce);
      gl.getLogs(callsTo('disable', WebGLRenderingContext.DEPTH_TEST)).verify(neverHappened);
    } else {
      gl.getLogs(callsTo('enable', WebGLRenderingContext.DEPTH_TEST)).verify(neverHappened);
      gl.getLogs(callsTo('disable', WebGLRenderingContext.DEPTH_TEST)).verify(happenedOnce);
    }
  }

  // Check the methods that will only be called if the depth buffer is enabled
  if (depthState.depthBufferEnabled) {
    // Check to see if depthFunc was called
    if (depthState.depthBufferFunction != depthStateLast.depthBufferFunction) {
      gl.getLogs(callsTo('depthFunc', depthState.depthBufferFunction)).verify(happenedOnce);
    } else {
      gl.getLogs(callsTo('depthFunc')).verify(neverHappened);
    }
  }

  // Check to see if writing to the depth buffer was enabled/disabled
  if (depthState.depthBufferWriteEnabled != depthStateLast.depthBufferWriteEnabled) {
    gl.getLogs(callsTo('depthMask', depthState.depthBufferWriteEnabled)).verify(happenedOnce);
  }

  // Copy the state if requested
  if (copyState) {
    copyDepthState(depthState, depthStateLast);
  }

  // Clear the log
  int numEntries = gl.log.logs.length;
  gl.clearLogs();

  // Return the number of entries
  return numEntries;
}

void testDepthStateTransitions(bool depthBufferEnabled) {
  MockWebGLRenderingContext gl = new MockWebGLRenderingContext();
  MockGraphicsDevice graphicsDevice = new MockGraphicsDevice(gl);
  GraphicsContext graphicsContext = new GraphicsContext(graphicsDevice);

  // Passing null will reset the values
  graphicsContext.setDepthState(null);
  verifyInitialRasterizerState(gl);

  gl.clearLogs();

  // Create the initial depth state
  DepthState depthState = new DepthState('DepthState', null);

  depthState.depthBufferEnabled = depthBufferEnabled;
  depthState.depthBufferWriteEnabled = false;
  depthState.depthBufferFunction = CompareFunction.Always;

  graphicsContext.setDepthState(depthState);
  int numEntries;

  if (depthBufferEnabled) {
    gl.getLogs(callsTo('depthFunc')).verify(happenedOnce);
    gl.getLogs(callsTo('depthMask')).verify(happenedOnce);

    // Shouldn't call enable
    numEntries = 2;
  } else {
    gl.getLogs(callsTo('disable', WebGLRenderingContext.DEPTH_TEST)).verify(happenedOnce);
    gl.getLogs(callsTo('depthMask')).verify(happenedOnce);

    // Shouldn't call depthFunc
    numEntries = 2;
  }

  expect(gl.log.logs.length, numEntries);

  gl.clearLogs();

  // Create another RasterizerState to provide a comparison
  DepthState depthStateLast = new DepthState('DepthStateLast', null);
  copyDepthState(depthState, depthStateLast);

  // Set the same state values again
  // This should result in zero calls
  graphicsContext.setDepthState(depthState);
  expect(verifyDepthState(gl, depthState, depthStateLast), 0);

  // Change whether the depth buffer is writeable
  depthState.depthBufferWriteEnabled = !depthState.depthBufferWriteEnabled;
  graphicsContext.setDepthState(depthState);
  expect(verifyDepthState(gl, depthState, depthStateLast), 1);

  // Change the depth function
  depthState.depthBufferFunction = CompareFunction.NotEqual;
  graphicsContext.setDepthState(depthState);
  expect(verifyDepthState(gl, depthState, depthStateLast, depthBufferEnabled), (depthBufferEnabled) ? 1 : 0);

  // Change whether the depth buffer is enabled
  depthState.depthBufferEnabled = !depthState.depthBufferEnabled;
  graphicsContext.setDepthState(depthState);
  expect(verifyDepthState(gl, depthState, depthStateLast), (depthBufferEnabled) ? 1 : 2);
}

void testDepthState() {
  test('setDepthState', () {
    testDepthStateTransitions(true);
    testDepthStateTransitions(false);
  });
}

//---------------------------------------------------------------------
// RasterizerState testing utility functions
//---------------------------------------------------------------------

void copyRasterizerState(RasterizerState original, RasterizerState copy) {
  copy.cullMode  = original.cullMode;
  copy.frontFace = original.frontFace;

  copy.depthBias           = original.depthBias;
  copy.slopeScaleDepthBias = original.slopeScaleDepthBias;

  copy.scissorTestEnabled = original.scissorTestEnabled;
}

int verifyInitialRasterizerState(MockWebGLRenderingContext gl) {
  RasterizerState rasterizerState = new RasterizerState.cullClockwise('InitialRasterizerState', null);

  // Make sure RasterizerState.cullClockwise was used
  gl.getLogs(callsTo('enable', WebGLRenderingContext.CULL_FACE)).verify(happenedOnce);

  gl.getLogs(callsTo('cullFace', rasterizerState.cullMode)).verify(happenedOnce);
  gl.getLogs(callsTo('frontFace', rasterizerState.frontFace)).verify(happenedOnce);

  gl.getLogs(callsTo('disable', WebGLRenderingContext.POLYGON_OFFSET_FILL)).verify(happenedOnce);
  gl.getLogs(callsTo('polygonOffset', rasterizerState.depthBias, rasterizerState.slopeScaleDepthBias)).verify(happenedOnce);

  gl.getLogs(callsTo('disable', WebGLRenderingContext.SCISSOR_TEST)).verify(happenedOnce);

  return 6;
}

int verifyRasterizerState(MockWebGLRenderingContext gl, RasterizerState rasterizerState, RasterizerState rasterizerStateLast, [bool copyState = true]) {
  // Check to see if culling was enabled/disabled
  if (rasterizerState.cullMode != rasterizerStateLast.cullMode) {
    if (rasterizerState.cullMode != CullMode.None) {
      gl.getLogs(callsTo('enable', WebGLRenderingContext.CULL_FACE)).verify(happenedOnce);
      gl.getLogs(callsTo('disable', WebGLRenderingContext.CULL_FACE)).verify(neverHappened);
    } else {
      gl.getLogs(callsTo('enable', WebGLRenderingContext.CULL_FACE)).verify(neverHappened);
      gl.getLogs(callsTo('disable', WebGLRenderingContext.CULL_FACE)).verify(happenedOnce);
    }
  }

  // Check the methods that will only be called if culling is enabled
  if (rasterizerState.cullMode != CullMode.None) {
    // Check to see if cullFace was called
    if (rasterizerState.cullMode != rasterizerStateLast.cullMode) {
      gl.getLogs(callsTo('cullFace', rasterizerState.cullMode)).verify(happenedOnce);
    } else {
      gl.getLogs(callsTo('cullFace')).verify(neverHappened);
    }

    // Check to see if frontFace was called
    if (rasterizerState.frontFace != rasterizerStateLast.frontFace) {
      gl.getLogs(callsTo('frontFace', rasterizerState.frontFace)).verify(happenedOnce);
    } else {
      gl.getLogs(callsTo('frontFace')).verify(neverHappened);
    }
  }

  // Check the methods that will only be called if a polygon offset is specified
  bool offsetEnabled = ((rasterizerStateLast.depthBias != 0.0) || (rasterizerStateLast.slopeScaleDepthBias != 0.0));

  if ((rasterizerState.depthBias != 0.0) || (rasterizerState.slopeScaleDepthBias != 0.0)) {
    // Check to see if polygon offset is enabled
    if (!offsetEnabled) {
      gl.getLogs(callsTo('enable', WebGLRenderingContext.POLYGON_OFFSET_FILL)).verify(happenedOnce);
    }

    // Check to see if polygonOffset was called
    if ((rasterizerState.depthBias           != rasterizerStateLast.depthBias) ||
        (rasterizerState.slopeScaleDepthBias != rasterizerStateLast.slopeScaleDepthBias))
    {
      gl.getLogs(callsTo('polygonOffset', rasterizerState.depthBias, rasterizerState.slopeScaleDepthBias)).verify(happenedOnce);
    } else {
      gl.getLogs(callsTo('polygonOffset')).verify(neverHappened);
    }
  } else {
    // Check to see if polygon offset is disabled
    if (offsetEnabled) {
      gl.getLogs(callsTo('disable', WebGLRenderingContext.POLYGON_OFFSET_FILL)).verify(happenedOnce);
    }
  }

  // Check to see if the scissor test was enabled/disabled
  if (rasterizerState.scissorTestEnabled != rasterizerStateLast.scissorTestEnabled) {
    if (rasterizerState.scissorTestEnabled) {
      gl.getLogs(callsTo('enable', WebGLRenderingContext.SCISSOR_TEST)).verify(happenedOnce);
    } else {
      gl.getLogs(callsTo('disable', WebGLRenderingContext.SCISSOR_TEST)).verify(happenedOnce);
    }
  }

  // Copy the state if requested
  if (copyState) {
    copyRasterizerState(rasterizerState, rasterizerStateLast);
  }

  // Clear the log
  int numEntries = gl.log.logs.length;
  gl.clearLogs();

  // Return the number of entries
  return numEntries;
}

void testRasterizerStateTransitions(bool cullEnabled) {
  MockWebGLRenderingContext gl = new MockWebGLRenderingContext();
  MockGraphicsDevice graphicsDevice = new MockGraphicsDevice(gl);
  GraphicsContext graphicsContext = new GraphicsContext(graphicsDevice);

  // Passing null will reset the values
  graphicsContext.setRasterizerState(null);
  verifyInitialRasterizerState(gl);

  gl.clearLogs();

  // Create the initial rasterizer state
  RasterizerState rasterizerState = new RasterizerState('RasterizerState', null);

  rasterizerState.cullMode = (cullEnabled) ? CullMode.Front : CullMode.None;
  rasterizerState.frontFace = FrontFace.Clockwise;
  rasterizerState.depthBias = 1.0;
  rasterizerState.slopeScaleDepthBias = 1.0;
  rasterizerState.scissorTestEnabled = true;

  graphicsContext.setRasterizerState(rasterizerState);
  int numEntries;

  if (rasterizerState.cullMode != CullMode.None) {
    gl.getLogs(callsTo('cullFace')).verify(happenedOnce);
    gl.getLogs(callsTo('frontFace')).verify(happenedOnce);
    gl.getLogs(callsTo('enable', WebGLRenderingContext.POLYGON_OFFSET_FILL)).verify(happenedOnce);
    gl.getLogs(callsTo('polygonOffset')).verify(happenedOnce);
    gl.getLogs(callsTo('enable', WebGLRenderingContext.SCISSOR_TEST)).verify(happenedOnce);

    // All methods should be called
    numEntries = 5;
  } else {
    gl.getLogs(callsTo('disable', WebGLRenderingContext.CULL_FACE)).verify(happenedOnce);
    gl.getLogs(callsTo('enable', WebGLRenderingContext.POLYGON_OFFSET_FILL)).verify(happenedOnce);
    gl.getLogs(callsTo('polygonOffset')).verify(happenedOnce);
    gl.getLogs(callsTo('enable', WebGLRenderingContext.SCISSOR_TEST)).verify(happenedOnce);

    // Just colorMask should be called
    numEntries = 4;
  }

  expect(gl.log.logs.length, numEntries);

  gl.clearLogs();

  // Create another RasterizerState to provide a comparison
  RasterizerState rasterizerStateLast = new RasterizerState('RasterizerStateLast', null);
  copyRasterizerState(rasterizerState, rasterizerStateLast);

  // Set the same state values again
  // This should result in zero calls
  graphicsContext.setRasterizerState(rasterizerState);
  expect(verifyRasterizerState(gl, rasterizerState, rasterizerStateLast), 0);

  // Change the front face
  rasterizerState.frontFace = FrontFace.CounterClockwise;
  graphicsContext.setRasterizerState(rasterizerState);
  expect(verifyRasterizerState(gl, rasterizerState, rasterizerStateLast, cullEnabled), (cullEnabled) ? 1: 0);

  // Change the polygon offset values
  rasterizerState.depthBias = 0.0;
  rasterizerState.slopeScaleDepthBias = 0.0;
  graphicsContext.setRasterizerState(rasterizerState);
  expect(verifyRasterizerState(gl, rasterizerState, rasterizerStateLast), 1);

  rasterizerState.depthBias = 1.0;
  graphicsContext.setRasterizerState(rasterizerState);
  expect(verifyRasterizerState(gl, rasterizerState, rasterizerStateLast), 2);

  rasterizerState.slopeScaleDepthBias = 1.0;
  graphicsContext.setRasterizerState(rasterizerState);
  expect(verifyRasterizerState(gl, rasterizerState, rasterizerStateLast), 1);

  // Change the scissor test
  rasterizerState.scissorTestEnabled = !rasterizerState.scissorTestEnabled;
  graphicsContext.setRasterizerState(rasterizerState);
  expect(verifyRasterizerState(gl, rasterizerState, rasterizerStateLast), 1);

  if (cullEnabled) {
    rasterizerState.cullMode = CullMode.None;

    numEntries = 1;
  } else {
    rasterizerState.cullMode = CullMode.Back;

    numEntries = 2;
  }

  graphicsContext.setRasterizerState(rasterizerState);

  expect(gl.log.logs.length, numEntries);
}

void testRasterizerState() {
  test('setRasterizerState', () {
    testRasterizerStateTransitions(true);
    testRasterizerStateTransitions(false);
  });
}

//---------------------------------------------------------------------
// Test entry point
//---------------------------------------------------------------------

void main() {
  test('construction', () {
    MockWebGLRenderingContext gl = new MockWebGLRenderingContext();
    MockGraphicsDevice graphicsDevice = new MockGraphicsDevice(gl);
    GraphicsContext graphicsContext = new GraphicsContext(graphicsDevice);

    // Make sure reset was called
    verifyInitialPipelineState(gl);
  });

  testBlendState();
  testDepthState();
  testRasterizerState();
}

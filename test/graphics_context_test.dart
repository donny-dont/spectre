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

void verifyBlendStateReset(MockWebGLRenderingContext gl) {
  // Make sure _resetBlendState was called
  gl.getLogs(callsTo('disable')).verify(happenedOnce);
  gl.getLogs(callsTo('blendFuncSeparate')).verify(happenedOnce);
  gl.getLogs(callsTo('blendEquationSeparate')).verify(happenedOnce);
  gl.getLogs(callsTo('colorMask')).verify(happenedOnce);
  gl.getLogs(callsTo('blendColor')).verify(happenedOnce);
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

void testBlendStateTransitions(MockWebGLRenderingContext gl, GraphicsContext graphicsContext, bool blendEnabled) {
  gl.clearLogs();

  // Passing null will reset the values
  graphicsContext.setBlendState(null);
  verifyBlendStateReset(gl);

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
  expect(verifyBlendState(gl, blendState, blendStateLast), numEntries);

  blendState.colorBlendOperation = BlendOperation.Subtract;
  graphicsContext.setBlendState(blendState);
  expect(verifyBlendState(gl, blendState, blendStateLast), numEntries);

  // Change the blend values
  blendState.alphaDestinationBlend = Blend.InverseBlendFactor;
  graphicsContext.setBlendState(blendState);
  expect(verifyBlendState(gl, blendState, blendStateLast), numEntries);

  blendState.alphaSourceBlend = Blend.InverseBlendFactor;
  graphicsContext.setBlendState(blendState);
  expect(verifyBlendState(gl, blendState, blendStateLast), numEntries);

  blendState.colorDestinationBlend = Blend.BlendFactor;
  graphicsContext.setBlendState(blendState);
  expect(verifyBlendState(gl, blendState, blendStateLast), numEntries);

  blendState.colorSourceBlend = Blend.BlendFactor;
  graphicsContext.setBlendState(blendState);
  expect(verifyBlendState(gl, blendState, blendStateLast), numEntries);

  // Change the blend factor values
  blendState.blendFactorRed   = 0.1;
  graphicsContext.setBlendState(blendState);
  expect(verifyBlendState(gl, blendState, blendStateLast), numEntries);

  blendState.blendFactorGreen = 0.2;
  graphicsContext.setBlendState(blendState);
  expect(verifyBlendState(gl, blendState, blendStateLast), numEntries);

  blendState.blendFactorBlue  = 0.3;
  graphicsContext.setBlendState(blendState);
  expect(verifyBlendState(gl, blendState, blendStateLast), numEntries);

  blendState.blendFactorAlpha = 0.4;
  graphicsContext.setBlendState(blendState);
  expect(verifyBlendState(gl, blendState, blendStateLast), numEntries);

  // Toggle the enabled value
  blendState.enabled = !blendEnabled;
  graphicsContext.setBlendState(blendState);

  if (blendState.enabled) {
    print(gl.log);
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

void testBlendState(MockWebGLRenderingContext gl, GraphicsContext graphicsContext) {
  test('setBlendState', () {
    testBlendStateTransitions(gl, graphicsContext, true);
    testBlendStateTransitions(gl, graphicsContext, false);
  });
}

//---------------------------------------------------------------------
// Test entry point
//---------------------------------------------------------------------

void main() {
  MockWebGLRenderingContext gl = new MockWebGLRenderingContext();
  MockGraphicsDevice graphicsDevice = new MockGraphicsDevice(gl);
  GraphicsContext graphicsContext = new GraphicsContext(graphicsDevice);

  test('construction', () {
    LogEntryList logEntries = gl.log;
    print(logEntries);

    // Make sure reset was called
    verifyBlendStateReset(gl);
  });

  testBlendState(gl, graphicsContext);
}

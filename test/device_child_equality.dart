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

library devicedepthState0.childdepthState0.equality;

import 'package:spectre/spectre.dart';

/// Compares two [BlendState]s for equality.
bool blendStateEqual(BlendState blendState0, BlendState blendState1) {
  if (identical(blendState0, blendState1)) {
    return true;
  }

  if (blendState0.enabled != blendState1.enabled) {
    return false;
  }

  if ((blendState0.blendFactorRed   != blendState1.blendFactorRed)   ||
      (blendState0.blendFactorGreen != blendState1.blendFactorGreen) ||
      (blendState0.blendFactorBlue  != blendState1.blendFactorBlue)  ||
      (blendState0.blendFactorAlpha != blendState1.blendFactorAlpha))
  {
    return false;
  }

  if (blendState0.alphaBlendOperation != blendState1.alphaBlendOperation) {
    return false;
  }
  if (blendState0.alphaDestinationBlend != blendState1.alphaDestinationBlend) {
    return false;
  }
  if (blendState0.alphaSourceBlend != blendState1.alphaSourceBlend) {
    return false;
  }

  if (blendState0.colorBlendOperation != blendState1.colorBlendOperation) {
    return false;
  }
  if (blendState0.colorDestinationBlend != blendState1.colorDestinationBlend) {
    return false;
  }
  if (blendState0.colorSourceBlend != blendState1.colorSourceBlend) {
    return false;
  }

  return ((blendState0.writeRenderTargetRed   == blendState1.writeRenderTargetRed)   &&
          (blendState0.writeRenderTargetGreen == blendState1.writeRenderTargetGreen) &&
          (blendState0.writeRenderTargetBlue  == blendState1.writeRenderTargetBlue)  &&
          (blendState0.writeRenderTargetAlpha == blendState1.writeRenderTargetAlpha));
}

/// Compares two [DepthState]s for equality.
bool depthStateEqual(DepthState depthState0, DepthState depthState1) {
  if (identical(depthState0, depthState1)) {
    return true;
  }

  return ((depthState0.depthBufferEnabled      == depthState1.depthBufferEnabled)      &&
          (depthState0.depthBufferWriteEnabled == depthState1.depthBufferWriteEnabled) &&
          (depthState0.depthBufferFunction     == depthState1.depthBufferFunction));
}

/// Compares two [RasterizerState]s for equality.
bool rasterizerStateEqual(RasterizerState rasterizerState0, RasterizerState rasterizerState1) {
  if (identical(rasterizerState0, rasterizerState1)) {
    return true;
  }

  if (rasterizerState0.cullMode != rasterizerState1.cullMode) {
    return false;
  }

  if (rasterizerState0.frontFace != rasterizerState1.frontFace) {
    return false;
  }

  if ((rasterizerState0.depthBias != rasterizerState1.depthBias) || (rasterizerState0.slopeScaleDepthBias != rasterizerState1.slopeScaleDepthBias)) {
    return false;
  }

  return rasterizerState0.scissorTestEnabled == rasterizerState1.scissorTestEnabled;
}

/// Compares two [SamplerState]s for equality.
bool samplerStateEqual(SamplerState samplerState0, SamplerState samplerState1) {
  if (identical(samplerState0, samplerState1)) {
    return true;
  }

  if (samplerState0.addressU != samplerState1.addressU) {
    return false;
  }

  if (samplerState0.addressV != samplerState1.addressV) {
    return false;
  }

  if (samplerState0.minFilter != samplerState1.minFilter) {
    return false;
  }

  if (samplerState0.magFilter != samplerState1.magFilter) {
    return false;
  }

  return samplerState0.maxAnisotropy == samplerState1.maxAnisotropy;
}

/// Compares two [Viewport]s for equality.
bool viewportEqual(Viewport viewport0, Viewport viewport1) {
  if (identical(viewport0, viewport1)) {
    return true;
  }

  if ((viewport0.x != viewport1.x) || (viewport0.y != viewport1.y)) {
    return false;
  }

  if ((viewport0.width != viewport1.width) || (viewport0.height != viewport1.height)) {
    return false;
  }

  return ((viewport0.minDepth == viewport1.minDepth) && (viewport0.maxDepth == viewport1.maxDepth));
}

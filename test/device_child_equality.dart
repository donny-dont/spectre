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

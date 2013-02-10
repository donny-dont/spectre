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

library device_child_equality;

import 'package:spectre/spectre.dart';

bool blendStateEqual(BlendState blend0, BlendState blend1) {
  if (identical(blend0, blend1)) {
    return true;
  }

  if (blend0.enabled != blend1.enabled) {
    return false;
  }

  if ((blend0.blendFactorRed   != blend1.blendFactorRed)   ||
      (blend0.blendFactorGreen != blend1.blendFactorGreen) ||
      (blend0.blendFactorBlue  != blend1.blendFactorBlue)  ||
      (blend0.blendFactorAlpha != blend1.blendFactorAlpha))
  {
    return false;
  }

  if (blend0.alphaBlendOperation != blend1.alphaBlendOperation) {
    return false;
  }
  if (blend0.alphaDestinationBlend != blend1.alphaDestinationBlend) {
    return false;
  }
  if (blend0.alphaSourceBlend != blend1.alphaSourceBlend) {
    return false;
  }

  if (blend0.colorBlendOperation != blend1.colorBlendOperation) {
    return false;
  }
  if (blend0.colorDestinationBlend != blend1.colorDestinationBlend) {
    return false;
  }
  if (blend0.colorSourceBlend != blend1.colorSourceBlend) {
    return false;
  }

  return ((blend0.writeRenderTargetRed   == blend1.writeRenderTargetRed)   &&
          (blend0.writeRenderTargetGreen == blend1.writeRenderTargetGreen) &&
          (blend0.writeRenderTargetBlue  == blend1.writeRenderTargetBlue)  &&
          (blend0.writeRenderTargetAlpha == blend1.writeRenderTargetAlpha));
}


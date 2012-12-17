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

/// Defines the color channels that can be chosen for a per-channel write to a render target color buffer.
class ColorWriteChannels {
  /// No channel selected.
  static const int None = 0x0;
  /// Red channel of a buffer.
  static const int Red = 0x1;
  /// Green channel of a buffer.
  static const int Green = 0x2;
  /// Blue channel of a buffer.
  static const int Blue = 0x4;
  /// Alpha channel of a buffer.
  static const int Alpha = 0x8;
  /// All buffer channels.
  static const int All = Red | Green | Blue | Alpha;
}

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

/// Defines input vertex data to the pipeline.
class InputLayoutElement {
  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  ///
  int _offset;
  int _usageIndex;
  int _format;
  int _usage;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  InputLayoutElement(int offset, int format, int usage, [int usageIndex = 0])
      : _offset = offset
      , _format = format
      , _usage = usage
      , _usageIndex = usageIndex;

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  int get offset => _offset;
  int get format => _format;
  int get usage => _usage;
  int get usageIndex => _usageIndex;
}

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

part of spectre_mesh;

/// Contains helper functions for generating mesh data.
///
/// Specifically [_VertexDataBuilder] holds methods that are common between
/// [NormalDataBuilder] and [TangentSpaceBuilder].
class _VertexDataBuilder {
  /// Gets the maximum vertex index.
  ///
  /// Uses the [offset], [length] and [lastIndex] to determine what the actual
  /// maximum index should be. This is computed by adding the [length] to the [offset].
  /// If that value is greater than [lastIndex] then [lastIndex] is returned.
  ///
  /// The value of [length] can be null. If that's the case then the value in
  /// [lastIndex] is always returned.
  static int _getMaxIndex(int offset, int length, int lastIndex) {
    if (length == null) {
      return lastIndex;
    } else {
      int maxIndex = offset + length;
      return Math.min(maxIndex, lastIndex);
    }
  }

  /// Helper method to add a [value] to the [array] at the given [index].
  ///
  /// A [temp] value is passed in to the function to prevent additional allocations.
  static void _addToVec3(int index, Vector3Array array, vec3 value, vec3 temp) {
    array.getAt(index, temp);
    temp.add(value);
    array.setAt(index, temp);
  }
}

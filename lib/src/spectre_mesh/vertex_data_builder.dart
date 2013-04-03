
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

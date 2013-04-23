/*
  Copyright (C) 2013 John McCutchan <john@johnmccutchan.com>
  Copyright (C) 2013 Don Olmstead <don.j.olmstead@gmail.com>

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

part of spectre_asset_pack;

/// Function signature for creating an [OpenGLTransmissionFormat] from a [Map].
///
/// Used when parsing a list of [OpenGLTransmissionFormat]s. The function
/// should just call the fromJson constructor of the format.
typedef OpenGLTransmissionFormat _CreateFormat(Map value);

/// Base class for OpenGL Transmission format readers.
class OpenGLTransmissionFormat {
  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// Whether the instance just refers to data defined elsewhere.
  bool _isReference;
  /// The name of the resource.
  ///
  /// This should be globally unique.
  String _name;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /// Creates an instance of the [OpenGLTransmissionFormat] where the data is
  /// in another instance.
  OpenGLTransmissionFormat._reference(String name)
      : _isReference = true
      , _name = name;

  /// Creates an instance of the [OpenGLTransmissionFormat] class from JSON
  /// data.
  OpenGLTransmissionFormat._fromJson(Map json)
      : _isReference = false
  {
    // Get the name
    _name = json['name'];

    if (_name == null) {
      throw new ArgumentError('A name was not provided');
    }
  }

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// Whether the instance just refers to data defined elsewhere.
  ///
  /// If the value is true then the [name] should be used to find the instance
  /// with the actual data; otherwise the instance will contain all the data
  /// required.
  bool get isReference => _isReference;

  /// The name of the resource.
  ///
  /// This should be globally unique.
  String get name => _name;

  //---------------------------------------------------------------------
  // Class methods
  //---------------------------------------------------------------------

  /// Parses a list containing a subclass of [OpenGLTransmissionFormat].
  ///
  /// Uses the [create] function to populate a [Map] containing the values
  /// where the [name] is the key value.
  static Map _parseList(List values, _CreateFormat create) {
    Map formats = new Map();

    values.forEach((value) {
      OpenGLTransmissionFormat format = create(value);

      if (formats.containsKey(format.name)) {
        throw new ArgumentError('The name ${format.name} is not unique');
      }

      formats[format.name] = format;
    });

    return formats;
  }
}

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

/// Defines a [Shader] asset to load.
///
/// This corresponds roughly to the shader specification within the [OpenGL
/// Transmission Format (glTF)]
/// (https://github.com/KhronosGroup/glTF/blob/master/specification/README.md#shader)
/// with the addition of a field that can hold the source code.
class ShaderFormat extends OpenGLTransmissionFormat {
  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The url for the resource shader source.
  String _url;
  /// The source for the shader.
  String _source;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /// Creates an instance of the [ShaderFormat] where the data is in another instance.
  ShaderFormat.reference(String name)
      : super._reference(name);

  /// Creates an instance of the [ShaderFormat] class from JSON data.
  ShaderFormat.fromJson(Map json)
      : super._fromJson(json)
  {
    // Get the URL or source.
    _url    = json['path'];
    _source = json['source'];

    // Make sure some data is present
    if ((_url == null) && (_source == null)) {
      throw new ArgumentError('Neither source nor a data uri was provided');
    }

    // Make sure only one path to the source is available.
    if ((_url != null) && (_source != null)) {
      throw new ArgumentError('Both source and a data uri was provided');
    }
  }

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// The name of the resource.
  ///
  /// This should be globally unique.
  String get name => _name;

  /// The url for the resource shader source.
  String get url => _url;

  /// The source for the shader.
  String get source => _source;

  /// Whether the source code is already loaded.
  bool get hasSource => _source != null;

  //---------------------------------------------------------------------
  // Class methods
  //---------------------------------------------------------------------

  /// Parses a list containing [ShaderFormat]s.
  ///
  /// Returns a [Map] containing the [ShaderFormat]s where the [name] is the
  /// key value.
  static Map<String, ShaderFormat> parseList(List formats) {
    var create = (value) => new ShaderFormat.fromJson(value);

    return OpenGLTransmissionFormat._parseList(formats, create);
  }
}

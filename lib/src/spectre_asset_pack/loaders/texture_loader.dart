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

part of spectre_asset_pack;

/// Loads a [Texture] resource.
///
///
class TextureLoader extends AssetLoader {
  ///
  Future<dynamic> load(AssetRequest assetRequest) {
    Map loadArguments = assetRequest.loadArguments;
    String extension;

    // See if the format is specified within the asset request
    if (loadArguments.containsKey('extension')) {
      extension = loadArguments['extension'];
    } else {
      extension = _getExtension(assetRequest.assetURL);
    }

    AssetLoader loader;

    // Check based on the extension what type of file this is
    if (_isImageElement(extension)) {
      loader = new ImageLoader();
    } else if (_isCompressedFormat(extension)) {
      loader = new ArrayBufferLoader();
    } else {
      // \todo is there a fallback? Maybe a null loader?
    }

    return loader.load(assetRequest);
  }

  /// Deletes the loaded resource.
  void delete(dynamic arg) {}

  /// Checks to see if the resource can be loaded into an [ImageElement].
  ///
  /// The following image types can be loaded into an [ImageElement].
  /// * .png
  /// * .gif
  /// * .jpeg, .jpg
  /// * .webp
  static bool _isImageElement(String extension) {
    switch (extension) {
      case 'png' :
      case 'gif' :
      case 'jpeg':
      case 'jpg' :
      case 'webp': return true;
    }

    return false;
  }

  /// Checks to see if the resource is a compressed format.
  ///
  /// Just checks for DDS currently. Expecting more formats to be added later.
  static bool _isCompressedFormat(String extension) {
    return extension == 'dds';
  }

  /// \todo REMOVE Add to AssetResource
  static String _getExtension(String path) {
    return path.substring(path.lastIndexOf('.') + 1).toLowerCase();
  }
}

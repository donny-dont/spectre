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

/// Importer for [Texture]s.
///
/// The [TextureImporter] takes the following arguments.
/// * surfaceFormat - Specifies the [SurfaceFormat] to use. This is only
///   applicable when [ImageElement]s are loaded. By default this value
///   is [SurfaceFormat.Rgba].
/// * generateMipmaps - Whether mip maps should be generated. This value is
///   only applicable when [ImageElement]s are loaded. By default this value
///   is true. If the [ImageElement] is a non-power of two mipmap generation
///   will be ignored.
class TextureImporter extends AssetImporter {
  //---------------------------------------------------------------------
  // Class variables
  //---------------------------------------------------------------------

  /// The argument name for specifying the surface format.
  static const String _surfaceFormatArgument = 'surfaceFormat';
  /// The argument name for specifying whether mipmaps should be generated.
  static const String _generateMipmapsArgument = 'generateMipmaps';

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The [GraphicsDevice] to create the [Texture] with.
  GraphicsDevice _graphicsDevice;

  /// Creates an instance of the [TextureImporter] class.
  TextureImporter(GraphicsDevice graphicsDevice)
      : _graphicsDevice = graphicsDevice;

  void initialize(Asset asset) {
    // Set the default values for the importer
    Map importArguments = asset.importArguments;

    importArguments.putIfAbsent(_surfaceFormatArgument, 'SurfaceFormat.Rgba');
    importArguments.putIfAbsent(_generateMipmapsArgument, true);

    // Can't initialize the actual asset yet
  }

  Future<dynamic> import(dynamic payload, Asset asset) {
    // Check the payload type to determine what to load
    if (payload is ImageElement) {
      return _importImageElement(payload, asset);
    } else if (payload is ArrayBuffer) {
      // Currently there's only DDS support
      // If more compressed formats are added change accordingly
      return _importDdsTexture(payload, asset);
    } else {

    }
  }

  Future<dynamic> _importImageElement(ImageElement payload, Asset asset) {
    asset.imported = new Texture2D(asset.name, _graphicsDevice);

    Map importerArguments = asset.importerArguments;

    // Upload the asset
    asset.imported.uploadElement(payload, surfaceType);

    // Generate mipmaps
    if (importerArguments[_generateMipmapsArgument]) {
      asset.imported.generateMipmaps();
    }
  }

  Future<dynamic> _importDdsTexture(ArrayBuffer payload, Asset asset) {
    DdsFile dds = new DdsFile(payload);

    // Not supported currently in WebGL
    if (dds.isVolumeTexture) {
      return new Future.immediate(asset);
    }

    int width = dds.width;
    int height = dds.height;
    int resourceFormat = dds.resourceFormat;

    if (dds.isCubeMap) {

    } else {
      Texture2D texture = new Texture2D(asset.name, _graphicsDevice);
      int surfaceFormat = DdsResourceFormat.toSurfaceFormat(resourceFormat);

      // Need a way to translate to SurfaceFormat
      if (DdsResourceFormat.isBlockCompressed(resourceFormat)) {
        Uint8Array array = new Uint8Array.fromBuffer(dds.getPixelData(0, 0));

        texture.uploadPixelArray(width, height, array, pixelFormat: surfaceFormat);
      } else {

      }
    }

    return new Future.immediate(asset);
  }

  void delete(dynamic imported) {
    assert(imported is SpectreTexture);
    if (imported != null) {
      imported.dispose();
    }
  }
}

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

class TextureImporter extends AssetImporter {
  final GraphicsDevice device;
  dynamic get fallback => null;

  TextureImporter(this.device);

  Future<dynamic> import(dynamic payload, AssetRequest assetRequest) {
    // Check the payload type to determine what to load
    if (payload is ImageElement) {

    } else if (payload is ArrayBuffer) {
      // Currently there's only DDS support
      // If more compressed formats are added change accordingly
      return _importDdsTexture(payload, assetRequest);
    } else {

    }
  }

  Future<dynamic> _importDdsTexture(ArrayBuffer payload, AssetRequest assetRequest) {
    DdsFile dds = new DdsFile(payload);

    // Not supported currently in WebGL
    if (dds.isVolumeTexture) {
      return new Future.immediate(fallback);
    }

    int width = dds.width;
    int height = dds.height;
    int resourceFormat = dds.resourceFormat;

    if (dds.isCubeMap) {

    } else {
      Texture2D texture = new Texture2D(assetRequest.name, device);

      // Need a way to translate to SurfaceFormat
      if (DdsResourceFormat.isBlockCompressed(resourceFormat)) {
        Uint8Array array = new Uint8Array.fromBuffer(dds.getPixelData(0, 0));

        texture.uploadPixelArray(width, height, array, pixelFormat: 0x83F0);
      } else {

      }

      return new Future.immediate(texture);
    }
  }

  void delete(dynamic imported) {
    imported.dispose();
  }
}

/*
  Copyright (C) 2013 John McCutchan <john@johnmccutchan.com>

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

class Tex2DImporter extends AssetImporter {
  final GraphicsDevice device;
  Tex2DImporter(this.device);

  void initialize(Asset asset) {
    asset.imported = new Texture2D(asset.name, device);
  }
  Texture2D _processImageElement(Asset request, ImageElement pixels) {
    var tex2d = new Texture2D(request.name, device);
    tex2d.uploadElement(pixels);
    return tex2d;
  }

  Future<dynamic> import(dynamic payload, Asset asset) {
    if (payload is ImageElement) {
      asset.imported.uploadElement(payload);
      // TODO (johnmccutchan): Support an import argument specifying mipmap
      // logic. For now, always generate them.
      asset.imported.generateMipmap();
    }
    return new Future.value(asset);
  }

  void delete(dynamic imported) {
    assert(imported is Texture2D);
    if (imported != null) {
      print('Deleting ${imported.name}');
      imported.dispose();
    }
  }
}

class TexCubeImporter extends AssetImporter {
  final GraphicsDevice device;
  TexCubeImporter(this.device);

  void initialize(Asset asset) {
    asset.imported = new TextureCube(asset.name, device);
  }

  Future<dynamic> import(dynamic payload, Asset asset) {
    if (payload is List<ImageElement>) {
      assert(payload.length == 6);  //  6 sides.
      if (payload[0] != null &&
          payload[1] != null &&
          payload[2] != null &&
          payload[3] != null &&
          payload[4] != null &&
          payload[5] != null) {
        TextureCube texCube = asset.imported;
        texCube.positiveX.uploadElement(payload[0]);
        texCube.negativeX.uploadElement(payload[1]);
        texCube.positiveY.uploadElement(payload[2]);
        texCube.negativeY.uploadElement(payload[3]);
        texCube.positiveZ.uploadElement(payload[4]);
        texCube.negativeZ.uploadElement(payload[5]);
        // TODO (johnmccutchan): Support an import argument specifying mipmap
        // logic. For now, always generate them.
        texCube.generateMipmap();
      }
    }
    return new Future.value(asset);
  }

  void delete(dynamic imported) {
    assert(imported is TextureCube);
    print('Deleting ${imported.name}');
    imported.dispose();
  }
}

class _ImagePackLoader extends AssetLoader {
  Future<dynamic> load(Asset asset) {
    TextLoader loader = new TextLoader();
    ImageLoader imgLoader = new ImageLoader();
    Future<String> futureText = loader.load(asset);
    return futureText.then((text) {
      List parsed;
      try {
        parsed = JSON.parse(text);
      } catch (e) {
        return new Future.value(null);
      }
      var futureImages = new List<Future<ImageElement>>();
      parsed.forEach((String imgSrc) {
        Asset imgRequest = new Asset(null, imgSrc, asset.baseUrl, imgSrc,
                                     asset.type, null, asset.loaderArguments,
                                     null, asset.importerArguments);
        Future futureImg = imgLoader.load(imgRequest);
        futureImages.add(futureImg);
      });
      return Future.wait(futureImages);
    });
  }

  void delete(dynamic arg) {
  }
}
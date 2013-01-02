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

class _AssetImporterTex2D extends AssetImporter {
  final GraphicsDevice device;
  dynamic get fallback => null;

  _AssetImporterTex2D(this.device);

  Texture2D _processImageElement(AssetRequest request, ImageElement pixels) {
    Texture2D tex2d = device.createTexture2D(request.name);
    tex2d.uploadElement(pixels);
    // TODO (johnmccutchan): Support an import argument specifying mipmap logic.
    // For now, always generate them.
    tex2d.generateMipmap();
    return tex2d;
  }

  Future<dynamic> import(dynamic payload, AssetRequest request) {
    if (payload is ImageElement) {
      return new Future.immediate(_processImageElement(request, payload));
    }
    return new Future.immediate(fallback);
  }

  void delete(dynamic imported) {
    assert(imported is Texture2D);
    device.deleteDeviceChild(imported);
  }
}

class _AssetImporterTexCube extends AssetImporter {
  final GraphicsDevice device;
  dynamic get fallback => null;

  _AssetImporterTexCube(this.device);

  TextureCube _processImageElements(String name, List<ImageElement> sides) {
    TextureCube texCube = device.createTextureCube(name);
    texCube.positiveX.uploadElement(sides[0]);
    texCube.negativeX.uploadElement(sides[1]);
    texCube.positiveY.uploadElement(sides[2]);
    texCube.negativeY.uploadElement(sides[3]);
    texCube.positiveZ.uploadElement(sides[4]);
    texCube.negativeZ.uploadElement(sides[5]);
    // TODO (johnmccutchan): Support an import argument specifying mipmap logic.
    // For now, always generate them.
    texCube.generateMipmap();
    return texCube;
  }

  Future<dynamic> import(dynamic payload, AssetRequest request) {
    if (payload is List<ImageElement>) {
      assert(payload.length == 6);  //  6 sides.
      if (payload[0] != null &&
          payload[1] != null &&
          payload[2] != null &&
          payload[3] != null &&
          payload[4] != null &&
          payload[5] != null) {
        return new Future.immediate(_processImageElements(request.name,
                                                          payload));
      }
    }
    return new Future.immediate(fallback);
  }

  void delete(dynamic imported) {
    assert(imported is TextureCube);
    device.deleteDeviceChild(imported);
  }
}

class _ImagePackLoader extends AssetLoader {
  Future<dynamic> load(AssetRequest request) {
    AssetLoaderText loader = new AssetLoaderText();
    Future<String> futureText = loader.load(request);
    Completer completer = new Completer();
    futureText.then((text) {
      try {
        List parsed = JSON.parse(text);
        List<Future<ImageElement>> futureImages = new List();
        parsed.forEach((String imgSrc) {
          AssetLoaderImage imgLoader = new AssetLoaderImage();
          AssetRequest imgRequest = new AssetRequest(imgSrc, request.baseURL,
                                                     imgSrc, request.type,
                                                     request.loadArguments,
                                                     request.importArguments);
          Future futureImg = imgLoader.load(imgRequest);
          futureImages.add(futureImg);
        });
        Futures.wait(futureImages).then((images) {
          completer.complete(images);
        });
      } catch (e) {
        completer.complete(null);
      }
    });
    return completer.future;
  }

  void delete(dynamic arg) {
  }
}
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
  dynamic get fallback => null;

  Tex2DImporter(this.device);

  Texture2D _processImageElement(AssetRequest request, ImageElement pixels) {
    var tex2d = new Texture2D(request.name, device);
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
    print('Deleting ${imported.name}');
    imported.dispose();
  }
}

class TexCubeImporter extends AssetImporter {
  final GraphicsDevice device;
  dynamic get fallback => null;

  TexCubeImporter(this.device);

  TextureCube _processImageElements(String name, List<ImageElement> sides) {
    var texCube = new TextureCube(name, device);
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
    print('Deleting ${imported.name}');
    imported.dispose();
  }
}

class _ImagePackLoader extends AssetLoader {
  Future<dynamic> load(AssetRequest request) {
    TextLoader loader = new TextLoader();
    ImageLoader imgLoader = new ImageLoader();
    Future<String> futureText = loader.load(request);
    return futureText.then((text) {
      List parsed;
      try {
        parsed = JSON.parse(text);
      } catch (e) {
        return new Future.immediate(null);
      }
      var futureImages = new List<Future<ImageElement>>();
      parsed.forEach((String imgSrc) {
        AssetRequest imgRequest = new AssetRequest(imgSrc, request.baseURL,
                                                   imgSrc, request.type,
                                                   request.loadArguments,
                                                   request.importArguments,
                                                   request.trace);
        Future futureImg = imgLoader.load(imgRequest);
        futureImages.add(futureImg);
      });
      return Future.wait(futureImages);
    });
  }

  void delete(dynamic arg) {
  }
}
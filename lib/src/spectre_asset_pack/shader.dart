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

class VertexShaderImporter extends AssetImporter {
  final GraphicsDevice device;
  VertexShaderImporter(this.device);

  void initialize(Asset asset) {
    VertexShader vs = new VertexShader(asset.name, device);
    asset.imported = vs;
  }

  Future<dynamic> import(dynamic payload, Asset asset) {
    if (payload is String) {
      VertexShader vs = asset.imported;
      vs.source = payload;
      vs.compile();
      print('Compiled vertex shader ${asset.name}: ${vs.compileLog}');

    }
    return new Future.immediate(asset);
  }

  void delete(VertexShader imported) {
    if (imported == null) {
      return;
    }
    print('Deleting vertex shader ${imported.name}');
    imported.dispose();
  }
}

class FragmentShaderImporter extends AssetImporter {
  final GraphicsDevice device;
  FragmentShaderImporter(this.device);
  void initialize(Asset asset) {
    FragmentShader fs = new FragmentShader(asset.name, device);
    asset.imported = fs;
  }
  Future<dynamic> import(dynamic payload, Asset asset) {
    if (payload is String) {
      FragmentShader fs = asset.imported;
      fs.source = payload;
      fs.compile();
      print('Compiled fragment shader ${asset.name}: ${fs.compileLog}');
    }
    return new Future.immediate(asset);
  }

  void delete(FragmentShader imported) {
    if (imported == null) {
      return;
    }
    print('Deleting fragment shader ${imported.name}');
    imported.dispose();
  }
}

class _TextListLoader extends AssetLoader {
  Future<dynamic> load(Asset asset) {
    TextLoader loader = new TextLoader();
    Future<String> futureText = loader.load(asset);
    return futureText.then((text) {
      List parsed;
      try {
        parsed = JSON.parse(text);
      } catch (e) {
        return new Future.immediate(null);
      }
      List<Future<String>> futureTexts = new List();
      parsed.forEach((String textSrc) {
        Asset textRequest = new Asset(null, textSrc, asset.baseUrl, textSrc,
                                      asset.type, null, {}, null, {});
        var futureText = loader.load(textRequest);
        futureTexts.add(futureText);
      });
      return Future.wait(futureTexts);
    });
  }

  void delete(dynamic arg) {
  }
}

class ShaderProgramImporter extends AssetImporter {
  final GraphicsDevice device;
  ShaderProgramImporter(this.device);

  void initialize(Asset asset) {
    ShaderProgram sp = new ShaderProgram(asset.name, device);
    VertexShader vs = new VertexShader(asset.name, device);
    FragmentShader fs = new FragmentShader(asset.name, device);
    sp.vertexShader = vs;
    sp.fragmentShader = fs;
    asset.imported = sp;
  }

  Future<dynamic> import(dynamic payload, Asset asset) {
    ShaderProgram sp = asset.imported;
    if (payload is List && payload.length == 2) {
      String vertexShaderSource = payload[0];
      String fragmentShaderSource = payload[1];
      bool shouldLink = false;
      if (vertexShaderSource is String) {
        VertexShader vs = sp.vertexShader;
        vs.source = vertexShaderSource;
        vs.compile();
        shouldLink = true;
        print('Compiled vertex shader ${asset.name}: ${vs.compileLog}');
      }
      if (fragmentShaderSource is String) {
        FragmentShader fs = sp.fragmentShader;
        fs.source = fragmentShaderSource;
        fs.compile();
        shouldLink = true;
        print('Compiled fragment shader ${asset.name}: ${fs.compileLog}');
      }
      if (shouldLink) {
        sp.link();
      }
    }
    return new Future.immediate(asset);
  }

  void delete(ShaderProgram imported) {
    if (imported == null) {
      return;
    }
    print('Deleting shader program ${imported.name}');
    imported.vertexShader.dispose();
    imported.fragmentShader.dispose();
    imported.dispose();
  }
}
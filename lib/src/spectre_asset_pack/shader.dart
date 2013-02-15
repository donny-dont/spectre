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
  dynamic get fallback => null;

  VertexShaderImporter(this.device);

  Future<dynamic> import(dynamic payload, AssetRequest request) {
    if (payload == null) {
      return new Future.immediate(fallback);
    }
    String shaderSource = payload;
    VertexShader vs = new VertexShader(request.name, device);
    vs.source = shaderSource;
    vs.compile();
    print('Compiled vertex shader ${request.name}: ${vs.compileLog}');
    return new Future.immediate(vs);
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
  dynamic get fallback => null;

  FragmentShaderImporter(this.device);
  Future<dynamic> import(dynamic payload, AssetRequest request) {
    if (payload == null) {
      return new Future.immediate(fallback);
    }
    String shaderSource = payload;
    FragmentShader fs = new FragmentShader(request.name, device);
    fs.source = shaderSource;
    fs.compile();
    print('Compiled fragment shader ${request.name}: ${fs.compileLog}');
    return new Future.immediate(fs);
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
  Future<dynamic> load(AssetRequest request) {
    TextLoader loader = new TextLoader();
    Future<String> futureText = loader.load(request);
    Completer completer = new Completer();
    futureText.then((text) {
      try {
        List parsed = JSON.parse(text);
        List<Future<String>> futureTexts = new List();
        parsed.forEach((String textSrc) {
          AssetRequest textRequest = new AssetRequest(textSrc, request.baseURL,
                                                      textSrc, request.type,
                                                      request.loadArguments,
                                                      request.importArguments);
          var futureText = loader.load(textRequest);
          futureTexts.add(futureText);
        });
        Future.wait(futureTexts).then((text) {
          completer.complete(text);
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

class ShaderProgramImporter extends AssetImporter {
  final GraphicsDevice device;
  dynamic get fallback => null;

  ShaderProgramImporter(this.device);

  Future<dynamic> import(dynamic payload, AssetRequest request) {
    if (payload == null) {
      return new Future.immediate(fallback);
    }
    List<String> sources = payload;
    String vertexShaderSource = sources[0];
    String fragmentShaderSource = sources[1];
    if (vertexShaderSource == null || fragmentShaderSource == null) {
      return new Future.immediate(fallback);
    }
    VertexShader vs = new VertexShader(request.name, device);
    vs.source = vertexShaderSource;
    vs.compile();
    print('Compiled vertex shader ${request.name}: ${vs.compileLog}');
    FragmentShader fs = new FragmentShader(request.name, device);
    fs.source = fragmentShaderSource;
    fs.compile();
    print('Compiled fragment shader ${request.name}: ${fs.compileLog}');
    ShaderProgram sp = new ShaderProgram(request.name, device);
    sp.vertexShader = vs;
    sp.fragmentShader = fs;
    sp.link();
    print('Linked shader program ${request.name}: ${sp.linkLog}');
    return new Future.immediate(sp);
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
part of spectre;

/*

  Copyright (C) 2012 John McCutchan <john@johnmccutchan.com>

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

class _ResourceLoaderResult {
  bool success;
  dynamic data;
  int handle;
  Completer<int> completer;
  _ResourceLoaderResult(this.success, this.data) {
    handle = 0;
  }
}

abstract class _ResourceLoader {
  bool canLoad(String URL, String extension) {
    return false;
  }

  Future<_ResourceLoaderResult> load(String url);

  dynamic createResource(String URL, ResourceManager rm) {
    return null;
  }
}


class _ImageResourceLoader extends _ResourceLoader {
  bool canLoad(String URL, String extension) {
    return extension == 'jpeg' || extension == 'jpg' || extension == 'png' || extension == 'gif';
  }

  Future<_ResourceLoaderResult> load(String url) {
    ImageElement image = new ImageElement();
    Completer<_ResourceLoaderResult> completer = new Completer<_ResourceLoaderResult>();
    image.on.load.add((event) {
      _ResourceLoaderResult r = new _ResourceLoaderResult(true, image);
      spectreLog.Info('Request for $url succesful.');
      completer.complete(r);
    });
    image.on.error.add((event) {
      _ResourceLoaderResult r = new _ResourceLoaderResult(false, image);
      spectreLog.Info('Request for $url failed..');
      completer.complete(r);
    });
    // Initiate load
    image.src = url;
    return completer.future;
  }

  ImageResource createResource(String url, ResourceManager rm) => new ImageResource(url, rm);
}

class _HttpResourceLoader extends _ResourceLoader {
  Future<_ResourceLoaderResult> load(String url) {
    Completer<_ResourceLoaderResult> completer = new Completer<_ResourceLoaderResult>();
    var req = new HttpRequest();
    req.open("GET", url, true);
    req.on.load.add((event) {
      _ResourceLoaderResult r = new _ResourceLoaderResult(req.response != null, req.response);
      spectreLog.Info('Request for $url succesful.');
      completer.complete(r);
    });
    req.on.error.add((event) {
      _ResourceLoaderResult r = new _ResourceLoaderResult(false, req.response);
      spectreLog.Info('Request for $url failed.');
      completer.complete(r);
    });
    // Initiate load
    req.send();

    return completer.future;
  }
}

class _MeshResourceLoader extends _HttpResourceLoader {
  bool canLoad(String URL, String extension) {
    return extension == 'mesh';
  }

  MeshResource createResource(String url, ResourceManager rm) => new MeshResource(url, rm);
}

class _ShaderResourceLoader extends _HttpResourceLoader {
  bool canLoad(String URL, String extension) {
    return extension == 'vs' || extension == 'fs';
  }

  ShaderResource createResource(String url, ResourceManager rm) => new ShaderResource(url, rm);
}

class _ShaderProgramResourceLoader extends _HttpResourceLoader {
  bool canLoad(String URL, String extension) {
    return extension == 'sp';
  }

  ShaderProgramResource createResource(String url, ResourceManager rm) => new ShaderProgramResource(url, rm);
}

class _PackResourceLoader extends _HttpResourceLoader {
  bool canLoad(String URL, String extension) {
    return extension == 'pack';
  }

  PackResource createResource(String url, ResourceManager rm) => new PackResource(url, rm);
}

class _RenderConfigResourceLoader extends _HttpResourceLoader {
  bool canLoad(String URL, String extension) {
    return extension == 'rc';
  }

  RenderConfigResource createResource(String url, ResourceManager rm) => new RenderConfigResource(url, rm);
}

class _SceneResourceLoader extends _HttpResourceLoader {
  bool canLoad(String URL, String extension) {
    return extension == 'scene';
  }

  SceneResource createResource(String url, ResourceManager rm) => new SceneResource(url, rm);
}

class ResourceLoaders {
  static String urlExtension(String URL) {
    List<String> chunks = URL.split('.');
    if (chunks.length > 0) {
      return chunks.last;
    }
    return '';
  }

  List<_ResourceLoader> _resourceLoaders;

  ResourceLoaders() {
    _resourceLoaders = new List();
    _resourceLoaders.add(new _ImageResourceLoader());
    _resourceLoaders.add(new _ShaderResourceLoader());
    _resourceLoaders.add(new _MeshResourceLoader());
    _resourceLoaders.add(new _PackResourceLoader());
    _resourceLoaders.add(new _ShaderProgramResourceLoader());
    _resourceLoaders.add(new _RenderConfigResourceLoader());
    _resourceLoaders.add(new _SceneResourceLoader());
  }

  _ResourceLoader findResourceLoader(String URL) {
    String extension = urlExtension(URL);
    for (_ResourceLoader loader in _resourceLoaders) {
      if (loader.canLoad(URL, extension)) {
        return loader;
      }
    }
    return null;
  }
}
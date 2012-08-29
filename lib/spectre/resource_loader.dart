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

class ResourceLoaderResult {
  bool success;
  Dynamic data;
  int handle;
  Completer<int> completer;
  ResourceLoaderResult(this.success, this.data) {
    handle = 0;
  }
}

class ResourceLoader {
  bool canLoad(String URL, String extension) {
    return false;
  }

  abstract Future<ResourceLoaderResult> load(String url);

  Dynamic createResource(String URL, ResourceManager rm) {
    return null;
  }
}


class ImageResourceLoader extends ResourceLoader {
  bool canLoad(String URL, String extension) {
    return extension == 'jpeg' || extension == 'jpg' || extension == 'png' || extension == 'gif';
  }

  Future<ResourceLoaderResult> load(String url) {
    ImageElement image = new ImageElement();
    Completer<ResourceLoaderResult> completer = new Completer<ResourceLoaderResult>();
    image.on.load.add((event) {
      ResourceLoaderResult r = new ResourceLoaderResult(true, image);
      completer.complete(r);
    });
    // Initiate load
    image.src = url;
    spectreLog.Info('Request for $url was handled by ImageResourceLoader.');
    return completer.future;
  }

  ImageResource createResource(String url, ResourceManager rm) => new ImageResource(url, rm);
}

class HttpResourceLoader extends ResourceLoader {
  Future<ResourceLoaderResult> load(String url) {
    Completer<ResourceLoaderResult> completer = new Completer<ResourceLoaderResult>();
    var req = new HttpRequest();
    req.open("GET", url, true);
    req.on.load.add((event) {
      ResourceLoaderResult r = new ResourceLoaderResult(req.response != null, req.response);
      completer.complete(r);
    });
    // Initiate load
    req.send();
    spectreLog.Info('Request for $url was handled by HttpResourceLoader.');
    return completer.future;
  }
}

class MeshResourceLoader extends HttpResourceLoader {
  bool canLoad(String URL, String extension) {
    return extension == 'mesh';
  }

  MeshResource createResource(String url, ResourceManager rm) => new MeshResource(url, rm);
}

class ShaderResourceLoader extends HttpResourceLoader {
  bool canLoad(String URL, String extension) {
    return extension == 'vs' || extension == 'fs';
  }

  ShaderResource createResource(String url, ResourceManager rm) => new ShaderResource(url, rm);
}

class ShaderProgramResourceLoader extends HttpResourceLoader {
  bool canLoad(String URL, String extension) {
    return extension == 'sp';
  }
  
  ShaderProgramResource createResource(String url, ResourceManager rm) => new ShaderProgramResource(url, rm);
}

class PackResourceLoader extends HttpResourceLoader {
  bool canLoad(String URL, String extension) {
    return extension == 'pack';
  }
  
  PackResource createResource(String url, ResourceManager rm) => new PackResource(url, rm);
}

class ResourceLoaders {
  static String urlExtension(String URL) {
    List<String> chunks = URL.split('.');
    if (chunks.length > 0) {
      return chunks.last();
    }
    return '';
  }

  List<ResourceLoader> _resourceLoaders;

  ResourceLoaders() {
    _resourceLoaders = new List();
    _resourceLoaders.add(new ImageResourceLoader());
    _resourceLoaders.add(new ShaderResourceLoader());
    _resourceLoaders.add(new MeshResourceLoader());
    _resourceLoaders.add(new PackResourceLoader());
    _resourceLoaders.add(new ShaderProgramResourceLoader());
  }

  ResourceLoader findResourceLoader(String URL) {
    String extension = urlExtension(URL);
    for (ResourceLoader loader in _resourceLoaders) {
      if (loader.canLoad(URL, extension)) {
        return loader;
      }
    }
    return null;
  }
}
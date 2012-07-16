class ResourceLoaderResult {
  bool success;
  Dynamic data;
  ResourceLoaderResult(this.success, this.data);
}

class ResourceLoader { 
  bool canLoad(String URL, String extension) {
    return false;
  }
  
  abstract Future<ResourceLoaderResult> load(String url);
  
  Dynamic createResource(String URL) {
    return null;
  }
}


class ImageResourceLoader extends ResourceLoader {
  bool canLoad(String URL, String extension) {
    return extension == 'jpeg' || extension == 'jpg' || extension == 'png';
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
  
  ImageResource createResource(String url) {
    return new ImageResource(url);
  }
}

class HttpResourceLoader extends ResourceLoader {
  Future<ResourceLoaderResult> load(String url) {
    Completer<ResourceLoaderResult> completer = new Completer<ResourceLoaderResult>();
    var req = new XMLHttpRequest();
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
  
  MeshResource createResource(String url) {
    return new MeshResource(url);
  }
}

class ShaderResourceLoader extends HttpResourceLoader {
  bool canLoad(String URL, String extension) {
    return extension == 'vs' || extension == 'fs';
  }
  
  ShaderResource createResource(String url) {
    return new ShaderResource(url);
  }
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
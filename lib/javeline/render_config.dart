class RenderResource {
  String name;
  String type;
  int width;
  int height;
  String format;
  int handle;
  RenderResource(this.name, this.type, this.width, this.height, this.format, this.handle);
}

class RenderLayer {
  String name;
  String sort;
  String type;
  int handle;
  RenderLayer(this.name, this.type, this.sort, this.handle);
}

class RenderConfig {
  Map _conf;
  Map<String, RenderLayer> _layers;
  Map<String, RenderResource> _buffers;
  Device _device;
  
  RenderConfig(this._device) {
    _buffers = new Map<String, RenderResource>();
    _layers = new Map<String, RenderLayer>();
  }
  
  void cleanup() {
    _layers.forEach((k,v) {
      spectreLog.Info('Destroying render layer $k');
      if (v.handle != 0) {
        _device.deleteDeviceChild(v.handle);  
      }
    });
    _layers.clear();
    _buffers.forEach((k,v) {
      spectreLog.Info('Destroying render resource $k');
      _device.deleteDeviceChild(v.handle);
    });
    _buffers.clear();
    _conf = null;
  }
  
  void setup() {
    List globalBuffers = _conf['global_buffers'];
    List layers = _conf['layers'];
    
    globalBuffers.forEach((bufferDesc) {
      String name = bufferDesc['name'];
      String type = bufferDesc['type'];
      int width = bufferDesc['width'];
      int height = bufferDesc['height'];
      String format = bufferDesc['format'];
      int handle = 0;
      if (type == 'depth') {
        handle = _device.createRenderBuffer(name, {
           'width': width,
           'height': height,
           'format': format,
        });
      } else {
        handle = _device.createTexture2D(name, {
            'width': width,
            'height': height,
            'format': format,
        });
      }
      if (handle == 0) {
        spectreLog.Error('Could not create render buffer $bufferDesc');
      } else {
        spectreLog.Info('Creating $type buffer $name');
        _buffers[name] = new RenderResource(name, type, width, height, format, handle);
      }
    });
    
    layers.forEach((layerDesc) {
      String name = layerDesc['name'];
      String type = layerDesc['type'];
      String color = layerDesc['color_target'];
      String depth = layerDesc['depth_target'];
      String sort = layerDesc['sort'];
      if (color == "system" && depth == "system") {
        // Layer only depends on system, 0 handle
        spectreLog.Info('Created system render layer $name');
        _layers[name] = new RenderLayer(name, type, sort, 0);
      } else {
        if (color == "system" || depth == "system") {
          spectreLog.Error('Cannot create a layer that uses some system and some non-system buffers');
        } else {
          int colorHandle = 0;
          int depthHandle = 0;
          if (color != null) {
            RenderResource cb = _buffers[color];
            colorHandle = cb.handle;
          }
          if (depth != null) {
            RenderResource db = _buffers[depth];
            depthHandle = db.handle;
          }
          int renderTargetHandle = 0;
          renderTargetHandle = _device.createRenderTarget(name, {
            'color0': colorHandle,
            'depth': depthHandle
          });
          if (renderTargetHandle == 0) {
            spectreLog.Error('Could not create render $layerDesc');
          } else {
            spectreLog.Info('Created render layer $name');
            _layers[name] = new RenderLayer(name, type, sort, renderTargetHandle);
          }
        }
      }
    });
  }
  
  int getBufferHandle(String bufferName) {
    RenderResource resource = _buffers[bufferName];
    return resource.handle;
  }
  
  int getLayerHandle(String layerName) {
    RenderLayer layer = _layers[layerName];
    return layer.handle;
  }
  
  void load(Map<String, Dynamic> conf) {
    cleanup();
    _conf = conf;
    setup();
  }
  
  void setupLayer(String layerName) {
    RenderLayer layer = _layers[layerName];
    _device.immediateContext.setRenderTarget(layer.handle);
  }
}

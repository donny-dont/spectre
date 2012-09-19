class Material extends SceneChild {
  int vertexShaderHandle;
  int fragmentShaderHandle;
  int shaderProgramHandle;
  Map<String, int> textureNameToUnit;
  Map entity;

  List<Map> meshinputs;
  Map uniformset;
  Material(String name, Scene scene) : super(name, scene) {
    vertexShaderHandle = 0;
    fragmentShaderHandle = 0;
    shaderProgramHandle = 0;
    textureNameToUnit = new Map<String, int>();
  }
  
  void delete() {
    scene.device.deleteDeviceChild(vertexShaderHandle);
    scene.device.deleteDeviceChild(fragmentShaderHandle);
    scene.device.deleteDeviceChild(shaderProgramHandle);
  }
  
  void processUniforms() {
    textureNameToUnit.clear();
    int textureUnitIndex = 0;
    scene.device.getDeviceChild(shaderProgramHandle).forEachUniforms((String name, int index, String type, int size, location) {
      if (type == 'sampler2D') {
        textureNameToUnit[name] = textureUnitIndex++;
      }
    });
  }

  static List<int> buildTextureHandleList(Map nameToUnit, Map nameToHandle) {
    if (nameToUnit == null) {
      print('null nameToUnit');
    }
    List<int> out = new List<int>(nameToUnit.length);
    nameToHandle.forEach((k, v) {
      int slot = nameToUnit[k];
      if (slot == null) {
        print('slot null');
      }
      int handle = v;
      out[slot] = handle;
    });
    return out;
  }

  static void updateTextureTable(Scene scene, Map textureNameToResourceName, Map textures, Map textureNameToHandle) {
    if (textures == null) {
      return;
    }
    textures.forEach((textureName, resourceName) {
      if (textureNameToResourceName[textureName] == resourceName) {
        // Already up to date
        return;
      }
      // New or changed texture resource
      textureNameToResourceName[textureName] = resourceName;
      int resourceTextureHandle = scene.device.getDeviceChildHandle(resourceName);
      if (resourceTextureHandle != Handle.BadHandle) {
        // Texture already exists, update table
        textureNameToHandle[textureName] = resourceTextureHandle;
        return;
      }
    });
  }
  
  static void updateSamplerTable(Scene scene, String prefix, Map textures, Map samplers, Map samplerNameToHandle) {
    if (textures == null || samplers == null) {
      return;
    }
    textures.forEach((textureName, _) {
      int handle = samplerNameToHandle[textureName];
      if (handle == null) {
        handle = scene.device.createSamplerState('$prefix.$textureName.sampler', {});
        samplerNameToHandle[textureName] = handle;
      }
      Map sampler = samplers[textureName];
      if (sampler != null) {
        scene.device.configureDeviceChild(handle, sampler);
      }
    });
  }
    
  void load(Map o) {
    entity = o;
    uniformset = o['uniformset'];
    meshinputs = o['meshinputs'];
    String shaderName = o['shader'];
    int handle = scene.resourceManager.getResourceHandle(shaderName);
    ShaderProgramResource spr = scene.resourceManager.getResource(handle);
    if (spr == null) {
      spectreLog.Error('Could not load $name');
      return;
    }
    if (vertexShaderHandle == 0) {
      vertexShaderHandle = scene.device.createVertexShader('$shaderName.vs', {});
    }
    if (fragmentShaderHandle == 0) {
      fragmentShaderHandle = scene.device.createFragmentShader('$shaderName.fs', {});
    }
    if (shaderProgramHandle == 0) {
      shaderProgramHandle = scene.device.createShaderProgram('$shaderName.sp', {});  
    }

    bool relink = false;
    VertexShader vs = scene.device.getDeviceChild(vertexShaderHandle);
    if (vs.source != spr.vertexShaderSource) {
      vs.source = spr.vertexShaderSource;
      vs.compile();
      relink = true;
    }
    
    FragmentShader fs = scene.device.getDeviceChild(fragmentShaderHandle);
    if (fs.source != spr.fragmentShaderSource) {
      fs.source = spr.fragmentShaderSource;
      fs.compile();
      relink = true;
    }
    
    ShaderProgram sp = scene.device.getDeviceChild(shaderProgramHandle);
    if (!sp.linked || relink) {
      scene.device.configureDeviceChild(shaderProgramHandle, {
        'VertexProgram': vertexShaderHandle,
        'FragmentProgram': fragmentShaderHandle,
      });
      processUniforms();
    }
  }
  
  void preDraw() {
    scene.device.immediateContext.setShaderProgram(shaderProgramHandle);
    if (uniformset != null) {
      uniformset.forEach((name, value) {
        scene.device.immediateContext.setUniform3f(name, value[0], value[1], value[2]);
      });
    }
  }
}
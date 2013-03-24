
part of spectre_asset_pack;

/// Importer for [Mesh]es.
///
/// [Mesh] data is held within a JSON file. See the [Mesh] file format
/// specification for information on the values held within the file.
///
/// The [MeshImporter] does not take any import arguments.
class MeshImporterRedux extends AssetImporter {
  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The [GraphicsDevice] to create the [Texture] with.
  GraphicsDevice _graphicsDevice;
  /// The [Base64Decoder] to use when processing encoded data.
  Base64Decoder _decoder = new Base64Decoder();

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /// Creates an instance of the [MeshImporter] class.
  MeshImporterRedux(GraphicsDevice graphicsDevice)
      : _graphicsDevice = graphicsDevice;

  void initialize(Asset asset) {
    // Can't initialize the actual asset yet
  }

  /// Imports the [Mesh] into Spectre.
  Future<Asset> import(dynamic payload, Asset asset) {
    if (payload != null) {
      // If the payload is a sting then we're dealing with JSON
      if (payload is String) {
        try {
          Map parsed = JSON.parse(payload);

          _importMesh(parsed, asset);
        } catch(_) {}
      }
    }

    return new Future.immediate(asset);
  }

  /// Processes the mesh.
  void _importMesh(Map meshValues, Asset asset) {
    // Load the individual vertex buffers
    int vertexBufferSlot = 0;
    List vertexBuffersData = meshValues['vertexBuffers'];
    List<VertexBuffer> vertexBuffers = new List<VertexBuffer>();
    InputLayout layout = new InputLayout('${asset.name}_layout', _graphicsDevice);

    vertexBuffersData.forEach((value) {
      // Load the vertex attributes
      int stride = value['stride'];

      value['layout'].forEach((layoutValue) {
        layout.elements.add(_createVertexElement(layoutValue, vertexBufferSlot, stride));
      });

      // Load the vertex buffer
      vertexBuffers.add(_createVertexBuffer(value['vertices'], '${asset.name}_vbo_${vertexBufferSlot}'));

      vertexBufferSlot++;
    });

    // Load the index buffer
    IndexBuffer indexBuffer = _createIndexBuffer(meshValues['indices'], 16, '${asset.name}_ibo');

    // Create the mesh
    asset.imported = new Mesh(asset.name, _graphicsDevice, vertexBuffers, layout, indexBuffer);
  }

  /// Creates a [VertexBuffer] from the given [values].
  VertexBuffer _createVertexBuffer(dynamic values, String name) {
    Float32Array vertices;

    // Get the vertices
    if (values is String) {
      ArrayBuffer buffer = _decoder.decode(values);

      vertices = new Float32Array.fromBuffer(buffer);
    } else {
      vertices = new Float32Array.fromList(values);
    }

    // Create the vertex buffer
    // \TODO Should the usage be specified in the format??
    VertexBuffer buffer = new VertexBuffer(name, _graphicsDevice);
    buffer.uploadData(vertices, SpectreBuffer.UsageStatic);

    return buffer;
  }

  /// Creates an [IndexBuffer] from the given [values].
  ///
  /// A [Mesh] does not always have an [IndexBuffer] associated with it so the
  /// return value could be null.
  IndexBuffer _createIndexBuffer(dynamic values, int size, String name) {
    if (values == null) {
      return null;
    }

    Uint16Array indices;

    // Get the indices
    // \TODO Support for UINT?
    if (values is String) {
      ArrayBuffer buffer = _decoder.decode(values);

      indices = new Uint16Array.fromBuffer(buffer);
    } else {
      indices = new Uint16Array.fromList(values);
    }

    // Create the index buffer
    IndexBuffer buffer = new IndexBuffer(name, _graphicsDevice);
    buffer.uploadData(indices, SpectreBuffer.UsageStatic);

    return buffer;
  }

  /// Creates a [SpectreMeshAttribute] from the given [values].
  InputLayoutElement _createVertexElement(Map values, int slot, int stride) {
    String name = values['name'];
    int index = _getAttributeIndex(name);
    DeviceFormat format = _getAttributeFormat(name);
    int offset = values['offset'];

    return new InputLayoutElement(slot, index, offset, stride, format);
  }

  /// \todo REMOVE!!!! This is a hack
  int _getAttributeIndex(String name) {
    switch (name) {
      case 'vPosition' : return 1;
      case 'vNormal'   : return 0;
      case 'vTangent'  : return 2;
      case 'vBitangent': return 3;
      case 'vTexCoord0': return 4;
    }

    return 5;
  }

  /// \todo REMOVE!!!! This is a hack
  DeviceFormat _getAttributeFormat(String name) {
    if (name == 'vTexCoord0') {
      return GraphicsDevice.DeviceFormatFloat2;
    } else {
      return GraphicsDevice.DeviceFormatFloat3;
    }
  }
}

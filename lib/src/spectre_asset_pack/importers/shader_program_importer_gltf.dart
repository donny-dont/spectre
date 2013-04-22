/*
  Copyright (C) 2013 Spectre Authors

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

/// Importer for [ShaderProgram]s using the OpenGL Transmission Format.
class ShaderProgramImporterGLTF extends AssetImporter {
  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The [GraphicsDevice] to create the [Texture] with.
  GraphicsDevice _graphicsDevice;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /// Creates an instance of the [ShaderProgramImporterGLTF] class.
  ShaderProgramImporterGLTF(GraphicsDevice graphicsDevice)
      : _graphicsDevice = graphicsDevice;

  //---------------------------------------------------------------------
  // Public methods
  //---------------------------------------------------------------------

  /// Initializes the [ShaderProgram] asset.
  void initialize(Asset asset) {
    ShaderProgram program = new ShaderProgram(asset.name, _graphicsDevice);

    asset.imported = program;
  }

  /// Imports the [ShaderProgram] into Spectre.
  Future<Asset> import(dynamic payload, Asset asset, AssetPackTrace tracer) {
    if (payload != null) {
      try {
        ProgramFormat format = new ProgramFormat.fromJson(payload);

        // Get the vertex shader
        ShaderFormat vertexFormat = format.vertexShader;

        VertexShader vertex = new VertexShader(
            vertexFormat.name,
            _graphicsDevice
        );

        vertex.source = vertexFormat.source;
        vertex.compile();

        // Get the fragment shader
        ShaderFormat fragmentFormat = format.fragmentShader;

        FragmentShader fragment = new FragmentShader(
            fragmentFormat.name,
            _graphicsDevice
        );

        fragment.source = fragmentFormat.source;
        fragment.compile();

        // Add to the program
        ShaderProgram program = asset.imported;

        program.vertexShader = vertex;
        program.fragmentShader = fragment;
        program.link();
      } on ArgumentError catch (e) {
        tracer.assetImportError(asset, e.message);
      } catch (_) {
        tracer.assetImportError(asset, 'An unknown error occurred');
      }
    }

    tracer.assetImportEnd(asset);

    return new Future.value(asset);
  }
}

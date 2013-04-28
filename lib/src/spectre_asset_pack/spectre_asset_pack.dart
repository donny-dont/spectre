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

/** Register the spectre graphics device with the asset_pack library.
 * asset manager. After calling this function, the asset manager
 * will be able to load meshes, textures, and shaders.
 */
void registerSpectreWithAssetManager(GraphicsDevice graphicsDevice,
                                     AssetManager assetManager) {
  assetManager.loaders['mesh'] = new TextLoader();
  assetManager.loaders['tex2d'] = new ImageLoader();
  assetManager.loaders['texCube'] = new _ImagePackLoader();
  assetManager.loaders['vertexShader'] = new TextLoader();
  assetManager.loaders['fragmentShader'] = new TextLoader();
  assetManager.loaders['shaderProgram'] = new _TextListLoader();

  assetManager.importers['mesh'] = new MeshImporter(graphicsDevice);
  assetManager.importers['tex2d'] = new Tex2DImporter(graphicsDevice);
  assetManager.importers['texCube'] = new TexCubeImporter(graphicsDevice);
  assetManager.importers['vertexShader'] =
      new VertexShaderImporter(graphicsDevice);
  assetManager.importers['fragmentShader'] =
      new FragmentShaderImporter(graphicsDevice);
  assetManager.importers['shaderProgram'] =
      new ShaderProgramImporter(graphicsDevice);
}
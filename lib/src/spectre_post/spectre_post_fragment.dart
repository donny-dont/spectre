part of spectre_post;

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

class SpectrePostFragment extends SpectrePostPass {
  final ShaderProgram shaderProgram;
  final InputLayout inputLayout;
  SpectrePostFragment(GraphicsDevice device, String name, this.shaderProgram,
                      this.inputLayout) : super() {
  }

  void cleanup(GraphicsDevice device) {
    shaderProgram.dispose();
  }

  void setup(GraphicsDevice device, Map<String, dynamic> args) {
    List<SpectreTexture> textures = args['textures'];
    List<SamplerState> samplers = args['samplers'];
    device.context.setTextures(0, textures);
    device.context.setSamplers(0, samplers);
    device.context.setShaderProgram(shaderProgram);
    device.context.setInputLayout(inputLayout);
  }
}

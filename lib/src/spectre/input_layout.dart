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

class _InputLayoutElement {
  int _vboSlot;
  int _vboOffset;
  int _attributeIndex;
  int _attributeStride;
  DeviceFormat _attributeFormat;

  String toString() {
    return 'Attribute $_attributeIndex bound to VBO: $_vboSlot VBO_OFFSET: $_vboOffset Attribute Stride: $_attributeStride Format: $_attributeFormat';
  }
}

/// A mapping of vertex buffers to shader program input attributes
/// Create using [Device.createInputLayout]
/// Set using [ImmediateContext.setInputLayout]
class InputLayout extends DeviceChild {
  int _maxAttributeIndex;
  List<_InputLayoutElement> _elements;
  List<InputElementDescription> _elementDescription;
  ShaderProgram _shaderProgram;

  InputLayout(String name, GraphicsDevice device) : super._internal(name, device) {
    _maxAttributeIndex = 0;
    _elements = null;
    _elementDescription = null;
  }

  void _createDeviceState() {
  }

  void _bind() {
    if (_elementDescription == null ||
        _elementDescription.length <= 0 ||
        _shaderProgram == null) {
      return;
    }

    _InputElementChecker checker = new _InputElementChecker();

    _maxAttributeIndex = -1;
    _elements = new List<_InputLayoutElement>();
    for (InputElementDescription e in _elementDescription) {
      checker.add(e);
      var index = device.gl.getAttribLocation(_shaderProgram._program, e.name);
      if (index == -1) {
        spectreLog.Warning('Can\'t find ${e.name} in ${_shaderProgram.name}');
        continue;
      }
      _InputLayoutElement el = new _InputLayoutElement();
      el._attributeIndex = index;
      if (index > _maxAttributeIndex) {
        _maxAttributeIndex = index;
      }
      el._attributeFormat = e.format;
      el._vboOffset = e.vertexBufferOffset;
      el._vboSlot = e.vertexBufferSlot;
      el._attributeStride = e.elementStride;
      _elements.add(el);
    }
  }

  void _configDeviceState(Map props) {

    dynamic o;

    o = props['shaderProgram'];
    if (o != null && o is ShaderProgram) {
      _shaderProgram = o;
    }
    o = props['elements'];
    if (o != null && o is List) {
      _elementDescription = o;
    }
    _bind();
  }
  void _destroyDeviceState() {
  }
}

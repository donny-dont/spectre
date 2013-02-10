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

part of spectre;

/// A resource created by a device
/// All resources have a [name]
abstract class DeviceChild extends Disposable implements Serializable {
  final GraphicsDevice device;
  final String name;
  String toString() => name;

  DeviceChild._internal(this.name, this.device) {
    if (device == null) {
      throw new ArgumentError('device cannot be null');
    }
  }

  dynamic toJson() {
    return '';
  }

  void fromJson(dynamic a) {
  }

  void finalize();
}

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

class HandleSystem {
  List<int> _handles;
  int _totalCapacity;
  int _staticCapacity;

  int _freeHead;

  int _dynamicUsed;
  int _dynamicCapacity;

  HandleSystem(this._totalCapacity, this._staticCapacity) {
    _handles = new List<int>(_totalCapacity);
    int i;
    for (i = 0; i < _staticCapacity; i++) {
      _handles[i] = Handle.makeStaticHandle(i, 0, 0);
    }
    _freeHead = i;
    for (; i < _totalCapacity; i++) {
      int next = i+1;
      if (next == _totalCapacity) {
        next = Handle.IndexMask;
      }
     _handles[i] = Handle.makeNextPointer(0, next);
    }
    _dynamicUsed = 0;
    _dynamicCapacity = _totalCapacity - _staticCapacity;;
  }

  int get maxStaticIndex() => _staticCapacity;
  int get dynamicSize() => _dynamicUsed;
  int get dynamicCapacity() => _dynamicCapacity;
  int get dynamicAvailable() => _dynamicCapacity - _dynamicUsed;

  /// Returns true if index is in the static range
  bool isStaticIndex(int index) => index >= 0 && index < _staticCapacity;

  /// Returns true if static index is free
  bool isStaticIndexFree(int index) {
    if (isStaticIndex(index) == false) {
      return false;
    }
    return Handle.checkStatusFlag(_handles[index], Handle.StatusUsed) == false;
  }

  /// Allocates a static handle at [index] with [type].
  /// Returns handle or [Handle.BadHandle] in case of error
  int allocateStaticIndex(int index, int type) {
    if (isStaticIndex(index) == false) {
      return Handle.BadHandle;
    }
    if (isStaticIndexFree(index) == false) {
      return Handle.BadHandle;
    }
    _handles[index] = Handle.makeStaticHandle(index, type, Handle.StatusUsed);
    return _handles[index];
  }

  /// Frees a static handle at [index]
  void freeStaticIndex(int index) {
    if (isStaticIndex(index) == false) {
      return;
    }
    _handles[index] = Handle.makeStaticHandle(index, 0, 0);
  }

  /// Allocates a static handle [handle]
  /// Returns [handle] or [Handle.BadHandle] in case of error
  int allocateStaticHandle(int handle) {
    int index = Handle.getIndex(handle);
    if (_isStaticHandle(handle) == false) {
      return Handle.BadHandle;
    }
    if (isStaticIndexFree(index) == false) {
      return Handle.BadHandle;
    }
    _handles[index] = handle;
    return handle;
  }

  /// Frees a static handle [handle]
  void freeStaticHandle(int handle) {
    int index = Handle.getIndex(handle);
    if (_isStaticHandle(handle) == false) {
      return;
    }
    _handles[index] = Handle.makeStaticHandle(index, 0, 0);
  }

  /// Set a static handle slot, no error checking
  /// Returns [handle] or [Handle.BadHandle] in case handle points outside of static area
  int setStaticHandle(int handle) {
    int index = Handle.getIndex(handle);
    if (_isStaticHandle(handle) == false) {
      return Handle.BadHandle;
    }
    _handles[index] = handle;
    return _handles[index];
  }

  /// Allocate a handle of [type] from the dynamic range
  /// Returns [handle] or [Handle.BadHandle]
  int allocateHandle(int type) {
    if (_dynamicUsed == _dynamicCapacity) {
      return Handle.BadHandle;
    }
    _dynamicUsed++;
    // Take first free handle
    int index = _freeHead;
    // Move free pointer forward
    _freeHead = Handle.getIndex(_handles[index]);
    int handle = _handles[index];
    // Index points to next element, point it at ourselves
    handle = Handle.setIndex(handle, index);
    //print('Allocating index ${index}');
    // Update serial number
    handle = Handle.nextSerial(handle);
    // Update flags
    handle = Handle.clearStatusFlag(handle, Handle.StatusFreeList);
    handle = Handle.setStatusFlag(handle, Handle.StatusUsed);
    // Set type
    handle = Handle.setType(handle, type);
    // Update handles array
    _handles[index] = handle;
    // Return new handle
    return handle;
  }

  /// Free [handle] from the dynamic range
  void freeHandle(int handle) {
    if (_dynamicUsed == 0) {
      return;
    }
    _dynamicUsed--;

    int handleIndex = Handle.getIndex(handle);
    int handleSerial = Handle.getSerial(handle);
    _handles[handleIndex] = Handle.makeNextPointer(handleSerial, _freeHead);
    _freeHead = handleIndex;
  }

  /// Returns true if [handle] is valid
  bool validHandle(int handle) {
    int index = Handle.getIndex(handle);
    if (index < 0 || index >= _totalCapacity) {
      return false;
    }
    int indexHandle = _handles[index];
    return handle == indexHandle;
  }

  bool _isStaticHandle(int handle) {
    int index = Handle.getIndex(handle);
    return Handle.isStaticHandle(handle) && isStaticIndex(index);
  }

  void _dumpStaticTable() {
    print('Dumping static table');
    for (int i = 0; i < _staticCapacity; i++) {
      int handle = _handles[i];
      int type = Handle.getType(handle);
      if (Handle.checkStatusFlag(handle, Handle.StatusUsed)) {
        print('[${Handle.getIndex(handle)}] Used ($handle) (type: $type)');
      } else {
        print('[${Handle.getIndex(handle)}] Free ($handle)');
      }
    }
  }

  void _dumpFreeList() {
    print('Dumping dynamic free list $dynamicAvailable');
    int i = _freeHead;
    while (i != Handle.IndexMask) {
      int serial = Handle.getSerial(_handles[i]);
      int next = Handle.getIndex(_handles[i]);
      print('$i ($serial) -> $next');
      i = next;
    }
  }
}

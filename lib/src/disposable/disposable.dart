/*
  Copyright (C) 2013 John McCutchan

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

part of disposable;

/** An abstract class for a disposable object.
 * You must implement [finalize]
 */
abstract class Disposable {
  int _referenceCount = 1;
  bool _disposed = false;

  /** This object has been disposed. */
  bool get isDisposed => _disposed;
  /** Count of pins */
  int get pinCount => _referenceCount;

  /** Pin the disposable object. See [dispose] for inverse.
   * Throws an exception if this object is already disposed.
   */
  void pin() {
    if (_disposed) {
      throw new StateError('It is an error to pin a disposed object.');
      return;
    }
    _referenceCount++;
  }

  /** Disposes of the object. If nothing else has this object pinned,
   * the finalizer will be called. See [pin] for inverse. Throws
   * an exception if the object is already disposed.
   */
  void dispose() {
    if (_disposed) {
      throw new StateError('It is an error to dispose a disposed object.');
      return;
    }
    _referenceCount--;
    if (_referenceCount == 0) {
      finalize();
      _disposed = true;
    }
  }

  /** Clean up any object state here. */
  void finalize();
}
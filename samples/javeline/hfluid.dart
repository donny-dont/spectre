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

#library('hfluid');

class HeightFieldFluidColumn {
  num height;
  num velocityX;
  num velocityY;
  
  HeightFieldFluidColumn(this.height, this.velocityX, this.velocityY) {
    
  }
}

class HeightFieldFluid {
  final num columnWidth;
  final int columnsWide;
  final num globalVelocityX = 0.0;
  final num globalVelocityY = 0.0;
  static final int BoundaryNorth = 1;
  static final int BoundaryEast = 2;
  static final int BoundarySouth = 3;
  static final int BoundaryWest = 4;
  num _dt;
  num _dx;
  num _invDx;
  num _gravity;
  num _velocityScale;
  
  List<HeightFieldFluidColumn> columns;
  List<HeightFieldFluidColumn> _tempColumns;
  
  int columnIndex(int i, int j) => i + (columnsWide * j);
  
  HeightFieldFluid(this.columnsWide, this.columnWidth) {
    final int numColumns = columnsWide * columnsWide;
    _velocityScale = 0.90;
    _gravity = -10.0;
    _dt = 1.0 / columnsWide;
    num domainSize = (numColumns)/2.0;
    _dx = domainSize / numColumns;
    _invDx = 1.0 / _dx;
    
    
    columns = new List<HeightFieldFluidColumn>(numColumns);
    _tempColumns = new List<HeightFieldFluidColumn>(numColumns);
    for (int i = 0; i < numColumns; i++) {
      columns[i] = new HeightFieldFluidColumn(1.0, 0.0, 0.0);
      _tempColumns[i] = new HeightFieldFluidColumn(1.0, 0.0, 0.0);
    }
  }
  
  num _interpolateVelocityX(num x, num y) {
    final int X = x.toInt();
    final int Y = y.toInt();
    final num s1 = x - X;
    final num s0 = 1.0 - s1;
    final num t1 = y - Y;
    final num t0 = 1.0 - t1;
    return s0*(t0* columns[X+columnsWide*Y].velocityX + t1*columns[X  +columnsWide*(Y+1)].velocityX )+ 
           s1*(t0* columns[(X+1)+columnsWide*Y].velocityX  + t1*columns[(X+1)+columnsWide*(Y+1)].velocityX);
  }
  
  void _advectVelocityX() {
    for (int i = 1; i < columnsWide-1; i++) {
      for (int j = 1; j < columnsWide-1; j++) {
        final int index = columnIndex(i, j);
        final int indexEast = index+1;
        final int indexNorth = index+columnsWide;
        final int indexNorthEast = index+columnsWide+1;
        num u = globalVelocityX;
        num v = globalVelocityY;
        
        u += columns[index].velocityX;
        v += (columns[index].velocityY + columns[indexEast].velocityY + columns[indexNorth].velocityY + columns[indexNorthEast].velocityY) * 0.25;
        
        // Project the water particle backwards in time to determine where it came from
        num sourceI = i - u * _dt * _invDx;
        num sourceJ = j - v * _dt * _invDx;
        // Clamp
        if (sourceI < 0.0) {
          sourceI = 0.0;
        } else if (sourceI > columnsWide-1) {
          sourceI = columnsWide-1;
        }
        if (sourceJ < 0.0) {
          sourceJ = 0.0;
        } else if (sourceJ > columnsWide-1) {
          sourceJ = columnsWide-1;
        }
        
        _tempColumns[index].velocityX = _interpolateVelocityX(sourceI, sourceJ);
      }
    }
    
    for (int i = 1; i < columnsWide-1; i++) {
      for (int j = 1; j < columnsWide-1; j++) {
        final int index = columnIndex(i, j);
        columns[index].velocityX = _tempColumns[index].velocityY;
      }
    }
  }
  
  num _interpolateVelocityY(num x, num y) {
    final int X = x.toInt();
    final int Y = y.toInt();
    final num s1 = x - X;
    final num s0 = 1.0 - s1;
    final num t1 = y - Y;
    final num t0 = 1.0 - t1;
    return s0*(t0* columns[X+columnsWide*Y].velocityY + t1*columns[X  +columnsWide*(Y+1)].velocityY)+ 
           s1*(t0* columns[(X+1)+columnsWide*Y].velocityY  + t1*columns[(X+1)+columnsWide*(Y+1)].velocityY);
  }
  
  
  void _advectVelocityY() {
    for (int i = 1; i < columnsWide-1; i++) {
      for (int j = 1; j < columnsWide-1; j++) {
        final int index = columnIndex(i, j);
        final int indexEast = index+1;
        final int indexNorth = index+columnsWide;
        final int indexNorthEast = index+columnsWide+1;
        num u = globalVelocityX;
        num v = globalVelocityY;
                
        u += (columns[index].velocityX+columns[indexEast].velocityX+columns[indexNorth].velocityX+columns[indexNorthEast].velocityX) *0.25;
        v += columns[index].velocityY;
        
        // Project the water particle backwards in time to determine where it came from
        num sourceI = i - u * _dt * _invDx;
        num sourceJ = j - v * _dt * _invDx;
        // Clamp
        if (sourceI < 0.0) {
          sourceI = 0.0;
        } else if (sourceI > columnsWide-1) {
          sourceI = columnsWide-1;
        }
        if (sourceJ < 0.0) {
          sourceJ = 0.0;
        } else if (sourceJ > columnsWide-1) {
          sourceJ = columnsWide-1;
        }
        
        _tempColumns[index].velocityY = _interpolateVelocityY(sourceI, sourceJ);
      }
    }
    
    for (int i = 1; i < columnsWide-1; i++) {
      for (int j = 1; j < columnsWide-1; j++) {
        final int index = columnIndex(i, j);
        columns[index].velocityY = _tempColumns[index].velocityY;
      }
    }
  }
  
  num _interpolateHeight(num x, num y) {
    final int X = x.toInt();
    final int Y = y.toInt();
    final num s1 = x - X;
    final num s0 = 1.0 - s1;
    final num t1 = y - Y;
    final num t0 = 1.0 - t1;
    return s0*(t0* columns[X+columnsWide*Y].height + t1*columns[X  +columnsWide*(Y+1)].height )+ 
           s1*(t0* columns[(X+1)+columnsWide*Y].height  + t1*columns[(X+1)+columnsWide*(Y+1)].height);
  }
  
  int _advectHeight() {
    for (int i = 1; i < columnsWide-1; i++) {
      for (int j = 1; j < columnsWide-1; j++) {
        final int index = columnIndex(i, j);
        final int indexEast = index+1;
        final int indexNorth = index+columnsWide;
        num u = 0.0;
        num v = 0.0;
        
        u += (columns[index].height+columns[indexEast].height) *0.5;
        v += (columns[index].height+columns[indexNorth].height) *0.5;
                
        // Project the water particle backwards in time to determine where it came from
        num sourceI = i - u * _dt * _invDx;
        num sourceJ = j - v * _dt * _invDx;
        // Clamp
        if (sourceI < 0.0) {
          sourceI = 0.0;
        } else if (sourceI > columnsWide-1) {
          sourceI = columnsWide-1;
        }
        if (sourceJ < 0.0) {
          sourceJ = 0.0;
        } else if (sourceJ > columnsWide-1) {
          sourceJ = columnsWide-1;
        }
        
        _tempColumns[index].height = _interpolateHeight(sourceI, sourceJ);
      }
    }
    
    for (int i = 1; i < columnsWide-1; i++) {
      for (int j = 1; j < columnsWide-1; j++) {
        final int index = columnIndex(i, j);
        columns[index].height = _tempColumns[index].height;
      }
    }
  }
  
  void _updateHeight() {
    for (int i = 1; i < columnsWide-1; i++) {
      for (int j = 1; j < columnsWide-1; j++) {
        final int index = columnIndex(i, j);
        final int indexNorth = index+columnsWide;
        final int indexEast = index+1;
        num dHeight = (columns[indexEast].velocityX - columns[index].velocityX) + 
                      (columns[indexNorth].velocityY - columns[index].velocityY);
        dHeight *= -0.5 * columns[index].height * _invDx * _dt;
        columns[index].height += dHeight;
      }
    }
  }
  
  void _updateVelocity() {
    // X velocity
    for (int i = 2; i < columnsWide-1; i++) {
      for (int j = 1; j < columnsWide-1; j++) {
        final int index = columnIndex(i, j);
        final int indexWest = index-1;
        num dVelocityX = columns[index].height - columns[indexWest].height; 
        dVelocityX *= _gravity * _dt * _invDx;
        columns[index].velocityX += dVelocityX;
        columns[index].velocityX *= _velocityScale;
      }
    }
    
    // Y velocity
    for (int i = 1; i < columnsWide-1; i++) {
      for (int j = 2; j < columnsWide-1; j++) {
        final int index = columnIndex(i, j);
        final int indexSouth = index-columnsWide;
        num dVelocityY = columns[index].height - columns[indexSouth].height;
        dVelocityY *= _gravity * _dt * _invDx;
        columns[index].velocityY += dVelocityY;
        columns[index].velocityY *= _velocityScale;
      }
    }
  }
  
  void _simpleUpdate() {
    num c = 3.0;
    num c2 = c * c;
    num h = columnWidth;
    num h2 = h*h;
    num invH2 = 1.0/h2;
    num maxSlope = 4.0;
    num maxOffset = maxSlope * h;
    for (int i = 1; i < columnsWide-1; i++) {
      for (int j = 1; j < columnsWide-1; j++) {
        final int index = columnIndex(i, j);
        final int indexEast = index+1;
        final int indexWest = index-1;
        final int indexNorth = index+columnsWide;
        final int indexSouth = index-columnsWide;
        num heightSum = columns[indexEast].height+columns[indexWest].height+columns[indexNorth].height+columns[indexSouth].height;
        heightSum = heightSum - 4 * columns[index].height;
        num offset = heightSum;
        num f = c2 * heightSum * invH2;
        columns[index].velocityX += f * _dt;
        _tempColumns[index].height = columns[index].height + columns[index].velocityX * _dt;
        
        // scale
        columns[index].velocityX *= 0.99;
        
        // clamp
        /*
        if (offset > maxOffset) {
          _tempColumns[index].height += offset - maxOffset;
        } else if (offset < -maxOffset) {
          _tempColumns[index].height += offset + maxOffset;
        }*/
      }
    }
    
    for (int i = 1; i < columnsWide-1; i++) {
      for (int j = 1; j < columnsWide-1; j++) {
        final int index = columnIndex(i, j);
        columns[index].height = _tempColumns[index].height;
      }
    }
  }
  
  void update() {
    _simpleUpdate();
    /*
    _advectHeight();
    _advectVelocityX();
    _advectVelocityY();
    _updateHeight();
    _updateVelocity();
    */
  }
  
  void _setReflectiveBoundaryNorth() {
    for (int i = 0; i < columnsWide; i++) {
      final int indexGhost = i + (columnsWide-1)*columnsWide;
      final int indexVisible = indexGhost-columnsWide;
      columns[indexGhost].height = columns[indexVisible].height;
    }
  }
  
  void _setReflectiveBoundaryEast() {
    for (int j = 0; j < columnsWide; j++) {
      int indexGhost = columnsWide-1 + j*columnsWide;
      int indexVisible = indexGhost-1;
      columns[indexGhost].height = columns[indexVisible].height;
    }
  }

  void _setReflectiveBoundarySouth() {
    for (int i = 0; i < columnsWide; i++) {
      final int indexGhost = i;
      final int indexVisible = indexGhost+columnsWide;
      columns[indexGhost].height = columns[indexVisible].height;
    }
  }

  void _setReflectiveBoundaryWest() {
    for (int j = 0; j < columnsWide; j++) {
      int indexGhost = j*columnsWide;
      int indexVisible = indexGhost+1;
      columns[indexGhost].height = columns[indexVisible].height;
    }
  }
  
  void setReflectiveBoundaryAll() {
    _setReflectiveBoundaryNorth();
    _setReflectiveBoundarySouth();
    _setReflectiveBoundaryEast();
    _setReflectiveBoundaryWest();
  }
  void setReflectiveBoundary(int boundaryLabel) {
    if (boundaryLabel == BoundaryNorth) {
      _setReflectiveBoundaryNorth();
    } else if (boundaryLabel == BoundaryEast) {
      _setReflectiveBoundaryEast();
    } else if (boundaryLabel == BoundarySouth) {
      _setReflectiveBoundarySouth();
    } else if (boundaryLabel == BoundaryWest) {
      _setReflectiveBoundaryWest();
    }
  }
}
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

part of spectre_asset_pack;

/// Wrapper around a Direct Draw Surface (.dds) file providing access to its contents.
///
/// A DDS file is a container for texture data. It can contain texture data with many
/// different formats, but the most common are DXT compressed formats. The use of DXT
/// formats require the [WEBGL_compressed_texture_s3tc](http://www.khronos.org/registry/webgl/extensions/WEBGL_compressed_texture_s3tc/)
/// extension, whose availablility can be queried using [GraphicsDeviceCapabilities.hasCompressedTextureS3TC].
///
/// The format can hold one or more textures as well as mipmap levels for them. One
/// use for holding multiple textures is for cube maps.
class DdsFile {
  //---------------------------------------------------------------------
  // Class variables
  //---------------------------------------------------------------------

  /// Magic number for a DDS file
  ///
  /// Value is 0x20534444 which is 'DDS ' in ASCII.
  static const int _magicNumber = 0x20534444;

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The buffer holding the file contents.
  ArrayBuffer _buffer;
  /// The offset to the data section of the file.
  int _dataOffset = 0;
  /// The [DdsResourceFormat] for the DDS file.
  int _resourceFormat = DdsResourceFormat.Unknown;
  /// The number of textures within the DDS file.
  int _arraySize = 0;
  /// The header for the DDS file.
  DdsHeader _header;
  /// The pixel format of the texture data contained within the DDS file.
  DdsPixelFormat _pixelFormat;
  /// The extended header for the DDS file.
  DdsExtendedHeader _extendedHeader;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /// Creates an instance of the [DdsFile] class.
  ///
  /// The contents of the DDS file in its entirery are within [buffer]. During
  /// construction an [ArgumentError] will be thrown if the [buffer] does not contain
  /// a valid DDS file.
  DdsFile(ArrayBuffer buffer) {
    _buffer = buffer;

    // The header, including magic number, is 128 bytes of data
    if (_buffer.byteLength <= DdsExtendedHeader._byteOffset) {
      throw new ArgumentError('Invalid DDS file');
    }

    Uint32Array reader = new Uint32Array.fromBuffer(_buffer);

    // Check the magic number
    if (reader[0] != _magicNumber) {
      throw new ArgumentError('Invalid DDS file');
    }

    _header = new DdsHeader._internal(_buffer);

    // Check that the header size is 124 bytes
    if (_header.size != DdsHeader._structSize) {
      throw new ArgumentError('Invalid DDS file');
    }

    _pixelFormat = new DdsPixelFormat._internal(_buffer);

    // Check that the pixel format size is 32 bytes
    if (_pixelFormat.size != DdsPixelFormat._structSize) {
      throw new ArgumentError('Invalid DDS file');
    }

    // See if the extended header is present
    if (_pixelFormat.characterCode == DdsPixelFormat._dx10CharacterCode) {
      if (_buffer.byteLength <= DdsExtendedHeader._byteOffset + DdsExtendedHeader._structSize) {
        throw new ArgumentError('Invalid DDS file');
      }

      _extendedHeader = new DdsExtendedHeader._internal(buffer);

      _dataOffset = DdsExtendedHeader._byteOffset + DdsExtendedHeader._structSize;
      _resourceFormat = _extendedHeader.resourceFormat;
      _arraySize = _extendedHeader.arraySize;

      // The format can hold an array of cubemaps so increase the size
      if (isCubeMap) {
        _arraySize *= 6;
      }
    } else {
      _dataOffset = DdsExtendedHeader._byteOffset;
      _resourceFormat = _pixelFormat.resourceFormat;

      // Get the number of textures in the file
      if (isCubeMap) {
        int surfaceDetail = _header.surfaceDetail;

        _arraySize  = ((surfaceDetail & DdsHeader.hasCubeMapPositiveX) == DdsHeader.hasCubeMapPositiveX) ? 1 : 0;
        _arraySize += ((surfaceDetail & DdsHeader.hasCubeMapNegativeX) == DdsHeader.hasCubeMapNegativeX) ? 1 : 0;

        _arraySize += ((surfaceDetail & DdsHeader.hasCubeMapPositiveY) == DdsHeader.hasCubeMapPositiveY) ? 1 : 0;
        _arraySize += ((surfaceDetail & DdsHeader.hasCubeMapNegativeY) == DdsHeader.hasCubeMapNegativeY) ? 1 : 0;

        _arraySize += ((surfaceDetail & DdsHeader.hasCubeMapPositiveZ) == DdsHeader.hasCubeMapPositiveZ) ? 1 : 0;
        _arraySize += ((surfaceDetail & DdsHeader.hasCubeMapNegativeZ) == DdsHeader.hasCubeMapNegativeZ) ? 1 : 0;
      } else {
        _arraySize = 1;
      }
    }
  }

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// The width of the compressed texture(s).
  int get width => _header.width;
  /// The height of the compressed texture(s).
  int get height => _header.height;
  /// The depth of the compressed texture(s).
  int get depth => _header.depth;
  /// The number of mipmaps within the texture(s).
  ///
  /// The mipmap count includes the original texture. A mipmap count of
  /// 1 means that there are no mipmaps actually present within the file.
  int get mipMapCount => _header.mipMapCount;
  /// The [DdsResourceFormat] for the DDS file.
  int get resourceFormat => _resourceFormat;
  /// The number of textures within the DDS file.
  int get arraySize => _arraySize;
  /// The header for the DDS file.
  DdsHeader get header => _header;
  /// The pixel format of the texture data contained within the DDS file.
  DdsPixelFormat get pixelFormat => _pixelFormat;
  /// The extended header for the DDS file.
  DdsExtendedHeader get extendedHeader => _extendedHeader;

  /// Whether the DDS file contains a cube map.
  bool get isCubeMap {
    if (_extendedHeader != null) {
      return (_extendedHeader.flags & DdsExtendedHeader.isCubeMap) == DdsExtendedHeader.isCubeMap;
    }

    return (_header.surfaceDetail & DdsHeader.isCubeMap) == DdsHeader.isCubeMap;
  }

  /// Whether all faces within a cube map are present.
  bool get hasAllCubeMapFaces {
    if (_extendedHeader != null) {
      // DX10 format always has all the cube map faces
      return (_extendedHeader.flags & DdsExtendedHeader.isCubeMap) == DdsExtendedHeader.isCubeMap;
    }

    return (_header.surfaceDetail & DdsHeader.hasAllCubeMapFaces) == DdsHeader.hasAllCubeMapFaces;
  }

  /// Whether the DDS file contains a volume texture.
  bool get isVolumeTexture {
    if (_extendedHeader != null) {
      return _extendedHeader.resourceFormat == DdsExtendedHeader.isTexture3d;
    }

    return (_header.surfaceDetail & DdsHeader.isVolumeTexture) == DdsHeader.isVolumeTexture;
  }

  /// Whether the DDS file has an extended header.
  bool get hasExtendedHeader => _extendedHeader != null;

  //---------------------------------------------------------------------
  // Public methods
  //---------------------------------------------------------------------

  /// Gets the pixel data from the texture at the given [index] with the requested mipmap [level].
  ArrayBuffer getPixelData(int index, int level) {
    if (_resourceFormat == DdsResourceFormat.Unknown) {
      throw new ArgumentError('File contains an unknown resource format');
    }

    if (index >= _arraySize) {
      throw new ArgumentError('File does not contain a texture at the given index');
    }

    if (level >= _header.mipMapCount) {
      throw new ArgumentError('File does not contain a texture at the given level');
    }

    int offset = _getImageOffset(index) + _getMipMapLevelOffset(level);

    int divisor = Math.pow(2, level);
    int currentWidth = Math.max(1, width ~/ divisor);
    int currentHeight = Math.max(1, height ~/ divisor);
    int currentDepth = Math.max(1, depth ~/ divisor);

    if (DdsResourceFormat.isBlockCompressed(_resourceFormat)) {
      int blockSize = (_resourceFormat == DdsResourceFormat.UnormBc1) || (_resourceFormat == DdsResourceFormat.SrgbUnormBc1) ? 8 : 16;

      return _buffer.slice(offset, offset + (currentDepth * _getCompressedSize(currentWidth, currentHeight, blockSize)));
    } else {
      int stride = _getStride(currentWidth, _resourceFormat);

      // It's not clear what specifies whether the rows are 32-bit aligned or
      // 8-bit aligned. It appears that MS tools are just byte aligned so the
      // code to take this into account is turned off.
      int padding = 0;//stride % 4;

      int sliceSize = stride * currentHeight;

      // Each row of the image has an expectation that it starts on a 32-bit boundary.
      //
      // If there is no padding the array can be sliced. Otherwise each individual
      // row must be copied one at a time
      if (padding == 0) {
        return _buffer.slice(offset, offset + (currentDepth * sliceSize));
      } else {
        Uint8Array copyTo = new Uint8Array(currentDepth * sliceSize);
        Uint8Array copyFrom = new Uint8Array.fromBuffer(_buffer, offset);
        int toIndex = 0;
        int fromIndex = 0;

        // Update this code to copy more than one byte at a time if
        // performance becomes an issue
        for (int j = 0; j < currentDepth; ++j) {
          for (int i = 0; i < stride; ++i) {
            copyTo[toIndex] = copyFrom[fromIndex];

            toIndex++;
            fromIndex++;
          }

          fromIndex += padding;
        }

        return copyTo.buffer;
      }
    }
  }

  //---------------------------------------------------------------------
  // Private methods
  //---------------------------------------------------------------------

  /// Get the offset to an image within the file.
  int _getImageOffset(int index) {
    return (index == 0) ? _dataOffset : (_getMipMapLevelOffset(mipMapCount) * index) + _dataOffset;
  }

  /// Get the offset to a mipmap level within the file.
  int _getMipMapLevelOffset(int level) {
    int offset = 0;
    int currentWidth  = width;
    int currentHeight = height;
    int currentDepth  = depth;

    for (int currentLevel = 0; currentLevel < level; ++currentLevel) {
      int sliceSize;

      if (DdsResourceFormat.isBlockCompressed(_resourceFormat)) {
        int blockSize = (_resourceFormat == DdsResourceFormat.UnormBc1) || (_resourceFormat == DdsResourceFormat.SrgbUnormBc1) ? 8 : 16;

        sliceSize = _getCompressedSize(currentWidth, currentHeight, blockSize);
      } else {
        int stride = _getStride(currentWidth, _resourceFormat);

        // It's not clear what specifies whether the rows are 32-bit aligned or
        // 8-bit aligned. It appears that MS tools are just byte aligned so the
        // code to take this into account is turned off.
        int padding = 0;//stride % 4;

        sliceSize = (stride + padding) * currentHeight;
      }

      offset += sliceSize * currentDepth;

      // Next mipmap level is half of the current
      currentWidth  = Math.max(1, currentWidth  ~/ 2);
      currentHeight = Math.max(1, currentHeight ~/ 2);
      currentDepth  = Math.max(1, currentDepth  ~/ 2);
    }

    return offset;
  }

  /// Computes the size of a compressed texture.
  static int _getCompressedSize(int width, int height, int blockSize) {
    return Math.max(1, width ~/ 4) * Math.max(1, height ~/ 4) * blockSize;
  }

  /// Computes the stride of an image given its [width] and [format].
  ///
  /// The computed stride is not always at a 32-bit boundary. If this is the case
  /// the image will require padding.
  static int _getStride(int width, int format) {
    if ((format == DdsResourceFormat.UnormR8G8B8G8) || (format == DdsResourceFormat.UnormG8R8G8B8)) {
      return ((width + 1) >> 1) * 4;
    } else {
      int bitsPerPixel = DdsResourceFormat.getBitsPerPixel(format);

      return ((width * bitsPerPixel) + 7) ~/ 8;
    }
  }
}

/// The header for the DDS file format.
///
/// Accessors correspond to the [DDS_HEADER](http://msdn.microsoft.com/en-us/library/windows/desktop/bb943982)
/// structure.
class DdsHeader {
  //---------------------------------------------------------------------
  // Class variables
  //---------------------------------------------------------------------

  /// The offset in bytes to the DDS_HEADER struct within the file.
  static const int _byteOffset = 4;
  /// The size of the DDS_HEADER struct.
  static const int _structSize = 124;

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// Flag within [flags] that signifies the textures have width.
  static const int hasWidth = 0x4;
  /// Flag within [flags] that signifies the textures have height.
  static const int hasHeight = 0x2;
  /// Flag within [flags] that signifies the textures have depth.
  static const int hasDepth = 0x800000;
  /// Flag within [flags] that signfies the textures have mipmaps.
  static const int hasMipMaps = 0x20000;

  /// Flag within [surfaceDetail] that signifies a cube map is present.
  static const int isCubeMap = 0x200;
  /// Flag within [surfaceDetail] that the positive x surface is present.
  static const int hasCubeMapPositiveX = 0x400;
  /// Flag within [surfaceDetail] that the negative x surface is present.
  static const int hasCubeMapNegativeX = 0x800;
  /// Flag within [surfaceDetail] that the positive y surface is present.
  static const int hasCubeMapPositiveY = 0x1000;
  /// Flag within [surfaceDetail] that the negative y surface is present.
  static const int hasCubeMapNegativeY = 0x2000;
  /// Flag within [surfaceDetail] that the positive z surface is present.
  static const int hasCubeMapPositiveZ = 0x4000;
  /// Flag within [surfaceDetail] that the negative z surface is present.
  static const int hasCubeMapNegativeZ = 0x8000;
  /// Flag within [surfaceDetail] signifying all cube map data is present.
  static const int hasAllCubeMapFaces = isCubeMap
                                      | hasCubeMapPositiveX | hasCubeMapNegativeX
                                      | hasCubeMapPositiveY | hasCubeMapNegativeY
                                      | hasCubeMapPositiveZ | hasCubeMapNegativeZ;
  /// Flag within [surfaceDetail] that signifies a volume textue is present.
  static const int isVolumeTexture = 0x200000;

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The size of the structure.
  int _size;
  /// Flags to indicate which members contain valid data.
  int _flags;
  /// The height of the compressed texture.
  int _height;
  /// The width of the compressed texture.
  int _width;

  int _pitchOrLinearSize;
  /// The depth of the compressed texture.
  int _depth;
  /// The number of mipmap levels.
  int _mipMapCount;
  /// Gets the surface complexity.
  int _surfaceComplexity;
  /// Gets details about the surface being stored.
  ///
  /// Stores flags signifying that a cubemap or volume texture is being
  /// used. If the extended header is present then that data takes
  /// precedence.
  int _surfaceDetail;

  //---------------------------------------------------------------------
  // Constructor
  //---------------------------------------------------------------------

  /// Creates an instance of the [DdsHeader] class.
  DdsHeader._internal(ArrayBuffer buffer) {
    Uint32Array reader = new Uint32Array.fromBuffer(buffer, _byteOffset);

    _size              = reader[0];
    _flags             = reader[1];
    _height            = (_flags & hasHeight)  == hasHeight  ? reader[2] : 0;
    _width             = (_flags & hasWidth)   == hasWidth   ? reader[3] : 0;
    _pitchOrLinearSize = reader[4];
    _depth             = (_flags & hasDepth)   == hasDepth   ? reader[5] : 1;
    _mipMapCount       = (_flags & hasMipMaps) == hasMipMaps ? reader[6] : 1;

    // Check for a mip map count of 0
    //
    // Some writers, such as the DirectX Texture Tool, will write 0 for the mipmap count
    // while others, such as texconv, will write 1 for the mipmap count.
    //
    // Standardize on a mipmap count of 1 meaning there are no actual mipmaps contained
    // in the file.
    if (_mipMapCount == 0) {
      _mipMapCount = 1;
    }

    _surfaceComplexity = reader[26];
    _surfaceDetail     = reader[27];
  }

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// The size of the structure.
  int get size => _size;
  /// Flags to indicate which members contain valid data.
  int get flags => _flags;
  /// The height of the compressed texture.
  int get height => _height;
  /// The width of the compressed texture.
  int get width => _width;

  int get pitchOrLinearSize => _pitchOrLinearSize;
  /// The depth of the compressed texture.
  int get depth => _depth;
  /// The number of mipmap levels.
  int get mipMapCount => _mipMapCount;
  /// Gets the surface complexity.
  int get surfaceComplexity => _surfaceComplexity;
  /// Gets details about the surface being stored.
  ///
  /// Stores flags signifying that a cubemap or volume texture is being
  /// used. If the extended header is present then that data takes
  /// precedence.
  int get surfaceDetail => _surfaceDetail;
}

/// The surface pixel format.
///
/// Accessors correspond to the [DDS_PIXELFORMAT](http://msdn.microsoft.com/en-us/library/windows/desktop/bb943984)
/// structure.
class DdsPixelFormat {
  //---------------------------------------------------------------------
  // Class variables
  //---------------------------------------------------------------------

  /// The offset in bytes to the DDS_PIXELFORMAT struct within the file.
  ///
  /// The DDS_PIXEL_FORMAT is within the boundary of DDS_HEADER.
  static const int _byteOffset = DdsHeader._byteOffset + 72;
  /// The size of the DDS_PIXELFORMAT struct.
  static const int _structSize = 32;

  //---------------------------------------------------------------------
  // Flags
  //---------------------------------------------------------------------

  /// Texture contains alpha data
  static const int _hasAlphaData = 0x1;
  /// Texture contains alpha data (legacy).
  static const int _hasAlphaDataLegacy = 0x2;
  /// Texture contains compressed data, floating point data, or some exotic format.
  ///
  /// If the flag is present the value in [characterCode] is valid.
  static const int _hasCharacterCode = 0x4;
  /// Texture contains uncompressed RGB data.
  ///
  /// The values in [bitCount] and the RGB masks [redBitMask], [greenBitMask], [blueBitMask] contain valid data.
  static const int _hasRgbValues = 0x40;
  /// Texture contains YUV compressed data.
  ///
  /// The value in [bitCount] contains the YUV bit count. The Y mask is within [redBitMask]. The U mask is
  /// within [greenBitMask]. The V mask is within [blueBitMask].
  static const int _hasYuvValues = 0x200;
  /// Texture contains luminance data or some other single channel color.
  ///
  /// The value in [bitCount] contains the luminance channel bit count. The channel mask is contained in
  /// [redBitMask]. It can be combined with [_hasAlpha] for a two channel DDS file.
  static const int _hasLuminanceValues = 0x20000;
  /// Texture contains uncompressed RGBA data.
  ///
  /// The values in [bitCount] and the RGB masks [redBitMask], [greenBitMask], [blueBitMask], and [alphaBitMask]
  /// contain valid data.
  static const int _hasRgbaValues = _hasAlphaData | _hasRgbValues;
  /// Texture contains two channels.
  static const int _hasTwoChannels = _hasAlphaData | _hasLuminanceValues;

  //---------------------------------------------------------------------
  // Character codes
  //---------------------------------------------------------------------

  /// The DXT1 character code, 'DXT1'.
  static const int _dxt1CharacterCode = 827611204;
  /// The DXT2 character code, 'DXT2'.
  static const int _dxt2CharacterCode = 844388420;
  /// The DXT3 character code, 'DXT3'.
  static const int _dxt3CharacterCode = 861165636;
  /// The DXT4 character code, 'DXT4'.
  static const int _dxt4CharacterCode = 877942852;
  /// The DXT5 character code, 'DXT5'.
  static const int _dxt5CharacterCode = 894720068;
  /// The BC4U character code, 'BC4U'.
  static const int _bc4uCharacterCode = 1429488450;
  /// The BC4S character code, 'BC4S'.
  static const int _bc4sCharacterCode = 1395934018;
  /// The ATI2 character code, 'ATI2'.
  static const int _ati2CharacterCode = 843666497;
  /// The BC5U character code, 'BC5U'.
  static const int _bc5uCharacterCode = 1429553986;
  /// The BC5S character code, 'BC5S'.
  static const int _bc5sCharacterCode = 1395999554;
  /// The RGBG character code, 'RGBG'.
  static const int _rgbgCharacterCode = 1195525970;
  /// The GRGB character code, 'GRGB'.
  static const int _grbgCharacterCode = 1111970375;
  /// The UYVY character code, 'UYVY'.
  static const int _uyvyCharacterCode = 1498831189;
  /// The YUY2 character code, 'YUY2'.
  static const int _yuy2CharacterCode = 844715353;
  /// 64-bit RGBA unsigned-normalized-integer character code.
  static const int _unormR16G16B16A16CharacterCode = 36;
  /// 64-bit RGBA signed-normalized-integer character code.
  static const int _normR16G16B16A16CharacterCode = 110;
  /// 16-bit R floating point character code.
  static const int _floatR16CharacterCode = 111;
  /// 32-bit RG floating point character code.
  static const int _floatR16G16CharacterCode = 112;
  /// 64-bit RGBA floating point character code.
  static const int _floatR16G16B16A16CharacterCode = 113;
  /// 32-bit R floating point character code.
  static const int _floatR32CharacterCode = 114;
  /// 64-bit RG floating point character code.
  static const int _floatR32G32CharacterCode = 115;
  /// 128-bit RGBA floating point character code.
  static const int _floatR32G32B32A32CharacterCode = 116;
  /// The DX10 character code, 'DX10'.
  ///
  /// Means that the extended header DX10 is present.
  static const int _dx10CharacterCode = 808540228;

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The size of the structure
  int _size;
  /// Flags to indicate what type of data is in the surface.
  int _flags;
  /// Character code for specifying compressed or custom format.
  int _characterCode;
  /// Number of bits in an RGB (possibly including alpha) format.
  int _rgbBitCount;
  /// Red (or lumiannce or Y) mask for reading color data.
  int _redBitMask;
  /// Green (or U) mask for reading color data.
  int _greenBitMask;
  /// Blue (or V) mask for reading color data.
  int _blueBitMask;
  /// Alpha mask for reading alpha data.
  int _alphaBitMask;

  //---------------------------------------------------------------------
  // Constructor
  //---------------------------------------------------------------------

  /// Creates an instance of the [DdsPixelFormat] class.
  DdsPixelFormat._internal(ArrayBuffer buffer) {
    Uint32Array reader = new Uint32Array.fromBuffer(buffer, _byteOffset);

    _size          = reader[0];
    _flags         = reader[1];
    _characterCode = reader[2];
    _rgbBitCount   = reader[3];
    _redBitMask    = reader[4];
    _greenBitMask  = reader[5];
    _blueBitMask   = reader[6];
    _alphaBitMask  = reader[7];
  }

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// The size of the structure
  int get size => _size;
  /// Flags to indicate what type of data is in the surface.
  int get flags => _flags;
  /// Character code for specifying compressed or custom format.
  int get characterCode => _characterCode;
  /// Number of bits in an RGB (possibly including alpha) format.
  int get rgbBitCount => _rgbBitCount;
  /// Red (or lumiannce or Y) mask for reading color data.
  int get redBitMask => _redBitMask;
  /// Green (or U) mask for reading color data.
  int get greenBitMask => _greenBitMask;
  /// Blue (or V) mask for reading color data.
  int get blueBitMask => _blueBitMask;
  /// Alpha mask for reading alpha data.
  int get alphaBitMask => _alphaBitMask;

  /// Gets the resource format.
  ///
  /// If the [DdsExtendedHeader] is present then this value should be ignored.
  int get resourceFormat {
    // Check for types encoded in a character code
    //
    // Some of these formats should be in the extended header but not all DDS
    // writers, including Microsoft's DirectX Texture Tool, use the extended header.
    if ((_flags & _hasCharacterCode) == _hasCharacterCode) {
      switch (_characterCode) {
        case _dxt1CharacterCode             : return DdsResourceFormat.UnormBc1;
        case _dxt2CharacterCode             : return DdsResourceFormat.Unknown;
        case _dxt3CharacterCode             : return DdsResourceFormat.UnormBc2;
        case _dxt4CharacterCode             : return DdsResourceFormat.Unknown;
        case _dxt5CharacterCode             : return DdsResourceFormat.UnormBc3;
        case _bc4uCharacterCode             : return DdsResourceFormat.UnormBc4;
        case _bc4sCharacterCode             : return DdsResourceFormat.NormBc4;
        case _ati2CharacterCode             : return DdsResourceFormat.UnormBc4;
        case _bc5uCharacterCode             : return DdsResourceFormat.UnormBc5;
        case _bc5sCharacterCode             : return DdsResourceFormat.NormBc5;
        case _rgbgCharacterCode             : return DdsResourceFormat.UnormR8G8B8G8;
        case _grbgCharacterCode             : return DdsResourceFormat.UnormG8R8G8B8;
        case _uyvyCharacterCode             : return DdsResourceFormat.Unknown;
        case _yuy2CharacterCode             : return DdsResourceFormat.Unknown;
        case _unormR16G16B16A16CharacterCode: return DdsResourceFormat.UnormR16G16B16A16;
        case _normR16G16B16A16CharacterCode : return DdsResourceFormat.NormR16G16B16A16;
        case _floatR16CharacterCode         : return DdsResourceFormat.FloatR16;
        case _floatR16G16CharacterCode      : return DdsResourceFormat.FloatR16G16;
        case _floatR16G16B16A16CharacterCode: return DdsResourceFormat.FloatR16G16B16A16;
        case _floatR32CharacterCode         : return DdsResourceFormat.FloatR32;
        case _floatR32G32CharacterCode      : return DdsResourceFormat.FloatR32G32;
        case _floatR32G32B32A32CharacterCode: return DdsResourceFormat.FloatR32G32B32A32;
        case _dx10CharacterCode             : return DdsResourceFormat.Unknown;
      }
    }

    // Check for RGB formats
    if (_rgbBitCount == 32) {
      if ((_flags & _hasRgbaValues) == _hasRgbaValues) {
        if ((_redBitMask == 0x000000ff) && (_greenBitMask == 0x0000ff00) && (_blueBitMask == 0x00ff0000) && (_alphaBitMask == 0xff000000)) {
          return DdsResourceFormat.UnormR8G8B8A8;
        } else if ((_redBitMask == 0x00ff0000) && (_greenBitMask == 0x0000ff00) && (_blueBitMask == 0x000000ff) && (_alphaBitMask == 0xff000000)) {
          return DdsResourceFormat.UnormB8G8R8A8;
        } else if ((_redBitMask == 0x0000ffff) && (_greenBitMask == 0xffff0000)) {
          // This is in the documentation but isn't an actual RGBA format
          return DdsResourceFormat.UnormR16G16;
        } else if ((_redBitMask == 0x3ff00000) && (_greenBitMask == 0x000ffc00) && (_blueBitMask == 0x000003ff) && (_alphaBitMask == 0x00c00000)) {
          return DdsResourceFormat.UnormR10G10B10A2;
        }
      } else if ((_flags & _hasRgbValues) == _hasRgbValues) {
        if ((_redBitMask == 0x0000ffff) && (_greenBitMask == 0xffff0000)) {
          return DdsResourceFormat.UnormR16G16;
        } else if ((_redBitMask == 0x00ff0000) && (_greenBitMask == 0x0000ff00) && (_blueBitMask == 0x000000ff)) {
          return DdsResourceFormat.UnormB8G8R8X8;
        }
      }
    } else if (_rgbBitCount == 16) {
      if ((flags & _hasRgbaValues) == _hasRgbaValues) {
        if ((_redBitMask == 0x7c00) && (_greenBitMask == 0x03e0) && (_blueBitMask == 0x001f) && (_alphaBitMask == 0x8000)) {
          return DdsResourceFormat.UnormB5G5R5A1;
        }
      } else if ((_flags & _hasRgbValues) == _hasRgbValues) {
        if ((_redBitMask == 0xf800) && (_greenBitMask == 0x07e0) && (_blueBitMask == 0x001f)) {
          return DdsResourceFormat.UnormB5G6R5;
        }
      } else if ((_flags & _hasTwoChannels) == _hasTwoChannels) {
        if ((_redBitMask == 0x00ff) && (_alphaBitMask == 0xff00)) {
          return DdsResourceFormat.UnormR8G8;
        }
      } else if ((_flags & _hasLuminanceValues) == _hasLuminanceValues) {
        if (_redBitMask == 0xffff) {
          return DdsResourceFormat.UnormR16;
        }
      }
    } else if (_rgbBitCount == 8) {
      if ((_flags & _hasLuminanceValues) == _hasLuminanceValues) {
        if (_redBitMask == 0xff) {
          return DdsResourceFormat.UnormR8;
        }
      } else if (((_flags & _hasAlphaData) == _hasAlphaData) || ((_flags & _hasAlphaDataLegacy) == _hasAlphaDataLegacy)) {
        if (_alphaBitMask == 0xff) {
          return DdsResourceFormat.UnormA8;
        }
      }
    }

    // Unknown format
    return DdsResourceFormat.Unknown;
  }
}

/// The extended header for the DDS file format.
///
/// The presence of this header is optional. If the character code in [DdsPixelFormat]
/// is "DX10" then the header is present.
///
/// Accessors correspond to the [DDS_HEADER_DX10](http://msdn.microsoft.com/en-us/library/windows/desktop/bb943983)
/// structure.
class DdsExtendedHeader {
  //---------------------------------------------------------------------
  // Class variables
  //---------------------------------------------------------------------

  /// The offset in bytes to the DDS_HEADER_DX10 struct within the file.
  static const int _byteOffset = DdsHeader._structSize + 4;
  /// The size of the DDS_HEADER_DX10 struct.
  static const int _structSize = 20;

  /// Resource is a one dimensional texture.
  static const int isTexture1d = 2;
  /// Resource is a two dimensional texture.
  static const int isTexture2d = 3;
  /// Resource is a three dimensional texture.
  static const int isTexture3d = 4;
  /// Resource is a cube map
  static const int isCubeMap = 4;

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The resource format.
  int _resourceFormat;
  /// The dimensionality of the resource.
  int _dimension;
  /// Identifies other less common options.
  int _flags;
  /// The number of elements present in the array.
  int _arraySize;

  //---------------------------------------------------------------------
  // Constructor
  //---------------------------------------------------------------------

  /// Creates an instance of the [DdsPixelFormat] class.
  DdsExtendedHeader._internal(ArrayBuffer buffer) {
    Uint32Array reader = new Uint32Array.fromBuffer(buffer, _byteOffset);

    _resourceFormat = reader[0];
    _dimension = reader[1];
    _flags = reader[2];
    _arraySize = reader[3];
  }

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// The resource format.
  int get resourceFormat => _resourceFormat;
  /// The dimensionality of the resource.
  int get dimension => _dimension;
  /// Identifies other less common options.
  int get flags => _flags;
  /// The number of elements present in the array.
  int get arraySize => _arraySize;
}

/// The indices used when accessing a cube map.
class DdsCubeMapFace {
  /// Index of the positive x face.
  const int PositiveX = 0;
  /// Index of the negative x face.
  const int NegativeX = 1;
  /// Index of the positive y face.
  const int PositiveY = 2;
  /// Index of the negative y face.
  const int NegativeY = 3;
  /// Index of the positive z face.
  const int PositiveZ = 4;
  /// Index of the negative z face.
  const int NegativeZ = 5;
}

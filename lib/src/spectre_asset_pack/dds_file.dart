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

  /// View over the [ArrayBuffer] for accessing the structure.
  Uint32Array _reader;
  /// The offset to the data section of the file.
  int _dataOffset;
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
    // The header, including magic number, is 128 bytes of data
    if (buffer.byteLength <= DdsExtendedHeader._byteOffset) {
      throw new ArgumentError('Invalid DDS file');
    }

    _reader = new Uint32Array.fromBuffer(buffer);

    // Check the magic number
    if (_reader[0] != _magicNumber) {
      throw new ArgumentError('Invalid DDS file');
    }

    _header = new DdsHeader._internal(buffer);

    // Check that the header size is 124 bytes
    if (_header.size != DdsHeader._structSize) {
      throw new ArgumentError('Invalid DDS file');
    }

    _pixelFormat = new DdsPixelFormat._internal(buffer);

    // Check that the pixel format size is 32 bytes
    if (_pixelFormat.size != DdsPixelFormat._structSize) {
      throw new ArgumentError('Invalid DDS file');
    }

    int test = _pixelFormat.resourceFormat;

    // See if the extended header is present
    if (_pixelFormat.characterCode == DdsPixelFormat._dx10CharacterCode) {
      if (buffer.byteLength <= DdsExtendedHeader._byteOffset + DdsExtendedHeader._structSize) {
        throw new ArgumentError('Invalid DDS file');
      }

      _extendedHeader = new DdsExtendedHeader._internal(buffer);

      _dataOffset = DdsExtendedHeader._byteOffset + DdsExtendedHeader._structSize;
    } else {
      _dataOffset = DdsExtendedHeader._byteOffset;
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
  int get mipMapCount => _header.mipMapCount;

  /// Whether the DDS file contains a cube map.
  bool get isCubeMap {
    if (_extendedHeader != null) {

    }

    return (_header.surfaceDetail & DdsHeader.isCubeMap) == DdsHeader.isCubeMap;
  }

  /// Whether all faces within a cube map are present.
  bool get hasAllCubeMapFaces {
    return (_header.surfaceDetail & DdsHeader.hasAllCubeMapFaces) == DdsHeader.hasAllCubeMapFaces;
  }

  /// Whether the DDS file contains a volume texture.
  bool get isVolumeTexture {

    return (_header.surfaceDetail & DdsHeader.isVolumeTexture) == DdsHeader.isVolumeTexture;
  }

  DdsHeader get header => _header;

  /// Whether the DDS file has an extended header.
  bool get hasExtendedHeader => _extendedHeader != null;

  //---------------------------------------------------------------------
  // Public methods
  //---------------------------------------------------------------------

  /// Gets the pixel data from the texture at the given [index] with the requested mipmap [level].
  ArrayBuffer getPixelData(int index, int level) {

  }

  //---------------------------------------------------------------------
  // Class methods
  //---------------------------------------------------------------------


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
    _height            = reader[2];
    _width             = reader[3];
    _pitchOrLinearSize = reader[4];
    _depth             = reader[5];
    _mipMapCount       = reader[6];
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
        case _dxt1CharacterCode             : print('DXT1'); return 0;
        case _dxt2CharacterCode             : print('DXT2'); return 0;
        case _dxt3CharacterCode             : print('DXT3'); return 0;
        case _dxt4CharacterCode             : print('DXT4'); return 0;
        case _dxt5CharacterCode             : print('DXT5'); return 0;
        case _floatR16CharacterCode         : print('DXGI_FORMAT_R16_FLOAT'); return 0;
        case _floatR16G16CharacterCode      : print('DXGI_FORMAT_R16G16_FLOAT'); return 0;
        case _floatR16G16B16A16CharacterCode: print('DXGI_FORMAT_R16G16B16A16_FLOAT'); return 0;
        case _floatR32CharacterCode         : print('DXGI_FORMAT_R32_FLOAT'); return 0;
        case _floatR32G32CharacterCode      : print('DXGI_FORMAT_R32G32_FLOAT'); return 0;
        case _floatR32G32B32A32CharacterCode: print('DXGI_FORMAT_R32G32B32A32_FLOAT'); return 0;
        case _dx10CharacterCode             : print('DX10'); return 0;
      }
    }

    // Check for RGB formats
    if (_rgbBitCount == 32) {
      if ((_flags & _hasRgbaValues) == _hasRgbaValues) {
        if ((_redBitMask == 0x000000ff) && (_greenBitMask == 0x0000ff00) && (_blueBitMask == 0x00ff0000) && (_alphaBitMask == 0xff000000)) {
          print('DXGI_FORMAT_R8G8B8A8_UNORM');
        } else if ((_redBitMask == 0x00ff0000) && (_greenBitMask == 0x0000ff00) && (_blueBitMask == 0x000000ff) && (_alphaBitMask == 0xff000000)) {
          print('D3DFMT_A8R8G8B8');
        } else if ((_redBitMask == 0x3ff00000) && (_greenBitMask == 0x000ffc00) && (_blueBitMask == 0x000003ff) && (_alphaBitMask == 0x00c00000)) {
          print('D3DFMT_A2R10G10B10');
        }
      } else if ((_flags & _hasRgbValues) == _hasRgbValues) {

      }
    } else if (_rgbBitCount == 16) {

    } else if (_rgbBitCount == 8) {

    }

    // Unknown format
    return 0;
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

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

  /// The width of the compressed texture.
  int get width => _header.width;
  /// The height of the compressed texture.
  int get height => _header.height;

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

  /// View over the [ArrayBuffer] for accessing the structure.
  Uint32Array _reader;

  //---------------------------------------------------------------------
  // Constructor
  //---------------------------------------------------------------------

  /// Creates an instance of the [DdsHeader] class.
  DdsHeader._internal(ArrayBuffer buffer)
    : _reader = new Uint32Array.fromBuffer(buffer, _byteOffset);

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// The size of the structure.
  int get size => _reader[0];
  /// Flags to indicate which members contain valid data.
  int get flags => _reader[1];
  /// The height of the compressed texture.
  int get height => _reader[2];
  /// The width of the compressed texture.
  int get width => _reader[3];

  int get pitchOrLinearSize => _reader[4];
  /// The depth of the compressed texture.
  int get depth => _reader[5];
  /// The number of mipmap levels.
  int get mipMapCount => _reader[6];
  /// Gets the surface complexity.
  int get surfaceComplexity => _reader[26];
  /// Gets details about the surface being stored.
  ///
  /// Stores flags signifying that a cubemap or volume texture is being
  /// used. If the extended header is present then that data takes
  /// precedence.
  int get surfaceDetail => _reader[27];
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
  /// The DX10 character code, 'DX10'.
  ///
  /// Means that the extended header DX10 is present.
  static const int _dx10CharacterCode = 808540228;

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// View over the [ArrayBuffer] for accessing the structure.
  Uint32Array _reader;

  //---------------------------------------------------------------------
  // Constructor
  //---------------------------------------------------------------------

  /// Creates an instance of the [DdsPixelFormat] class.
  DdsPixelFormat._internal(ArrayBuffer buffer)
    : _reader = new Uint32Array.fromBuffer(buffer, _byteOffset);

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// The size of the structure.
  int get size => _reader[0];
  /// Flags to indicate what type of data is in the surface.
  int get flags => _reader[1];
  /// Character code for specifying compressed or custorm formats.
  int get characterCode => _reader[2];

/*
  DWORD dwSize;
  DWORD dwFlags;
  DWORD dwFourCC;
  DWORD dwRGBBitCount;
  DWORD dwRBitMask;
  DWORD dwGBitMask;
  DWORD dwBBitMask;
  DWORD dwABitMask;
*/
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

  /// View over the [ArrayBuffer] for accessing the structure.
  Uint32Array _reader;

  //---------------------------------------------------------------------
  // Constructor
  //---------------------------------------------------------------------

  /// Creates an instance of the [DdsPixelFormat] class.
  DdsExtendedHeader._internal(ArrayBuffer buffer)
    : _reader = new Uint32Array.fromBuffer(buffer, _byteOffset);

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------


}

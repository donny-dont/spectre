/*
  Copyright (C) 2013 John McCutchan

  This software is provided 'as-is'; without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose;
  including commercial applications; and to alter it and redistribute it
  freely; subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product; an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such; and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
*/

part of spectre_asset_pack;

/// Resource formats contained in DDS.
///
/// This mostly corresponds to the [DXGI_FORMAT](http://msdn.microsoft.com/en-us/library/windows/desktop/bb173059.aspx)
/// but there are some additional formats added that correspond to [D3DFORMAT](http://msdn.microsoft.com/en-us/library/windows/desktop/bb172558.aspx).
/// Formats that are not expected within a DDS file are not enumerated.
class DdsResourceFormat {
  /// An unknown format.
  static const int Unknown = 0;

  //---------------------------------------------------------------------
  // 128-bit formats
  //---------------------------------------------------------------------

  //static const int TypelessR32G32B32A32       = 1;
  static const int FloatR32G32B32A32 = 2;
  static const int UintR32G32B32A32           = 3;
  static const int IntR32G32B32A32            = 4;
  //static const int TypelessR32G32B32          = 5;
  static const int FloatR32G32B32             = 6;
  static const int UintR32G32B32              = 7;
  static const int IntR32G32B32               = 8;

  //---------------------------------------------------------------------
  // 64-bit formats
  //---------------------------------------------------------------------


  //static const int R16G16B16A16_TYPELESS       = 9;
  static const int FloatR16G16B16A16          = 10;
  static const int UnormR16G16B16A16          = 11;
  static const int UintR16G16B16A16           = 12;
  static const int NormR16G16B16A16           = 13;
  static const int IntR16G16B16A16            = 14;
  //static const int TypelessR32G32             = 15;
  static const int FloatR32G32                = 16;
  static const int UintR32G32                 = 17;
  static const int IntR32G32                  = 18;
  //static const int R32G8X24_TYPELESS           = 19;
  //static const int D32_FLOAT_S8X24_UINT        = 20;
  //static const int R32_FLOAT_X8X24_TYPELESS    = 21;
  //static const int X32_TYPELESS_G8X24_UINT     = 22;
  //static const int R10G10B10A2_TYPELESS        = 23;

  //---------------------------------------------------------------------
  // 32-bit formats
  //---------------------------------------------------------------------

  static const int UnormR10G10B10A2           = 24;
  static const int UintR10G10B10A2            = 25;
  static const int FloatR11G11B10             = 26;
  //static const int R8G8B8A8_TYPELESS           = 27;
  static const int UnormR8G8B8A8              = 28;
  static const int SrgbUnormR8G8B8A8          = 29;
  static const int UintR8G8B8A8               = 30;
  static const int NormR8G8B8A8               = 31;
  static const int IntR8G8B8A8                = 32;
  //static const int R16G16_TYPELESS             = 33;
  static const int FloatR16G16                = 34;
  static const int UnormR16G16                = 35;
  static const int UintR16G16                 = 36;
  static const int NormR16G16                 = 37;
  static const int IntR16G16                  = 38;
  //static const int R32_TYPELESS                = 39;
  //static const int D32_FLOAT                   = 40;
  static const int FloatR32                   = 41;
  static const int UintR32                    = 42;
  static const int IntR32                     = 43;
  //static const int R24G8_TYPELESS              = 44;
  //static const int D24_UNORM_S8_UINT           = 45;
  //static const int R24_UNORM_X8_TYPELESS       = 46;
  //static const int X24_TYPELESS_G8_UINT        = 47;
  //static const int R8G8_TYPELESS               = 48;
  static const int UnormR8G8                  = 49;
  static const int UintR8G8                   = 50;
  static const int NormR8G8                   = 51;
  static const int IntR8G8                    = 52;
  //static const int R16_TYPELESS                = 53;
  static const int FloatR16                   = 54;
  //static const int D16_UNORM                   = 55;
  static const int UnormR16                   = 56;
  static const int UintR16                    = 57;
  static const int NormR16                   = 58;
  static const int IntR16                    = 59;
  //static const int R8_TYPELESS                 = 60;
  static const int UnormR8                    = 61;
  static const int UintR8                     = 62;
  static const int NormR8                     = 63;
  static const int IntR8                      = 64;
  static const int UnormA8                    = 65;
  //static const int R1_UNORM                    = 66;
  static const int SharedExpR9G9B9E5          = 67;
  static const int UnormR8G8B8G8              = 68;
  static const int UnormG8R8G8B8              = 69;
  //static const int BC1_TYPELESS                = 70;
  static const int UnormBc1                   = 71;
  static const int SrgbUnormBc1               = 72;
  //static const int BC2_TYPELESS                = 73;
  static const int UnormBc2                   = 74;
  static const int SrgbUnormBc2               = 75;
  //static const int BC3_TYPELESS                = 76;
  static const int UnormBc3                   = 77;
  static const int SrgbUnormBc3               = 78;
  //static const int BC4_TYPELESS                = 79;
  static const int UnormBc4                   = 80;
  static const int NormBc4                   = 81;
  //static const int BC5_TYPELESS                = 82;
  static const int UnormBc5                   = 83;
  static const int NormBc5                    = 84;
  static const int UnormB5G6R5                = 85;
  static const int UnormB5G5R5A1              = 86;
  static const int UnormB8G8R8A8              = 87;
  static const int UnormB8G8R8X8              = 88;
  static const int XrBiasA2UnormR10G10B10    = 89;
  //static const int B8G8R8A8_TYPELESS           = 90;
  static const int SrgbUnormB8G8R8A8         = 91;
  //static const int B8G8R8X8_TYPELESS           = 92;
  static const int SrgbUnormB8G8R8X8         = 93;
  //static const int BC6H_TYPELESS               = 94;
  static const int Uf16Bc6h                   = 95;
  static const int Sf16Bc6h                   = 96;
  //static const int BC7_TYPELESS                = 97;
  static const int UnormBc7                   = 98;
  static const int SrgbUnormBc7              = 99;
  /*
  static const int AYUV                        = 100;
  static const int Y410                        = 101;
  static const int Y416                        = 102;
  static const int NV12                        = 103;
  static const int P010                        = 104;
  static const int P016                        = 105;
  static const int 420_OPAQUE                  = 106;
  static const int YUY2                        = 107;
  static const int Y210                        = 108;
  static const int Y216                        = 109;
  static const int NV11                        = 110;
  static const int AI44                        = 111;
  static const int IA44                        = 112;
  static const int P8                          = 113;
  static const int A8P8                        = 114;
  */
  //static const int B4G4R4A4_UNORM              = 115;



  static const int UnormR8G8B8 = 116;

  static int getBitsPerPixel(int value) {
    switch (value) {
      case FloatR32G32B32A32     :
      case UintR32G32B32A32      :
      case IntR32G32B32A32       : return 128;
      case FloatR32G32B32        :
      case UintR32G32B32         :
      case IntR32G32B32          : return 96;
      case FloatR16G16B16A16     :
      case UnormR16G16B16A16     :
      case UintR16G16B16A16      :
      case NormR16G16B16A16      :
      case IntR16G16B16A16       :
      case FloatR32G32           :
      case UintR32G32            :
      case IntR32G32             : return 64;
      case UnormR10G10B10A2      :
      case UintR10G10B10A2       :
      case FloatR11G11B10        :
      case UnormR8G8B8A8         :
      case SrgbUnormR8G8B8A8     :
      case UintR8G8B8A8          :
      case NormR8G8B8A8          :
      case IntR8G8B8A8           :
      case FloatR16G16           :
      case UnormR16G16           :
      case UintR16G16            :
      case NormR16G16            :
      case IntR16G16             :
      case FloatR32              :
      case UintR32               :
      case IntR32                : return 32;
      case UnormR8G8             :
      case UintR8G8              :
      case NormR8G8              :
      case IntR8G8               :
      case FloatR16              :
      case UnormR16              :
      case UintR16               :
      case NormR16               :
      case IntR16                : return 16;
      case UnormR8               :
      case UintR8                :
      case NormR8                :
      case IntR8                 :
      case UnormA8               : return 8;
      case SharedExpR9G9B9E5     : return 32;
      case UnormR8G8B8G8         :
      case UnormG8R8G8B8         : return 0;
      case UnormBc1              :
      case SrgbUnormBc1          :
      case UnormBc2              :
      case SrgbUnormBc2          :
      case UnormBc3              :
      case SrgbUnormBc3          :
      case UnormBc4              :
      case NormBc4               :
      case UnormBc5              :
      case NormBc5               : return 0;
      case UnormB5G6R5           :
      case UnormB5G5R5A1         : return 16;
      case UnormB8G8R8A8         :
      case UnormB8G8R8X8         :
      case XrBiasA2UnormR10G10B10: return 32;
      case SrgbUnormB8G8R8A8     :
      case SrgbUnormB8G8R8X8     : return 32;
      case Uf16Bc6h              :
      case Sf16Bc6h              :
      case UnormBc7              :
      case SrgbUnormBc7          : return 0;
    }

    return 0;
  }

  /// Determines whether the format is block compressed.
  static bool isBlockCompressed(int value) {
    switch (value) {
      case UnormBc1    :
      case SrgbUnormBc1:
      case UnormBc2    :
      case SrgbUnormBc2:
      case UnormBc3    :
      case SrgbUnormBc3:
      case UnormBc4    :
      case NormBc4     :
      case UnormBc5    :
      case NormBc5     :
      case Uf16Bc6h    :
      case Sf16Bc6h    :
      case UnormBc7    :
      case SrgbUnormBc7: return true;
    }

    return false;
  }
}

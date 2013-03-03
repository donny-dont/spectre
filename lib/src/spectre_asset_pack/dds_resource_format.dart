/*
  Copyright (C) 2013 Spectre Authors

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

class DdsResourceFormat {
  /// An unknown format.
  const int Unknown = 0;


  //const int TypelessR32G32B32A32       = 1;
  const int FloatR32G32B32A32 = 2;
  const int UintR32G32B32A32           = 3;
  const int IntR32G32B32A32            = 4;
  //const int TypelessR32G32B32          = 5;
  const int FloatR32G32B32             = 6;
  const int UintR32G32B32              = 7;
  const int IntR32G32B32               = 8;
  //const int R16G16B16A16_TYPELESS       = 9;
  const int FloatR16G16B16A16          = 10;
  const int UnormR16G16B16A16          = 11;
  const int UintR16G16B16A16           = 12;
  const int NormR16G16B16A16           = 13;
  const int IntR16G16B16A16            = 14;
  //const int TypelessR32G32             = 15;
  const int FloatR32G32                = 16;
  const int UintR32G32                 = 17;
  const int IntR32G32                  = 18;
  //const int R32G8X24_TYPELESS           = 19;
  //const int D32_FLOAT_S8X24_UINT        = 20;
  //const int R32_FLOAT_X8X24_TYPELESS    = 21;
  //const int X32_TYPELESS_G8X24_UINT     = 22;
  //const int R10G10B10A2_TYPELESS        = 23;
  const int UnormR10G10B10A2           = 24;
  const int UintR10G10B10A2            = 25;
  const int FloatR11G11B10             = 26;
  //const int R8G8B8A8_TYPELESS           = 27;
  const int UnormR8G8B8A8              = 28;
  const int SrgbUnormR8G8B8A8          = 29;
  const int UintR8G8B8A8               = 30;
  const int NormR8G8B8A8               = 31;
  const int IntR8G8B8A8                = 32;
  //const int R16G16_TYPELESS             = 33;
  const int FloatR16G16                = 34;
  const int UnormR16G16                = 35;
  const int UintR16G16                 = 36;
  const int NormR16G16                 = 37;
  const int IntR16G16                  = 38;
  //const int R32_TYPELESS                = 39;
  //const int D32_FLOAT                   = 40;
  const int FloatR32                   = 41;
  const int UintR32                    = 42;
  const int IntR32                     = 43;
  //const int R24G8_TYPELESS              = 44;
  //const int D24_UNORM_S8_UINT           = 45;
  //const int R24_UNORM_X8_TYPELESS       = 46;
  //const int X24_TYPELESS_G8_UINT        = 47;
  //const int R8G8_TYPELESS               = 48;
  const int UnormR8G8                  = 49;
  const int UintR8G8                   = 50;
  const int NormR8G8                   = 51;
  const int IntR8G8                    = 52;
  //const int R16_TYPELESS                = 53;
  const int FloatR16                   = 54;
  //const int D16_UNORM                   = 55;
  const int UnormR16                   = 56;
  const int UintR16                    = 57;
  const int NormR16                   = 58;
  const int IntR16                    = 59;
  //const int R8_TYPELESS                 = 60;
  const int UnormR8                    = 61;
  const int UintR8                     = 62;
  const int NormR8                     = 63;
  const int IntR8                      = 64;
  const int UnormA8                    = 65;
  //const int R1_UNORM                    = 66;
  const int SharedExpR9G9B9E5          = 67;
  const int UnormR8G8B8G8              = 68;
  const int UnormG8R8G8B8              = 69;
  //const int BC1_TYPELESS                = 70;
  const int UnormBc1                   = 71;
  const int SrgbUnormBc1               = 72;
  //const int BC2_TYPELESS                = 73;
  const int UnormBc2                   = 74;
  const int SrgbUnormBc2               = 75;
  //const int BC3_TYPELESS                = 76;
  const int UnormBc3                   = 77;
  const int SrgbUnormBc3               = 78;
  //const int BC4_TYPELESS                = 79;
  const int UnormBc4                   = 80;
  const int NormBc4                   = 81;
  //const int BC5_TYPELESS                = 82;
  const int UnormBc5                   = 83;
  const int NormBc5                    = 84;
  const int UnormB5G6R5                = 85;
  const int UnormB5G5R5A1              = 86;
  const int UnormB8G8R8A8              = 87;
  const int UnormB8G8R8X8              = 88;
  const int XrBiasA2UnormR10G10B10    = 89;
  //const int B8G8R8A8_TYPELESS           = 90;
  const int SrgbUnormB8G8R8A8         = 91;
  //const int B8G8R8X8_TYPELESS           = 92;
  const int SrgbUnormB8G8R8X8         = 93;
  //const int BC6H_TYPELESS               = 94;
  const int Uf16Bc6h                   = 95;
  const int Sf16Bc6h                   = 96;
  //const int BC7_TYPELESS                = 97;
  const int UnormBc7                   = 98;
  const int SrgbUnormBc7              = 99;
  /*
  const int AYUV                        = 100;
  const int Y410                        = 101;
  const int Y416                        = 102;
  const int NV12                        = 103;
  const int P010                        = 104;
  const int P016                        = 105;
  const int 420_OPAQUE                  = 106;
  const int YUY2                        = 107;
  const int Y210                        = 108;
  const int Y216                        = 109;
  const int NV11                        = 110;
  const int AI44                        = 111;
  const int IA44                        = 112;
  const int P8                          = 113;
  const int A8P8                        = 114;
  const int B4G4R4A4_UNORM              = 115;
  */
}

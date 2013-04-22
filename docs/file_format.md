File Format Support
===================

Spectre provides support for loading numerous asset formats. This document
describes what is supported natively within Spectre.

Contents
========
- [Textures](#textures)  
  - [Image formats](#imageFormats)
  - [Compressed formats](#compressedFormats)
  - [Memory requirements](#memoryRequirements)
  - [Choosing the right format](#choosingImageFormat)
- [Shaders](#shaders)
  - [Example](#shaderExample)

<a name="textures"/>
Textures
========

Spectre has support for creating 2D textures and cubemaps. WebGL 1.0 does not
contain support for volume (3D) textures and texture arrays so they cannot be
used.

Additionally some texture formats are only supported through extensions. WebGL
has mulitple extensions for compressed formats.
[S3 Texture Compression](http://www.khronos.org/registry/webgl/extensions/WEBGL_compressed_texture_s3tc/)
support is typically found in desktop PCs. The 
[PVRTC format](http://www.khronos.org/registry/webgl/extensions/WEBGL_compressed_texture_pvrtc/)
is found on mobile devices but not on desktops. There is also the
[ATC format](http://www.khronos.org/registry/webgl/extensions/WEBGL_compressed_texture_atc/)
which is AMD's format for mobile devices.

On top of compressed formats there are also extensions for floating point
textures. This includes both full
[32-bit floating point textures](http://www.khronos.org/registry/webgl/extensions/OES_texture_float/)
and [16-bit half floating point textures](http://www.khronos.org/registry/webgl/extensions/OES_texture_half_float/).

When choosing what extensions to use its important to see the level of support
an extension has. A site such as [WebGL Stats](http://webglstats.com/) can
provide information on the capabilities of WebGL enabled browsers.

<a name="imageFormats"/>
Image Formats
-------------

Textures can be created directly from HTMLImageElements. After retrieving the
asset the image is then uploaded to the texture surface by the importer.

The following image formats are supported by all browsers

- JPEG
- PNG
- GIF

Additionally those directly targeting Chrome can assume WebP support which has
a higher compression than JPEG.

<a name="videoFormats"/>
Video formats
-------------

Textures can also be loaded with image data from HTMLVideoElements.

Video formats are not as uniformly available as image formats. See the following
table for what the current support situation is.

<table style="width:100%;text-align:center">
  <tr>
    <th></th>
    <th>MP4</th>
    <th>OGG</th>
    <th>WebM</th>
  </tr>
  <tr>
    <td>Google Chrome</td>
    <td>YES</td>
    <td>YES</td>
    <td>YES</td>
  </tr>
  <tr>
    <td>Mozilla Firefox</td>
    <td>NO</td>
    <td>YES</td>
    <td>YES</td>
  </tr>
  <tr>
    <td>Apple Safari</td>
    <td>YES</td>
    <td>NO</td>
    <td>NO</td>
  </tr>
</table>
    
</table>

When using a video as a texture the data must be manually updated whenever a
frame change occurs. There is not currently an implementation which
automatically uploads the texture though if the
[dynamic texture extension](http://www.khronos.org/registry/webgl/extensions/proposals/WEBGL_dynamic_texture/)
is implemented this behavior will change.

<a name="compressedFormats"/>
Compressed Formats
------------------

Spectre provides support for
[Direct Draw Surface (DDS)](http://msdn.microsoft.com/en-us/library/windows/desktop/bb943991.aspx)
textures. While DDS files can contain uncompressed data they typically contain
data compressed in a
[S3 Texture Compression](http://en.wikipedia.org/wiki/S3_Texture_Compression)
format. Additionally DDS files can be used to contain floating point textures
though as the data is uncompressed the file size would be fairly large.

The following features are supported in the DDS file reader within Spectre.

- DX9 and DX10 formats
- Compressed and uncompressed formats
- Cubemaps
- Volume textures
- Texture arrays
- Mipmaps

The DDS file format has support for numerous surface formats and texture types.
However not all of them are supported within Spectre due to limitations in WebGL
1.0. While the file reader can fully parse the format if the texture is not
supported then the importer will fallback to a default texture and log an error.

Any more complicated importing scenario will require creating a new
AssetImporter. As an example if one wished they could read each individual slice
of a volume texture and create a single 2D texture for each.

<a name="memoryRequirements"/>
Memory Requirements
-------------------

The amount of memory required for a texture is dependent upon the format it is
stored in on the graphics card. If the image is not stored in a native
compressed format, which is true for any image that can be stored in a
HTMLImageFormat, then it is uncompressed and then loaded onto the graphics card.

The following table gives information on the formats supported by WebGL and also
how much space a 1024x1024 texture would occupy on the graphics card.

<table style="width:100%;text-align:center">
  <tr>
    <th></th>
    <th>Format</th>
    <th>Bits Per Pixel</th>
    <th>Red</th>
    <th>Green</th>
    <th>Blue</th>
    <th>Alpha</th>
    <th>1024x1204 texture</th>
  </tr>
  <tr>
    <td>RGB</td>
    <td>Unsigned byte</td>
    <td>24</td>
    <td>8</td>
    <td>8</td>
    <td>8</td>
    <td>0</td>
    <td>3 MB</td>
  </tr>
  <tr>
    <td>RGBA</td>
    <td>Unsigned byte</td>
    <td>32</td>
    <td>8</td>
    <td>8</td>
    <td>8</td>
    <td>8</td>
    <td>4 MB</td>
  </tr>
  <tr>
    <td>RGB 565</td>
    <td>Unsigned short</td>
    <td>16</td>
    <td>5</td>
    <td>6</td>
    <td>5</td>
    <td>0</td>
    <td>2 MB</td>
  </tr>
  <tr>
    <td>RGBA 5551</td>
    <td>Unsigned short</td>
    <td>16</td>
    <td>5</td>
    <td>5</td>
    <td>5</td>
    <td>1</td>
    <td>2 MB</td>
  </tr>
  <tr>
    <td>RGBA 4444</td>
    <td>Unsigned short</td>
    <td>16</td>
    <td>4</td>
    <td>4</td>
    <td>4</td>
    <td>4</td>
    <td>2 MB</td>
  </tr>
  <tr>
    <td>R32G32B32</td>
    <td>Float</td>
    <td>96</td>
    <td>32</td>
    <td>32</td>
    <td>32</td>
    <td>0</td>
    <td>12 MB</td>
  </tr>
  <tr>
    <td>R32G32B32A32</td>
    <td>Float</td>
    <td>128</td>
    <td>32</td>
    <td>32</td>
    <td>32</td>
    <td>32</td>
    <td>16 MB</td>
  </tr>
  <tr>
    <td>R16G16B16</td>
    <td>Half Float</td>
    <td>48</td>
    <td>16</td>
    <td>16</td>
    <td>16</td>
    <td>0</td>
    <td>6 MB</td>
  </tr>
  <tr>
    <td>R16G16B16A16</td>
    <td>Half Float</td>
    <td>64</td>
    <td>16</td>
    <td>16</td>
    <td>16</td>
    <td>16</td>
    <td>8 MB</td>
  </tr>
  <tr>
    <td>DXT1</td>
    <td>Compressed</td>
    <td>N/A</td>
    <td>N/A</td>
    <td>N/A</td>
    <td>N/A</td>
    <td>N/A</td>
    <td>0.5 MB</td>
  </tr>  
  <tr>
    <td>DXT3</td>
    <td>Compressed</td>
    <td>N/A</td>
    <td>N/A</td>
    <td>N/A</td>
    <td>N/A</td>
    <td>N/A</td>
    <td>1 MB</td>
  </tr>  
  <tr>
    <td>DXT5</td>
    <td>Compressed</td>
    <td>N/A</td>
    <td>N/A</td>
    <td>N/A</td>
    <td>N/A</td>
    <td>N/A</td>
    <td>1 MB</td>
  </tr>  
</table>

<a name="choosingImageFormat"/>
Choosing the Right Format
-------------------------

When choosing a texture format for assets the following should be taken into
account

- Alpha channel support, not all formats support alpha channels.
- Download size, the larger the asset size the longer it will take to download.
- Image quality, some formats are lossy while others are lossless.
- Memory requirements, textures cannot be compressed on the fly.

The following table addresses these concerns. For the file size the classic
[Lena](http://en.wikipedia.org/wiki/Lenna) image is used. The values are meant
to give general numbers on what the formats produce. The numbers will vary
dependent on the compressor used, except for DXT compressed files whose size is
dependent on the dimensions of the image being stored.

<table style="width:100%;text-align:center">
  <tr>
    <th></th>
    <th>Alpha channel</th>
    <th>Quality</th>
    <th>File Size</th>
    <th>Memory Usage</th>
  </tr>
  <tr>
    <td>PNG</td>
    <td>YES</td>
    <td>Lossless</td>
    <td>462 KB</td>
    <td>768 KB</td>
  </tr>
  <tr>
    <td>JPEG</td>
    <td>NO</td>
    <td>Lossy</td>
    <td>94 KB</td>
    <td>768 KB</td>
  </tr>
  <tr>
    <td>WebP</td>
    <td>NO</td>
    <td>Lossy</td>
    <td>93 KB</td>
    <td>768 KB</td>
  </tr>
  <tr>
    <td>DXT1</td>
    <td>NO</td>
    <td>Lossy</td>
    <td>128 KB</td>
    <td>128 KB</td>
  </tr>
</table>

For most images the WebP format will provide the smallest download size. If that
is not available than a JPEG comes in at the number two slot. The next slot goes
to DDS which is a bit larger but has the added benefit of taking up less texture
memory. A PNG file is not ideal for photographic data so it does not perform
well in this case.

To diminish the size of a DDS file additional compression could be applied. The
[Crunch](https://code.google.com/p/crunch/) library could be used to achieve
file sizes smaller than WebP. Another option is to compress the DDS file using a
compression algorithm such as [LZHAM](https://code.google.com/p/lzham/).
Currently Spectre has no support for additional compression of DDS.

The PNG format works best for files that contain sharp transitions and large
areas of solid color, which is likely the case for sprite data. If memory usage
is a concern then consider using the 16-bit color space, RGB565, RGB5551, or
RGBA4444.

The assets should be processed to use 16-bit color using an image editor. An
editor should be able to apply a
[dithering algorithm](http://en.wikipedia.org/wiki/Floyd%E2%80%93Steinberg_dithering)
when cutting the color space which should provide a better quality image.

It should be noted that the PNG format does not provide special treatment to
16-bit color. The values will still end up as 24 or 32 bit color data, dependent
on the format, but will likely result in a smaller file size. The color values
will be converted to 16-bit values when passing the HTMLImageElement to WebGL.

<a name="shaders"/>
Shaders
=======

Spectre supports the creation of shader programs which are used to control the
rendering of geometry to the screen. A shader program is built by combining a
vertex shader and a fragment shader. After compiling and linking the two
together a program that can be bound to the graphics pipeline is created.

Spectre supports the
[OpenGL Transmission Format](https://github.com/KhronosGroup/glTF/blob/master/specification/README.md)
for loading shader programs. This format specifies a shader program in a JSON
format.

Currently the loaded file is expected to contain a single shader program with
the vertex and fragment shaders contained inline.

<a name="shaderExample"/>
Example
-------

    {
      "name":"shaderProgram",
      "attributes": [
        {
          "semantic":"POSITION",
          "symbol":"vPosition"
        },
        {
          "semantic":"NORMAL",
          "symbol":"vNormal"
        },
        {
          "semantic":"TEXCOORD",
          "symbol":"vTexCoord"
        }
      ],
      "vertexShader": {
        "name":"vertShader",
        "source":"...SOURCE GOES HERE..."
      },
      "fragmentShader": {
        "name":"fragShader",
        "source":"...SOURCE GOES HERE..."
      }
    }

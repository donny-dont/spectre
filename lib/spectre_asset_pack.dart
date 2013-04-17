/*
  Copyright (C) 2013 John McCutchan <john@johnmccutchan.com>

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

/** Spectre asset_pack companion library */

library spectre_asset_pack;

import 'dart:html';
import 'dart:json' as JSON;
import 'dart:math' as Math;
import 'dart:async';
import 'package:asset_pack/asset_pack.dart';
import 'package:spectre/spectre.dart';

part 'src/spectre_asset_pack/dds_file.dart';
part 'src/spectre_asset_pack/dds_resource_format.dart';
part 'src/spectre_asset_pack/mesh.dart';
part 'src/spectre_asset_pack/shader.dart';
part 'src/spectre_asset_pack/spectre_asset_pack.dart';
part 'src/spectre_asset_pack/texture.dart';

part 'src/spectre_asset_pack/formats/opengl_transmission_format.dart';
part 'src/spectre_asset_pack/formats/program_attribute.dart';
part 'src/spectre_asset_pack/formats/program_format.dart';
part 'src/spectre_asset_pack/formats/semantic_format.dart';
part 'src/spectre_asset_pack/formats/shader_format.dart';

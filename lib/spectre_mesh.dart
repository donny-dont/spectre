/*

  Copyright (C) 2012 The Spectre Project authors.

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

library spectre_mesh;

import 'dart:html';
import 'dart:scalarlist';
import 'spectre.dart';
import 'package:vector_math/vector_math.dart';

part 'src/spectre_mesh/arrays.dart';
part 'src/spectre_mesh/box_generator.dart';
part 'src/spectre_mesh/mesh_generator.dart';
part 'src/spectre_mesh/normal_data_builder.dart';
part 'src/spectre_mesh/plane_generator.dart';
part 'src/spectre_mesh/tangent_space_builder.dart';
part 'src/spectre_mesh/vertex_data.dart';
part 'src/spectre_mesh/scalar_list.dart';
part 'src/spectre_mesh/strided_list.dart';
part 'src/spectre_mesh/vector2_list.dart';
part 'src/spectre_mesh/vector3_list.dart';
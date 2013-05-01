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

library animation_baker;

import 'dart:io';
import 'dart:typed_data';
import 'dart:json' as JSON;

class BonePositionAnimation {
  final int tick;
  final Float32List position = new Float32List(3);
  BonePositionAnimation(this.tick, List values) {
    position[0] = values[0].toDouble();
    position[1] = values[1].toDouble();
    position[2] = values[2].toDouble();
  }
}

class BoneRotationAnimation {
  final int tick;
  final Float32List rotation = new Float32List(4);
  BoneRotationAnimation(this.tick, List values) {
    rotation[0] = values[0].toDouble();
    rotation[1] = values[1].toDouble();
    rotation[2] = values[2].toDouble();
    rotation[3] = values[3].toDouble();
  }
}

class BoneScaleAnimation {
  final int tick;
  final Float32List scale = new Float32List(3);
  BoneScaleAnimation(this.tick, List values) {
    scale[0] = values[0].toDouble();
    scale[1] = values[1].toDouble();
    scale[2] = values[2].toDouble();
  }
}

class BoneAnimation {
  final String name;
  final List<BonePositionAnimation> positions = 
      new List<BonePositionAnimation>();
  final List<BoneRotationAnimation> rotations = 
      new List<BoneRotationAnimation>();
  final List<BoneScaleAnimation> scales = new List<BoneScaleAnimation>();
  BoneAnimation(this.name);
}

class AnimationBaker {
  final Map input;
  final Map output = new Map();
  final Map<String, BoneAnimation> animations =
      new Map<String, BoneAnimation>();
  AnimationBaker(this.input);

  clear() {
  }
  
  bake() {
    List animations = input['animations'];
    if (animations == null) {
      throw new ArgumentError('Input has no animations.');
    }
    
    output['name'] = 'nameme';
    output['duration'] = input['duration'];
    output['ticksPerSecond'] = input['tickspersecond'];
  }
}

main() {
  File f = new File("/usr/local/google/home/johnmccutchan/Downloads/idle2.json");
  String inputString = f.readAsStringSync();
  Map inputAnimation = JSON.parse(inputString);
  AnimationBaker ab = new AnimationBaker(inputAnimation);
  ab.bake();
  print(JSON.stringify(ab.output));
}

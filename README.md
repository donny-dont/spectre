# Spectre #

## Introduction ##
A low level 3D graphics library for Dart.

Spectre is a modern graphics API wrapping WebGL. 

A "modern graphics API" consists of:

Device - Manage vertex buffers, index buffers, textures, shaders, and other GPU objects
ImmediateContext - Set GPU state and initiate draw calls
ProgramBuilder - Build your rendering commands once
Interpreter - Execute your prebuilt programs
Resource - Resource types including images, meshes, shaders, and more
ResourceManager - Manage and load resources 

Spectre also includes a resource manager and a demo framework called 'Javeline'.


## Status: Beta ##
Stuff works but the API is not guaranteed yet.


## Getting Started ##
Create a Dart project and add a **pubspec.yaml** file to it

```
dependencies:
  spectre:
    git: https://github.com/johnmccutchan/spectre.git
```
and run **pub install** to install **spectre** (including its dependencies). Now add import

```
#import('package:vector_math/vector_math_browser.dart'); 
#import('package:spectre/spectre.dart');
#import('package:spectre/spectre_scene.dart');
#import('package:spectre/spectre_post.dart');
```

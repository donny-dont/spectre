# Mesh Processing Tools

The Spectre mesh processing tools accept meshes that have been
preprocessed via [assimp2json](https://github.com/acgessler/assimp2json).

By relying on `assimp2json` Spectre can handle a wide variety of [mesh
formats](http://assimp.sourceforge.net/main_features_formats.html).

## Animation Baker

Processes a set of skeletal animations to be loaded in Spectre.

`dart ./bin/animation_baker.dart <input file> <output file>`

## Skinned Mesh Baker

Processes a mesh containing a skeleton to be loaded in Spectre.

`dart ./bin/skinned_mesh_baker.dart <input file> <output file>`

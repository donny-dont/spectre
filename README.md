# Spectre
## A modern graphics API for WebGL development with Dart

__Spectre__ is a modern graphics API aimed at developers creating games and other interactive 3D applications. It is designed for performance while retaining a developer friendly interface.

## Try It Now
__Spectre__ is in a fully working state, but the API has not completely solidified and is subject to change. This will be the case until an official 1.0 release occurs, though as this approaches major revisions are unlikely. Because of this it is recommended to work against the master branch of the library. It is also recommended to have the latest released version of the Dart SDK before starting development.

Add the __Spectre__ package to your `pubspec.yaml` file which references the main repository.
```yaml
dependencies:
  spectre:
    git: https://github.com/johnmccutchan/spectre.git
```

Then within your application it can be imported using the following code
```
import 'package:spectre/spectre.dart';
import 'package:vector_math/vector_math.dart';
```

## Documentation

[API Reference](http://johnmccutchan.github.com/spectre/)
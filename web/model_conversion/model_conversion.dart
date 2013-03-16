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

import 'dart:html';
import 'dart:async';
import 'package:web_ui/web_ui.dart';

/// Model viewer web component.
ModelViewerComponent _modelViewerComponent;
/// URL to the conversion API.
///
/// Currently using a server on Heroku.
//const String _convertUrl = 'http://evening-hamlet-7692.herokuapp.com/api/convert';
const String _convertUrl = 'http://127.0.0.1:3000/api/convert';
/// The [FileSystem] to write to.
FileSystem _fileSystem;
/// The largest model size to expect.
///
/// Using a temporary filesystem so the user doesn't have to be
/// prompted.
const int _maxModelSize = 5 * 1024 * 1024;

/// Convert the models.
void _convertModel(_) {
  FormElement form = query('form');
  FormData formData = new FormData(form);

  HttpRequest request = new HttpRequest();
  request.open('POST', _convertUrl);
  request.onLoadEnd.listen((_) {
    if (_fileSystem != null) {
      // Show the file contents
      TextAreaElement textArea = query('#modelFile');
      textArea.value = request.responseText;

      // Write out the file
      _writeText('model.mesh', request.responseText).then((modelUrl) {
        _modelViewerComponent.loadModelFromUrl(modelUrl, true);
      });
    }
  });

  request.send(formData);
}

/// Application loop.
void _onUpdate(double time) {
  // Update the animation
  _modelViewerComponent.update(time);

  // Draw the scene
  _modelViewerComponent.draw();

  // For the animation to continue the function
  // needs to set itself again
  window.requestAnimationFrame(_onUpdate);
}

/// Starts up the application.
///
/// There's a delay between when [main] is called and when the web
/// components are actually ready to be used. Because of this the
/// initialization can't actually happen in main.
void _startup() {
  // Load the model viewer
  _modelViewerComponent = query('#model_viewer').xtag;
  _modelViewerComponent.loadModelFromUrl('../meshes/cube.mesh', false);

  // Hook into the submit button
  InputElement submitButton = query('#convertModel');
  submitButton.onClick.listen(_convertModel);

  // Request storage
  window.storageInfo.requestQuota(StorageInfo.TEMPORARY, _maxModelSize,
    (grantedBytes) {
      print('Granted $grantedBytes bytes');
      // Request the file system
      window.requestFileSystem(StorageInfo.TEMPORARY, grantedBytes, _onFileSystemCreated, _onFileSystemError);
    },
    (error) {
      print(error);
    }
  );

  // Start up the animation loop
  window.requestAnimationFrame(_onUpdate);
}

/// Callback for when the [FileSystem] is created.
void _onFileSystemCreated(FileSystem fileSystem) {
  _fileSystem = fileSystem;
}

/// Callback for when an error occurs when using the [FileSystem].
void _onFileSystemError(FileError error) {
  String messageCode = '';

  switch (error.code) {
    case FileError.QUOTA_EXCEEDED_ERR: messageCode = 'Quota Exceeded'; break;
    case FileError.NOT_FOUND_ERR: messageCode = 'Not found '; break;
    case FileError.SECURITY_ERR: messageCode = 'Security Error'; break;
    case FileError.INVALID_MODIFICATION_ERR: messageCode = 'Invalid Modificaiton'; break;
    case FileError.INVALID_STATE_ERR: messageCode = 'Invalid State'; break;
    default: messageCode = 'Unknown error'; break;
  }

  print('Filesystem error: $messageCode');
}

/// Writes a text file to disk.
Future<String> _writeText(String fileName, String text)
{
  Blob data = new Blob([text], 'text/plain');
  Completer completer = new Completer();

  Map options = { 'create': true };

  _fileSystem.root.getFile(fileName, options: { 'create': true }, successCallback: (fileEntry) {
    fileEntry.createWriter((fileWriter) {
      bool truncated = false;

      fileWriter.onWriteEnd.listen((_) {
        if (truncated)
        {
          completer.complete(fileEntry.toUrl());
        }
        else
        {
          fileWriter.write(data);
          truncated = true;
        }
      });

      // Clear the current file
      // The file is not overwritten completely unless
      // a truncate is performed.
      fileWriter.truncate(0);
    });
  }, errorCallback: _onFileSystemError);

  return completer.future;
}

/// Entry-point to the application.
void main() {
  //useShadowDom = true; // to enable use of experimental Shadow DOM in the browser

  // Start up the application
  // Add a delay so the Web Components are initialized
  Timer.run(_startup);
}

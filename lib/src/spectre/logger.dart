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

part of spectre;

/// Spectre Logging interface
abstract class Logger {
  // Report an error
  void Error(String e);
  // Report a warning
  void Warning(String w);
  // Report information
  void Info(String i);
}

/// An implementation of [Logger] that calls print
class PrintLogger implements Logger {
  void Error(String e) {
    print('Error: $e');
  }

  void Warning(String w) {
    print('Warning: $w');
  }

  void Info(String i) {
    print('$i');
  }
}

/// An implementation of [Logger] that does nothing
class NullLogger implements Logger {
  void Error(String e) {
  }
  void Warning(String w) {
  }
  void Info(String i) {
  }
}

/// An implementation of [Logger] that appends to an HTML element
class HtmlLogger implements Logger {
  Element _logElement;
  int _line_num;
  /// element is the CSS id of the HTML element to log into
  HtmlLogger(String element) {
    _logElement = document.query(element);
    _line_num = 0;
  }
  void _Append(String a) {
    _logElement.innerHtml = '$a ${_logElement.innerHtml}';
    _line_num++;
  }
  void Error(String e) {
    print('Error: $e');
    _Append('<p style=\"color:red\">${_line_num}: $e</p>');
  }
  void Warning(String w) {
    print('Warning: $w');
    _Append('<p style=\"color:orange\">${_line_num}: $w</p>');
  }
  void Info(String i) {
    print('Info: $i');
    _Append('<p style=\"color:black\">${_line_num}: $i</p>');
  }
  void Log(String i) => Info(i);
}

// We have a single logger
Logger spectreLog = new PrintLogger();
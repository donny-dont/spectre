part of skeletal_animation_cpu;

class ApplicationControls {

  static String _controlContainerId = '#ui_wrap';
  static String _hideClassName = 'hide';
  static String _showClassName = 'show';

  DivElement _controlContainer;

  /// Creates an instance of the [ApplicationControls] class.
  ApplicationControls() {
    _controlContainer = query(_controlContainerId);
  }

  /// Show the controls.
  ///
  /// Uses a CSS animation to display the application controls.
  void show() {
    // Initially display is set as none
    _controlContainer.style.display = 'block';

    _controlContainer.classes.remove(_hideClassName);
    _controlContainer.classes.add(_showClassName);
  }

  /// Hide the controls.
  ///
  /// Uses a CSS animation to hide the application controls.
  void hide() {
    _controlContainer.classes.remove(_showClassName);
    _controlContainer.classes.add(_hideClassName);
  }
}

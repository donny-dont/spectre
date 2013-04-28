/*
  Copyright (C) 2013 John McCutchan

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

part of skeletal_animation_cpu;

/// Controls for the [Application].
class ApplicationControls {
  //---------------------------------------------------------------------
  // Class variables
  //---------------------------------------------------------------------

  /// Identifier for the container holding the UI controls.
  static String _controlContainerId = '#ui_wrap';
  /// Identifier for the container holding the model selection.
  static String _modelSelectionId = '#model_selection';
  /// Identifier for the show skeleton checkbox.
  static String _showSkeletonId = '#show_skeleton';
  /// Classname for an option
  static String _optionClassName = 'option';
  /// Classname for when the UI should be hidden.
  static String _hideClassName = 'hide';
  /// Classname for when the UI should be shown.
  static String _showClassName = 'show';
  /// Classname for when an option is selected.
  static String _selectedClassName = 'selected';
  /// Classname for when an option is disabled.
  ///
  /// Used to disable mouse events after the model is selected.
  static String _disabledClassName = 'disabled';

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// [DivElement] containing the UI controls.
  DivElement _controlContainer;
  /// [DivElement] containing the model selection.
  DivElement _modelSelection;

  /// Creates an instance of the [ApplicationControls] class.
  ApplicationControls() {
    _controlContainer = query(_controlContainerId);
    _modelSelection = query(_modelSelectionId);

    print('Children: ${_modelSelection.children.length}');

    // Hook up the show skeleton button
    InputElement showSkeleton = query(_showSkeletonId);

    DivElement showSkeletonParent = showSkeleton.parent;
    showSkeletonParent.onClick.listen((_) {
      _toggleCheckboxArea(showSkeleton, showSkeletonParent);

      _application.drawDebugInformation = showSkeleton.checked;
    });
  }

  //---------------------------------------------------------------------
  // Public methods
  //---------------------------------------------------------------------

  /// Add a model to the UI.
  void addModel(String name, String iconPath) {
    List children = _modelSelection.children;

    // Get the current length as this will be the index to use
    // when the model is selected
    int index = children.length;

    // Create the container
    DivElement container = new DivElement();
    container.classes.add(_optionClassName);

    if (index == 0) {
      container.classes.add(_selectedClassName);
      container.classes.add(_disabledClassName);
    }

    // Add the ImageElement
    ImageElement icon = new ImageElement();
    icon.src = iconPath;

    container.children.add(icon);

    // Add a DivElement containing the name
    DivElement nameElement = new DivElement();
    nameElement.innerHtml = name;

    container.children.add(nameElement);

    // Add a callback for when the model is selected
    container.onClick.listen((_) {
      _selectModel(index);
    });

    // Attach the element
    children.add(container);
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

  //---------------------------------------------------------------------
  // Private methods
  //---------------------------------------------------------------------

  /// Selects the model at the given [index] and updates the UI.
  void _selectModel(int index) {
    int currentIndex = _application.meshIndex;

    if (currentIndex == index) {
      return;
    }

    // Remove selection classes from the old selection
    DivElement current = _modelSelection.children[currentIndex];
    current.classes.remove(_selectedClassName);
    current.classes.remove(_disabledClassName);

    // Add selection classes to the new selection
    DivElement selected = _modelSelection.children[index];
    selected.classes.add(_selectedClassName);
    selected.classes.add(_disabledClassName);

    // Change the model being displayed
    _application.meshIndex = index;
  }

  //---------------------------------------------------------------------
  // Class methods
  //---------------------------------------------------------------------

  /// Changes the visual appearance of the checkbox area.
  static void _toggleCheckboxArea(InputElement checkbox, DivElement parent) {
    bool enabled = !checkbox.checked;

    if (enabled) {
      parent.classes.add(_selectedClassName);
    } else {
      parent.classes.remove(_selectedClassName);
    }

    checkbox.checked = enabled;
  }
}

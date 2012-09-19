
class ConfigEditorItem {
  final String name;
  bool readOnly;
  ConfigEditorItem(this.name) {
    readOnly = false;
  }
  DivElement makeElement(JavelineConfigVariable value) {
    return null;
  }
}

class ConfigSlider extends ConfigEditorItem {
  num min;
  num max;
  num step;
  ConfigSlider(String name, Map props) : super(name) {
    min = props['min'];
    max = props['max'];
    step = props['step'];
  }
  DivElement makeElement(JavelineConfigVariable variable) {
    DivElement root = new DivElement();

    if (variable.value is num) {
      LabelElement l = new LabelElement();
      l.text = '${variable.value}';
      InputElement e = new InputElement();
      e.type = 'range';
      if (min != null) e.min = '$min';
      if (max != null) e.max = '$max';
      if (step != null) e.step = '$step';
      e.value = '${variable.value}';
      e.on.input.add((event) {
        l.text = e.value;
        variable.value = double.parse(e.value);
        JavelineConfigStorage.storeVariable(variable.name);
      });
      root.nodes.add(l);
      root.nodes.add(e);
    }

    return root;
  }
}

class ConfigToggle extends ConfigEditorItem {
  ConfigToggle(String name, Map props) : super(name) {

  }
}

class ConfigTextEntry extends ConfigEditorItem {
  num min;
  num max;
  num step;
  String type;
  ConfigTextEntry(String name, Map props) : super(name) {
    type = props['type'] ? props['type'] : 'text';
    min = props['min'];
    max = props['max'];
    step = props['step'];
  }
}

class ConfigDropdown extends ConfigEditorItem {
  List<String> values;
  ConfigDropdown(String name, Map props) : super(name) {
    values = props['values'];
    if (values == null) {
      values = [''];
    }
  }

  DivElement makeElement(JavelineConfigVariable variable) {
    DivElement root = new DivElement();
    SelectElement selector = new SelectElement();
    root.nodes.add(selector);
    values.forEach((value) {
      OptionElement option = new OptionElement();
      option.text = value;
      option.value = value;
      selector.nodes.add(option);
    });
    selector.on.change.add((event) {
      variable.value = selector.value;
      JavelineConfigStorage.storeVariable(variable.name);
    });
    return root;
  }
}

class ConfigUI {
  Element root;
  List<ConfigEditorItem> _items;
  ConfigUI() {
    _items = new List<ConfigEditorItem>();
  }

  void addItem(Map props) {
    String name = props['name'];
    String widget = props['widget'];
    Map settings = props['settings'];
    JavelineConfigVariable variable = JavelineConfigStorage.variables[name];
    if (variable == null) {
      spectreLog.Error('Could not find $name');
      return;
    }
    ConfigEditorItem item = null;
    switch (widget) {
      case 'slider':
        item = new ConfigSlider(name, settings);
        break;
      case 'dropdown':
        item = new ConfigDropdown(name, settings);
        break;
      case 'text':
        item = new ConfigTextEntry(name, settings);
        break;
      case 'toggle':
        item = new ConfigToggle(name, settings);
        break;
    }
    if (item == null) {
      spectreLog.Warning('Cannot display config widget $widget ($name)');
      return;
    }
    item.readOnly = props['readOnly'] != null;
    _items.add(item);
  }

  void load(Map conf) {
    if (conf['items'] == null) {
      return;
    }

    List<Map> items = conf['items'];
    items.forEach((item) {
      addItem(item);
    });
  }

  void build() {
    root = new TableElement();
    _items.forEach((configitem) {
      TableRowElement item = new TableRowElement();
      {
        TableCellElement label = new TableCellElement();
        label.classes.add('configlabel');
        label.innerHTML = '${configitem.name}';
        item.nodes.add(label);
      }
      {
        TableCellElement contents = new TableCellElement();
        JavelineConfigVariable variable = JavelineConfigStorage.variables[configitem.name];
        contents.nodes.add(configitem.makeElement(variable));
        contents.classes.add('configvalue');
        item.nodes.add(contents);
      }
      root.nodes.add(item);
    });
  }
}

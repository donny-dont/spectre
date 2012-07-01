/*

  Copyright (C) 2012 John McCutchan <john@johnmccutchan.com>
  
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

class CommandBuffer {
  List<Command> _commands;
  
  CommandBuffer() {
    _commands = new List<Command>();
  }
  
  void addCommand(Command cmd) {
    _commands.add(cmd);
  }
  
  void clear() {
    _commands.clear();
  }
  
  void apply(ResourceManager resourceManager, Device device, ImmediateContext context) {
    for (final Command cmd in _commands) {
      cmd.apply(resourceManager, device, context);
    }
  }
  
  void bind(ResourceManager resourceManager, Device device, List<BoundCommand> commands) {
    for (final Command cmd in _commands) {
      commands.add(cmd.bind(resourceManager, device));
    }
  }
}
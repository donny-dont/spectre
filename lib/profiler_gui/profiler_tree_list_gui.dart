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

class ProfilerTreeListGUI {
  static UListElement buildNode(ProfilerTreeNode node) {
    UListElement list = new UListElement();
    for (ProfilerTreeNode child in node.children) {
      if (child.enterCount == 0) {
        continue;
      }
      LIElement item = new LIElement();
      ParagraphElement p = new ParagraphElement();
      {
        int microsecondFrequency = Clock.frequency() ~/ 1000000;
        // average across call counts
        int inclusiveTime = child.inclusiveTicks~/child.enterCount;
        int exclusiveTime = child.exclusiveTicks~/child.enterCount;
        // determine microseconds
        inclusiveTime ~/= microsecondFrequency;
        exclusiveTime ~/= microsecondFrequency;
        p.innerHTML = '${child.name} I: ${inclusiveTime} µs E: ${exclusiveTime} µs C: ${child.enterCount} calls';
      }
      item.nodes.add(p);
      if (child.children.length > 0) {
        item.nodes.add(buildNode(child));
      }
      list.nodes.add(item);
    }
    return list;
  }
  
  static UListElement buildTree(ProfilerTree tree) {
    UListElement root = new UListElement();
    LIElement item = new LIElement();
    ParagraphElement p = new ParagraphElement();
    p.innerHTML = '<p>Root</p>';
    item.nodes.add(p);
    Element r = buildNode(tree.root);
    if (r != null) {
      item.nodes.add(r);
    }
    root.nodes.add(item);
    return root;
  }
}

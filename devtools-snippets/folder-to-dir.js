walk(document.body);

function walk(node) {
  var child, next;
  switch (node.nodeType) {
  case 1:
    // Element
  case 9:
    // Document
  case 11:
    // Document fragment
    child = node.firstChild;
    while (child) {
      next = child.nextSibling;
      walk(child);
      child = next;
    }
    break;
  case 3:
    // Text node
    handleText(node);
    break;
  }
}

function handleText(textNode) {
  var v = textNode.nodeValue;
  
  v = v.replace(/\bfolder\b/g, "directory");
  v = v.replace(/\bfolders\b/g, "directories");
  v = v.replace(/\bFolder\b/g, "Directory");
  v = v.replace(/\bDirectories\b/g, "Directories");
  
  textNode.nodeValue = v;
}

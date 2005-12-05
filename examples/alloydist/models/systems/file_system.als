module systems/file_system

sig Object {}

sig Name {}

disj sig File extends Object {
} {
  some d: Dir | this in d::entries::contents
}

disj sig Dir extends Object {
  entries: set DirEntry,
  parent: option Dir
} {
  parent = this.~DirEntry$contents.~Dir$entries
  all e1, e2 : entries | e1.name = e2.name => e1 = e2
  this !in this.^Dir$parent
  this != Root => Root in this.^Dir$parent
}

fact FileDirPartition {
  File + Dir = Object
}

static sig Root extends Dir {
} {
  no parent
}

sig Cur extends Dir {
}

fact SoleCur {
  sole Cur
}

sig DirEntry {
  name: Name,
  contents: Object
} {
  one this.~entries
}

fact OneParent {
    // all directories besides root xhave one parent
    all d: Dir - Root | one d.parent
}

fun Simple () {
  some DirEntry
}

assert NoDirAliases {
    // Only files may be linked (that is, have more than one entry)
    // That is, all directories are the contents of at most one directory entry
    // Invalid: an error in the spec.
    all o: Dir | sole o.~contents
}

check NoDirAliases for 5



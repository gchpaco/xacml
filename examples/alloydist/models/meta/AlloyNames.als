/**
   model of Alloy's module system
   and name system
*/

module meta/AlloyNames

open std/seq

// an identifier in Alloy.  identifiers
// are associated with variables, and
// can also be used to refer to paragraphs
// in certain cases
sig Id {}

// a name in Alloy.  names are associated
// with modules and paragraphs.
sig Name {
  // every name in Alloy has at least one
  // identifier associated with it
  id : Id,
  // names have a "path,"
  // a sequence of identifiers that
  // correspond to the enclosing module
  // name for a paragraph, and literally
  // to the path to the file for a module 
  // (possibly empty)
  path : Seq[Id]
} {
  // names are unique, ie. no
  // two different names have
  // the same path and id
  no other : Name - this |
    path..SeqEquals(other::path) && other::id = id
}

// converts a name to a sequence
// of Ids
fun Name::toIdSeq () : Seq[Id] {
    // initial sequence of result is indentical
    // to path of name
    (all i : this.path..SeqInds() |
      this.path..SeqAt(i) = result..SeqAt(i))
    // result has one more element than path of name
    # result..SeqInds() = # this.path..SeqInds() + 1
    // last element of result is id of name
    result..SeqLast() = this.id
}


// a module in Alloy
sig Module {
  // every module has a name
  name : Name,
  // a set of paragraphs can be defined in a module
  paras : set Paragraph,
  // modules can "use" other modules, meaning
  // that paragraphs of that module can refer to 
  // paragraphs of the other modules using
  // names
  usedModules : set Module,
  // modules can "open" other modules, meaning
  // they can "use" the other modules and refer to
  // their paragraphs using just the id of their names
  openedModules : set Module
} {
  no other: Module - this |
    // modules have unique names
    other::name = name 
  // no other module has a name which starts
  // with the name of this module (since you
  // can't have a file and a directory with the
  // same name contained in the same directory)
  // NOTE: weirdness in semantics of invocation inlining,
  // we need to work on this
  some foo : name..toIdSeq() | no other: Module - this | 
    (other::name.path)..SeqStartsWith(name..toIdSeq())
  // modules cannot open or use themselves
  this !in (usedModules + openedModules)
  // if a module opens another module,
  // it also uses it
  openedModules in usedModules
}

// a paragraph (signature, function, fact, assertion)
// in Alloy
sig Paragraph {
  // every paragraph is declared in one module  
  enclosingModule: Module,
  // name of paragraph
  name : Name
} {
  // path of name is same as module's name
  name.path = (enclosingModule::name)..toIdSeq()
  // no two paragraphs have the same name
  no other: Paragraph - this | other::name = name 
}

fact ModulePara {
  // paragraphs contained by module match
  // enclosing module pointers of paragraphs
  Module$paras = ~Paragraph$enclosingModule
}

// makes nicer solutions
fact NiceOutput {
  // get rid of sequences that are not
  // associated with names
  Seq[Id] = Name.path
  // get rid of unused Ids
  Id = Name.id + { id : Id | some name : Name | 
                     id in name.path..SeqElems() }
  // get rid of unused names
  Name = Paragraph.name + Module.name
  // get rid of modules with no paragraphs
  Module = Paragraph.enclosingModule
  // create some paragraph to make things
  // interesting
  # Module > 1
}

assert A1 { all p1, p2 : Paragraph | (p1 != p2 && p1.enclosingModule = p2.enclosingModule) => 
                                     p1.name.id != p2.name.id }
fun SomeState () { }
 
run SomeState for 3

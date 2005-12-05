module meta/SwitchBooleanDag

open std/bool
open std/util
open std/seq
open meta/BasicBooleanDag
open meta/CommonBooleanDefs

sig CacheSlot { }

disj sig CacheNode extends BoolNode {
   slot: CacheSlot,
   args: set BoolNode,
   nextArg: args ?->? args,
   firstArg, lastArg: args
}{
  one children
  // nextArg is a sequence of args
  args in firstArg.*nextArg
  no firstArg.~nextArg
  no lastArg.nextArg
  all a: args - firstArg - lastArg { one a.nextArg && one a.~nextArg }
  // args are subtrees
  args in children.^BoolNode$children
  // args are constant-valued
  no LitNode & args.*BoolNode$children
}

fact ValidCacheInfo {
   all v1,v2: Visit | let n1 = v1.node, n2 = v2.node {
      (n1 + n2 in CacheNode && n1.slot = n2.slot &&
       ) => {
         
      }
   }
}



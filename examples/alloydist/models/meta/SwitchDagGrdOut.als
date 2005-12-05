module models/SwitchDagGrdOut

open std/bool
open std/util
open std/seq
open meta/CommonBooleanDefs
open meta/BasicBooleanDag
open meta/SwitchBooleanDag

fun GroundingOut(grdMap: Visit ->! BoolNode) {
   all v: Visit | let orig = v.node, grd = v.grdMap | {
       (orig in SwitchableConstNode => 
         no grd.children &&
         (IsTrueSwitchableConst(v) => (grd in AndNode) else (grd in OrNode))
      )
      orig in SwitchSetterNode => grd = v.children.grdMap
      orig in LitNode => grd = orig
      orig in AndNode => grd in AndNode
      orig in OrNode => grd in OrNode
      orig in NotNode => grd in NotNode
      orig in AndNode + OrNode + NotNode => {
        # orig.children = # grd.children
        all i: SeqIdx | {
           let visitToThisChild = v.children & orig..BoolChildAt(i).~Visit$node {
              visitToThisChild -> grd..BoolChildAt(i) in grdMap
           }
        }
      }
  }
}

static sig Witness {
  grdMap : Visit -> ! BoolNode,
  origRoot, grdRoot: BoolNode
}{
   no (origRoot + grdRoot).~BoolNode$children
   Visit = origRoot.*children.~Visit$node
   some origRoot.~Visit$node
   all n: BoolNode - origRoot - grdRoot | some n.~BoolNode$children
   grdRoot = origRoot.~Visit$node.grdMap
}

fun SomeGrdOut ( ) {
   GroundingOut(Witness.grdMap)
   some SwitchableConstNode
   SwitchAndStandardOnly()
}


run SomeGrdOut for 1 but 2 Bool, 2 Seq[BoolNode], 3 BoolNode, 1 Var, 2 Lit, 2 Visit

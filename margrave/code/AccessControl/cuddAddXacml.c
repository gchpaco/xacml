#include    "util.h"
#include    "cuddInt.h"

/***** Kathi TO-DO ***************

- handle derefs through GC

*********************************/

/******************** XACML Constants **********************/
 
/* Believe CUDD has special uses for 0 and 1, hence number choices */
#define DENY_VAL 2
#define PERMIT_VAL 3
#define NA_VAL 4
#define EC_VAL 55

#define PP_VAL 5
#define PD_VAL 6
#define PN_VAL 7
#define DP_VAL 8
#define DD_VAL 9
#define DN_VAL 20
#define NP_VAL 21
#define ND_VAL 22
#define NN_VAL 23
#define EP_VAL 30
#define EN_VAL 31
#define ED_VAL 32
#define PE_VAL 33
#define NE_VAL 34
#define DE_VAL 40
#define EE_VAL 41

DdNode *
XACML_ADD_DENY_CONST(DdManager * dd)
{   DdNode *res;
    res = Cudd_addConst (dd, DENY_VAL);
    Cudd_Ref(res);
    return(res);
}

DdNode *
XACML_ADD_PERMIT_CONST(DdManager * dd)
{   DdNode *res;
    res = Cudd_addConst (dd, PERMIT_VAL);
    Cudd_Ref(res);
    return(res);
}

DdNode *
XACML_ADD_NA_CONST(DdManager * dd)
{   DdNode *res;
    res = Cudd_addConst (dd, NA_VAL);
    Cudd_Ref(res);
    return(res);
}

DdNode *
XACML_ADD_EC_CONST(DdManager * dd)
{   DdNode *res;
    res = Cudd_addConst (dd, EC_VAL);
    Cudd_Ref(res);
    return(res);
}

DdNode* XACML_ADD_PP_CONST(DdManager *dd) 
{ return (Cudd_addConst (dd, PP_VAL)); }

DdNode* XACML_ADD_PD_CONST(DdManager *dd) 
{ return (Cudd_addConst (dd, PD_VAL)); }

DdNode* XACML_ADD_PN_CONST(DdManager *dd) 
{ return (Cudd_addConst (dd, PN_VAL)); }

DdNode* XACML_ADD_DP_CONST(DdManager *dd) 
{ return (Cudd_addConst (dd, DP_VAL)); }

DdNode* XACML_ADD_DD_CONST(DdManager *dd) 
{ return (Cudd_addConst (dd, DD_VAL)); }

DdNode* XACML_ADD_DN_CONST(DdManager *dd) 
{ return (Cudd_addConst (dd, DN_VAL)); }

DdNode* XACML_ADD_NP_CONST(DdManager *dd) 
{ return (Cudd_addConst (dd, NP_VAL)); }

DdNode* XACML_ADD_ND_CONST(DdManager *dd) 
{ return (Cudd_addConst (dd, ND_VAL)); }

DdNode* XACML_ADD_NN_CONST(DdManager *dd) 
{ return (Cudd_addConst (dd, NN_VAL)); }

DdNode* XACML_ADD_EP_CONST(DdManager *dd) 
{ return (Cudd_addConst (dd, EP_VAL)); }

DdNode* XACML_ADD_ED_CONST(DdManager *dd) 
{ return (Cudd_addConst (dd, ED_VAL)); }

DdNode* XACML_ADD_EN_CONST(DdManager *dd) 
{ return (Cudd_addConst (dd, EN_VAL)); }

DdNode* XACML_ADD_PE_CONST(DdManager *dd) 
{ return (Cudd_addConst (dd, PE_VAL)); }

DdNode* XACML_ADD_DE_CONST(DdManager *dd) 
{ return (Cudd_addConst (dd, DE_VAL)); }

DdNode* XACML_ADD_NE_CONST(DdManager *dd) 
{ return (Cudd_addConst (dd, NE_VAL)); }

DdNode* XACML_ADD_EE_CONST(DdManager *dd) 
{ return (Cudd_addConst (dd, EE_VAL)); }

/******************** Rule Creation **********************/

/* use add-apply -when reach ONE/ZERO constants, insert appropriate 
   permit deny from existing rule */
DdNode *
Xacml_ADD_Augment_Rule_Op(
  DdManager * dd,
  DdNode ** conditions,
  DdNode ** rule)
{
    DdNode *F, *G;

    F = *conditions;
    G = *rule;
    if (F == DD_ZERO(dd))
      return (XACML_ADD_NA_CONST(dd));
    if (F == DD_ONE(dd))
      return (G);
    return (NULL);  
}

DdNode *
Xacml_ADD_Augment_Rule(DdManager *dd,
		       DdNode * conditions,
		       DdNode * rule)		       
{
  DdNode * res ;
  res = Cudd_addApply(dd, Xacml_ADD_Augment_Rule_Op, conditions, rule);
  Cudd_Ref(res);  /* necessary?? */
  return(res);
}

/******************** Rule Combining **********************/

DdNode *
Xacml_ADD_PermitOverride_Op(
  DdManager * dd,
  DdNode ** f,
  DdNode ** g)
{
    DdNode *F, *G;

    F = *f; G = *g;
    if ((F == XACML_ADD_PERMIT_CONST(dd)) || (G == XACML_ADD_PERMIT_CONST(dd)))
      return(XACML_ADD_PERMIT_CONST(dd));
    if (cuddIsConstant(F) && cuddIsConstant(G)) {
      if ((F == XACML_ADD_DENY_CONST(dd)) || (G == XACML_ADD_DENY_CONST(dd)))
	return(XACML_ADD_DENY_CONST(dd));
      else return(XACML_ADD_NA_CONST(dd)) ;
      /* return (F); */
    }
    return (NULL) ; /* not a terminal case */
}

DdNode *
Xacml_ADD_PermitOverride(DdManager *dd,
			 DdNode * policy1,
			 DdNode * policy2)
{
  DdNode * res ;
  res = Cudd_addApply(dd, Xacml_ADD_PermitOverride_Op, policy1, policy2);
  Cudd_Ref(res);  /* necessary?? */
  return(res);
}

DdNode *
Xacml_ADD_DenyOverride_Op(
  DdManager * dd,
  DdNode ** f,
  DdNode ** g)
{
    DdNode *F, *G;

    F = *f; G = *g;
    if ((F == XACML_ADD_DENY_CONST(dd)) || (G == XACML_ADD_DENY_CONST(dd)))
      return(XACML_ADD_DENY_CONST(dd));
    if (cuddIsConstant(F) && cuddIsConstant(G)) {
      if ((F == XACML_ADD_PERMIT_CONST(dd)) || (G == XACML_ADD_PERMIT_CONST(dd)))
	return(XACML_ADD_PERMIT_CONST(dd));
      else return(XACML_ADD_NA_CONST(dd)) ;
      /* return (F); */
    }
    return (NULL) ; /* not a terminal case */
}

DdNode *
Xacml_ADD_DenyOverride(DdManager * dd,
		       DdNode * policy1,
		       DdNode * policy2)
{
  DdNode * res ;
  res = Cudd_addApply(dd, Xacml_ADD_DenyOverride_Op, policy1, policy2);
  Cudd_Ref(res);  /* necessary?? */
  return(res);
}

/* Want to apply f before g */
/* Algorithm: when first hits permit or deny, use.  If second hits
   decision, continue until reach terminal on first.  Use decision from
   first if permit/deny, else use decision from second. */
DdNode *
Xacml_ADD_FirstApplicable_Op(
  DdManager * dd,
  DdNode ** f,
  DdNode ** g)
{
    DdNode *F, *G;

    F = *f; G = *g;
    if (F == XACML_ADD_DENY_CONST(dd))
      return(XACML_ADD_DENY_CONST(dd));
    if (F == XACML_ADD_PERMIT_CONST(dd))
      return(XACML_ADD_PERMIT_CONST(dd));
    if (cuddIsConstant(F) && cuddIsConstant(G))  /* F must be NA */
      return(G);
    return (NULL); /* not a terminal case */
}

DdNode *
Xacml_ADD_FirstApplicable(DdManager *dd,
			  DdNode * policy1,
			  DdNode * policy2)
{
  DdNode * res ;
  res = Cudd_addApply(dd, Xacml_ADD_FirstApplicable_Op, policy1, policy2);
  Cudd_Ref(res);  /* necessary?? */
  return(res);
}

/******************** Terminal Remapping **********************/

DdNode *
Xacml_NAtoDeny_Op(
  DdManager * dd,
  DdNode * F)
{
    if (F == XACML_ADD_NA_CONST(dd))
      return (XACML_ADD_DENY_CONST(dd));
    if (cuddIsConstant(F))
      return (F);
    return (NULL);  
}

DdNode *
Xacml_NAtoDeny(DdManager *dd,
	       DdNode * f)		       
{
  DdNode * res ;
  res = Cudd_addMonadicApply(dd, Xacml_NAtoDeny_Op, f);
  Cudd_Ref(res);  /* necessary?? */
  return(res);
}

/******************** Change ADDs **********************/

DdNode *
Xacml_ADD_ChangeMerge_Op(
  DdManager * dd,
  DdNode ** f,
  DdNode ** g)
{
    DdNode *F, *G;

    F = *f; G = *g;
    if ((F == XACML_ADD_PERMIT_CONST(dd)) && (G == XACML_ADD_PERMIT_CONST(dd)))
      return(XACML_ADD_PP_CONST(dd)) ;
    if ((F == XACML_ADD_PERMIT_CONST(dd)) && (G == XACML_ADD_DENY_CONST(dd)))
      return(XACML_ADD_PD_CONST(dd)) ;
    if ((F == XACML_ADD_PERMIT_CONST(dd)) && (G == XACML_ADD_NA_CONST(dd)))
      return(XACML_ADD_PN_CONST(dd)) ;
    if ((F == XACML_ADD_PERMIT_CONST(dd)) && (G == XACML_ADD_EC_CONST(dd)))
      return(XACML_ADD_PE_CONST(dd)) ;

    if ((F == XACML_ADD_DENY_CONST(dd)) && (G == XACML_ADD_PERMIT_CONST(dd)))
      return(XACML_ADD_DP_CONST(dd)) ;
    if ((F == XACML_ADD_DENY_CONST(dd)) && (G == XACML_ADD_DENY_CONST(dd)))
      return(XACML_ADD_DD_CONST(dd)) ;
    if ((F == XACML_ADD_DENY_CONST(dd)) && (G == XACML_ADD_NA_CONST(dd)))
      return(XACML_ADD_DN_CONST(dd)) ;
    if ((F == XACML_ADD_DENY_CONST(dd)) && (G == XACML_ADD_EC_CONST(dd)))
      return(XACML_ADD_DE_CONST(dd)) ;

    if ((F == XACML_ADD_NA_CONST(dd)) && (G == XACML_ADD_PERMIT_CONST(dd)))
      return(XACML_ADD_NP_CONST(dd)) ;
    if ((F == XACML_ADD_NA_CONST(dd)) && (G == XACML_ADD_DENY_CONST(dd)))
      return(XACML_ADD_ND_CONST(dd)) ;
    if ((F == XACML_ADD_NA_CONST(dd)) && (G == XACML_ADD_NA_CONST(dd)))
      return(XACML_ADD_NN_CONST(dd)) ;
    if ((F == XACML_ADD_NA_CONST(dd)) && (G == XACML_ADD_EC_CONST(dd)))
      return(XACML_ADD_NE_CONST(dd)) ;

    if ((F == XACML_ADD_EC_CONST(dd)) && (G == XACML_ADD_PERMIT_CONST(dd)))
      return(XACML_ADD_EP_CONST(dd)) ;
    if ((F == XACML_ADD_EC_CONST(dd)) && (G == XACML_ADD_DENY_CONST(dd)))
      return(XACML_ADD_ED_CONST(dd)) ;
    if ((F == XACML_ADD_EC_CONST(dd)) && (G == XACML_ADD_NA_CONST(dd)))
      return(XACML_ADD_EN_CONST(dd)) ;
    if ((F == XACML_ADD_EC_CONST(dd)) && (G == XACML_ADD_EC_CONST(dd)))
      return(XACML_ADD_EE_CONST(dd)) ;

    return (NULL); /* not a terminal case */
}

DdNode *
Xacml_ADD_ChangeMerge(DdManager *dd,
		      DdNode * policy1,
		      DdNode * policy2)
{
  DdNode * res ;
  res = Cudd_addApply(dd, Xacml_ADD_ChangeMerge_Op, policy1, policy2);
  Cudd_Ref(res);  /* necessary?? */
  return(res);
}

/******************** Applying Assumptions **********************/

DdNode *
 Xacml_XADD_Assume_Op(
  DdManager * dd,
  DdNode ** f,
  DdNode ** constraint)
{
    DdNode *F, *C;

    F = *f; C = *constraint;
    if (C == DD_ONE(dd)) return(F) ;
    if (C == DD_ZERO(dd)) return (XACML_ADD_EC_CONST(dd)) ;
    return (NULL); /* not a terminal case */
}

DdNode *
Xacml_XADD_Assume(DdManager * dd,
		  DdNode * f,
		  DdNode * g)
{
  DdNode * res ;
  res = Cudd_addApply(dd, Xacml_XADD_Assume_Op, f, g);
  Cudd_Ref(res);  /* necessary?? */
  return(res);
}

/******************** Misc Logical Functions **********************/

DdNode *
Xacml_ADD_And_Op(
  DdManager * dd,
  DdNode ** f,
  DdNode ** g)
{
    DdNode *F, *G;

    F = *f; G = *g;
    if ((F == DD_ZERO(dd)) || (G == DD_ZERO(dd))) return (DD_ZERO(dd)) ;
    if (cuddIsConstant(F)) return(G);
    if (cuddIsConstant(G)) return(F);
    if (F == G) return(F);
    if (F > G) { /* swap f and g */
	*f = G;
	*g = F;
    }
    return (NULL); /* not a terminal case */
}

DdNode *
Xacml_ADD_LogicalAnd(DdManager * dd,
		     DdNode * f,
		     DdNode * g)
{
  DdNode * res ;
  res = Cudd_addApply(dd, Xacml_ADD_And_Op, f, g);
  Cudd_Ref(res);  /* necessary?? */
  return(res);
}

DdNode *
Xacml_ADD_LogicalOr(DdManager *dd,
		    DdNode * f,
		    DdNode * g)
{
  DdNode * res ;
  res = Cudd_addApply(dd, Cudd_addOr, f, g);
  Cudd_Ref(res);  /* necessary?? */
  return(res);
}

DdNode *
Xacml_ADD_LogicalNot (DdManager *dd,
		      DdNode * f)
{
  DdNode *fbdd, *res ;

  fbdd = Cudd_addBddPattern(dd, f) ;
  Cudd_Ref(fbdd);
  res = Cudd_BddToAdd(dd, Cudd_Not(fbdd)) ; 
  Cudd_RecursiveDeref(dd,fbdd);
  return (res) ;
}

/******************** Misc Performance Functions **********************/
 
void
Cudd_Print_Stats (DdManager *dd,
	          DdNode * f)
{
  printf ("Decision diagram has %d nodes \n",
	  Cudd_DagSize(f) ) ;
  
  printf ("Manager using %d bytes of memory\n\n", Cudd_ReadMemoryInUse(dd));
}

/************************************************************************/

main () {
  DdManager * dd ;
  DdNode * var1, * var2 ;
  DdNode * rule1 , * rule2 , * cond1, *policy1;
  DdNode *tmp1, *tmp2 ;
  int print_res ;

  printf ("XACML initialized\n");

  dd = Cudd_Init (2, 0, CUDD_UNIQUE_SLOTS,CUDD_CACHE_SLOTS,0);
  var1 = Cudd_addNewVar (dd) ;
  Cudd_Ref(var1) ;
  var2 = Cudd_addNewVar (dd) ;
  Cudd_Ref(var2) ;
  cond1 = Xacml_ADD_LogicalAnd (dd, var1, var2);
  Cudd_Ref(cond1) ;

  rule1 = Xacml_ADD_Augment_Rule(dd, cond1, XACML_ADD_PERMIT_CONST(dd)); 
  rule2 = Xacml_ADD_Augment_Rule(dd, cond1, XACML_ADD_DENY_CONST(dd)); 
  printf("Rule 1\n") ;
  print_res = Cudd_PrintMinterm(dd, rule1) ;
  printf("\nRule 2\n");
  print_res = Cudd_PrintMinterm(dd, rule2) ;
  policy1 = Xacml_ADD_PermitOverride (dd, rule1, rule2) ;
  printf("\npolicy\n") ;
  print_res = Cudd_PrintMinterm(dd, policy1) ;
  printf("\nRestrict Permits\n") ;
  tmp1 = Cudd_addBddInterval(dd, policy1, PERMIT_VAL, PERMIT_VAL) ;
  print_res = Cudd_PrintMinterm(dd, tmp1) ;
  printf("\nAs an ADD\n") ;
  tmp2 = Cudd_BddToAdd (dd, tmp1) ;
  print_res = Cudd_PrintMinterm(dd, tmp2) ;
  

  /*
  printf("\nRestrict Denies\n") ;
  tmp2 = Cudd_addBddInterval(dd, policy1, DENY_VAL, DENY_VAL) ;
  print_res = Cudd_PrintMinterm(dd, tmp2 ) ;
  */

  /*
  print_res = Cudd_PrintMinterm(dd, var1) ;
  print_res = Cudd_PrintMinterm(dd, XACML_ADD_DENY_CONST(dd)) ;
  print_res = Cudd_PrintMinterm(dd, XACML_ADD_PERMIT_CONST(dd)) ;
  print_res = Cudd_PrintMinterm(dd, XACML_ADD_NA_CONST(dd)) ;
  */
  
  printf ("XACML finished\n");
}

#include    "util.h"
#include    "cuddInt.h"

/***** Kathi TO-DO ***************

- handle derefs through GC

*********************************/

#define BOOL int
#define CUDD_MAX_CACHE_SIZE 0


/******************** XACML Constants **********************/
 
/* Believe CUDD has special uses for 0 and 1, hence number choices */
/* these must be in sync with the values found in the .scm files */
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
XACML_ADD_DENY_CONST(DdManager * manager)
{   DdNode *res;
  res = Cudd_addConst (manager, DENY_VAL);
  Cudd_Ref(res);
  return(res);
}

DdNode *
XACML_ADD_PERMIT_CONST(DdManager * manager)
{   DdNode *res;
  res = Cudd_addConst (manager, PERMIT_VAL);
  Cudd_Ref(res);
  return(res);
}

DdNode *
XACML_ADD_NA_CONST(DdManager * manager)
{   DdNode *res;
  res = Cudd_addConst (manager, NA_VAL);
  Cudd_Ref(res);
  return(res);
}

DdNode *
XACML_ADD_EC_CONST(DdManager * manager)
{   DdNode *res;
  res = Cudd_addConst (manager, EC_VAL);
  Cudd_Ref(res);
  return(res);
}

DdNode* XACML_ADD_PP_CONST(DdManager *manager) 
{ return (Cudd_addConst (manager, PP_VAL)); }

DdNode* XACML_ADD_PD_CONST(DdManager *manager) 
{ return (Cudd_addConst (manager, PD_VAL)); }

DdNode* XACML_ADD_PN_CONST(DdManager *manager) 
{ return (Cudd_addConst (manager, PN_VAL)); }

DdNode* XACML_ADD_DP_CONST(DdManager *manager) 
{ return (Cudd_addConst (manager, DP_VAL)); }

DdNode* XACML_ADD_DD_CONST(DdManager *manager) 
{ return (Cudd_addConst (manager, DD_VAL)); }

DdNode* XACML_ADD_DN_CONST(DdManager *manager) 
{ return (Cudd_addConst (manager, DN_VAL)); }

DdNode* XACML_ADD_NP_CONST(DdManager *manager) 
{ return (Cudd_addConst (manager, NP_VAL)); }

DdNode* XACML_ADD_ND_CONST(DdManager *manager) 
{ return (Cudd_addConst (manager, ND_VAL)); }

DdNode* XACML_ADD_NN_CONST(DdManager *manager) 
{ return (Cudd_addConst (manager, NN_VAL)); }

DdNode* XACML_ADD_EP_CONST(DdManager *manager) 
{ return (Cudd_addConst (manager, EP_VAL)); }

DdNode* XACML_ADD_ED_CONST(DdManager *manager) 
{ return (Cudd_addConst (manager, ED_VAL)); }

DdNode* XACML_ADD_EN_CONST(DdManager *manager) 
{ return (Cudd_addConst (manager, EN_VAL)); }

DdNode* XACML_ADD_PE_CONST(DdManager *manager) 
{ return (Cudd_addConst (manager, PE_VAL)); }

DdNode* XACML_ADD_DE_CONST(DdManager *manager) 
{ return (Cudd_addConst (manager, DE_VAL)); }

DdNode* XACML_ADD_NE_CONST(DdManager *manager) 
{ return (Cudd_addConst (manager, NE_VAL)); }

DdNode* XACML_ADD_EE_CONST(DdManager *manager) 
{ return (Cudd_addConst (manager, EE_VAL)); }


/******************** Set Up *****************************/

DdManager* 
Xacml_make_dd_manager()
{
  DdManager*  new_C_manager = Cudd_Init(0, 
					0, 
					CUDD_UNIQUE_SLOTS,
					CUDD_CACHE_SLOTS, 
					CUDD_MAX_CACHE_SIZE);
  return ( new_C_manager ) ;
}


/******************** Rule Creation **********************/

/* use add-apply -when reach ONE/ZERO constants, insert appropriate 
   permit deny from existing rule */
DdNode *
Xacml_ADD_Augment_Rule_Op(DdManager * manager,
			  DdNode ** conditions,
			  DdNode ** rule)
{
  DdNode *F, *G;

  F = *conditions;
  G = *rule;
  if (F == DD_ZERO(manager))
    return (XACML_ADD_NA_CONST(manager));
  if (F == DD_ONE(manager))
    return (G);
  return (NULL);  
}

DdNode *
Xacml_ADD_Augment_Rule(DdManager *manager,
		       DdNode * conditions,
		       DdNode * rule)		       
{
  DdNode * res ;
  res = Cudd_addApply(manager, Xacml_ADD_Augment_Rule_Op, conditions, rule);
  Cudd_Ref(res);  /* necessary?? */
  return(res);
}

/******************** Rule Combining **********************/

DdNode *
Xacml_ADD_PermitOverride_Op(DdManager * manager,
			    DdNode ** f,
			    DdNode ** g)
{
  DdNode *F, *G;

  F = *f; G = *g;
  if ((F == XACML_ADD_PERMIT_CONST(manager)) || (G == XACML_ADD_PERMIT_CONST(manager)))
    return(XACML_ADD_PERMIT_CONST(manager));
  if (cuddIsConstant(F) && cuddIsConstant(G)) {
    if ((F == XACML_ADD_DENY_CONST(manager)) || (G == XACML_ADD_DENY_CONST(manager)))
      return(XACML_ADD_DENY_CONST(manager));
    else return(XACML_ADD_NA_CONST(manager)) ;
    /* return (F); */
  }
  return (NULL) ; /* not a terminal case */
}

DdNode *
Xacml_ADD_PermitOverride(DdManager *manager,
			 DdNode * policy1,
			 DdNode * policy2)
{
  DdNode * res ;
  res = Cudd_addApply(manager, Xacml_ADD_PermitOverride_Op, policy1, policy2);
  Cudd_Ref(res);  /* necessary?? */
  return(res);
}

DdNode *
Xacml_ADD_DenyOverride_Op(DdManager * manager,
			  DdNode ** f,
			  DdNode ** g)
{
  DdNode *F, *G;

  F = *f; G = *g;
  if ((F == XACML_ADD_DENY_CONST(manager)) || (G == XACML_ADD_DENY_CONST(manager)))
    return(XACML_ADD_DENY_CONST(manager));
  if (cuddIsConstant(F) && cuddIsConstant(G)) {
    if ((F == XACML_ADD_PERMIT_CONST(manager)) || (G == XACML_ADD_PERMIT_CONST(manager)))
      return(XACML_ADD_PERMIT_CONST(manager));
    else return(XACML_ADD_NA_CONST(manager)) ;
    /* return (F); */
  }
  return (NULL) ; /* not a terminal case */
}

DdNode *
Xacml_ADD_DenyOverride(DdManager * manager,
		       DdNode * policy1,
		       DdNode * policy2)
{
  DdNode * res ;
  res = Cudd_addApply(manager, Xacml_ADD_DenyOverride_Op, policy1, policy2);
  Cudd_Ref(res);  /* necessary?? */
  return(res);
}

/* Want to apply f before g */
/* Algorithm: when first hits permit or deny, use.  If second hits
   decision, continue until reach terminal on first.  Use decision from
   first if permit/deny, else use decision from second. */
DdNode *
Xacml_ADD_FirstApplicable_Op(DdManager * manager,
			     DdNode ** f,
			     DdNode ** g)
{
  DdNode *F, *G;

  F = *f; G = *g;
  if (F == XACML_ADD_DENY_CONST(manager))
    return(XACML_ADD_DENY_CONST(manager));
  if (F == XACML_ADD_PERMIT_CONST(manager))
    return(XACML_ADD_PERMIT_CONST(manager));
  if (cuddIsConstant(F) && cuddIsConstant(G))  /* F must be NA */
    return(G);
  return (NULL); /* not a terminal case */
}

DdNode *
Xacml_ADD_FirstApplicable(DdManager *manager,
			  DdNode * policy1,
			  DdNode * policy2)
{
  DdNode * res ;
  res = Cudd_addApply(manager, Xacml_ADD_FirstApplicable_Op, policy1, policy2);
  Cudd_Ref(res);  /* necessary?? */
  return(res);
}

/******************** Terminal Remapping **********************/

DdNode *
Xacml_NAtoDeny_Op(DdManager * manager,
		  DdNode * F)
{
  if (F == XACML_ADD_NA_CONST(manager))
    return (XACML_ADD_DENY_CONST(manager));
  if (cuddIsConstant(F))
    return (F);
  return (NULL);  
}

DdNode *
Xacml_NAtoDeny(DdManager *manager,
	       DdNode * f)		       
{
  DdNode * res ;
  res = Cudd_addMonadicApply(manager, Xacml_NAtoDeny_Op, f);
  Cudd_Ref(res);  /* necessary?? */
  return(res);
}

/******************** Change ADDs **********************/

DdNode *
Xacml_ADD_ChangeMerge_Op(DdManager * manager,
			 DdNode ** f,
			 DdNode ** g)
{
  DdNode *F, *G;

  F = *f; G = *g;
  if ((F == XACML_ADD_PERMIT_CONST(manager)) && (G == XACML_ADD_PERMIT_CONST(manager)))
    return(XACML_ADD_PP_CONST(manager)) ;
  if ((F == XACML_ADD_PERMIT_CONST(manager)) && (G == XACML_ADD_DENY_CONST(manager)))
    return(XACML_ADD_PD_CONST(manager)) ;
  if ((F == XACML_ADD_PERMIT_CONST(manager)) && (G == XACML_ADD_NA_CONST(manager)))
    return(XACML_ADD_PN_CONST(manager)) ;
  if ((F == XACML_ADD_PERMIT_CONST(manager)) && (G == XACML_ADD_EC_CONST(manager)))
    return(XACML_ADD_PE_CONST(manager)) ;

  if ((F == XACML_ADD_DENY_CONST(manager)) && (G == XACML_ADD_PERMIT_CONST(manager)))
    return(XACML_ADD_DP_CONST(manager)) ;
  if ((F == XACML_ADD_DENY_CONST(manager)) && (G == XACML_ADD_DENY_CONST(manager)))
    return(XACML_ADD_DD_CONST(manager)) ;
  if ((F == XACML_ADD_DENY_CONST(manager)) && (G == XACML_ADD_NA_CONST(manager)))
    return(XACML_ADD_DN_CONST(manager)) ;
  if ((F == XACML_ADD_DENY_CONST(manager)) && (G == XACML_ADD_EC_CONST(manager)))
    return(XACML_ADD_DE_CONST(manager)) ;

  if ((F == XACML_ADD_NA_CONST(manager)) && (G == XACML_ADD_PERMIT_CONST(manager)))
    return(XACML_ADD_NP_CONST(manager)) ;
  if ((F == XACML_ADD_NA_CONST(manager)) && (G == XACML_ADD_DENY_CONST(manager)))
    return(XACML_ADD_ND_CONST(manager)) ;
  if ((F == XACML_ADD_NA_CONST(manager)) && (G == XACML_ADD_NA_CONST(manager)))
    return(XACML_ADD_NN_CONST(manager)) ;
  if ((F == XACML_ADD_NA_CONST(manager)) && (G == XACML_ADD_EC_CONST(manager)))
    return(XACML_ADD_NE_CONST(manager)) ;

  if ((F == XACML_ADD_EC_CONST(manager)) && (G == XACML_ADD_PERMIT_CONST(manager)))
    return(XACML_ADD_EP_CONST(manager)) ;
  if ((F == XACML_ADD_EC_CONST(manager)) && (G == XACML_ADD_DENY_CONST(manager)))
    return(XACML_ADD_ED_CONST(manager)) ;
  if ((F == XACML_ADD_EC_CONST(manager)) && (G == XACML_ADD_NA_CONST(manager)))
    return(XACML_ADD_EN_CONST(manager)) ;
  if ((F == XACML_ADD_EC_CONST(manager)) && (G == XACML_ADD_EC_CONST(manager)))
    return(XACML_ADD_EE_CONST(manager)) ;

  return (NULL); /* not a terminal case */
}

DdNode *
Xacml_ADD_ChangeMerge(DdManager *manager,
		      DdNode * policy1,
		      DdNode * policy2)
{
  DdNode * res ;
  res = Cudd_addApply(manager, Xacml_ADD_ChangeMerge_Op, policy1, policy2);
  Cudd_Ref(res);  /* necessary?? */
  return(res);
}

/******************** Equality ************************************/

BOOL Xacml_bdd_equal (DdNode * f,
		      DdNode * g)
  
{
  return (f == g);
}
 

/******************** Misc Logical Functions **********************/

DdNode *
Xacml_ADD_And_Op(DdManager * manager,
		 DdNode ** f,
		 DdNode ** g)
{
  DdNode *F, *G;

  F = *f; G = *g;
  if ((F == DD_ZERO(manager)) || (G == DD_ZERO(manager))) return (DD_ZERO(manager)) ;
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
Xacml_ADD_LogicalAnd(DdManager * manager,
		     DdNode * f,
		     DdNode * g)
{
  DdNode * res ;
  res = Cudd_addApply(manager, Xacml_ADD_And_Op, f, g);
  Cudd_Ref(res);  /* necessary?? */
  return(res);
}

DdNode *
Xacml_ADD_LogicalOr(DdManager *manager,
		    DdNode * f,
		    DdNode * g)
{
  DdNode * res ;
  res = Cudd_addApply(manager, Cudd_addOr, f, g);
  Cudd_Ref(res);  /* necessary?? */
  return(res);
}

DdNode *
Xacml_ADD_LogicalNot (DdManager *manager,
		      DdNode * f)
{
  DdNode *fbdd, *res ;

  fbdd = Cudd_addBddPattern(manager, f) ;
  Cudd_Ref(fbdd);
  res = Cudd_BddToAdd(manager, Cudd_Not(fbdd)) ; 
  Cudd_RecursiveDeref(manager,fbdd);
  return (res) ;
}



/******************** Applying Assumptions **********************/

DdNode *
Xacml_XADD_Assume_Op(DdManager * manager,
		     DdNode ** f,
		     DdNode ** constraint)
{
  DdNode *F, *C;

  F = *f; C = *constraint;
  if (C == DD_ONE(manager)) return(F) ;
  if (C == DD_ZERO(manager)) return (XACML_ADD_EC_CONST(manager)) ;
  return (NULL); /* not a terminal case */
}

DdNode *
Xacml_XADD_Assume(DdManager * manager,
		  DdNode * f,
		  DdNode * g)
{
  DdNode * res ;
  res = Cudd_addApply(manager, Xacml_XADD_Assume_Op, f, g);
  Cudd_Ref(res);  /* necessary?? */
  return(res);
}

DdNode *
Xacml_bdd_add_interval (DdManager * manager,
			DdNode * f,
			int lower_term,
			int upper_term)
{
      DdNode *tmp, *res ;

      tmp = Cudd_addBddInterval ( manager, f, lower_term, upper_term);
      Cudd_Ref(tmp) ;
      res = Cudd_BddToAdd ( manager, tmp ) ;
      Cudd_Ref(res) ;
      Cudd_RecursiveDeref( manager, tmp) ;

      return ( res ) ; 
}




/******************** Output ******************************************/
  
void Xacml_print_minterms (DdManager * manager,
			   DdNode * node,
			   char* file_name)
{

  int printres ;                       
  FILE *fp , *oldfp ;
                                
  fp = fopen(file_name, "w") ;
  if(! fp){
    perror("In function scheme_print_minterms, error opening temp file for printing MTBDD");
    exit(1);
  }
  oldfp = Cudd_ReadStdout( manager ) ;
  Cudd_SetStdout ( manager, fp) ;
  printres = Cudd_PrintMinterm ( manager , node ) ;
  Cudd_SetStdout ( manager, oldfp) ;
  fclose(fp) ;
  printf ("\n") ;
  return; 
}


/*
Scheme_Object* vararray_to_scheme_list (int *array , int arraysize , int trueval )
{
  Scheme_Object *IndexList = scheme_null ;
  int i = arraysize - 1 ;
  
  while (i >= 0) {
    if (trueval == array[i]) {
      IndexList = scheme_make_pair ( scheme_true, IndexList ) ;
    }
    else {
      IndexList = scheme_make_pair ( scheme_false, IndexList ) ;
    }
    i = i - 1 ;
  }
  return (IndexList) ;
}

*/

 /* 
    int*  vararray_to_scheme_list (int *array , int arraysize , int trueval )
    {
    //for(int i=0; i < arraysize
    //printf("%d,", array[i]);
    return array;
    }
 */

/* Scheme_Object */
/* returns a int* with a number of entries equal to the number of vars.
   an entry is 1 iff the var corriponding to that position in the array,
   matches the requirement of whichchoicetype in f.  
   These requirements are as follows:
   0 - always false
   1 - always true
   2 - always don't care (never matters) */
int* Xacml_support_indicies (DdManager * manager,
			     DdNode * f,
			     int whichchoicetype)
	  
{  
  int numvars = Cudd_ReadSize ( manager ) ;     
  int *indices[numvars] ; /* will be array of 0s, 1s, and 2s. */
  
  if (2 == whichchoicetype) { // want dont-care vars
  // get an array with one entry for each var.
  //    the entry is 1 iff the f depends on that var.
  //    else it is 0.
    int* indices = Cudd_SupportIndex ( manager , f ) ; 
    int i = 0;
    for(i=0; i< numvars; ++i){
      if(indices[i] == 0){
	indices[i] = 1;
      }else{
	indices[i] = 0;
      }
    }
      
    return(indices);
 
  }else{
 
    DdNode *essential ;
 
    //  char **ret[numvars][
	
    /* returns the cube (product, and) of the vars essential vars */
    essential = Cudd_FindEssential ( manager , f ) ;
  
    if (1 == Cudd_BddToCubeArray ( manager , essential, indices )) {
      /* will return an array by the out argument indices
	 that for the ith position will have 1 iff the ith var 
	 is true in the cude essential, will have 0 iff it is false,
	 and will have a 2 iff it is not in the cude (is don't care). */
      /* convert it a boolean array based on the choicetype */
      int i = 0;
      for(i = 0; i < numvars ; ++i){
	if(indices[i] == whichchoicetype){
	  indices[i] = 1;
	}else{
	  indices[i] = 0;
	}
      }
      return(indices);

      /* if (1 ==  whichchoicetype) // want true vars
	 return ( vararray_to_scheme_list ( indices , numvars, 1 ) );
	 if (0 == whichchoicetype) // want false vars 
	 return ( vararray_to_scheme_list ( indices , numvars, 0 ) );
      */

    }else{
      /* should never happen since essential should always be a cude
	 Cudd_BddToCudeArray will only return non-1 iff given
	 a non-cude */
      printf ("Cudd problem in cube picking\n") ;
      exit ( 1 ) ;
    }
  }
  /* why do I need the special case for the don't cares?
     why can I not use the twos from indicies in the normal case? */

}

/******************** Misc Performance Functions **********************/

/* use the cudd functions instead */

/* 
void
Cudd_Print_Stats (DdManager *manager,
	          DdNode * f)
{
  printf ("Decision diagram has %d nodes \n",
	  Cudd_DagSize(f) ) ;
  
  printf ("Manager using %d bytes of memory\n\n", Cudd_ReadMemoryInUse(manager));
}
*/






/************************************************************************/
/*              for testing                                             */
/************************************************************************/

main () {
  DdManager * manager ;
  DdNode * var1, * var2 ;
  DdNode * rule1 , * rule2 , * cond1, *policy1;
  DdNode *tmp1, *tmp2 ;
  int print_res ;

  printf ("XACML initialized\n");

  manager = Cudd_Init (2, 0, CUDD_UNIQUE_SLOTS,CUDD_CACHE_SLOTS,0);
  var1 = Cudd_addNewVar (manager) ;
  Cudd_Ref(var1) ;
  var2 = Cudd_addNewVar (manager) ;
  Cudd_Ref(var2) ;
  cond1 = Xacml_ADD_LogicalAnd (manager, var1, var2);
  Cudd_Ref(cond1) ;

  rule1 = Xacml_ADD_Augment_Rule(manager, cond1, XACML_ADD_PERMIT_CONST(manager)); 
  rule2 = Xacml_ADD_Augment_Rule(manager, cond1, XACML_ADD_DENY_CONST(manager)); 
  printf("Rule 1\n") ;
  print_res = Cudd_PrintMinterm(manager, rule1) ;
  printf("\nRule 2\n");
  print_res = Cudd_PrintMinterm(manager, rule2) ;
  policy1 = Xacml_ADD_PermitOverride (manager, rule1, rule2) ;
  printf("\npolicy\n") ;
  print_res = Cudd_PrintMinterm(manager, policy1) ;
  printf("\nRestrict Permits\n") ;
  tmp1 = Cudd_addBddInterval(manager, policy1, PERMIT_VAL, PERMIT_VAL) ;
  print_res = Cudd_PrintMinterm(manager, tmp1) ;
  printf("\nAs an ADD\n") ;
  tmp2 = Cudd_BddToAdd (manager, tmp1) ;
  print_res = Cudd_PrintMinterm(manager, tmp2) ;
  

  /*
    printf("\nRestrict Denies\n") ;
    tmp2 = Cudd_addBddInterval(manager, policy1, DENY_VAL, DENY_VAL) ;
    print_res = Cudd_PrintMinterm(manager, tmp2 ) ;
  */

  /*
    print_res = Cudd_PrintMinterm(manager, var1) ;
    print_res = Cudd_PrintMinterm(manager, XACML_ADD_DENY_CONST(manager)) ;
    print_res = Cudd_PrintMinterm(manager, XACML_ADD_PERMIT_CONST(manager)) ;
    print_res = Cudd_PrintMinterm(manager, XACML_ADD_NA_CONST(manager)) ;
  */
  
  printf ("XACML finished\n");
}

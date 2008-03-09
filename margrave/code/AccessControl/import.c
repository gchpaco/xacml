/* will need the ref and deref commands here too */
/* check on static vars and GC comment */

#include <escheme.h>
#include <cudd.h>

#define CUDD_MAX_CACHE_SIZE 0
/* #define PRINT_FNAME "x0print0tmp" */
#define MODULE_NAME "import"

Scheme_Type scheme_bdd_type ;
Scheme_Type scheme_bdd_manager_type ;

struct scheme_bdd_struct 
{
  Scheme_Type   type ;
  DdNode*       data ;
} dummy_scheme_bdd_struct ;

typedef struct scheme_bdd_struct * scheme_bdd ;

struct scheme_bdd_manager_struct
{
  Scheme_Type   type ;
  DdManager*    data ;
} dummy_scheme_bdd_manager_struct ;

typedef struct scheme_bdd_struct * scheme_bdd_manager ;

scheme_bdd construct_scheme_bdd(the_bdd)
{
  scheme_bdd new_Scheme_bdd;
  
  new_Scheme_bdd = (scheme_bdd)                               
    scheme_malloc (sizeof (dummy_scheme_bdd_struct) ) ;              
  new_Scheme_bdd -> type = scheme_bdd_type ;                  
  new_Scheme_bdd -> data = (DdNode*) the_bdd ;

  return (new_Scheme_bdd) ;
}

scheme_bdd_manager construct_scheme_bdd_manager(the_mgr)
{
  scheme_bdd_manager scheme_manager ;

  scheme_manager = (scheme_bdd_manager)
    scheme_malloc (sizeof (dummy_scheme_bdd_manager_struct) ) ;
  scheme_manager -> type = scheme_bdd_manager_type ;
  scheme_manager -> data = (DdManager*) the_mgr ;

  return (scheme_manager) ;
}

#define managerop(f, nm)           \
  scheme_bdd_manager the_manager ; \
                                   \
  the_manager = (scheme_bdd_manager) argList [ 0 ] ; \
  if (scheme_bdd_manager_type == (SCHEME_TYPE (the_manager))) \
    {                                                      \
      DdNode*   new_C_bdd ;                                 \
      scheme_bdd  new_Scheme_bdd ;                         \
                                                           \
      new_C_bdd = f ( (the_manager -> data) ) ;            \
      new_Scheme_bdd = construct_scheme_bdd( new_C_bdd ) ; \
      return ( (Scheme_Object*) new_Scheme_bdd ) ;         \
    }                                                      \
  else                                                     \
    {                                                      \
      printf ("C error in %s, expected a manager argument \n", nm) ; \
      exit (1) ; \
    }                                  

#define nodeonlybddop(f, nm)                                \
  scheme_bdd         first_bdd ;                            \
                                                            \
  first_bdd = (scheme_bdd) argList [ 0 ] ;                  \
                                                            \
  if (scheme_bdd_type == (SCHEME_TYPE (first_bdd)))         \
    {                                                       \
      DdNode* new_C_bdd ;                                    \
      scheme_bdd new_Scheme_bdd ;                           \
                                                            \
      new_C_bdd = f ( (first_bdd -> data) ) ;               \
      new_Scheme_bdd = construct_scheme_bdd ( new_C_bdd ) ; \
      return ( (Scheme_Object*) new_Scheme_bdd ) ;          \
    }                                                       \
  else                                                      \
    {                                                       \
      printf ("C error in %s, expected a bdd argument \n", nm) ; \
      exit (1) ; \
    }             

#define unarybddop(f, nm)                                \
  scheme_bdd         first_bdd ;                            \
  scheme_bdd_manager mgr ;                               \
                                                            \
  first_bdd = (scheme_bdd) argList [ 0 ] ;                  \
  mgr = (scheme_bdd_manager) argList [ 1 ] ;             \
                                                            \
  if ((scheme_bdd_type == (SCHEME_TYPE (first_bdd))) &&         \
      (scheme_bdd_manager_type == (SCHEME_TYPE (mgr))))    \
    {                                                       \
      DdNode* new_C_bdd ;                                    \
      scheme_bdd new_Scheme_bdd ;                           \
                                                            \
      new_C_bdd = f ( (mgr -> data) , (first_bdd -> data) ) ;               \
      new_Scheme_bdd = construct_scheme_bdd ( new_C_bdd ) ; \
      return ( (Scheme_Object*) new_Scheme_bdd ) ;          \
    }                                                       \
  else                                                      \
    {                                                       \
      if (scheme_bdd_manager_type != (SCHEME_TYPE (mgr))) \
        printf ("C error in %s, expected manager first argument \n", nm); \
      if (scheme_bdd_type != (SCHEME_TYPE (first_bdd)))           \
        printf ("C error in %s, expected bdd second argument \n", nm) ; \
      exit (1) ;                                                   \
    }                                                              


#define binarybddopwphases(f, nm)                        \
  scheme_bdd         first_bdd ;                         \
  scheme_bdd         second_bdd ;                        \
  scheme_bdd_manager mgr ;                               \
                                                         \
  first_bdd   = (scheme_bdd)         argList [ 0 ] ;     \
  second_bdd  = (scheme_bdd)         argList [ 1 ] ;     \
  mgr = (scheme_bdd_manager) argList [ 2 ] ;             \
                                                         \
  if ((scheme_bdd_type == (SCHEME_TYPE (first_bdd))) &&  \
      (scheme_bdd_type == (SCHEME_TYPE (second_bdd))))   \
    {                                                    \
      DdNode* new_C_bdd ;                                \
      scheme_bdd new_Scheme_bdd ;                        \
                                                         \
      new_C_bdd = f ( (mgr -> data),                     \
                      (first_bdd -> data),               \
                      (second_bdd -> data) ) ;           \
      new_Scheme_bdd = construct_scheme_bdd ( new_C_bdd ) ; \
      return ( (Scheme_Object*) new_Scheme_bdd ) ;   \
    }                                                    \
  else                                                   \
    {                                                    \
      if (scheme_bdd_type != (SCHEME_TYPE (first_bdd)))  \
        printf ("C error in %s, expected bdd first argument \n", nm) ; \
      if (scheme_bdd_type != (SCHEME_TYPE (second_bdd))) \
        printf ("C error in %s, expected bdd second argument \n", nm) ; \
      exit (1) ;                                         \
    }                     

Scheme_Object* scheme_xacml_new_var (int argCount ,
				     Scheme_Object **argList)
{ managerop(Cudd_addNewVar, "xacml-new-var") }

Scheme_Object* scheme_xacml_permit (int argCount ,
				    Scheme_Object **argList)
{ managerop(XACML_ADD_PERMIT_CONST, "xacml-permit") }

Scheme_Object* scheme_xacml_deny (int argCount ,
				    Scheme_Object **argList)
{ managerop(XACML_ADD_DENY_CONST, "xacml-deny") }

Scheme_Object* scheme_xacml_na (int argCount ,
				    Scheme_Object **argList)
{ managerop(XACML_ADD_NA_CONST, "xacml-na") }

Scheme_Object* scheme_xacml_ec (int argCount ,
				    Scheme_Object **argList)
{ managerop(XACML_ADD_EC_CONST, "xacml-ec") }

Scheme_Object* scheme_xacml_augment_rule  (int argCount ,
					   Scheme_Object **argList)
{ binarybddopwphases(Xacml_ADD_Augment_Rule, "xacml-augment-rule") }

Scheme_Object* scheme_xacml_permit_override  (int argCount ,
					      Scheme_Object **argList)
{ binarybddopwphases(Xacml_ADD_PermitOverride, "combine-permit-override") }

Scheme_Object* scheme_xacml_deny_override  (int argCount ,
					    Scheme_Object **argList)
{ binarybddopwphases(Xacml_ADD_DenyOverride, "combine-deny-override") }

Scheme_Object* scheme_xacml_first_applicable  (int argCount ,
					       Scheme_Object **argList)
{ binarybddopwphases(Xacml_ADD_FirstApplicable, "combine-first-applicable") }

Scheme_Object* scheme_xacml_add_and  (int argCount ,
				      Scheme_Object **argList)
{ binarybddopwphases(Xacml_ADD_LogicalAnd, "xacml-and") }

Scheme_Object* scheme_xacml_add_or  (int argCount ,
				      Scheme_Object **argList)
{ binarybddopwphases(Xacml_ADD_LogicalOr, "xacml-or") }

Scheme_Object* scheme_xacml_add_not (int argCount ,
				     Scheme_Object **argList)
{ unarybddop(Xacml_ADD_LogicalNot, "xacml-not") }

Scheme_Object* scheme_add_zero (int argCount ,
				Scheme_Object **argList)
{ managerop(Cudd_ReadZero, "add-false") }

Scheme_Object* scheme_add_one (int argCount ,
			       Scheme_Object **argList)
{ managerop(Cudd_ReadOne, "add-true") }

Scheme_Object* scheme_cudd_add_constrain  (int argCount ,
					   Scheme_Object **argList)
{ binarybddopwphases(Cudd_addConstrain, "cudd-add-constrain") }

Scheme_Object* scheme_xadd_assume  (int argCount ,
				    Scheme_Object **argList)
{ binarybddopwphases(Xacml_XADD_Assume, "xadd-assume") }

Scheme_Object* scheme_xacml_change_merge  (int argCount ,
					      Scheme_Object **argList)
{ binarybddopwphases(Xacml_ADD_ChangeMerge, "xacml-change-merge") }

Scheme_Object* scheme_xacml_na_to_deny (int argCount ,
					Scheme_Object **argList)
{ unarybddop(Xacml_NAtoDeny, "xadd-na-to-deny") }






Scheme_Object* scheme_bdd_new_var (int argCount ,
                                   Scheme_Object **argList)
{ managerop(Cudd_bddNewVar, "pl-new-var") }

Scheme_Object* scheme_bdd_not (int argCount ,
                               Scheme_Object **argList)
{ nodeonlybddop(Cudd_Not, "pl-not") }

Scheme_Object* scheme_bdd_and  (int argCount ,
                               Scheme_Object **argList)
{ binarybddopwphases(Cudd_bddAnd, "pl-and") }

Scheme_Object* scheme_bdd_init (int argCount ,
                                Scheme_Object **argList)
{
  DdManager*  new_C_manager ;
  scheme_bdd_manager  new_Scheme_manager ;
  int numVars ;

  numVars = (int) argList [ 0 ] ;

  new_C_manager = Cudd_Init(0, 0, CUDD_UNIQUE_SLOTS,
                            CUDD_CACHE_SLOTS, CUDD_MAX_CACHE_SIZE);
  new_Scheme_manager = (scheme_bdd_manager)
    malloc (sizeof (dummy_scheme_bdd_manager_struct) ) ;
  new_Scheme_manager -> type = scheme_bdd_manager_type ;
  new_Scheme_manager -> data = new_C_manager ;

  return ( (Scheme_Object*) new_Scheme_manager );
}

Scheme_Object* scheme_bdd_deref (int argCount ,
                                 Scheme_Object **argList)
{ 
  scheme_bdd_manager the_manager ;                                
  scheme_bdd         first_bdd ;                                  
                                                                  
  the_manager = (scheme_bdd_manager) argList [ 0 ] ;              
  first_bdd   = (scheme_bdd)         argList [ 1 ] ;              
                                                                  
  if ((scheme_bdd_manager_type == (SCHEME_TYPE (the_manager))) && 
      (scheme_bdd_type         == (SCHEME_TYPE (first_bdd))))     
    {                                                             
      Cudd_RecursiveDeref ( (the_manager -> data),    
		            (first_bdd -> data) ) ;                     
      return ( scheme_void ) ;
    }                                                             
  else                                                            
    {                                                             
      if (scheme_bdd_manager_type != (SCHEME_TYPE (the_manager))) 
        printf ("C error in %s, expected manager first argument \n", 
		"bdd-deref") ;                                    
      if (scheme_bdd_type != (SCHEME_TYPE (first_bdd)))           
        printf ("C error in %s, expected bdd second argument \n",    
		"bdd-deref") ;                                     
      exit (1) ;                                                  
    }                                                              
}

Scheme_Object* scheme_bdd_equal (int argCount ,
				 Scheme_Object **argList)
{
  scheme_bdd          bdd1 ;
  scheme_bdd          bdd2 ;

  bdd1 = (scheme_bdd) argList [ 0 ] ;
  bdd2 = (scheme_bdd) argList [ 1 ] ;

  if ((scheme_bdd_type == (SCHEME_TYPE (bdd1))) &&
      (scheme_bdd_type == (SCHEME_TYPE (bdd2))))
    {
      if ( (bdd1 -> data) == (bdd2 -> data) )
	return (scheme_true) ;
      else
	return (scheme_false) ;
    }
  else
    {
      if (scheme_bdd_type != (SCHEME_TYPE (bdd1)))           
        printf ("C error in %s, expected bdd first argument \n",    
		"bdd-equal?") ;                                     
      if (scheme_bdd_type != (SCHEME_TYPE (bdd2)))           
        printf ("C error in %s, expected bdd second argument \n",    
		"bdd-equal?") ;                                     
      exit (1) ;
    }
}

Scheme_Object* scheme_print_minterms (int argCount ,
				      Scheme_Object **argList)
{
  scheme_bdd         first_bdd ;                         
  scheme_bdd_manager mgr ;  
  //scheme_char_type x;
  //scheme_string_type file_name_scheme = NULL;
  Scheme_Object* file_name_scheme ;

  int printres ;                       
  FILE *fp , *oldfp ;
                                
  first_bdd   = (scheme_bdd) argList [ 0 ] ;     
  mgr = (scheme_bdd_manager) argList [ 1 ] ;
  file_name_scheme = (Scheme_Object*) argList [ 2 ] ;
                                                         
  if ( (scheme_bdd_type == (SCHEME_TYPE (first_bdd))) &&
       (scheme_bdd_manager_type == (SCHEME_TYPE (mgr))) &&
       (scheme_string_type == (SCHEME_TYPE (file_name_scheme))) )
    {            
      /* fp = fopen(PRINT_FNAME, "w") ; */
      char* file_name_c =  SCHEME_STR_VAL(file_name_scheme) ;
      fp = fopen(file_name_c, "w") ;
      if(! fp){
	perror("In function scheme_print_minterms, error opening temp file for printing MTBDD");
	exit(1);
      }
      oldfp = Cudd_ReadStdout(mgr -> data) ;
      Cudd_SetStdout ((mgr -> data), fp) ;
      printres = Cudd_PrintMinterm ((mgr -> data) , (first_bdd -> data)) ;
      Cudd_SetStdout ((mgr -> data), oldfp) ;
      fclose(fp) ;
      printf ("\n") ;
      return ( (Scheme_Object*) scheme_true ) ;   
    }                                                    
  else                                                   
    {                                                    
      if (scheme_bdd_type != (SCHEME_TYPE (first_bdd)))  
        printf ("C error in print-minterms, expected bdd first argument \n") ; 
      if (scheme_bdd_manager_type != (SCHEME_TYPE (mgr)))  
        printf ("C error in print-minterms, expected manager second argument \n") ; 
      exit (1) ;                                         
    }                     
}
 
Scheme_Object* scheme_xacml_stats (int argCount ,
				   Scheme_Object **argList)
{ 
  scheme_bdd_manager the_manager ;                                
  scheme_bdd         first_bdd ;                                  
                                                                  
  first_bdd   = (scheme_bdd)         argList [ 0 ] ;              
  the_manager = (scheme_bdd_manager) argList [ 1 ] ;              
                                                                  
  if ((scheme_bdd_manager_type == (SCHEME_TYPE (the_manager))) && 
      (scheme_bdd_type         == (SCHEME_TYPE (first_bdd))))     
    {                                                             
      Cudd_Print_Stats ( (the_manager -> data),    
		            (first_bdd -> data) ) ;                     
      return ( scheme_void ) ;
    }                                                             
  else                                                            
    {                                                             
      if (scheme_bdd_manager_type != (SCHEME_TYPE (the_manager))) 
        printf ("C error in %s, expected manager first argument \n", 
		"scheme_xacml_stats") ;                                    
      if (scheme_bdd_type != (SCHEME_TYPE (first_bdd)))           
        printf ("C error in %s, expected bdd second argument \n",    
		"scheme_xacml_stats") ;                                     
      exit (1) ;                                                  
    }                                                              
}

Scheme_Object* scheme_bdd_add_interval (int argCount ,
					Scheme_Object **argList)
{
  scheme_bdd         first_bdd ;                         
  scheme_bdd_manager mgr ;                               
  Scheme_Object *lowin, *upin ;                       
                                
  first_bdd = (scheme_bdd) argList [ 0 ] ;     
  lowin = argList [ 1 ] ;
  upin = argList [ 2 ] ;
  mgr = (scheme_bdd_manager) argList [ 3 ] ;             
                                                         
  if ((scheme_bdd_type == (SCHEME_TYPE (first_bdd))) &&
      (SCHEME_INTP (lowin)) &&
      (SCHEME_INTP (upin)) &&
      (scheme_bdd_manager_type == (SCHEME_TYPE (mgr))))
    {            
      int lower, upper ;
      DdNode *tmp, *res ;
      scheme_bdd new_Scheme_add ;

      lower = SCHEME_INT_VAL (lowin) ;
      upper = SCHEME_INT_VAL (upin) ;

      tmp = Cudd_addBddInterval ( (mgr -> data), (first_bdd -> data), lower, upper);
      Cudd_Ref(tmp) ;
      res = Cudd_BddToAdd ( (mgr -> data), tmp ) ;
      Cudd_Ref(res) ;
      Cudd_RecursiveDeref((mgr -> data), tmp) ; /* mct: added the ';' at the end of the line */
      new_Scheme_add = construct_scheme_bdd ( res ) ; \
      return ( (Scheme_Object*) new_Scheme_add ) ;   \
    }                                                    
  else                                                   
    {                                                    
      if (scheme_bdd_type != (SCHEME_TYPE (first_bdd)))  
        printf ("C error in add-bdd-interval, expected bdd first argument \n") ; 
      if (!(SCHEME_INTP(lowin)))
        printf ("C error in add-bdd-interval, expected integer second argument \n") ; 
      if (!(SCHEME_INTP (upin)))
        printf ("C error in add-bdd-interval, expected integer third argument \n") ; 
      if (scheme_bdd_manager_type != (SCHEME_TYPE (mgr)))  
        printf ("C error in add-bdd-interval, expected manager fourth argument \n") ; 
      exit (1) ;                                         
    }                     
}

Scheme_Object* vararray_to_scheme_list (int *array , int arraysize , int trueval )
{
  Scheme_Object *IndexList = scheme_null ;
  int i = arraysize - 1 ;
  
  while (i >= 0) {
    /* printf ("%d th var is %d\n", i, indices[i] ) ; */
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

Scheme_Object* scheme_support_vars (int argCount ,
				    Scheme_Object **argList)
{
  scheme_bdd         first_bdd ;                         
  scheme_bdd_manager mgr ;                               
  Scheme_Object *whichtype ;
  
  first_bdd = (scheme_bdd) argList [ 0 ] ;     
  mgr = (scheme_bdd_manager) argList [ 1 ] ;             
  whichtype = (scheme_bdd_manager) argList [ 2 ] ;             
                                                         
  if ((scheme_bdd_type == (SCHEME_TYPE (first_bdd))) &&
      (scheme_bdd_manager_type == (SCHEME_TYPE (mgr))) &&
      (SCHEME_INTP(whichtype)) && (SCHEME_INT_VAL(whichtype) >= 0) &&
      (SCHEME_INT_VAL(whichtype) <= 2))
    {
      int numvars = Cudd_ReadSize ( mgr -> data ) ;
      
      if (2 == SCHEME_INT_VAL(whichtype)) { /* want dont-care vars */
	int* indices = Cudd_SupportIndex ( mgr -> data , first_bdd -> data ) ;
	return ( vararray_to_scheme_list ( indices , numvars , 0 ) ) ;
      }
      else {
	DdNode *essential ;
	int *indices[numvars] ;
	
	essential = Cudd_FindEssential ( mgr -> data , first_bdd -> data ) ;
	/* printf ("Essential cube \n") ;
	   Cudd_PrintMinterm ((mgr -> data) , essential ) ;
	*/
	if (1 == Cudd_BddToCubeArray ( mgr -> data , essential, indices )) {
	  if (1 == SCHEME_INT_VAL(whichtype)) /* want true vars */
	    return ( vararray_to_scheme_list ( indices , numvars, 1 ) );
	  if (0 == SCHEME_INT_VAL(whichtype)) /* want false vars */
	    return ( vararray_to_scheme_list ( indices , numvars, 0 ) );
	}
	else {
	  printf ("Cudd problem in cube picking\n") ;
	  exit ( 1 ) ;
	}
      }
    }
  else                                                   
    {                                                    
      if (scheme_bdd_type != (SCHEME_TYPE (first_bdd)))  
        printf ("C error in scheme_support_vars, expected bdd first argument \n") ; 
      if (scheme_bdd_manager_type != (SCHEME_TYPE (mgr)))  
        printf ("C error in scheme_support_vars, expected manager second argument \n") ; 
      if (!((SCHEME_INTP(whichtype)) && (SCHEME_INT_VAL(whichtype) >= 0) &&
	    (SCHEME_INT_VAL(whichtype) <= 2)))
        printf ("C error in scheme_support_vars, expected integer in range [0,2] as third argument \n") ; 
      exit (1) ;                                         
    }                       
}

Scheme_Object *scheme_reload(Scheme_Env *env) 
{

  Scheme_Env *menv;
  Scheme_Object *proc;

  menv = scheme_primitive_module(scheme_intern_symbol(MODULE_NAME),
				 env);


  scheme_bdd_type = scheme_make_type ( "<scheme-bdd>" ) ;
  scheme_bdd_manager_type = scheme_make_type ( "<scheme-bdd-manager>" ) ;

  scheme_add_global ("make-dd-manager",
                     scheme_make_prim_w_arity (scheme_bdd_init,
                                               "make-dd-manager",
                                               0,
                                               0),
                     menv) ;

  scheme_add_global ("xacml-new-var",
                     scheme_make_prim_w_arity (scheme_xacml_new_var,
                                               "xacml-new-var",
                                               1,
                                               1),
                     menv) ;

  scheme_add_global ("xacml-permit",
                     scheme_make_prim_w_arity (scheme_xacml_permit,
                                               "xacml-permit",
                                               1,
                                               1),
                     menv) ;

  scheme_add_global ("xacml-deny",
                     scheme_make_prim_w_arity (scheme_xacml_deny,
                                               "xacml-deny",
                                               1,
                                               1),
                     menv) ;

  scheme_add_global ("xacml-na",
                     scheme_make_prim_w_arity (scheme_xacml_na,
                                               "xacml-na",
                                               1,
                                               1),
                     menv) ;

  scheme_add_global ("xacml-ec",
                     scheme_make_prim_w_arity (scheme_xacml_ec,
                                               "xacml-ec",
                                               1,
                                               1),
                     menv) ;

  scheme_add_global ("xacml-augment-rule",
                     scheme_make_prim_w_arity (scheme_xacml_augment_rule,
                                               "xacml-augment-rule",
                                               3,
                                               3),
                     menv) ;

  scheme_add_global ("combine-permit-override",
                     scheme_make_prim_w_arity (scheme_xacml_permit_override,
                                               "combine-permit-override",
                                               3,
                                               3),
                     menv) ;
  
  scheme_add_global ("combine-deny-override",
                     scheme_make_prim_w_arity (scheme_xacml_deny_override,
                                               "combine-deny-override",
                                               3,
                                               3),
                     menv) ;
  
  scheme_add_global ("combine-first-applicable",
                     scheme_make_prim_w_arity (scheme_xacml_first_applicable,
                                               "combine-first-applicable",
                                               3,
                                               3),
                     menv) ;

   scheme_add_global ("xacml-and",
                     scheme_make_prim_w_arity (scheme_xacml_add_and,
                                               "xacml-and",
                                               3,
                                               3),
                     menv) ;

  scheme_add_global ("xacml-or",
                     scheme_make_prim_w_arity (scheme_xacml_add_or,
                                               "xacml-or",
                                               3,
                                               3),
                     menv) ;

  scheme_add_global ("xacml-not",
                     scheme_make_prim_w_arity (scheme_xacml_add_not,
                                               "xacml-not",
                                               2,
                                               2),
                     menv) ;

  scheme_add_global ("print-minterms",
                     scheme_make_prim_w_arity (scheme_print_minterms,
                                               "print-minterms",
                                               3,
                                               3),
                     menv) ;

  scheme_add_global ("add-false",
		     scheme_make_prim_w_arity (scheme_add_zero,
					       "add-false",
					       1,
					       1),
		     menv) ;

  scheme_add_global ("add-true",
		     scheme_make_prim_w_arity (scheme_add_one,
					       "add-true",
					       1,
					       1),
		     menv) ;

   scheme_add_global ("cudd-add-constrain",
                     scheme_make_prim_w_arity (scheme_cudd_add_constrain,
                                               "cudd-add-constrain",
                                               3,
                                               3),
                     menv) ;

   scheme_add_global ("xadd-assume",
                     scheme_make_prim_w_arity (scheme_xadd_assume,
                                               "xadd-assume",
                                               3,
                                               3),
                     menv) ;

   scheme_add_global ("cudd-add-restrict-interval",
                     scheme_make_prim_w_arity (scheme_bdd_add_interval,
                                               "cudd-add-restrict-interval",
                                               4,
                                               4),
                     menv) ;

   scheme_add_global ("xacml-change-merge",
                     scheme_make_prim_w_arity (scheme_xacml_change_merge,
                                               "xacml-change-merge",
                                               3,
                                               3),
                     menv) ;

   scheme_add_global ("xacml-support-indices",
                     scheme_make_prim_w_arity (scheme_support_vars,
                                               "xacml-support-indices",
                                               3,
                                               3),
                     menv) ;

   scheme_add_global ("add-equal?",
		      scheme_make_prim_w_arity (scheme_bdd_equal,
						"add-equal?",
						2,
						2),
		      menv) ;

   scheme_add_global ("xadd-na-to-deny",
		      scheme_make_prim_w_arity (scheme_xacml_na_to_deny,
						"xadd-na-to-deny",
						2,
						2),
		      menv) ;

   scheme_add_global ("xacml-stats",
		      scheme_make_prim_w_arity (scheme_xacml_stats,
						"xacml-stats",
						2,
						2),
		      menv) ;

  scheme_finish_primitive_module(menv); 

  return scheme_void;



  /* fix */
  /*
  scheme_add_global ("get-pl-true",
		     scheme_make_prim_w_arity (scheme_bdd_one,
					       "get-pl-true",
					       1,
					       1),
		     menv) ;

  scheme_add_global ("pl-not",
                     scheme_make_prim_w_arity (scheme_bdd_not,
                                               "pl-not",
                                               1,
                                               1),
                     menv) ;

  scheme_add_global ("pl-and",
                     scheme_make_prim_w_arity (scheme_bdd_and,
                                               "pl-and",
                                               3,
                                               3),
                     menv) ;

  scheme_add_global ("pl-deref",
		     scheme_make_prim_w_arity (scheme_bdd_deref,
					       "pl-deref",
					       2,
					       2),
		     menv) ;

  return scheme_void ;
  */
}

Scheme_Object *scheme_initialize(Scheme_Env *env)
{
  /* First load is same as every load: */
  return scheme_reload(env);
}


Scheme_Object *scheme_module_name()
{
  /* This extension defines a module named `MODULE_NAME': */
  return scheme_intern_symbol( MODULE_NAME );
}


//Scheme_Object *scheme_module_name () {
//  return (scheme_false) ;
//}

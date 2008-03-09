/* will need the ref and deref commands here too */
/* check on static vars and GC comment */

#include <escheme.h>
#include <cudd.h>

#define CUDD_MAX_CACHE_SIZE 0
#define PRINT_FNAME "x0print0tmp"

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




Scheme_Object* scheme_bdd_new_var (int argCount ,
                                   Scheme_Object **argList)
{ managerop(Cudd_bddNewVar, "pl-new-var") }

Scheme_Object* scheme_bdd_not (int argCount ,
                               Scheme_Object **argList)
{ nodeonlybddop(Cudd_Not, "pl-not") }

Scheme_Object* scheme_bdd_and  (int argCount ,
                               Scheme_Object **argList)
{ binarybddopwphases(Cudd_bddAnd, "pl-and") }

Scheme_Object* scheme_bdd_one (int argCount ,
			       Scheme_Object **argList)
{ managerop(Cudd_ReadOne, "get-pl-true") }

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
  int printres ;                       
  FILE *fp , *oldfp ;
                                
  first_bdd   = (scheme_bdd) argList [ 0 ] ;     
  mgr = (scheme_bdd_manager) argList [ 1 ] ;             
                                                         
  if ((scheme_bdd_type == (SCHEME_TYPE (first_bdd))) &&
      (scheme_bdd_manager_type == (SCHEME_TYPE (mgr))))
    {            
      fp = fopen(PRINT_FNAME, "w") ;
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
 
Scheme_Object* scheme_initialize (Scheme_Env  *env)
{
  scheme_bdd_type = scheme_make_type ( "<scheme-bdd>" ) ;
  scheme_bdd_manager_type = scheme_make_type ( "<scheme-bdd-manager>" ) ;

  scheme_add_global ("make-dd-manager",
                     scheme_make_prim_w_arity (scheme_bdd_init,
                                               "make-dd-manager",
                                               0,
                                               0),
                     env) ;

  scheme_add_global ("xacml-new-var",
                     scheme_make_prim_w_arity (scheme_xacml_new_var,
                                               "xacml-new-var",
                                               1,
                                               1),
                     env) ;

  scheme_add_global ("xacml-permit",
                     scheme_make_prim_w_arity (scheme_xacml_permit,
                                               "xacml-permit",
                                               1,
                                               1),
                     env) ;

  scheme_add_global ("xacml-deny",
                     scheme_make_prim_w_arity (scheme_xacml_deny,
                                               "xacml-deny",
                                               1,
                                               1),
                     env) ;

  scheme_add_global ("xacml-na",
                     scheme_make_prim_w_arity (scheme_xacml_na,
                                               "xacml-na",
                                               1,
                                               1),
                     env) ;

  scheme_add_global ("xacml-augment-rule",
                     scheme_make_prim_w_arity (scheme_xacml_augment_rule,
                                               "xacml-augment-rule",
                                               3,
                                               3),
                     env) ;

  scheme_add_global ("combine-permit-override",
                     scheme_make_prim_w_arity (scheme_xacml_permit_override,
                                               "combine-permit-override",
                                               3,
                                               3),
                     env) ;
  
  scheme_add_global ("combine-deny-override",
                     scheme_make_prim_w_arity (scheme_xacml_deny_override,
                                               "combine-deny-override",
                                               3,
                                               3),
                     env) ;
  
  scheme_add_global ("combine-first-applicable",
                     scheme_make_prim_w_arity (scheme_xacml_first_applicable,
                                               "combine-first-applicable",
                                               3,
                                               3),
                     env) ;

   scheme_add_global ("xacml-and",
                     scheme_make_prim_w_arity (scheme_xacml_add_and,
                                               "xacml-and",
                                               3,
                                               3),
                     env) ;

  scheme_add_global ("xacml-or",
                     scheme_make_prim_w_arity (scheme_xacml_add_or,
                                               "xacml-or",
                                               3,
                                               3),
                     env) ;

  scheme_add_global ("xacml-not",
                     scheme_make_prim_w_arity (scheme_xacml_add_not,
                                               "xacml-not",
                                               2,
                                               2),
                     env) ;

  scheme_add_global ("print-minterms",
                     scheme_make_prim_w_arity (scheme_print_minterms,
                                               "print-minterms",
                                               2,
                                               2),
                     env) ;


  /* fix */
  scheme_add_global ("get-pl-true",
		     scheme_make_prim_w_arity (scheme_bdd_one,
					       "get-pl-true",
					       1,
					       1),
		     env) ;

  scheme_add_global ("pl-not",
                     scheme_make_prim_w_arity (scheme_bdd_not,
                                               "pl-not",
                                               1,
                                               1),
                     env) ;

  scheme_add_global ("pl-and",
                     scheme_make_prim_w_arity (scheme_bdd_and,
                                               "pl-and",
                                               3,
                                               3),
                     env) ;

  scheme_add_global ("pl-deref",
		     scheme_make_prim_w_arity (scheme_bdd_deref,
					       "pl-deref",
					       2,
					       2),
		     env) ;

  scheme_add_global ("pl-equal?",
		     scheme_make_prim_w_arity (scheme_bdd_equal,
					       "pl-equal?",
					       2,
					       2),
		     env) ;
  return scheme_void ;
}

Scheme_Object *scheme_reload(Scheme_Env *env) {
   return scheme_initialize(env); /* Nothing special for reload */
 }

Scheme_Object *scheme_module_name () {
  return (scheme_false) ;
}

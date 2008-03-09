#define MZC_SRC_FILE "/proj/scheme/plt/collects/plot/fit-low-level.ss"

#include "escheme.h"

/* c-declare literals */

#include "fit.h"

 double * list_to_array(Scheme_Object * list)
 {  
  double * ar = (double *)scheme_malloc(scheme_list_length(list) * sizeof(double));
  int i = 0;
  while(!SCHEME_NULLP(list))
    {
      Scheme_Object * car = SCHEME_CAR(list);
      double tmp;
      
      tmp = scheme_real_to_double(car);
      ar[i] = tmp;
      list = SCHEME_CDR(list);
      i++;
    }
  
  return ar;
  }

 Scheme_Object * array_to_list(double * dbls, int length)
  {	
    int i;
    Scheme_Object * result = scheme_null;
    for(i = length - 1; i >= 0 ;i--)    {
 	result = scheme_make_pair(scheme_make_double(dbls[i]),result);
       }	
    return result;
  }
 

/* done with c-declare literals */


/* c-lambda implementations */

Scheme_Object *mzc_cffi_0(int argc, Scheme_Object **argv) {
  Scheme_Object* ___arg1;
  Scheme_Object* ___arg2;
  Scheme_Object* ___arg3;
  Scheme_Object* ___arg4;
  Scheme_Object* ___arg5;
  Scheme_Object* ___arg6;
  Scheme_Object* ___result;
  Scheme_Object *converted_result;
  ___arg1 = argv[0];
  ___arg2 = argv[1];
  ___arg3 = argv[2];
  ___arg4 = argv[3];
  ___arg5 = argv[4];
  ___arg6 = argv[5];
 {

 {                            
 double * result_params = do_fit(___arg1,
                                 scheme_list_length(___arg2),
                                 list_to_array(___arg2),
                                 list_to_array(___arg3),
                                 list_to_array(___arg4),
                                 list_to_array(___arg5),
                                 scheme_list_length(___arg6),
                                 list_to_array(___arg6));
 // now make the result_params into a list
 

 if(result_params == NULL)
	{
 	___result =  scheme_null;
	}
 else {

 int len = scheme_list_length(___arg6);

 Scheme_Object * fit_final_params = 
	array_to_list(result_params, len);

 Scheme_Object * fit_asym_error = 
	array_to_list (get_asym_error(), len);

 Scheme_Object * fit_asym_error_percent =  
	array_to_list (get_asym_error_percent(), len);

 Scheme_Object * fit_rms = scheme_make_double(get_rms());
 Scheme_Object * fit_varience = scheme_make_double(get_varience());

 ___result = 
	scheme_make_pair(fit_final_params,
         scheme_make_pair(fit_asym_error,	
          scheme_make_pair(fit_asym_error_percent,
	   scheme_make_pair(fit_rms,
	    scheme_make_pair(fit_varience, scheme_null)))));
	}
 }

  converted_result = ___result;
#ifdef ___AT_END
  ___AT_END
#undef ___AT_END
#endif
 }
  return converted_result;

}

/* done with c-lambda implementations */

#include "mzc.h"

/* compiler-written structures */

static const char *SYMBOL_STRS[6] = {
  "fit-internal", /* 0 */
  "fit-low-level", /* 1 */
  "mzscheme", /* 2 */
  "lib", /* 3 */
  "#%kernel", /* 4 */
  "list", /* 5 */
}; /* end of SYMBOL_STRS */

static const long SYMBOL_LENS[6] = {
  12, /* 0 */
  13, /* 1 */
  8, /* 2 */
  3, /* 3 */
  8, /* 4 */
  4, /* 5 */
}; /* end of SYMBOL_LENS */

static Scheme_Object * SYMBOLS[6];

/* list.ss */
static const char STRING_3[8] = {
    108, 105, 115, 116, 46, 115, 115, 0 }; /* end of STRING_3 */

/* cffi.ss */
static const char STRING_0[8] = {
    99, 102, 102, 105, 46, 115, 115, 0 }; /* end of STRING_0 */

/* compiler */
static const char STRING_1[9] = {
    99, 111, 109, 112, 105, 108, 101, 114, 0 }; /* end of STRING_1 */

/* etc.ss */
static const char STRING_2[7] = {
    101, 116, 99, 46, 115, 115, 0 }; /* end of STRING_2 */

/* primitives referenced by the code */
static struct {
  Scheme_Object * glg7867__kernel_list;
} P;

/* compiler-written static variables */
static struct {
  /* Write fields as an array to help C compilers */
  /* that don't like really big records. */
  Scheme_Object * _consts_[12];
# define const7876 _consts_[0]
# define const7875 _consts_[1]
# define const7874 _consts_[2]
# define const7873 _consts_[3]
# define const7872 _consts_[4]
# define const7871 _consts_[5]
# define const7870 _consts_[6]
# define const7869 _consts_[7]
# define const7868 _consts_[8]
# define const7866 _consts_[9]
# define const7865 _consts_[10]
# define const7864 _consts_[11]
} S;

/* compiler-written per-load static variables */
typedef struct Scheme_Per_Load_Statics {
  int dummy;
} Scheme_Per_Load_Statics;

/* compiler-written per-invoke variables for module 0 */
typedef struct Scheme_Per_Invoke_Statics_0 {
  int dummy;
} Scheme_Per_Invoke_Statics_0;
typedef struct Scheme_Per_Invoke_Syntax_Statics_0 {
  int dummy;
} Scheme_Per_Invoke_Syntax_Statics_0;



static void make_symbols()
{
  int i;
  for (i = 6; i--; )
    SYMBOLS[i] = scheme_intern_exact_symbol(SYMBOL_STRS[i], SYMBOL_LENS[i]);
}

static void make_syntax_strings()
{
}

static void gc_registration()
{
    /* register compiler-written static variables with GC */
    scheme_register_extension_global(&SYMBOLS, sizeof(SYMBOLS));
    scheme_register_extension_global(&P, sizeof(P));
    scheme_register_extension_global(&S, sizeof(S));

}

static void init_prims(Scheme_Env * env)
{
   /* primitives referenced by the code */
    P.glg7867__kernel_list = scheme_module_bucket(SYMBOLS[4], SYMBOLS[5], -1, env)->val;
}

static void init_constants_0(Scheme_Env * env)
{
#define self_modidx NULL
    Scheme_Object * arg[7];
    Scheme_Thread * pr = scheme_current_thread;
    Scheme_Object ** tail_buf;
    { /* [#f,#f] */
        S.const7864 = scheme_make_prim_w_arity(mzc_cffi_0, "fit-internal", 6, 6);
    }
    { /* [3,8] */
        S.const7865 = scheme_make_immutable_sized_string((char *)STRING_0, 7, 0);
    }
    { /* [3,18] */
        S.const7866 = scheme_make_immutable_sized_string((char *)STRING_1, 8, 0);
    }
    { /* [3,3] */
        arg[0] = SYMBOLS[3];
        arg[1] = S.const7865;
        arg[2] = S.const7866;
        S.const7868 = _scheme_direct_apply_primitive_multi(P.glg7867__kernel_list, 3, arg);
    }
    { /* [4,8] */
        S.const7869 = scheme_make_immutable_sized_string((char *)STRING_2, 6, 0);
    }
    { /* [4,3] */
        Scheme_Object * macapply7877;
        Scheme_Object * macapply7878;
        macapply7877 = SYMBOLS[3];
        macapply7878 = S.const7869;
        S.const7870 = MZC_LIST2(P.glg7867__kernel_list, macapply7877, macapply7878);
    }
    { /* [5,8] */
        S.const7871 = scheme_make_immutable_sized_string((char *)STRING_3, 7, 0);
    }
    { /* [5,3] */
        Scheme_Object * macapply7879;
        Scheme_Object * macapply7880;
        macapply7879 = SYMBOLS[3];
        macapply7880 = S.const7871;
        S.const7872 = MZC_LIST2(P.glg7867__kernel_list, macapply7879, macapply7880);
    }
    { /* [1,0] */
        arg[0] = SYMBOLS[2];
        arg[1] = S.const7868;
        arg[2] = S.const7870;
        arg[3] = S.const7872;
        S.const7873 = _scheme_direct_apply_primitive_multi(P.glg7867__kernel_list, 4, arg);
    }
    { /* [1,0] */
        Scheme_Object * macapply7881;
        Scheme_Object * macapply7882;
        macapply7881 = SYMBOLS[2];
        macapply7882 = SYMBOLS[2];
        S.const7874 = MZC_LIST2(P.glg7867__kernel_list, macapply7881, macapply7882);
    }
    { /* [1,0] */
        Scheme_Object * macapply7883;
        macapply7883 = SYMBOLS[0];
        S.const7875 = MZC_LIST1(P.glg7867__kernel_list, macapply7883);
    }
    { /* [1,0] */
        arg[0] = SYMBOLS[1];
        arg[1] = S.const7873;
        arg[2] = S.const7874;
        arg[3] = S.const7875;
        arg[4] = scheme_null;
        arg[5] = scheme_null;
        arg[6] = scheme_false;
        S.const7876 = _scheme_direct_apply_primitive_multi(P.glg7867__kernel_list, 7, arg);
    }
#undef self_modidx
} /* end of init_constants_0 */

static void module_body_0_0(Scheme_Env * env, Scheme_Per_Load_Statics *PLS, long phase_shift, Scheme_Object *self_modidx, Scheme_Per_Invoke_Statics_0 *PMIS)
{
    Scheme_Object * arg[7];
    Scheme_Thread * pr = scheme_current_thread;
    Scheme_Object ** tail_buf;
    { /* [39,1] */
        Scheme_Bucket * Gglg7863MoD_fit_internal;
        Gglg7863MoD_fit_internal = scheme_global_bucket(SYMBOLS[0], env);
        scheme_set_global_bucket("define-values", Gglg7863MoD_fit_internal, S.const7864, 1);
    }
} /* end of module_body_0_0 */

static void module_syntax_body_0_0(Scheme_Env * env, Scheme_Per_Load_Statics *PLS, long phase_shift, Scheme_Object *self_modidx, Scheme_Per_Invoke_Syntax_Statics_0 *PMIS)
{
    Scheme_Object * arg[7];
    Scheme_Thread * pr = scheme_current_thread;
    Scheme_Object ** tail_buf;
    { /* [#f,#f] */
    }
} /* end of module_syntax_body_0_0 */

static void module_invoke_0(Scheme_Env *env, long phase_shift, Scheme_Object *self_modidx, void *pls)
{
    Scheme_Per_Invoke_Statics_0 *PMIS;
    PMIS = (Scheme_Per_Invoke_Statics_0 *)scheme_malloc(sizeof(Scheme_Per_Invoke_Statics_0));
    module_body_0_0(env, (Scheme_Per_Load_Statics *)pls, phase_shift, self_modidx, PMIS);
}

static void module_invoke_syntax_0(Scheme_Env *env, long phase_shift, Scheme_Object *self_modidx, void *pls)
{
    Scheme_Per_Invoke_Syntax_Statics_0 *PMIS;
    PMIS = (Scheme_Per_Invoke_Syntax_Statics_0 *)scheme_malloc(sizeof(Scheme_Per_Invoke_Syntax_Statics_0));
    module_syntax_body_0_0(env, (Scheme_Per_Load_Statics *)pls, phase_shift, self_modidx, PMIS);
}

static Scheme_Object * top_level_0(Scheme_Env * env, Scheme_Per_Load_Statics *PLS)
{
    Scheme_Object * arg[7];
    Scheme_Thread * pr = scheme_current_thread;
    Scheme_Object ** tail_buf;
    { /* [1,0] */
        return scheme_declare_module(S.const7876, module_invoke_0, module_invoke_syntax_0, PLS, SCHEME_CURRENT_ENV(pr));
    }
} /* end of top_level_0 */

Scheme_Object * scheme_reload(Scheme_Env * env)
{
    Scheme_Per_Load_Statics *PLS;
    PLS = (Scheme_Per_Load_Statics *)scheme_malloc(sizeof(Scheme_Per_Load_Statics));
    return top_level_0(env, PLS);
}


void scheme_setup(Scheme_Env * env)
{
    scheme_set_tail_buffer_size(1);
    gc_registration();
    make_symbols();
    make_syntax_strings();
    init_prims(env);
    init_constants_0(env);
}


Scheme_Object * scheme_initialize(Scheme_Env * env)
{
    scheme_setup(env);
    return scheme_reload(env);
}


Scheme_Object * scheme_module_name()
{
    return scheme_intern_exact_symbol("fit-low-level", 13);
}

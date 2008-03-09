#include "escheme.h"
#ifdef XONX
#include <GL/gl.h>
#else
#ifdef OS_X
#include <OpenGL/gl.h>
#else
#include <GL/gl.h>
#endif
#endif
#include <math.h>

/* Primitives for working with gl-int-vectors.
   All parameters are checked, except that Scheme values 
   that must be converted into GLints are not.  This
   happens in vector->gl-int-vector and
   gl-int-vector-set!.
*/

static Scheme_Type gl_int_vector_type;
#include "gl-int-vector.h"

static Scheme_Object* scheme_make_boolean(GLboolean x)
{
  if (x)
    return scheme_true;
  else
    return scheme_false;
}

static GLboolean scheme_get_boolean(Scheme_Object* o)
{
  return o != scheme_false;
}

static GLint scheme_get_int(Scheme_Object* o)
{
  long l;
  l = 0;
  scheme_get_int_val(o, &l);
  return l;
}

static GLuint scheme_get_uint(Scheme_Object* o)
{
  unsigned long l;
  l = 0;
  scheme_get_unsigned_int_val(o, &l);
  return l;
}

static void check_type(const char *name, const Scheme_Object *v,
		       int which, int argc, Scheme_Object **argv)
{
  if (!SAME_TYPE(SCHEME_TYPE(v), gl_int_vector_type))
    scheme_wrong_type(name, "gl-int-vector", which, argc, argv);
  return;
}

/* Copied from vector.c in the mzscheme sources and modified */
static Scheme_Object *
bad_index(char *name, Scheme_Object *vec, Scheme_Object *i, int len)
{
  if (len) {
    char *vstr;
    int vlen;
    vstr = scheme_make_provided_string(vec, 2, &vlen);
    scheme_raise_exn(MZEXN_APPLICATION_MISMATCH,
		     i,
		     "%s: index %s out of range [%d, %d] for gl-int-vector: %t",
		     name, 
		     scheme_make_provided_string(i, 2, NULL), 
		     0, len-1,
		     vstr, vlen);
  } else
    scheme_raise_exn(MZEXN_APPLICATION_MISMATCH,
		     i,
		     "%s: bad index %s for empty gl-int-vector",
		     name,
		     scheme_make_provided_string(i, 0, NULL));
  
  return NULL;
}

/* Copied from fun.c in do_map in the mzscheme sources and modified */
static void length_mismatch(const char *name, int argc, Scheme_Object **argv, int i)
{
  char *argstr;
  long alen;
  
  argstr = scheme_make_args_string("", -1, argc, argv, &alen);
  
  scheme_raise_exn(MZEXN_APPLICATION_MISMATCH, argv[i],
		   "%s: all gl-int-vectors must have same length%t", 
		   name, argstr, alen);
  return;
}

/* 1 argument, a vector.
   assumes the values in the vector can be converted to GLint
*/
static Scheme_Object* vector_to_gl_int_vector(int argc, Scheme_Object **argv)
{
  int length, i;
  Scheme_Object **old_vec;
  gl_int_vector *new_vec;

  if (!SCHEME_VECTORP(argv[0]))
    scheme_wrong_type("vector->gl-int-vector", "vector", 0, argc, argv);

  length = SCHEME_VEC_SIZE(argv[0]);
  new_vec = make_gl_int_vector(length);
  old_vec = SCHEME_VEC_ELS(argv[0]);

  for (i = 0; i < length; ++i)
    new_vec->els[i] = scheme_get_int(old_vec[i]);
  
  return (Scheme_Object*)new_vec;
}

/* 1 argument, a gl-int-vector */
static Scheme_Object* gl_int_vector_to_vector(int argc, Scheme_Object **argv)
{
  int length, i;
  Scheme_Object *new_vec;
  gl_int_vector *old_vec; 

  check_type("gl-int-vector", argv[0], 0, argc, argv);

  old_vec = (gl_int_vector*)argv[0];
  length = old_vec->length;

  new_vec = scheme_make_vector(old_vec->length, scheme_void);
  for (i = 0; i < length; ++i)
    SCHEME_VEC_ELS(new_vec)[i] = scheme_make_integer_value(old_vec->els[i]);
  return new_vec;
}

/* 1 argument, a gl-int-vector */
static Scheme_Object* gl_int_vector_length(int argc, Scheme_Object **argv)
{
  check_type("gl-int-vector-length", argv[0], 0, argc, argv);

  return scheme_make_integer(((gl_int_vector*)argv[0])->length);
}

/* 2 arguments, a gl-int-vector and a non-negative integer */
static Scheme_Object* gl_int_vector_ref(int argc, Scheme_Object **argv)
{
  int length;
  long l;

  check_type("gl-int-vector-ref", argv[0], 0, argc, argv);
  
  length = ((gl_int_vector*)argv[0])->length;

  if (!SCHEME_EXACT_INTEGERP(argv[1]))
    scheme_wrong_type("gl-int-vector-ref",
		      "non-negative exact integer",
		      1, argc, argv);

  l = SCHEME_INT_VAL(argv[1]);

  if (SCHEME_BIGNUMP(argv[1]) || l < 0 || l >= length)
    bad_index("gl-int-vector-ref", argv[0], argv[1], length);
  
  return scheme_make_integer_value(((gl_int_vector*)argv[0])->els[SCHEME_INT_VAL(argv[1])]);
}

/* 3 arguments, a gl-int-vector, a non-negative integer,
   assumes the 3rd is convertible to GLint
*/
static Scheme_Object* gl_int_vector_set(int argc, Scheme_Object **argv)
{
  int length;
  long l;

  check_type("gl-int-vector-ref", argv[0], 0, argc, argv);
  
  length = ((gl_int_vector*)argv[0])->length;

  if (!SCHEME_EXACT_INTEGERP(argv[1]))
    scheme_wrong_type("gl-int-vector-set!",
		      "non-negative exact integer",
		      1, argc, argv);

  l = SCHEME_INT_VAL(argv[1]);

  if (SCHEME_BIGNUMP(argv[1]) || l < 0 || l >= length)
    bad_index("gl-int-vector-set!", argv[0], argv[1], length);

  ((gl_int_vector*)argv[0])->els[SCHEME_INT_VAL(argv[1])] = scheme_get_int(argv[2]);
  return scheme_void;
}

/* 1 argument */
static Scheme_Object* gl_int_vectorP(int argc, Scheme_Object **argv)
{
  if (SCHEME_TYPE(argv[0]) == gl_int_vector_type)
    return scheme_true;
  else
    return scheme_false;
}

/* 2 arguments, gl-int-vectors of equal lengths. */
static Scheme_Object* gl_int_vector_plus(int argc, Scheme_Object **argv)
{
  gl_int_vector* vec;
  int length, i;
  gl_int_vector *v1, *v2;

  check_type("gl-int-vector+", argv[0], 0, argc, argv);
  check_type("gl-int-vector+", argv[1], 1, argc, argv);

  v1 = (gl_int_vector*) argv[0];
  v2 = (gl_int_vector*) argv[1];

  length = v1->length;

  if (length != v2->length)
    length_mismatch("gl-int-vector+", argc, argv, 1);

  vec = make_gl_int_vector(length);
  
  for (i = 0; i < length; ++i)
    vec->els[i] = v1->els[i] + v2->els[i];

  return (Scheme_Object*) vec;  
}

/* 2 arguments, gl-int-vector with equal lengths. */
static Scheme_Object* gl_int_vector_minus(int argc, Scheme_Object **argv)
{
  gl_int_vector* vec;
  int length, i;
  gl_int_vector *v1, *v2;

  check_type("gl-int-vector-", argv[0], 0, argc, argv);
  check_type("gl-int-vector-", argv[1], 1, argc, argv);

  v1 = (gl_int_vector*) argv[0];
  v2 = (gl_int_vector*) argv[1];

  length = v1->length;

  if (length != v2->length)
    length_mismatch("gl-int-vector-", argc, argv, 1);

  vec = make_gl_int_vector(length);
  
  for (i = 0; i < length; ++i)
    vec->els[i] = v1->els[i] - v2->els[i];

  return (Scheme_Object*) vec;  
}

/* 2 arguments, a scheme real and a gl-int-vector */
static Scheme_Object* gl_int_vector_times(int argc, Scheme_Object **argv)
{
  gl_int_vector* vec;
  int length, i;
  GLint d;
  gl_int_vector *v0;

  if (!SCHEME_REALP(argv[0]))
    scheme_wrong_type("gl-int-vector-times", "real number", 0, argc, argv);

  check_type("gl-int-vector*", argv[1], 1, argc, argv);

  v0 = (gl_int_vector*) argv[1];

  d = scheme_get_int(argv[0]);
  length = v0->length;
  vec = make_gl_int_vector(length);

  for (i = 0; i < length; ++i)
    vec->els[i] = d * v0->els[i];

  return (Scheme_Object*)vec;
}

/* 1 argument, a gl-int-vector */
static Scheme_Object* gl_int_vector_norm(int argc, Scheme_Object **argv)
{
  int length, i;
  GLint d;
  gl_int_vector *v;

  check_type("gl-int-vector-norm", argv[0], 0, argc, argv);

  v = (gl_int_vector*) argv[0];
  length = v->length;
  d = 0.0;
  for (i = 0; i < length; ++i)
    d = d + v->els[i] * v->els[i];
  return scheme_make_integer_value(sqrt(d));
}


static void add_func(char *name, Scheme_Env *mod, Scheme_Prim *c_fun, int mina, int maxa)
{
  scheme_add_global(name, scheme_make_prim_w_arity(c_fun, name, mina, maxa), mod);
  return;
}

Scheme_Object *scheme_reload(Scheme_Env *env)
{
  Scheme_Env *mod_env = scheme_primitive_module(scheme_intern_symbol("gl-int-vector"), env);
  
  add_func("vector->gl-int-vector", mod_env, vector_to_gl_int_vector, 1, 1);
  add_func("gl-int-vector->vector", mod_env, gl_int_vector_to_vector, 1, 1);
  add_func("gl-int-vector-length", mod_env, gl_int_vector_length, 1, 1);
  add_func("gl-int-vector-ref", mod_env, gl_int_vector_ref, 2, 2);
  add_func("gl-int-vector-set!", mod_env, gl_int_vector_set, 3, 3);
  add_func("gl-int-vector?", mod_env, gl_int_vectorP, 1, 1);
  add_func("gl-int-vector+", mod_env, gl_int_vector_plus, 2, 2);
  add_func("gl-int-vector-", mod_env, gl_int_vector_minus, 2, 2);
  add_func("gl-int-vector*", mod_env, gl_int_vector_times, 2, 2);
  add_func("gl-int-vector-norm", mod_env, gl_int_vector_norm, 1, 1);
  scheme_add_global("gl-int-vector-internal-type", 
		    scheme_make_integer(gl_int_vector_type),
		    mod_env);

  scheme_finish_primitive_module(mod_env);
  return scheme_void;
}

Scheme_Object *scheme_initialize(Scheme_Env *env)
{
  gl_int_vector_type = scheme_make_type("<gl-int-vector>");
  return scheme_reload(env);
}

Scheme_Object *scheme_module_name()
{
  return scheme_intern_symbol("gl-int-vector");
}




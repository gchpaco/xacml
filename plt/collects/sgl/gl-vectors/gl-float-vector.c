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

/* Primitives for working with gl-float-vectors.
   All parameters are checked, except that Scheme values 
   that must be converted into GLfloats are not.  This
   happens in vector->gl-float-vector and
   gl-float-vector-set!.
*/

static Scheme_Type gl_float_vector_type;
#include "gl-float-vector.h"

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
  if (!SAME_TYPE(SCHEME_TYPE(v), gl_float_vector_type))
    scheme_wrong_type(name, "gl-float-vector", which, argc, argv);
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
		     "%s: index %s out of range [%d, %d] for gl-float-vector: %t",
		     name, 
		     scheme_make_provided_string(i, 2, NULL), 
		     0, len-1,
		     vstr, vlen);
  } else
    scheme_raise_exn(MZEXN_APPLICATION_MISMATCH,
		     i,
		     "%s: bad index %s for empty gl-float-vector",
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
		   "%s: all gl-float-vectors must have same length%t", 
		   name, argstr, alen);
  return;
}

/* 1 argument, a vector.
   assumes the values in the vector can be converted to GLfloat
*/
static Scheme_Object* vector_to_gl_float_vector(int argc, Scheme_Object **argv)
{
  int length, i;
  Scheme_Object **old_vec;
  gl_float_vector *new_vec;

  if (!SCHEME_VECTORP(argv[0]))
    scheme_wrong_type("vector->gl-float-vector", "vector", 0, argc, argv);

  length = SCHEME_VEC_SIZE(argv[0]);
  new_vec = make_gl_float_vector(length);
  old_vec = SCHEME_VEC_ELS(argv[0]);

  for (i = 0; i < length; ++i)
    new_vec->els[i] = scheme_real_to_double(old_vec[i]);
  
  return (Scheme_Object*)new_vec;
}

/* 1 argument, a gl-float-vector */
static Scheme_Object* gl_float_vector_to_vector(int argc, Scheme_Object **argv)
{
  int length, i;
  Scheme_Object *new_vec;
  gl_float_vector *old_vec; 

  check_type("gl-float-vector", argv[0], 0, argc, argv);

  old_vec = (gl_float_vector*)argv[0];
  length = old_vec->length;

  new_vec = scheme_make_vector(old_vec->length, scheme_void);
  for (i = 0; i < length; ++i)
    SCHEME_VEC_ELS(new_vec)[i] = scheme_make_double(old_vec->els[i]);
  return new_vec;
}

/* 1 argument, a gl-float-vector */
static Scheme_Object* gl_float_vector_length(int argc, Scheme_Object **argv)
{
  check_type("gl-float-vector-length", argv[0], 0, argc, argv);

  return scheme_make_integer(((gl_float_vector*)argv[0])->length);
}

/* 2 arguments, a gl-float-vector and a non-negative integer */
static Scheme_Object* gl_float_vector_ref(int argc, Scheme_Object **argv)
{
  int length;
  long l;

  check_type("gl-float-vector-ref", argv[0], 0, argc, argv);
  
  length = ((gl_float_vector*)argv[0])->length;

  if (!SCHEME_EXACT_INTEGERP(argv[1]))
    scheme_wrong_type("gl-float-vector-ref",
		      "non-negative exact integer",
		      1, argc, argv);

  l = SCHEME_INT_VAL(argv[1]);

  if (SCHEME_BIGNUMP(argv[1]) || l < 0 || l >= length)
    bad_index("gl-float-vector-ref", argv[0], argv[1], length);
  
  return scheme_make_double(((gl_float_vector*)argv[0])->els[SCHEME_INT_VAL(argv[1])]);
}

/* 3 arguments, a gl-float-vector, a non-negative integer,
   assumes the 3rd is convertible to GLfloat
*/
static Scheme_Object* gl_float_vector_set(int argc, Scheme_Object **argv)
{
  int length;
  long l;

  check_type("gl-float-vector-ref", argv[0], 0, argc, argv);
  
  length = ((gl_float_vector*)argv[0])->length;

  if (!SCHEME_EXACT_INTEGERP(argv[1]))
    scheme_wrong_type("gl-float-vector-set!",
		      "non-negative exact integer",
		      1, argc, argv);

  l = SCHEME_INT_VAL(argv[1]);

  if (SCHEME_BIGNUMP(argv[1]) || l < 0 || l >= length)
    bad_index("gl-float-vector-set!", argv[0], argv[1], length);

  ((gl_float_vector*)argv[0])->els[SCHEME_INT_VAL(argv[1])] = scheme_real_to_double(argv[2]);
  return scheme_void;
}

/* 1 argument */
static Scheme_Object* gl_float_vectorP(int argc, Scheme_Object **argv)
{
  if (SCHEME_TYPE(argv[0]) == gl_float_vector_type)
    return scheme_true;
  else
    return scheme_false;
}

/* 2 arguments, gl-float-vectors of equal lengths. */
static Scheme_Object* gl_float_vector_plus(int argc, Scheme_Object **argv)
{
  gl_float_vector* vec;
  int length, i;
  gl_float_vector *v1, *v2;

  check_type("gl-float-vector+", argv[0], 0, argc, argv);
  check_type("gl-float-vector+", argv[1], 1, argc, argv);

  v1 = (gl_float_vector*) argv[0];
  v2 = (gl_float_vector*) argv[1];

  length = v1->length;

  if (length != v2->length)
    length_mismatch("gl-float-vector+", argc, argv, 1);

  vec = make_gl_float_vector(length);
  
  for (i = 0; i < length; ++i)
    vec->els[i] = v1->els[i] + v2->els[i];

  return (Scheme_Object*) vec;  
}

/* 2 arguments, gl-float-vector with equal lengths. */
static Scheme_Object* gl_float_vector_minus(int argc, Scheme_Object **argv)
{
  gl_float_vector* vec;
  int length, i;
  gl_float_vector *v1, *v2;

  check_type("gl-float-vector-", argv[0], 0, argc, argv);
  check_type("gl-float-vector-", argv[1], 1, argc, argv);

  v1 = (gl_float_vector*) argv[0];
  v2 = (gl_float_vector*) argv[1];

  length = v1->length;

  if (length != v2->length)
    length_mismatch("gl-float-vector-", argc, argv, 1);

  vec = make_gl_float_vector(length);
  
  for (i = 0; i < length; ++i)
    vec->els[i] = v1->els[i] - v2->els[i];

  return (Scheme_Object*) vec;  
}

/* 2 arguments, a scheme real and a gl-float-vector */
static Scheme_Object* gl_float_vector_times(int argc, Scheme_Object **argv)
{
  gl_float_vector* vec;
  int length, i;
  GLfloat d;
  gl_float_vector *v0;

  if (!SCHEME_REALP(argv[0]))
    scheme_wrong_type("gl-float-vector-times", "real number", 0, argc, argv);

  check_type("gl-float-vector*", argv[1], 1, argc, argv);

  v0 = (gl_float_vector*) argv[1];

  d = scheme_real_to_double(argv[0]);
  length = v0->length;
  vec = make_gl_float_vector(length);

  for (i = 0; i < length; ++i)
    vec->els[i] = d * v0->els[i];

  return (Scheme_Object*)vec;
}

/* 1 argument, a gl-float-vector */
static Scheme_Object* gl_float_vector_norm(int argc, Scheme_Object **argv)
{
  int length, i;
  GLfloat d;
  gl_float_vector *v;

  check_type("gl-float-vector-norm", argv[0], 0, argc, argv);

  v = (gl_float_vector*) argv[0];
  length = v->length;
  d = 0.0;
  for (i = 0; i < length; ++i)
    d = d + v->els[i] * v->els[i];
  return scheme_make_double(sqrt(d));
}


static void add_func(char *name, Scheme_Env *mod, Scheme_Prim *c_fun, int mina, int maxa)
{
  scheme_add_global(name, scheme_make_prim_w_arity(c_fun, name, mina, maxa), mod);
  return;
}

Scheme_Object *scheme_reload(Scheme_Env *env)
{
  Scheme_Env *mod_env = scheme_primitive_module(scheme_intern_symbol("gl-float-vector"), env);
  
  add_func("vector->gl-float-vector", mod_env, vector_to_gl_float_vector, 1, 1);
  add_func("gl-float-vector->vector", mod_env, gl_float_vector_to_vector, 1, 1);
  add_func("gl-float-vector-length", mod_env, gl_float_vector_length, 1, 1);
  add_func("gl-float-vector-ref", mod_env, gl_float_vector_ref, 2, 2);
  add_func("gl-float-vector-set!", mod_env, gl_float_vector_set, 3, 3);
  add_func("gl-float-vector?", mod_env, gl_float_vectorP, 1, 1);
  add_func("gl-float-vector+", mod_env, gl_float_vector_plus, 2, 2);
  add_func("gl-float-vector-", mod_env, gl_float_vector_minus, 2, 2);
  add_func("gl-float-vector*", mod_env, gl_float_vector_times, 2, 2);
  add_func("gl-float-vector-norm", mod_env, gl_float_vector_norm, 1, 1);
  scheme_add_global("gl-float-vector-internal-type", 
		    scheme_make_integer(gl_float_vector_type),
		    mod_env);

  scheme_finish_primitive_module(mod_env);
  return scheme_void;
}

Scheme_Object *scheme_initialize(Scheme_Env *env)
{
  gl_float_vector_type = scheme_make_type("<gl-float-vector>");
  return scheme_reload(env);
}

Scheme_Object *scheme_module_name()
{
  return scheme_intern_symbol("gl-float-vector");
}




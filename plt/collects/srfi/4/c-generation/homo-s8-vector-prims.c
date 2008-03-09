#include "escheme.h"
#include <math.h>

Scheme_Type homo_s8_vector_type;
#include "homo-s8-vector-prims.h"

char *homo_vector_int32msg = "expected int32, given %V";
char *homo_vector_anytypemsg = "expected s8, given %V";

static int32_t scheme_get_int32(Scheme_Object* o)
{
  long l;
  int result;

  l = 0;

  result = scheme_get_int_val(o, &l);
  if ((result == 0) || (l > 0x7fffffff) || (l < -0x7fffffff))
    scheme_raise_exn(MZEXN_APPLICATION_TYPE,o,scheme_intern_symbol("int32"),
		     homo_vector_int32msg,o);

  return l;
}

/* references to scheme_get(u)int are inserted by the generating function
   that specializes this code by type */

/* to extend this code to handle 64-bit ints, change the return types of 
   these functions: */

static int32_t scheme_get_int(Scheme_Object* o)
{
  long l;
  int result;

  l = 0;

  result = scheme_get_int_val(o, &l);
  if ((result == 0) || (1 && (l > 0x7f || l < -0x80)))
    scheme_raise_exn(MZEXN_APPLICATION_TYPE,o,scheme_intern_symbol("s8"),homo_vector_anytypemsg,o);
  
  return l;
}

static uint32_t scheme_get_uint(Scheme_Object* o)
{
  unsigned long l;
  int result;

  l = 0;

  result = scheme_get_unsigned_int_val(o, &l);
  if ((result == 0) || (1 && (l > 0x7f || l < -0x80)))
    scheme_raise_exn(MZEXN_APPLICATION_TYPE,o,scheme_intern_symbol("s8"),homo_vector_anytypemsg,o);
  
  return l;
}

/* 1 argument, assumes that input is a scheme number */

static Scheme_Object *construct_homo_s8_vector_uninitialized(int argc, Scheme_Object **argv)
{
  int32_t length;
  homo_s8_vector *new_vec;

  length = scheme_get_int32(argv[0]);

  new_vec = make_homo_s8_vector(length);

  return (Scheme_Object *)new_vec;
}

/* 2 arguments, assumest that inputs are two scheme real numbers */

static Scheme_Object *construct_homo_s8_vector(int argc, Scheme_Object **argv)
{
  int32_t length = scheme_get_int32(argv[0]);
  int32_t i;
  int8_t initializer = scheme_get_int(argv[1]);
  homo_s8_vector *new_vec;
  
  new_vec = make_homo_s8_vector(length);

  for (i = 0; i < length; i++) {
    new_vec->els[i] = initializer;
  }

  return (Scheme_Object *)new_vec;
}

/* 1 argument, assumes that input is a vector of Scheme real numbers */
static Scheme_Object* vector_to_homo_s8_vector(int argc, Scheme_Object **argv)
{
  int32_t length, i; 
  Scheme_Object** old_vec;
  homo_s8_vector* new_vec;

  length = SCHEME_VEC_SIZE(argv[0]);
  new_vec = make_homo_s8_vector(length);
  old_vec = SCHEME_VEC_ELS(argv[0]);

  for (i = 0; i < length; ++i) {
    new_vec->els[i] = scheme_get_int(old_vec[i]);
  }
  
  return (Scheme_Object*)new_vec;
}

/* 1 argument, assumes that input is a homo-s8-vector */
static Scheme_Object* homo_s8_vector_to_vector(int argc, Scheme_Object **argv)
{
  Scheme_Object* new_vec;
  int32_t i, length;
  homo_s8_vector* old_vec; 

  old_vec = (homo_s8_vector*)argv[0];
  length = old_vec->length;

  new_vec = scheme_make_vector(old_vec->length, scheme_void);
  for (i = 0; i < length; ++i)
    SCHEME_VEC_ELS(new_vec)[i] = scheme_make_integer_value(old_vec->els[i]);
  return new_vec;
}

/* 1 argument, assumes that input is a homo-s8-vector */
static Scheme_Object* homo_s8_vector_length(int argc, Scheme_Object **argv)
{
  return scheme_make_integer(((homo_s8_vector*)argv[0])->length);
}

/* 2 arguments, assumes first is homo-s8-vector, 2nd is a scheme integer */
static Scheme_Object* homo_s8_vector_ref(int argc, Scheme_Object **argv)
{
  return scheme_make_integer_value(((homo_s8_vector*)argv[0])->els[SCHEME_INT_VAL(argv[1])]);
}

/* 3 arguments: assume homo-s8-vector, scheme integer, scheme real number */
static Scheme_Object* homo_s8_vector_set(int argc, Scheme_Object **argv)
{
  ((homo_s8_vector*)argv[0])->els[SCHEME_INT_VAL(argv[1])] = scheme_get_int(argv[2]);
  return scheme_void;
}

/* 1 argument, no assumptions */
static Scheme_Object* homo_s8_vectorP(int argc, Scheme_Object **argv)
{
  if (SCHEME_TYPE(argv[0]) == homo_s8_vector_type)
    return scheme_true;
  else
    return scheme_false;
}

/* 2 arguments, assume both homo-s8-vector of the same length */
static Scheme_Object* homo_s8_vector_plus(int argc, Scheme_Object **argv)
{
  homo_s8_vector* vec;
  int32_t length, i;
  homo_s8_vector *v1, *v2;

  v1 = (homo_s8_vector*) argv[0];
  v2 = (homo_s8_vector*) argv[1];

  length = v1->length;
  vec = make_homo_s8_vector(length);
  
  for (i = 0; i < length; ++i)
    vec->els[i] = v1->els[i] + v2->els[i];

  return (Scheme_Object*) vec;  
}

/* 2 arguments, assume both homo-s8-vector of the same length */
static Scheme_Object* homo_s8_vector_minus(int argc, Scheme_Object **argv)
{
  homo_s8_vector* vec;
  int32_t length, i;
  homo_s8_vector *v1, *v2;

  v1 = (homo_s8_vector*) argv[0];
  v2 = (homo_s8_vector*) argv[1];

  length = v1->length;
  vec = make_homo_s8_vector(length);
  
  for (i = 0; i < length; ++i)
    vec->els[i] = v1->els[i] - v2->els[i];

  return (Scheme_Object*) vec;  
}

/* 2 arguments, assume first scheme real number, 2nd homo-s8-vector */
static Scheme_Object* homo_s8_vector_times(int argc, Scheme_Object **argv)
{
  homo_s8_vector* vec;
  int32_t length, i;
  int8_t d;
  homo_s8_vector *v0;

  v0 = (homo_s8_vector*) argv[1];

  d = scheme_get_int(argv[0]);
  length = v0->length;
  vec = make_homo_s8_vector(length);

  for (i = 0; i < length; ++i)
    vec->els[i] = d * v0->els[i];

  return (Scheme_Object*)vec;
}

/* 1 argument, homo-s8-vector */
static Scheme_Object* homo_s8_vector_norm(int argc, Scheme_Object **argv)
{
  int32_t length, i;
  int8_t d;
  homo_s8_vector *v;

  v = (homo_s8_vector*) argv[0];
  length = v->length;
  d = 0.0;
  for (i = 0; i < length; ++i)
    d = d + v->els[i] * v->els[i];
  return scheme_make_integer_value(sqrt(d));
}

Scheme_Object *scheme_reload(Scheme_Env *env)
{
  Scheme_Object* funs[13];

  funs[0] = scheme_make_prim_w_arity(vector_to_homo_s8_vector,
				     "vector->s8vector",
				     0, -1);
  funs[1] = scheme_make_prim_w_arity(homo_s8_vector_to_vector,
				     "s8vector->vector",
				     0, -1);
  funs[2] = scheme_make_prim_w_arity(homo_s8_vector_length,
				     "s8vector-length",
				     0, -1);
  funs[3] = scheme_make_prim_w_arity(homo_s8_vector_ref,
				     "s8vector-ref",
				     0, -1);
  funs[4] = scheme_make_prim_w_arity(homo_s8_vector_set,
				     "s8vector-set!",
				     0, -1);
  funs[5] = scheme_make_prim_w_arity(homo_s8_vectorP,
				     "s8vector?",
				     1, 1);
  funs[6] = scheme_make_prim_w_arity(homo_s8_vector_plus,
				     "s8vector-sum",
				     0, -1);
  funs[7] = scheme_make_prim_w_arity(homo_s8_vector_minus,
				     "s8vector-difference",
				     0, -1);
  funs[8] = scheme_make_prim_w_arity(homo_s8_vector_times,
				     "s8vector-scale",
				     0, -1);
  funs[9] = scheme_make_prim_w_arity(homo_s8_vector_norm,
				     "s8vector-norm",
				     0, -1);
  funs[10] = scheme_make_integer(homo_s8_vector_type);
  funs[11] = scheme_make_prim_w_arity(construct_homo_s8_vector_uninitialized,
				      "make-s8vector-uninitialized",
				      1, 1);
  funs[12] = scheme_make_prim_w_arity(construct_homo_s8_vector,
				      "make-s8vector",
				      2, 2);

  return scheme_values(13, funs);
}

Scheme_Object *scheme_initialize(Scheme_Env *env)
{
  homo_s8_vector_type = scheme_make_type("<s8vector>");
  return scheme_reload(env);
}

Scheme_Object *scheme_module_name()
{
  return scheme_false;
}




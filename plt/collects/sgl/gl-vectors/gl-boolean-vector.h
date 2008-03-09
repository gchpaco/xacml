#ifndef _GL_boolean_VECTOR_PRIMS_H
#define _GL_boolean_VECTOR_PRIMS_H

typedef struct 
{
  Scheme_Type type;
  short keyex; /* 1 in low bit indicates immutable */
  int length;
  GLboolean els[1];
} gl_boolean_vector;

static gl_boolean_vector* make_gl_boolean_vector(int length)
{
  gl_boolean_vector* vec;

  vec = (gl_boolean_vector*)scheme_malloc_atomic(sizeof(GLboolean) * length +
						     sizeof(gl_boolean_vector) - sizeof(GLboolean));
  vec->type = gl_boolean_vector_type;
  vec->length = length;
  vec->keyex = 0;
  return vec;
}

static GLboolean *arg_boolean_data(const char *name, Scheme_Object *arg, 
				    unsigned long n,
				    int which, int argc, Scheme_Object** argv)
{
  if (gl_boolean_vector_type == SCHEME_TYPE(arg) &&
      ((gl_boolean_vector *) arg)->length == n)
    return ((gl_boolean_vector *) arg)->els;
  else
  {
    char err_str[128];
    sprintf(err_str, "gl-boolean-vector of length %d", n);
    scheme_wrong_type(name, err_str, which, argc, argv);
  }
  return NULL;
}

#define arg_GLbooleanv(idx, len) \
          ((GLboolean *) arg_boolean_data((char *)p, v[idx], len, idx, c, v))

#endif

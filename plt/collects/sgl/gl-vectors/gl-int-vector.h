#ifndef _GL_int_VECTOR_PRIMS_H
#define _GL_int_VECTOR_PRIMS_H

typedef struct 
{
  Scheme_Type type;
  short keyex; /* 1 in low bit indicates immutable */
  int length;
  GLint els[1];
} gl_int_vector;

static gl_int_vector* make_gl_int_vector(int length)
{
  gl_int_vector* vec;

  vec = (gl_int_vector*)scheme_malloc_atomic(sizeof(GLint) * length +
						     sizeof(gl_int_vector) - sizeof(GLint));
  vec->type = gl_int_vector_type;
  vec->length = length;
  vec->keyex = 0;
  return vec;
}

static GLint *arg_int_data(const char *name, Scheme_Object *arg, 
				    unsigned long n,
				    int which, int argc, Scheme_Object** argv)
{
  if (gl_int_vector_type == SCHEME_TYPE(arg) &&
      ((gl_int_vector *) arg)->length == n)
    return ((gl_int_vector *) arg)->els;
  else
  {
    char err_str[128];
    sprintf(err_str, "gl-int-vector of length %d", n);
    scheme_wrong_type(name, err_str, which, argc, argv);
  }
  return NULL;
}

#define arg_GLintv(idx, len) \
          ((GLint *) arg_int_data((char *)p, v[idx], len, idx, c, v))

#endif

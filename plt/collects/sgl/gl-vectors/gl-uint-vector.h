#ifndef _GL_uint_VECTOR_PRIMS_H
#define _GL_uint_VECTOR_PRIMS_H

typedef struct 
{
  Scheme_Type type;
  short keyex; /* 1 in low bit indicates immutable */
  int length;
  GLuint els[1];
} gl_uint_vector;

static gl_uint_vector* make_gl_uint_vector(int length)
{
  gl_uint_vector* vec;

  vec = (gl_uint_vector*)scheme_malloc_atomic(sizeof(GLuint) * length +
						     sizeof(gl_uint_vector) - sizeof(GLuint));
  vec->type = gl_uint_vector_type;
  vec->length = length;
  vec->keyex = 0;
  return vec;
}

static GLuint *arg_uint_data(const char *name, Scheme_Object *arg, 
				    unsigned long n,
				    int which, int argc, Scheme_Object** argv)
{
  if (gl_uint_vector_type == SCHEME_TYPE(arg) &&
      ((gl_uint_vector *) arg)->length == n)
    return ((gl_uint_vector *) arg)->els;
  else
  {
    char err_str[128];
    sprintf(err_str, "gl-uint-vector of length %d", n);
    scheme_wrong_type(name, err_str, which, argc, argv);
  }
  return NULL;
}

#define arg_GLuintv(idx, len) \
          ((GLuint *) arg_uint_data((char *)p, v[idx], len, idx, c, v))

#endif

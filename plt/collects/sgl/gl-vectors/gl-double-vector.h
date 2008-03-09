#ifndef _GL_double_VECTOR_PRIMS_H
#define _GL_double_VECTOR_PRIMS_H

typedef struct 
{
  Scheme_Type type;
  short keyex; /* 1 in low bit indicates immutable */
  int length;
  GLdouble els[1];
} gl_double_vector;

static gl_double_vector* make_gl_double_vector(int length)
{
  gl_double_vector* vec;

  vec = (gl_double_vector*)scheme_malloc_atomic(sizeof(GLdouble) * length +
						     sizeof(gl_double_vector) - sizeof(GLdouble));
  vec->type = gl_double_vector_type;
  vec->length = length;
  vec->keyex = 0;
  return vec;
}

static GLdouble *arg_double_data(const char *name, Scheme_Object *arg, 
				    unsigned long n,
				    int which, int argc, Scheme_Object** argv)
{
  if (gl_double_vector_type == SCHEME_TYPE(arg) &&
      ((gl_double_vector *) arg)->length == n)
    return ((gl_double_vector *) arg)->els;
  else
  {
    char err_str[128];
    sprintf(err_str, "gl-double-vector of length %d", n);
    scheme_wrong_type(name, err_str, which, argc, argv);
  }
  return NULL;
}

#define arg_GLdoublev(idx, len) \
          ((GLdouble *) arg_double_data((char *)p, v[idx], len, idx, c, v))

#endif

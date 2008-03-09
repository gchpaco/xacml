#ifndef _GL_float_VECTOR_PRIMS_H
#define _GL_float_VECTOR_PRIMS_H

typedef struct 
{
  Scheme_Type type;
  short keyex; /* 1 in low bit indicates immutable */
  int length;
  GLfloat els[1];
} gl_float_vector;

static gl_float_vector* make_gl_float_vector(int length)
{
  gl_float_vector* vec;

  vec = (gl_float_vector*)scheme_malloc_atomic(sizeof(GLfloat) * length +
						     sizeof(gl_float_vector) - sizeof(GLfloat));
  vec->type = gl_float_vector_type;
  vec->length = length;
  vec->keyex = 0;
  return vec;
}

static GLfloat *arg_float_data(const char *name, Scheme_Object *arg, 
				    unsigned long n,
				    int which, int argc, Scheme_Object** argv)
{
  if (gl_float_vector_type == SCHEME_TYPE(arg) &&
      ((gl_float_vector *) arg)->length == n)
    return ((gl_float_vector *) arg)->els;
  else
  {
    char err_str[128];
    sprintf(err_str, "gl-float-vector of length %d", n);
    scheme_wrong_type(name, err_str, which, argc, argv);
  }
  return NULL;
}

#define arg_GLfloatv(idx, len) \
          ((GLfloat *) arg_float_data((char *)p, v[idx], len, idx, c, v))

#endif

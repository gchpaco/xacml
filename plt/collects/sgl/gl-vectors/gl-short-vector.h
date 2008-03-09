#ifndef _GL_short_VECTOR_PRIMS_H
#define _GL_short_VECTOR_PRIMS_H

typedef struct 
{
  Scheme_Type type;
  short keyex; /* 1 in low bit indicates immutable */
  int length;
  GLshort els[1];
} gl_short_vector;

static gl_short_vector* make_gl_short_vector(int length)
{
  gl_short_vector* vec;

  vec = (gl_short_vector*)scheme_malloc_atomic(sizeof(GLshort) * length +
						     sizeof(gl_short_vector) - sizeof(GLshort));
  vec->type = gl_short_vector_type;
  vec->length = length;
  vec->keyex = 0;
  return vec;
}

static GLshort *arg_short_data(const char *name, Scheme_Object *arg, 
				    unsigned long n,
				    int which, int argc, Scheme_Object** argv)
{
  if (gl_short_vector_type == SCHEME_TYPE(arg) &&
      ((gl_short_vector *) arg)->length == n)
    return ((gl_short_vector *) arg)->els;
  else
  {
    char err_str[128];
    sprintf(err_str, "gl-short-vector of length %d", n);
    scheme_wrong_type(name, err_str, which, argc, argv);
  }
  return NULL;
}

#define arg_GLshortv(idx, len) \
          ((GLshort *) arg_short_data((char *)p, v[idx], len, idx, c, v))

#endif

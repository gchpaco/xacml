#ifndef _GL_ushort_VECTOR_PRIMS_H
#define _GL_ushort_VECTOR_PRIMS_H

typedef struct 
{
  Scheme_Type type;
  short keyex; /* 1 in low bit indicates immutable */
  int length;
  GLushort els[1];
} gl_ushort_vector;

static gl_ushort_vector* make_gl_ushort_vector(int length)
{
  gl_ushort_vector* vec;

  vec = (gl_ushort_vector*)scheme_malloc_atomic(sizeof(GLushort) * length +
						     sizeof(gl_ushort_vector) - sizeof(GLushort));
  vec->type = gl_ushort_vector_type;
  vec->length = length;
  vec->keyex = 0;
  return vec;
}

static GLushort *arg_ushort_data(const char *name, Scheme_Object *arg, 
				    unsigned long n,
				    int which, int argc, Scheme_Object** argv)
{
  if (gl_ushort_vector_type == SCHEME_TYPE(arg) &&
      ((gl_ushort_vector *) arg)->length == n)
    return ((gl_ushort_vector *) arg)->els;
  else
  {
    char err_str[128];
    sprintf(err_str, "gl-ushort-vector of length %d", n);
    scheme_wrong_type(name, err_str, which, argc, argv);
  }
  return NULL;
}

#define arg_GLushortv(idx, len) \
          ((GLushort *) arg_ushort_data((char *)p, v[idx], len, idx, c, v))

#endif

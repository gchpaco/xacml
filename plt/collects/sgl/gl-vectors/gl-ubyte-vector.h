#ifndef _GL_ubyte_VECTOR_PRIMS_H
#define _GL_ubyte_VECTOR_PRIMS_H

typedef struct 
{
  Scheme_Type type;
  short keyex; /* 1 in low bit indicates immutable */
  int length;
  GLubyte els[1];
} gl_ubyte_vector;

static gl_ubyte_vector* make_gl_ubyte_vector(int length)
{
  gl_ubyte_vector* vec;

  vec = (gl_ubyte_vector*)scheme_malloc_atomic(sizeof(GLubyte) * length +
						     sizeof(gl_ubyte_vector) - sizeof(GLubyte));
  vec->type = gl_ubyte_vector_type;
  vec->length = length;
  vec->keyex = 0;
  return vec;
}

static GLubyte *arg_ubyte_data(const char *name, Scheme_Object *arg, 
				    unsigned long n,
				    int which, int argc, Scheme_Object** argv)
{
  if (gl_ubyte_vector_type == SCHEME_TYPE(arg) &&
      ((gl_ubyte_vector *) arg)->length == n)
    return ((gl_ubyte_vector *) arg)->els;
  else
  {
    char err_str[128];
    sprintf(err_str, "gl-ubyte-vector of length %d", n);
    scheme_wrong_type(name, err_str, which, argc, argv);
  }
  return NULL;
}

#define arg_GLubytev(idx, len) \
          ((GLubyte *) arg_ubyte_data((char *)p, v[idx], len, idx, c, v))

#endif

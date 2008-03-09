#ifndef _GL_byte_VECTOR_PRIMS_H
#define _GL_byte_VECTOR_PRIMS_H

typedef struct 
{
  Scheme_Type type;
  short keyex; /* 1 in low bit indicates immutable */
  int length;
  GLbyte els[1];
} gl_byte_vector;

static gl_byte_vector* make_gl_byte_vector(int length)
{
  gl_byte_vector* vec;

  vec = (gl_byte_vector*)scheme_malloc_atomic(sizeof(GLbyte) * length +
						     sizeof(gl_byte_vector) - sizeof(GLbyte));
  vec->type = gl_byte_vector_type;
  vec->length = length;
  vec->keyex = 0;
  return vec;
}

static GLbyte *arg_byte_data(const char *name, Scheme_Object *arg, 
				    unsigned long n,
				    int which, int argc, Scheme_Object** argv)
{
  if (gl_byte_vector_type == SCHEME_TYPE(arg) &&
      ((gl_byte_vector *) arg)->length == n)
    return ((gl_byte_vector *) arg)->els;
  else
  {
    char err_str[128];
    sprintf(err_str, "gl-byte-vector of length %d", n);
    scheme_wrong_type(name, err_str, which, argc, argv);
  }
  return NULL;
}

#define arg_GLbytev(idx, len) \
          ((GLbyte *) arg_byte_data((char *)p, v[idx], len, idx, c, v))

#endif

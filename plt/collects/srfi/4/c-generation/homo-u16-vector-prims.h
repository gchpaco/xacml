#ifndef _HOMO_u16_VECTOR_PRIMS_H
#define _HOMO_u16_VECTOR_PRIMS_H


#ifdef _WIN32 
/* Windows isn't C99 in this regard */
#include <wtypes.h>
typedef UINT32 uint32_t;
typedef UINT16 uint16_t;
typedef UINT8 uint8_t;
typedef INT32 int32_t;
typedef INT16 int16_t;
typedef INT8 int8_t;  
#else
#include <inttypes.h>
#endif

typedef struct 
{
  Scheme_Type type;
  short keyex; /* 1 in low bit indicates immutable */
  int length;
  uint16_t els[1];
} homo_u16_vector;


extern Scheme_Type homo_u16_vector_type;


static homo_u16_vector* make_homo_u16_vector(int length)
{
  homo_u16_vector* vec;

  vec = (homo_u16_vector*)scheme_malloc_atomic(sizeof(uint16_t) * length + sizeof(homo_u16_vector) - sizeof(uint16_t));
  vec->type = homo_u16_vector_type;
  vec->length = length;
  vec->keyex = 0;
  return vec;
}

#define HOMO_U16_VECTORP(obj)   SAME_TYPE(SCHEME_TYPE(obj), homo_u16_vector_type)



#endif

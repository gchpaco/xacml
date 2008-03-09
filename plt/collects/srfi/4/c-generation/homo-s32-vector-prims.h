#ifndef _HOMO_s32_VECTOR_PRIMS_H
#define _HOMO_s32_VECTOR_PRIMS_H


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
  int32_t els[1];
} homo_s32_vector;


extern Scheme_Type homo_s32_vector_type;


static homo_s32_vector* make_homo_s32_vector(int length)
{
  homo_s32_vector* vec;

  vec = (homo_s32_vector*)scheme_malloc_atomic(sizeof(int32_t) * length + sizeof(homo_s32_vector) - sizeof(int32_t));
  vec->type = homo_s32_vector_type;
  vec->length = length;
  vec->keyex = 0;
  return vec;
}

#define HOMO_S32_VECTORP(obj)   SAME_TYPE(SCHEME_TYPE(obj), homo_s32_vector_type)



#endif

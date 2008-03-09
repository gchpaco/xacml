#include "homo-f64-vector-glue.c"
#include "homo-f32-vector-glue.c"
#include "homo-s32-vector-glue.c"
#include "homo-s16-vector-glue.c"
#include "homo-s8-vector-glue.c"
#include "homo-u32-vector-glue.c"
#include "homo-u16-vector-glue.c"
#include "homo-u8-vector-glue.c"

Scheme_Object *set_all_vector_types(int argc, Scheme_Object **argv)
{
  set_homo_f64_vector_type(argc, argv);
  set_homo_f32_vector_type(argc, argv);
  set_homo_s32_vector_type(argc, argv);
  set_homo_s16_vector_type(argc, argv);
  set_homo_s8_vector_type(argc, argv);
  set_homo_u32_vector_type(argc, argv);
  set_homo_u16_vector_type(argc, argv);
  set_homo_u8_vector_type(argc, argv);


  return scheme_false;
}

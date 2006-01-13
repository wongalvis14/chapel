#ifndef _PRIMITIVE_H_
#define _PRIMITIVE_H_

#include "vec.h"
#include "map.h"

class InterpreterOp;
class AnalysisOp;

enum PrimitiveKind {
  PRIMITIVE_NONE = 0,   // use only for CallExprs which are NOT primitives
  PRIMITIVE_UNKNOWN,    // use for any primitives not in this list
  PRIMITIVE_INIT,
  PRIMITIVE_SIZEOF,
  PRIMITIVE_FOPEN,
  PRIMITIVE_FCLOSE,
  PRIMITIVE_STRERROR,
  PRIMITIVE_FPRINTF,
  PRIMITIVE_FSCANF,
  PRIMITIVE_ARRAY_INDEX,
  PRIMITIVE_ARRAY_SET,
  PRIMITIVE_UNARY_MINUS,
  PRIMITIVE_UNARY_PLUS,
  PRIMITIVE_UNARY_BNOT,
  PRIMITIVE_UNARY_NOT,
  PRIMITIVE_ADD,
  PRIMITIVE_SUBTRACT,
  PRIMITIVE_MULT,
  PRIMITIVE_DIV,
  PRIMITIVE_MOD,
  PRIMITIVE_EQUAL,
  PRIMITIVE_NOTEQUAL,
  PRIMITIVE_ELSSOREQUAL,
  PRIMITIVE_GREATEROREQUAL,
  PRIMITIVE_LESS,
  PRIMITIVE_GREATER,
  PRIMITIVE_AND,
  PRIMITIVE_OR,
  PRIMITIVE_XOR,
  PRIMITIVE_LAND,
  PRIMITIVE_LOR,
  PRIMITIVE_EXP,
  PRIMITIVE_GET_MEMBER,
  PRIMITIVE_SET_MEMBER,
  PRIMITIVE_PTR_EQ,
  PRIMITIVE_PTR_NEQ,
  PRIMITIVE_CAST,
  PRIMITIVE_TO_STRING,
  PRIMITIVE_COPY_STRING,
  PRIMITIVE_STRING_INDEX,
  PRIMITIVE_STRING_CONCAT,
  PRIMITIVE_STRING_EQUAL,
  PRIMITIVE_STRING_SELECT,
  PRIMITIVE_STRING_STRIDED_SELECT,
  PRIMITIVE_STRING_LENGTH,
  PRIMITIVE_CHPL_ALLOC,
  PRIMITIVE_EXIT,
  PRIMITIVE_HALT,
  PRIMITIVE_ASSERT
};

class PrimitiveOp : public gc { public:
  PrimitiveKind kind;
  char *name;
  InterpreterOp *interpreterOp;
  AnalysisOp *analysisOp;

  PrimitiveOp(PrimitiveKind akind, char *aname, InterpreterOp *aiop, AnalysisOp *aaop);
};

extern Vec<PrimitiveOp *> primitives;
extern HashMap<char *, StringHashFns, PrimitiveOp *> primitives_map;

extern PrimitiveOp* prim_move;

void initPrimitive();

#endif

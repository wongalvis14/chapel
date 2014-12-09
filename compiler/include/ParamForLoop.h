/*
 * Copyright 2004-2014 Cray Inc.
 * Other additional copyright holders may be indicated within.
 *
 * The entirety of this work is licensed under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 *
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef _PARAM_FOR_LOOP_H_
#define _PARAM_FOR_LOOP_H_

#include "LoopStmt.h"

class ParamForLoop : public LoopStmt
{
  //
  // Class interface
  //
public:
  static BlockStmt*      buildParamForLoop(VarSymbol* indexVar,
                                           Expr*      range,
                                           BlockStmt* stmts);

private:
  static VarSymbol*      newParamVar();


  //
  // Instance Interface
  //
public:
                         ParamForLoop(VarSymbol*   indexVar,
                                      VarSymbol*   low,
                                      VarSymbol*   high,
                                      VarSymbol*   stride,
                                      LabelSymbol* breakLabel,
                                      BlockStmt*   initBody);
  virtual               ~ParamForLoop();

  virtual Expr*          getFirstExpr();
  virtual Expr*          getNextExpr(Expr* expr);

  virtual bool           isParamForLoop()                             const;

  virtual CallExpr*      blockInfoGet()                               const;
  virtual CallExpr*      blockInfoSet(CallExpr* expr);

  CallExpr*              paramInfoGet()                               const;

private:
                         ParamForLoop();

  VarSymbol*             mIndexVariable;
  VarSymbol*             mLowVariable;
  VarSymbol*             mHighVariable;
  VarSymbol*             mStrideVariable;
};

#endif


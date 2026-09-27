//===-- BoingusTargetMachine.cpp - Define TargetMachine for Boingus -*-*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "TargetInfo/BoingusTargetInfo.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/Compiler.h"

using namespace llvm;

extern "C" LLVM_ABI LLVM_EXTERNAL_VISIBILITY void
LLVMInitializeBoingusTarget() {
  // TODO: once BoingusTargetMachine exists (see ARCTargetMachine.cpp):
  //   RegisterTargetMachine<BoingusTargetMachine> X(getTheBoingusTarget());
  // and initialize the ISel / AsmPrinter passes here.
  //
  // Until then, `llc -mtriple=boingus` reports that it can't create a target
  // machine.
}

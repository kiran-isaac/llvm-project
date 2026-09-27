//===-- BoingusTargetInfo.cpp - Boingus Target Implementation -*-*- C++ -*-===//
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

Target &llvm::getTheBoingusTarget() {
  static Target TheBoingusTarget;
  return TheBoingusTarget;
}

extern "C" LLVM_ABI LLVM_EXTERNAL_VISIBILITY void
LLVMInitializeBoingusTargetInfo() {
  RegisterTarget<Triple::boingus> X(getTheBoingusTarget(), "boingus",
                                    "Boingus (experimental)", "Boingus");
}

//===-- BoingusISelLowering.h - Boingus DAG Lowering Interface --*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_BOINGUS_BOINGUSISELLOWERING_H
#define LLVM_LIB_TARGET_BOINGUS_BOINGUSISELLOWERING_H

#include "llvm/CodeGen/TargetLowering.h"

namespace llvm {

class BoingusSubtarget;

class BoingusTargetLowering : public TargetLowering {
public:
  BoingusTargetLowering(const TargetMachine &TM, const BoingusSubtarget &STI);

  // TODO: override as the backend grows (see learning/TRACE.md 1.2):
  //   LowerFormalArguments - incoming arguments (A0-A7)
  //   LowerReturn          - return value (A0/A1) + return instruction
  //   LowerCall            - outgoing calls
  //   LowerOperation       - for anything marked Custom in the constructor
};

} // namespace llvm

#endif // LLVM_LIB_TARGET_BOINGUS_BOINGUSISELLOWERING_H

//===-- BoingusInstrInfo.h - Boingus Instruction Information ----*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_BOINGUS_BOINGUSINSTRINFO_H
#define LLVM_LIB_TARGET_BOINGUS_BOINGUSINSTRINFO_H

#include "BoingusRegisterInfo.h"
#include "llvm/CodeGen/TargetInstrInfo.h"

#define GET_INSTRINFO_HEADER
#include "BoingusGenInstrInfo.inc"

namespace llvm {

class BoingusSubtarget;

class BoingusInstrInfo : public BoingusGenInstrInfo {
  const BoingusRegisterInfo RI;
  virtual void anchor();

public:
  explicit BoingusInstrInfo(const BoingusSubtarget &STI);

  const BoingusRegisterInfo &getRegisterInfo() const { return RI; }

  // TODO: override as the backend grows:
  //   copyPhysReg            - register-to-register move (needed almost at once)
  //   storeRegToStackSlot /
  //   loadRegFromStackSlot   - spills and reloads
  //   analyzeBranch / insertBranch / removeBranch - branch optimizations
};

} // namespace llvm

#endif // LLVM_LIB_TARGET_BOINGUS_BOINGUSINSTRINFO_H

//===-- BoingusFrameLowering.h - Define frame lowering for Boingus ----*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_BOINGUS_BOINGUSFRAMELOWERING_H
#define LLVM_LIB_TARGET_BOINGUS_BOINGUSFRAMELOWERING_H

#include "llvm/CodeGen/TargetFrameLowering.h"

namespace llvm {

class BoingusSubtarget;

class BoingusFrameLowering : public TargetFrameLowering {
public:
  explicit BoingusFrameLowering(const BoingusSubtarget &STI);

  // Code at the start/end of every function: set up and tear down the stack
  // frame, save/restore LR and callee-saved registers.
  void emitPrologue(MachineFunction &MF, MachineBasicBlock &MBB) const override;
  void emitEpilogue(MachineFunction &MF, MachineBasicBlock &MBB) const override;

protected:
  // Does this function need a frame pointer?
  bool hasFPImpl(const MachineFunction &MF) const override;
};

} // namespace llvm

#endif // LLVM_LIB_TARGET_BOINGUS_BOINGUSFRAMELOWERING_H

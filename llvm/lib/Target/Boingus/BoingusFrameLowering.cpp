//===-- BoingusFrameLowering.cpp - Boingus Frame Information --------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "BoingusFrameLowering.h"
#include "BoingusSubtarget.h"
#include "llvm/CodeGen/MachineFunction.h"

using namespace llvm;

// Stack grows down, 16-byte aligned (matches "S128" in the data layout),
// no local area offset.
BoingusFrameLowering::BoingusFrameLowering(const BoingusSubtarget &STI)
    : TargetFrameLowering(StackGrowsDown, Align(16), /*LocalAreaOffset=*/0) {}

void BoingusFrameLowering::emitPrologue(MachineFunction &MF,
                                        MachineBasicBlock &MBB) const {
  // TODO: allocate the frame (SP -= size), save LR/FP if needed.
  // Empty is fine for functions that don't use the stack.
}

void BoingusFrameLowering::emitEpilogue(MachineFunction &MF,
                                        MachineBasicBlock &MBB) const {
  // TODO: undo the prologue.
}

bool BoingusFrameLowering::hasFPImpl(const MachineFunction &MF) const {
  return false;
}

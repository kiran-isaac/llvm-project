//===-- BoingusRegisterInfo.h - Boingus Register Information Impl ---*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_BOINGUS_BOINGUSREGISTERINFO_H
#define LLVM_LIB_TARGET_BOINGUS_BOINGUSREGISTERINFO_H

#include "llvm/CodeGen/TargetRegisterInfo.h"

#define GET_REGINFO_HEADER
#include "BoingusGenRegisterInfo.inc"

namespace llvm {

class BoingusRegisterInfo : public BoingusGenRegisterInfo {
public:
  BoingusRegisterInfo();

  // Registers a function must preserve (callee-saved, from BoingusCC).
  const MCPhysReg *getCalleeSavedRegs(const MachineFunction *MF) const override;

  // Registers the register allocator must never hand out.
  BitVector getReservedRegs(const MachineFunction &MF) const override;

  // Rewrite a stack-slot reference (frame index) into SP/FP + offset.
  bool eliminateFrameIndex(MachineBasicBlock::iterator II, int SPAdj,
                           unsigned FIOperandNum,
                           RegScavenger *RS = nullptr) const override;

  Register getFrameRegister(const MachineFunction &MF) const override;
};

} // namespace llvm

#endif // LLVM_LIB_TARGET_BOINGUS_BOINGUSREGISTERINFO_H

//===-- BoingusRegisterInfo.cpp - Boingus Register Information ------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "BoingusRegisterInfo.h"
#include "BoingusSubtarget.h"
#include "MCTargetDesc/BoingusMCTargetDesc.h"
#include "llvm/ADT/BitVector.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/Support/ErrorHandling.h"

using namespace llvm;

#define GET_REGINFO_TARGET_DESC
#include "BoingusGenRegisterInfo.inc"

// LR is the return-address register.
BoingusRegisterInfo::BoingusRegisterInfo() : BoingusGenRegisterInfo(Boingus::LR) {}

const MCPhysReg *
BoingusRegisterInfo::getCalleeSavedRegs(const MachineFunction *MF) const {
  // S0-S11 (R17-R28) and FP, per BoingusCC. Zero-terminated.
  // TODO: replace with CSR_Boingus_SaveList once BoingusCallingConv.td exists.
  static const MCPhysReg CalleeSavedRegs[] = {
      Boingus::R17, Boingus::R18, Boingus::R19, Boingus::R20, Boingus::R21,
      Boingus::R22, Boingus::R23, Boingus::R24, Boingus::R25, Boingus::R26,
      Boingus::R27, Boingus::R28, Boingus::FP,  0};
  return CalleeSavedRegs;
}

BitVector BoingusRegisterInfo::getReservedRegs(const MachineFunction &MF) const {
  BitVector Reserved(getNumRegs());
  Reserved.set(Boingus::Z);
  Reserved.set(Boingus::SP);
  Reserved.set(Boingus::FP);
  Reserved.set(Boingus::LR);
  return Reserved;
}

bool BoingusRegisterInfo::eliminateFrameIndex(MachineBasicBlock::iterator II,
                                              int SPAdj, unsigned FIOperandNum,
                                              RegScavenger *RS) const {
  // TODO: needed once functions use the stack (locals, spills).
  report_fatal_error("Boingus: eliminateFrameIndex not implemented yet");
}

Register BoingusRegisterInfo::getFrameRegister(const MachineFunction &MF) const {
  return Boingus::FP;
}

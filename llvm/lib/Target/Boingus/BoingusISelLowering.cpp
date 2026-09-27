//===-- BoingusISelLowering.cpp - Boingus DAG Lowering Implementation -----===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "BoingusISelLowering.h"
#include "BoingusSubtarget.h"
#include "MCTargetDesc/BoingusMCTargetDesc.h"

using namespace llvm;

#define DEBUG_TYPE "boingus-lower"

BoingusTargetLowering::BoingusTargetLowering(const TargetMachine &TM,
                                             const BoingusSubtarget &STI)
    : TargetLowering(TM, STI) {
  // i32 values live in GPRs; that makes i32 the only legal integer type.
  addRegisterClass(MVT::i32, &Boingus::GPRRegClass);
  computeRegisterProperties(STI.getRegisterInfo());

  setStackPointerRegisterToSaveRestore(Boingus::SP);

  // TODO: setOperationAction(...) for everything Boingus can't do directly,
  // e.g. setOperationAction(ISD::MUL, MVT::i32, LibCall);
}

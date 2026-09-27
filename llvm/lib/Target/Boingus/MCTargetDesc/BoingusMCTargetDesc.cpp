//===-- BoingusMCTargetDesc.cpp - Boingus Target Descriptions -*-*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "BoingusMCTargetDesc.h"
#include "BoingusMCAsmInfo.h"
#include "TargetInfo/BoingusTargetInfo.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/Compiler.h"

using namespace llvm;

#define GET_INSTRINFO_MC_DESC
#include "BoingusGenInstrInfo.inc"

#define GET_SUBTARGETINFO_MC_DESC
#include "BoingusGenSubtargetInfo.inc"

#define GET_REGINFO_MC_DESC
#include "BoingusGenRegisterInfo.inc"

static MCInstrInfo *createBoingusMCInstrInfo() {
  auto *X = new MCInstrInfo();
  InitBoingusMCInstrInfo(X);
  return X;
}

static MCRegisterInfo *createBoingusMCRegisterInfo(const Triple &TT) {
  auto *X = new MCRegisterInfo();
  // Second argument is the return-address register.
  InitBoingusMCRegisterInfo(X, Boingus::LR);
  return X;
}

static MCSubtargetInfo *
createBoingusMCSubtargetInfo(const Triple &TT, StringRef CPU, StringRef FS) {
  if (CPU.empty())
    CPU = "generic";
  return createBoingusMCSubtargetInfoImpl(TT, CPU, /*TuneCPU=*/CPU, FS);
}

static MCAsmInfo *createBoingusMCAsmInfo(const MCRegisterInfo &MRI,
                                         const Triple &TT,
                                         const MCTargetOptions &Options) {
  return new BoingusMCAsmInfo(TT);
}

extern "C" LLVM_ABI LLVM_EXTERNAL_VISIBILITY void
LLVMInitializeBoingusTargetMC() {
  Target &T = getTheBoingusTarget();
  RegisterMCAsmInfoFn X(T, createBoingusMCAsmInfo);
  TargetRegistry::RegisterMCInstrInfo(T, createBoingusMCInstrInfo);
  TargetRegistry::RegisterMCRegInfo(T, createBoingusMCRegisterInfo);
  TargetRegistry::RegisterMCSubtargetInfo(T, createBoingusMCSubtargetInfo);
  // TODO: RegisterMCInstPrinter once BoingusInstPrinter exists.
  // Later, for object files: RegisterMCCodeEmitter, RegisterMCAsmBackend.
}

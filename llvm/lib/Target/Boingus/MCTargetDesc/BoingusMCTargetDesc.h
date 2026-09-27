//===-- BoingusMCTargetDesc.h - Boingus Target Descriptions -*-*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_BOINGUS_MCTARGETDESC_BOINGUSMCTARGETDESC_H
#define LLVM_LIB_TARGET_BOINGUS_MCTARGETDESC_BOINGUSMCTARGETDESC_H

// Defines symbolic names for Boingus registers, instructions and subtarget
// features (Boingus::R0, Boingus::ADD, ...).
#define GET_REGINFO_ENUM
#include "BoingusGenRegisterInfo.inc"

#define GET_INSTRINFO_ENUM
#define GET_INSTRINFO_MC_HELPER_DECLS
#include "BoingusGenInstrInfo.inc"

#define GET_SUBTARGETINFO_ENUM
#include "BoingusGenSubtargetInfo.inc"

#endif // LLVM_LIB_TARGET_BOINGUS_MCTARGETDESC_BOINGUSMCTARGETDESC_H

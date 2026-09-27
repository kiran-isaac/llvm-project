//===-- BoingusInstrInfo.cpp - Boingus Instruction Information ------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "BoingusInstrInfo.h"
#include "BoingusSubtarget.h"
#include "MCTargetDesc/BoingusMCTargetDesc.h"

using namespace llvm;

#define GET_INSTRINFO_CTOR_DTOR
#include "BoingusGenInstrInfo.inc"

void BoingusInstrInfo::anchor() {}

BoingusInstrInfo::BoingusInstrInfo(const BoingusSubtarget &STI)
    : BoingusGenInstrInfo(STI, RI), RI() {}

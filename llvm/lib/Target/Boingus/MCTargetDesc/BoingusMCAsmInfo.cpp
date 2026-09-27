//===-- BoingusMCAsmInfo.cpp - Boingus asm properties -----*-*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "BoingusMCAsmInfo.h"

using namespace llvm;

void BoingusMCAsmInfo::anchor() {}

BoingusMCAsmInfo::BoingusMCAsmInfo(const Triple &TT) {
  CodePointerSize = 4;
  CalleeSaveStackSlotSize = 4;
  CommentString = "#";
  Data32bitsDirective = "\t.word\t";
}

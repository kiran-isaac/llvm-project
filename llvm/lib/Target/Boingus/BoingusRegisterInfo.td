//===-- BoingusRegisterInfo.td - Boingus Register defs ------*-*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// PLACEHOLDER register file: 16 x 32-bit general purpose registers r0-r15.
// Replace with the real Boingus registers. Pick which ones are the stack
// pointer, return address, zero register, etc. when you write
// BoingusRegisterInfo.cpp (getReservedRegs, getCalleeSavedRegs, ...).

class BoingusReg<bits<16> Enc, string n> : Register<n> {
  let HWEncoding = Enc;
  let Namespace = "Boingus";
}

foreach I = 0-15 in
  def R#I : BoingusReg<I, "r"#I>, DwarfRegNum<[I]>;

def GPR : RegisterClass<"Boingus", [i32], 32, (sequence "R%u", 0, 15)>;

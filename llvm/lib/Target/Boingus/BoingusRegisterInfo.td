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

class BoingusReg<bits<16> Enc, string n, list<string> altNames> : Register<n, altNames> {
  let HWEncoding = Enc;
  let Namespace = "Boingus";
}

def Z : BoingusReg<0, "z", ["r0"]>;

foreach I = 1-28 in
  def R#I : BoingusReg<I, "r"#I, []>;

def SP : BoingusReg<29, "SP", ["r29"]>;
def FP : BoingusReg<30, "FP", ["r30"]>;
def LR : BoingusReg<31, "LR", ["r31"]>;

// General Purpose Registers
def GPR : RegisterClass<"Boingus", [i32], 32, (sequence "R%u", 1, 28)>;
// All the registers that can be an operand to an instr
def Operands : RegisterClass<"Boingus", [i32], 32, (add Z, (sequence "R%u", 1, 28), SP, FP, LR)>;
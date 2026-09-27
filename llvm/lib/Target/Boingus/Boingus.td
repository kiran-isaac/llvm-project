//===-- Boingus.td - Describe the Boingus Target Machine ----*-*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

include "llvm/Target/Target.td"

//===----------------------------------------------------------------------===//
// Subtarget features (e.g. optional ISA extensions) go here, like RISC-V's
// FeatureStdExtZba in RISCVFeatures.td.
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Register file, instructions, calling convention
//===----------------------------------------------------------------------===//

include "BoingusRegisterInfo.td"
include "BoingusInstrInfo.td"
// include "BoingusCallingConv.td"

// Generic pseudos with pointer operands (e.g. for stack slots) use GPR.
defm : RemapAllTargetPseudoPointerOperands<GPR>;

def BoingusInstrInfo : InstrInfo;

//===----------------------------------------------------------------------===//
// Processors
//===----------------------------------------------------------------------===//

def : ProcessorModel<"generic", NoSchedModel, []>;

//===----------------------------------------------------------------------===//
// Target
//===----------------------------------------------------------------------===//

def Boingus : Target {
  let InstructionSet = BoingusInstrInfo;
}

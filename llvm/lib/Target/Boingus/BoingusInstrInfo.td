//===-- BoingusInstrInfo.td - Target Description for Boingus --*-*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// Instruction definitions and selection patterns go here. Start with the
// minimum from learning/: add, add-immediate, load/store word,
// load-immediate, move, compare-and-branch, jump, return.

class BoingusInst<dag outs, dag ins, string asmstr, list<dag> pattern>
    : Instruction {
  let Namespace = "Boingus";
  let OutOperandList = outs;
  let InOperandList = ins;
  let AsmString = asmstr;
  let Pattern = pattern;
  let Size = 4;
}

// PLACEHOLDER: TableGen refuses a target with no instructions. Replace with
// real ones, e.g.:
//
//   def ADD : BoingusInst<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
//                         "add\t$rd, $rs1, $rs2",
//                         [(set GPR:$rd, (add GPR:$rs1, GPR:$rs2))]>;
let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def NOP : BoingusInst<(outs), (ins), "nop", []>;

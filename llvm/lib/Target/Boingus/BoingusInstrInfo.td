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

// All formats below describe one 32-bit instruction. Layout comments run from
// bit 31 (the most-significant bit) on the left to bit 0 on the right. Field
// names follow Boingus.md: R, N, and M are register slots, A is an address or
// PC-relative offset, I is an immediate, and O is a shift amount.

class BoingusInst<dag outs, dag ins, string asmstr, list<dag> pattern>
    : Instruction {
  let Namespace = "Boingus";
  let OutOperandList = outs;
  let InOperandList = ins;
  let AsmString = asmstr;
  let Pattern = pattern;
  let Size = 4;

  field bits<32> Inst;
}

// rrr: [31:29] 000 | [28:15] opcode | [14:10] R | [9:5] N | [4:0] M
class BoingusInstRRR<bits<14> op, dag outs, dag ins, string asmstr, 
                     list<dag> pattern> :
  BoingusInst<outs, ins, asmstr, pattern>  {
  bits<5> R;
  bits<5> N;
  bits<5> M;
  let Inst{31-29} = 0b000;
  let Inst{28-15} = op;
  let Inst{14-10} = R;
  let Inst{9-5} = N;
  let Inst{4-0} = M;
}

// rr: [31:29] 001 | [28:10] opcode | [9:5] R | [4:0] N
class BoingusInstRR<bits<19> op, dag outs, dag ins, string asmstr, 
                     list<dag> pattern> :
  BoingusInst<outs, ins, asmstr, pattern> {
  bits<5> R;
  bits<5> N;
  let Inst{31-29} = 0b001;
  let Inst{28-10} = op;
  let Inst{9-5} = R;
  let Inst{4-0} = N;
}

// rru12 header: [31:30] 01 | [29:24] opcode | [23:22] access size
// Access sizes: 00 = 1 byte, 01 = 2 bytes, and 10 = 4 bytes. 11 is reserved.
// The instruction definitions determine how the raw 12-bit offset is signed
// and scaled for each access size.
class BoingusInstRRu12<bits<6> op, bits<2> size_code, dag outs, dag ins, string asmstr,
                       list<dag> pattern> :
  BoingusInst<outs, ins, asmstr, pattern> {
  let Inst{31-30} = 0b01;
  let Inst{29-24} = op;
  let Inst{23-22} = size_code;
}

// Load tail: [21:17] R (destination) | [16:12] A (base) |
//            [11:0] I (offset)
class BoingusInstRRu12_Load<bits<2> size_code, dag outs, dag ins, string asmstr,
                       list<dag> pattern> :
  BoingusInstRRu12<0b000000, size_code, outs, ins, asmstr, pattern> {
  bits<5> R;
  bits<5> A;
  bits<12> I;

  let Inst{21-17} = R;
  let Inst{16-12} = A;
  let Inst{11-0} = I;
}

// Store tail: [21:17] N (value) | [16:12] A (base) |
//             [11:0] I (offset)
class BoingusInstRRu12_Store<bits<2> size_code, dag outs, dag ins, string asmstr,
                       list<dag> pattern> :
  BoingusInstRRu12<0b000001, size_code, outs, ins, asmstr, pattern> {
  bits<5> N;
  bits<5> A;
  bits<12> I;

  let Inst{21-17} = N;
  let Inst{16-12} = A;
  let Inst{11-0} = I;
}

// rru16 header: [31:30] 10 | [29] format selector | [28:26] opcode
// A zero format selector identifies binary operations; one identifies
// conditional branches, where opcode is the condition code.
class BoingusInstRRu16<bits<1> sub_enc, bits<3> op, dag outs, dag ins, string asmstr,
                       list<dag> pattern> :
  BoingusInst<outs, ins, asmstr, pattern> {
  let Inst{31-30} = 0b10;
  let Inst{29} = sub_enc;
  let Inst{28-26} = op;
}

// Binary tail: [25:21] R (destination) | [20:16] N | [15:0] I
class BoingusInstRRu16_Bin<bits<3> op, dag outs, dag ins, string asmstr,
                       list<dag> pattern> :
  BoingusInstRRu16<0b0, op, outs, ins, asmstr, pattern> {
  bits<5> R;
  bits<5> N;
  bits<16> I;

  let Inst{25-21} = R;
  let Inst{20-16} = N;
  let Inst{15-0} = I;
}

// Branch tail: [25:21] N | [20:16] M |
//              [15:0] A (PC-relative offset)
class BoingusInstRRu16_Branch<bits<3> cond, dag outs, dag ins, string asmstr,
                              list<dag> pattern> : 
  BoingusInstRRu16<0b1, cond, outs, ins, asmstr, pattern> {
  bits<5> N;
  bits<5> M;
  bits<16> A;

  let Inst{25-21} = N;
  let Inst{20-16} = M;
  let Inst{15-0} = A;
}

// ru16u5: [31:29] 110 | [28:26] opcode | [25:21] R |
//          [20:5] I (immediate) | [4:0] O (shift amount)
// I is a raw field here; the opcode determines its signed interpretation.
class BoingusInstRu16u5<bits<3> op, dag outs, dag ins, string asmstr,
                        list<dag> pattern> :
  BoingusInst<outs, ins, asmstr, pattern> {
  bits<5> R;
  bits<16> I;
  bits<5> O;

  let Inst{31-29} = 0b110;
  let Inst{28-26} = op;
  let Inst{25-21} = R;
  let Inst{20-5} = I;
  let Inst{4-0} = O;
}

// u28: [31:29] 111 | [28] link | [27:0] A (PC-relative word offset)
// link = 0 selects B; link = 1 selects BL. A is a signed offset measured in
// four-byte instructions, giving a reach of approximately +/-512 MiB.
class BoingusInstU28<bits<1> link, dag outs, dag ins, string asmstr,
                     list<dag> pattern> :
  BoingusInst<outs, ins, asmstr, pattern> {
  bits<28> A;

  let Inst{31-29} = 0b111;
  let Inst{28} = link;
  let Inst{27-0} = A;
}
         

// PLACEHOLDER: TableGen refuses a target with no instructions. Replace with
// real ones, e.g.:
//
//   def ADD : BoingusInst<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
//                         "add\t$rd, $rs1, $rs2",
//                         [(set GPR:$rd, (add GPR:$rs1, GPR:$rs2))]>;
let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def NOP : BoingusInst<(outs), (ins), "nop", []>;


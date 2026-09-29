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

//----------------------------------------------------------------------------
// Binary operations.
//----------------------------------------------------------------------------

def uimm16 : Operand<i32>,
             ImmLeaf<i32, [{ return isUInt<16>(Imm); }]>;

def simm16 : Operand<i32>,
             ImmLeaf<i32, [{ return isInt<16>(Imm); }]>;

// Binary operations using the rrr encoding.
class BoingusBinaryRRR<bits<14> opcode, string mnemonic,
                       SDPatternOperator OpNode>
    : BoingusInstRRR<
          opcode,
          (outs BoingusOpReg:$R),
          (ins BoingusOpReg:$N, BoingusOpReg:$M),
          mnemonic # "\t$R, $N, $M",
          [(set BoingusOpReg:$R,
                (OpNode BoingusOpReg:$N, BoingusOpReg:$M))]> {
  let hasSideEffects = 0;
  let mayLoad = 0;
  let mayStore = 0;
}

// Binary operations using the rru16 encoding. The immediate is zero-extended
// to i32; the shift instructions use its low five bits.
class BoingusBinaryRRu16<bits<3> opcode, string mnemonic,
                         SDPatternOperator OpNode>
    : BoingusInstRRu16_Bin<
          opcode,
          (outs BoingusOpReg:$R),
          (ins BoingusOpReg:$N, uimm16:$I),
          mnemonic # "\t$R, $N, $I",
          [(set BoingusOpReg:$R,
                (OpNode BoingusOpReg:$N, uimm16:$I))]> {
  let hasSideEffects = 0;
  let mayLoad = 0;
  let mayStore = 0;
}

// Define both encodings from one shared opcode. The rrr sub-encoding is
// 14 bits wide, so its three-bit opcode is prefixed with eleven zero bits.
multiclass BoingusBinary<bits<3> opcode, string mnemonic,
                         SDPatternOperator OpNode> {
  def rrr : BoingusBinaryRRR<{0b00000000000, opcode}, mnemonic, OpNode>;
  def rru16 : BoingusBinaryRRu16<opcode, mnemonic, OpNode>;
}

// Register-register and register-immediate forms with matching opcodes.
defm ADD : BoingusBinary<0b000, "add", add>;
defm SUB : BoingusBinary<0b001, "sub", sub>;
defm AND : BoingusBinary<0b010, "and", and>;
defm OR  : BoingusBinary<0b011, "or", or>;
defm XOR : BoingusBinary<0b100, "xor", xor>;
defm LSL : BoingusBinary<0b101, "lsl", shl>;
defm LSR : BoingusBinary<0b110, "lsr", srl>;
defm ASR : BoingusBinary<0b111, "asr", sra>;

// These rrr-only operations follow the shared three-bit opcode space.
// def LD64 : BoingusBinaryRRR<0b00000000001000, ...>;
// def ST64 : BoingusBinaryRRR<0b00000000001001, ...>;

// Register comparison forms.
def SEQrrr  : BoingusBinaryRRR<0b00000001000000, "seq", seteq>;
def SNErrr  : BoingusBinaryRRR<0b00000001000001, "sne", setne>;
def SLTrrr  : BoingusBinaryRRR<0b00000001000010, "slt", setlt>;
def SGErrr  : BoingusBinaryRRR<0b00000001000011, "sge", setge>;
def SLTUrrr : BoingusBinaryRRR<0b00000001000100, "sltu", setult>;
def SGEUrrr : BoingusBinaryRRR<0b00000001000101, "sgeu", setuge>;

//----------------------------------------------------------------------------
// Unary operations.
//----------------------------------------------------------------------------

class BoingusUnaryRR<bits<19> opcode, string mnemonic,
                       SDPatternOperator OpNode>
    : BoingusInstRR<
          opcode,
          (outs BoingusOpReg:$R),
          (ins BoingusOpReg:$N),
          mnemonic # "\t$R, $N",
          [(set BoingusOpReg:$R,
                (OpNode BoingusOpReg:$N))]> {
  let hasSideEffects = 0;
  let mayLoad = 0;
  let mayStore = 0;
}

def NOT : BoingusUnaryRR<0b0000000000000000000, "not", not>;

def boingus_sext8 : PatFrag<
    (ops node:$src),
    (sext_inreg node:$src, i8)>;

def boingus_sext16 : PatFrag<
    (ops node:$src),
    (sext_inreg node:$src, i16)>;

def boingus_zext8 : PatFrag<
    (ops node:$src),
    (and node:$src, 0xff)>;

def boingus_zext16 : PatFrag<
    (ops node:$src),
    (and node:$src, 0xffff)>;

def SX8rr  : BoingusUnaryRR<1, "sx8",  boingus_sext8>;
def SX16rr : BoingusUnaryRR<2, "sx16", boingus_sext16>;
def ZX8rr  : BoingusUnaryRR<3, "zx8",  boingus_zext8>;
def ZX16rr : BoingusUnaryRR<4, "zx16", boingus_zext16>;

//----------------------------------------------------------------------------
// Control-flow instructions.
//----------------------------------------------------------------------------

// Raw jump-and-link encoding: write PC + 4 to R, then branch to N.
// It is deliberately neutral here because semantic pseudos distinguish calls
// (R = LR) from non-call indirect branches (R = ZERO).
def BLrr : BoingusInstRR<
    0b0000000000000000101,
    (outs BoingusOpReg:$R),
    (ins BoingusOpReg:$N),
    "bl\t$R, $N",
    []> {
  let hasSideEffects = 0;
  let mayLoad = 0;
  let mayStore = 0;
}

// Compiler-facing form of an indirect call. Calls always place the return
// address in LR; the real instruction keeps its general R operand so it can
// also represent non-call jump-and-link operations.
//
// Add the BoingusISD::CALL selection pattern here after LowerCall creates
// that target-specific DAG node.
let isCall = 1, Defs = [LR], hasSideEffects = 0,
    mayLoad = 0, mayStore = 0 in
def PseudoCALLIndirect :
    BoingusInst<(outs), (ins BoingusOpReg:$N), "", []>,
    PseudoInstExpansion<(BLrr LR, BoingusOpReg:$N)> {
  let isCodeGenOnly = 1;
}

// Branch indirectly, is bl zero, A
// we dont need to set the lr
let isBranch = 1, isIndirectBranch = 1,
    isTerminator = 1, isBarrier = 1,
    hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def PseudoBRIndirect :
    BoingusInst<(outs), (ins BoingusOpReg:$N), "", []>,
    PseudoInstExpansion<(BLrr Z, BoingusOpReg:$N)> {
  let isCodeGenOnly = 1;
}

// Return is br (indirect branch) lr
let isReturn = 1, isTerminator = 1, isBarrier = 1,
    Uses = [LR],
    hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def PseudoRET :
    BoingusInst<(outs), (ins), "", []>,
    PseudoInstExpansion<(BLrr Z, LR)> {
  let isCodeGenOnly = 1;
}

def simm28 : Operand<i32>,
             ImmLeaf<i32, [{ return isInt<28>(Imm); }]>;

def brtarget16 : Operand<OtherVT> {
  let OperandType = "OPERAND_PCREL";
}

def brtarget28 : Operand<OtherVT> {
  let OperandType = "OPERAND_PCREL";
}

def Bu28 : BoingusInstU28<
    0b0,
    (outs),
    (ins brtarget28:$A),
    "b\t$A",
    [(br bb:$A)]> {
  let isBranch = 1;
  let isTerminator = 1;
  let isBarrier = 1;
  let hasSideEffects = 0;
  let mayLoad = 0;
  let mayStore = 0;
}

def BLu28 : BoingusInstU28<
    0b1,
    (outs),
    (ins simm28:$A),
    "bl\t$A",
    []> {
  let isCall = 1;
  let Defs = [LR];
  let hasSideEffects = 0;
  let mayLoad = 0;
  let mayStore = 0;
}

// Conditional branches use a signed 16-bit offset in four-byte instruction
// units, so the byte displacement is A << 2.
class BoingusBranchRRu16<bits<3> cond, string mnemonic>
    : BoingusInstRRu16_Branch<
          cond,
          (outs),
          (ins BoingusOpReg:$N, BoingusOpReg:$M, simm16:$A),
          mnemonic # "\t$N, $M, $A",
          []> {
  let isBranch = 1;
  let isTerminator = 1;
  let hasSideEffects = 0;
  let mayLoad = 0;
  let mayStore = 0;
}

def BEQ  : BoingusBranchRRu16<0b000, "beq">;
def BNE  : BoingusBranchRRu16<0b001, "bne">;
def BLT  : BoingusBranchRRu16<0b010, "blt">;
def BGE  : BoingusBranchRRu16<0b011, "bge">;
def BLTU : BoingusBranchRRu16<0b100, "bltu">;
def BGEU : BoingusBranchRRu16<0b101, "bgeu">;


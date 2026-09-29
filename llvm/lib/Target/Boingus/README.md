# Boingus LLVM backend: status and roadmap

Boingus is an experimental 32-bit, little-endian LLVM target. The ISA is
described in `Boingus.md`; treat that file as the source of truth for register
roles, instruction semantics, and encodings.

Configure LLVM with:

```sh
cmake ... -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=Boingus
```

The target is registered well enough to appear in `llc --version`, but it
cannot generate code yet because `BoingusTargetMachine.cpp` is still a stub.

## Current implementation

### Integration outside this directory

| File | Current support |
|---|---|
| `include/llvm/TargetParser/Triple.h` | `Triple::boingus` architecture |
| `lib/TargetParser/Triple.cpp` | Triple parsing/printing, ELF default, 32-bit little-endian properties |
| `lib/TargetParser/TargetDataLayout.cpp` | `e-m:e-p:32:32-i64:64-n32-S128` |
| `include/llvm/IR/RuntimeLibcalls.td` | Default compiler-rt/libgcc libcalls |
| top-level `CMakeLists.txt` | Boingus is an experimental target |
| `test/CodeGen/Boingus/` | One XFAIL `add.ll` smoke test |

### Registers and ABI

`BoingusRegisterInfo.td` defines the real 32-register file:

- `Z`/`r0` is constant zero.
- `R1`-`R28` are allocatable general registers.
- `SP`, `FP`, and `LR` are encoded as registers 29, 30, and 31.
- `GPR` contains allocatable registers; `BoingusOpReg` also contains the
  reserved/special registers so instructions may name them.

`BoingusRegisterInfo.cpp` currently reserves `Z`, `SP`, `FP`, and `LR`, and
hard-codes `R17`-`R28` plus `FP` as callee-saved. This matches the ABI in
`Boingus.md`, but should eventually be generated from
`BoingusCallingConv.td`. The old placeholder comment at the top of
`BoingusRegisterInfo.td` is stale.

### Encoding formats

`BoingusInstrInfo.td` defines all six 32-bit instruction layouts:

| Format | Prefix | Fields | Status |
|---|---:|---|---|
| `rrr` | `000` | 14-bit opcode + three registers | Defined |
| `rr` | `001` | 19-bit opcode + two registers | Defined |
| `rru12` | `01` | operation/size + two registers + 12-bit offset | Format only |
| `rru16` | `10` | binary/branch selector + 3-bit operation + operands | Defined |
| `ru16u5` | `110` | 3-bit operation + register + immediate + shift | Format only |
| `u28` | `111` | link bit + 28-bit PC-relative offset | Defined |

### Instruction definitions

There are TableGen records for 36 of the 48 architectural instructions
documented in `Boingus.md`.

Implemented records:

- Both `rrr` and `rru16` forms of `ADD`, `SUB`, `AND`, `OR`, `XOR`, `LSL`,
  `LSR`, and `ASR`.
- `SEQ`, `SNE`, `SLT`, `SGE`, `SLTU`, and `SGEU`.
- `NOT`, `SX8`, `SX16`, `ZX8`, and `ZX16`.
- Raw register jump-and-link `BLrr`.
- Direct `B` (`Bu28`) and direct `BL` (`BLu28`).
- `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, and `BGEU`.

Still missing architectural instruction records:

- `LD64`, `ST64`.
- `LD8`, `LD16`, `LD32`.
- `ST8`, `ST16`, `ST32`.
- `ADDSH`, `ANDSH`, `ORSH`, `ADR`.

The `rru12` load/store and `ru16u5` format classes already exist, so these
instructions do not require new top-level layouts.

### Opcode decisions

The eight shared binary operations use the same three-bit operation code in
their `rrr` and `rru16` forms. The `rrr` form prefixes that code with eleven
zero bits because its opcode field is 14 bits wide. A multiclass emits both
records while preserving names such as `ADDrrr` and `ADDrru16`.

`LD64` and `ST64` are reserved `rrr` opcodes 8 and 9. Comparisons occupy
opcodes 64-69. Their low three bits deliberately match branch conditions:

| Code | Value-producing comparison | Conditional branch |
|---:|---|---|
| `000` | `SEQ` | `BEQ` |
| `001` | `SNE` | `BNE` |
| `010` | `SLT` | `BLT` |
| `011` | `SGE` | `BGE` |
| `100` | `SLTU` | `BLTU` |
| `101` | `SGEU` | `BGEU` |
| `110`, `111` | Reserved | Reserved |

### Control-flow modelling

`BLrr R, N` is the raw hardware operation: write `PC + 4` to `R`, then jump
to the address in `N`. The raw record is intentionally neutral because LLVM
needs different semantic flags depending on how that encoding is used.

Compiler-facing pseudos currently exist for:

- `PseudoCALLIndirect`: marked `isCall`, implicitly defines `LR`, and expands
  to `BLrr LR, N`.
- `PseudoBRIndirect`: marked as an indirect, unconditional branch and expands
  to `BLrr Z, N`.
- `PseudoRET`: marked as a return, uses `LR`, and expands to `BLrr Z, LR`.

Conditional branches are `isBranch` and `isTerminator`, but not barriers
because their false edge falls through. Direct `B` and indirect `BR` are
barriers. Calls are `isCall` rather than ordinary branches because execution
is expected to return to the following instruction.

`PC` is not a general-purpose register and must not be added to the register
file. Call/return-address behaviour is represented by instruction semantics,
implicit `Defs`/`Uses`, DAG chains/glue, and lowering.

### Existing selection patterns

Arithmetic, logical, comparison, and unary records have SelectionDAG patterns.
The control-flow records and pseudos still use empty patterns, so LLVM cannot
select branches, calls, or returns yet.

For ordinary branches, begin with generic SelectionDAG nodes:

- `(br bb:$A)` selects direct `B`.
- `(brcond (seteq ...), bb:$A)` and the other conditions select conditional
  branches.
- `(brind BoingusOpReg:$N)` selects `PseudoBRIndirect`.

The ISA lacks `>` and `<=` branch encodings. Select them by swapping operands:

- signed `N > M` becomes `BLT M, N`;
- signed `N <= M` becomes `BGE M, N`;
- unsigned forms similarly use `BLTU` and `BGEU`.

If legalization does not preserve a directly matchable `brcond(setcc)` shape,
custom-lower `ISD::BRCOND` to a target `BoingusISD::BR_CC` node. Do not add
custom C++ lowering until the direct patterns prove insufficient.

### PC-relative branch operands

The current branch instructions use `simm16`/`simm28`. To match basic blocks
and symbols correctly, replace these with branch-specific `Operand<OtherVT>`
operands such as `brtarget16` and `brtarget28`, marked `OPERAND_PCREL`.

Selection and SelectionDAG lowering operate on the real byte-address target;
they must not insert the architectural `<< 2`. Encoding is split as follows:

1. Calculate the byte displacement (`target - PC`).
2. Check that the low two bits are zero.
3. Check `isShiftedInt<16, 2>` or `isShiftedInt<28, 2>`.
4. Encode the displacement shifted right by two.

For numeric operands, this belongs in the `MCCodeEmitter` operand method. For
labels and symbols, the PC-relative fixup and `MCAsmBackend` perform it. The
disassembler sign-extends the field and shifts it left by two.

## C++ backend status

| Component | Status |
|---|---|
| `BoingusSubtarget` | Owns instruction, register, frame, and target-lowering helpers |
| `BoingusInstrInfo` | Generated info only; no copies, spills, reloads, or branch analysis |
| `BoingusRegisterInfo` | Reserved/callee-saved sets exist; frame-index elimination aborts |
| `BoingusFrameLowering` | Stack direction/alignment exist; prologue and epilogue are empty |
| `BoingusISelLowering` | Registers legal `i32` GPRs and `SP`; no ABI or custom lowering |
| `BoingusISelDAGToDAG` | Missing |
| `BoingusSelectionDAGInfo` | Missing |
| `BoingusTargetMachine` | Stub; no target machine or pass configuration is registered |
| Calling convention | Missing `BoingusCallingConv.td` |
| Asm printer / MC lowering | Missing |
| Object emission | Missing code emitter, fixups, asm backend, and ELF writer |
| Assembly parser / disassembler | Missing |

Because the TargetMachine and instruction-selector pass are absent, valid
TableGen patterns can currently be generated and inspected but cannot run in
`llc`.

## Recommended next steps

1. Add `brtarget16`/`brtarget28` and the direct `br`, `brcond`, and `brind`
   patterns described above. Validate with `-gen-dag-isel`.
2. Define the six `rru12` loads/stores; at minimum `LD32`/`ST32` are needed
   for stack slots and spills.
3. Define the four `ru16u5` instructions and `LD64`/`ST64`.
4. Write `BoingusCallingConv.td` and generate
   `BoingusGenCallingConv.inc`.
5. Implement `LowerFormalArguments`, `LowerReturn`, and then `LowerCall`.
   Return lowering should produce a target return node that selects
   `PseudoRET`; call lowering should produce target call nodes with chain/glue.
6. Add `BoingusISelDAGToDAG`, enable `BoingusGenDAGISel.inc`, and connect it
   through a real `BoingusTargetMachine` and `TargetPassConfig`.
7. Implement `copyPhysReg`, spill/reload hooks, frame-index elimination, and
   prologue/epilogue emission.
8. Add the instruction printer, `BoingusMCInstLower`, and AsmPrinter. Enable
   generated pseudo lowering and include `BoingusGenMCPseudoLowering.inc`.
9. Add the MC code emitter, branch/call fixups, asm backend, ELF writer,
   assembly parser, and disassembler.
10. Remove the XFAIL from `test/CodeGen/Boingus/add.ll`, then add tests for
    arithmetic, branches, stack frames, calls, returns, and relocations.

The commented `tablegen(...)` lines in `CMakeLists.txt` identify several
generators that should be enabled as their consumers are added. Re-run CMake
after adding an `*AsmPrinter.cpp` file because LLVM's build detects target
AsmPrinter support during configuration.

## TableGen validation

The current instruction records have been checked with the instruction-info,
encoder, assembly-writer, DAG-selector, and pseudo-lowering generators. From
the `llvm-project` directory, equivalent checks are:

```sh
llvm-tblgen -I llvm/include -I llvm/lib/Target/Boingus \
  -gen-instr-info llvm/lib/Target/Boingus/Boingus.td -o /dev/null
llvm-tblgen -I llvm/include -I llvm/lib/Target/Boingus \
  -gen-emitter llvm/lib/Target/Boingus/Boingus.td -o /dev/null
llvm-tblgen -I llvm/include -I llvm/lib/Target/Boingus \
  -gen-asm-writer llvm/lib/Target/Boingus/Boingus.td -o /dev/null
llvm-tblgen -I llvm/include -I llvm/lib/Target/Boingus \
  -gen-dag-isel llvm/lib/Target/Boingus/Boingus.td -o /dev/null
llvm-tblgen -I llvm/include -I llvm/lib/Target/Boingus \
  -gen-pseudo-lowering llvm/lib/Target/Boingus/Boingus.td -o /dev/null
```

These checks establish that the records are internally valid; they do not
replace `llc`, assembler, disassembler, relocation, or execution tests.

For implementation examples, `lib/Target/ARC/` is a relatively small target,
while LoongArch and RISC-V show complete compare-and-branch lowering,
PC-relative operands, pseudo expansion, and fixup handling.

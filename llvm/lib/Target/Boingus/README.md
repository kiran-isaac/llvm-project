# Boingus backend: roadmap

Experimental target. Build it with:
```
cmake ... -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=Boingus
```

## What exists already

**Outside this folder:**

| File | Change |
|---|---|
| `include/llvm/TargetParser/Triple.h` | `Triple::boingus` arch enum |
| `lib/TargetParser/Triple.cpp` | name parsing/printing, ELF default, 32-bit, little endian, DWARF CFI exceptions |
| `lib/TargetParser/TargetDataLayout.cpp` | data layout `e-m:e-p:32:32-i64:64-n32-S128` |
| `include/llvm/IR/RuntimeLibcalls.td` | Boingus uses the default libcalls (`__mulsi3`, `__divsi3`, ...), needed for `LibCall` legalization |
| `CMakeLists.txt` | `Boingus` in `LLVM_ALL_EXPERIMENTAL_TARGETS` |
| `test/CodeGen/Boingus/` | `lit.local.cfg` and a first (XFAIL) test |

**In this folder**, just enough to register the target (it appears in `llc --version`):

| File | Contents |
|---|---|
| `TargetInfo/` | `getTheBoingusTarget()` + `LLVMInitializeBoingusTargetInfo` |
| `MCTargetDesc/` | MC register/instr/subtarget info + `BoingusMCAsmInfo` |
| `Boingus.td`, `BoingusRegisterInfo.td`, `BoingusInstrInfo.td` | placeholder 16 x i32 register file, one placeholder `NOP` |
| `BoingusTargetMachine.cpp` | an empty `LLVMInitializeBoingusTarget` |

`llc -mtriple=boingus` can't generate code yet because no TargetMachine is
registered. In an assertions build it stops at
`Assertion 'Target && "Could not allocate target machine!"'`. `llvm-mc` fails
with "unable to create instruction printer" until step 5.

## What to write, in order

`../ARC/` is the closest simple template for every file below; RISC-V shows the
full-scale version. Section references are to `learning/TRACE.md`.

1. **Registers:** make `BoingusRegisterInfo.td` match the real ISA.
2. **Instructions:** in `BoingusInstrInfo.td` (+ `BoingusInstrFormats.td` for
   encodings), define the minimum set with `Pat`s:
   - `add`, add-immediate,
   - load/store word,
   - load-immediate, move,
   - compare-and-branch, jump, return.
3. **Calling convention:** `BoingusCallingConv.td` (arguments in which registers,
   return value in which register). Include it from `Boingus.td`.
4. **C++ classes.** Add each `.cpp` to `add_llvm_target` in `CMakeLists.txt`,
   plus the matching `tablegen(...)` line (listed there as comments).

   | Class | Contents | Reference |
   |---|---|---|
   | `BoingusSubtarget` | owns the four classes below | |
   | `BoingusRegisterInfo` | reserved regs, callee-saved, `eliminateFrameIndex`, frame register | |
   | `BoingusInstrInfo` | `copyPhysReg`, `storeRegToStackSlot`, `loadRegFromStackSlot` | |
   | `BoingusFrameLowering` | `emitPrologue` / `emitEpilogue` | |
   | `BoingusISelLowering` | constructor (`addRegisterClass`, `computeRegisterProperties`, `setOperationAction(... Expand/LibCall)`), `LowerFormalArguments`, `LowerReturn`; `LowerCall` later | TRACE.md 1.2, 1.4, 1.6 |
   | `BoingusISelDAGToDAG` | `Select()` → `SelectCode()` | TRACE.md 1.7 |
   | `BoingusSelectionDAGInfo` | needed by the Subtarget | |
   | `BoingusTargetMachine` (.h + .cpp) + a `TargetPassConfig` | registers the target machine: `addInstSelector` | ARC's |
5. **Printing:** `MCTargetDesc/BoingusInstPrinter`, `BoingusMCInstLower`, and
   `BoingusAsmPrinter.cpp`.
   - Register the InstPrinter in `BoingusMCTargetDesc.cpp`.
   - Initialize the AsmPrinter pass in `LLVMInitializeBoingusTarget`.
   - **Re-run cmake** after adding `BoingusAsmPrinter.cpp`: CMake globs for
     `*AsmPrinter.cpp` to decide whether to require
     `LLVMInitializeBoingusAsmPrinter`.
6. **Test:** remove the XFAIL from `test/CodeGen/Boingus/add.ll` and grow from
   there: branches, stack, calls.

**Later / optional:**
- object files: `MCCodeEmitter`, `MCAsmBackend`, ELF writer, and an `EM_*` machine
  number in `lib/BinaryFormat/ELF.cpp`,
- an assembly parser (`AsmParser/`) and `Disassembler/`,
- a scheduling model,
- clang support (`clang/lib/Basic/Targets/`).

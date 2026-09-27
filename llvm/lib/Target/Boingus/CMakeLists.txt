add_llvm_component_group(Boingus)

set(LLVM_TARGET_DEFINITIONS Boingus.td)

tablegen(LLVM BoingusGenInstrInfo.inc -gen-instr-info)
tablegen(LLVM BoingusGenRegisterInfo.inc -gen-register-info)
tablegen(LLVM BoingusGenSubtargetInfo.inc -gen-subtarget)
# Add these as you write the matching pieces:
#   tablegen(LLVM BoingusGenAsmWriter.inc -gen-asm-writer)       # InstPrinter
#   tablegen(LLVM BoingusGenCallingConv.inc -gen-callingconv)    # BoingusCallingConv.td
#   tablegen(LLVM BoingusGenDAGISel.inc -gen-dag-isel)           # ISelDAGToDAG
#   tablegen(LLVM BoingusGenSDNodeInfo.inc -gen-sd-node-info)    # SelectionDAGInfo
#   tablegen(LLVM BoingusGenMCPseudoLowering.inc -gen-pseudo-lowering)

add_public_tablegen_target(BoingusCommonTableGen)

add_llvm_target(BoingusCodeGen
  BoingusTargetMachine.cpp

  LINK_COMPONENTS
  Analysis
  AsmPrinter
  BoingusDesc
  BoingusInfo
  CodeGen
  CodeGenTypes
  Core
  MC
  SelectionDAG
  Support
  Target
  TargetParser

  ADD_TO_COMPONENT
  Boingus
  )

add_subdirectory(MCTargetDesc)
add_subdirectory(TargetInfo)

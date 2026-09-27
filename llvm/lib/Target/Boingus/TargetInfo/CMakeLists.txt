add_llvm_component_library(LLVMBoingusInfo
  BoingusTargetInfo.cpp

  LINK_COMPONENTS
  MC
  Support

  ADD_TO_COMPONENT
  Boingus
  )

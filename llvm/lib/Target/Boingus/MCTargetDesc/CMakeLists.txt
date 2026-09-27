add_llvm_component_library(LLVMBoingusDesc
  BoingusMCAsmInfo.cpp
  BoingusMCTargetDesc.cpp

  LINK_COMPONENTS
  MC
  Support
  BoingusInfo
  TargetParser

  ADD_TO_COMPONENT
  Boingus
  )

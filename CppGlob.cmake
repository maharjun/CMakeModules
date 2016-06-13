function(GET_EXT_FILES VARIABLE DIRECTORY)

   if(ARGC EQUAL 0)
      # set nothing
   else()
      foreach(ext in ${ARGN})
         file(GLOB TEMPVAR "${DIRECTORY}/*.${ext}")
         set(EXT_FILES "${EXT_FILES};${TEMPVAR}")
      endforeach()
   endif()
   set(${VARIABLE} ${EXT_FILES} PARENT_SCOPE)
   message(STATUS "Extensions requested = ${ARGN}")
   message(STATUS "Directory requested = ${DIRECTORY}")

endfunction()

function(GET_CXX_FILES VARIABLE)

   set(CXX_EXTENSIONS "cpp;c;h;hpp;inl")

   cmake_parse_arguments(get_cxx_files "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

   foreach(_dir ${get_cxx_files_UNPARSED_ARGUMENTS})
      GET_EXT_FILES(CPP_FILES_temp ${_dir} ${CXX_EXTENSIONS})
      list(APPEND CPP_FILES ${CPP_FILES_temp})
   endforeach()
   list(REMOVE_DUPLICATES CPP_FILES)
   
   set(${VARIABLE} ${CPP_FILES} PARENT_SCOPE)
   message(STATUS "Files Found = ${CPP_FILES}")
endfunction()
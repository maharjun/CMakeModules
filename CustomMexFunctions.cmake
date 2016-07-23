include(BasicFuncs)

function(get_mex_libs libs_var_name libdir_var_name)
    if(Matlab_FOUND)
        # Extract the containing library from the value of Matlab_MEX_LIBRARY
        get_filename_component(Matlab_LIB_DIR ${Matlab_MEX_LIBRARY} DIRECTORY)

        # Extract the library prefix (includes the path)
        string(REGEX REPLACE "^(.*[/\\\\][^/\\\\]*)mex.*$" "\\1" MEX_LIBRARY_PREFIX ${Matlab_MEX_LIBRARY})

        # Extract the library postfix
        string(REGEX REPLACE "^.*[/\\\\][^/\\\\]*mex(.*)$" "\\1" MEX_LIBRARY_POSTFIX ${Matlab_MEX_LIBRARY})

        # Add the above post and pre fix to all the relevant libraries to get the full path
        # note that all this is because the ut library is not provided by FindMatlab
        set(Matlab_LINK_LIBNAMES mat mex mx ut)
        foreach(Matlab_lib ${Matlab_LINK_LIBNAMES})
            list(APPEND Temp_Matlab_LINK_LIBS ${MEX_LIBRARY_PREFIX}${Matlab_lib}${MEX_LIBRARY_POSTFIX})
        endforeach()
        set(Matlab_LINK_LIBS_FULL ${Temp_Matlab_LINK_LIBS})
    endif()

    # return the libs and the lib dir
    set(${libs_var_name} ${Matlab_LINK_LIBS_FULL} PARENT_SCOPE)
    set(${libdir_var_name} ${Matlab_LIB_DIR} PARENT_SCOPE)
endfunction()

function(custom_add_mex_exec exec_name)
    # 
    # call syntax:
    # 
    #   custom_add_mex_exec(<name>
    #       <src files>
    #       LINK_TO <additional libs>
    #   )
    # 
    # The major differences between this and the original add_mex command are:
    # 
    # 1. The stripping of any _mexexe suffix to the exec_name
    # 2. The linking of the libut libmat and libmx library 
    # 3. The addition of Release LTO and 
    # 4. The addition of libraries to RPATH

    # parsing input arguments
    set(multiValueArgs LINK_TO)
    cmake_parse_arguments(custom_add_mex_exec "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    
    # processing name of target to strip _mexexe
    string(REGEX REPLACE "_mexexe$" "" exec_name_stripped ${exec_name})

    # add executable target with given source files
    add_executable(${exec_name} ${custom_add_mex_exec_UNPARSED_ARGUMENTS})
    set_target_properties(${exec_name} PROPERTIES OUTPUT_NAME ${exec_name_stripped})

    # add MEX_EXE definition
    target_compile_definitions(${exec_name} PRIVATE MEX_EXE)

    # include MEX include directories
    target_include_directories(${exec_name} PRIVATE ${Matlab_INCLUDE_DIRS})
    
    # link libraries
    get_mex_libs(Matlab_LINK_LIBS Matlab_LIB_DIR)
    target_link_libraries(${exec_name} 
        PRIVATE
        ${Matlab_LINK_LIBS}
        ${custom_add_mex_exec_LINK_TO})

    # Set Compile and link flags
    set_target_compile_link_flags(${exec_name})

    # Set install rpath
    set_target_properties(${exec_name} PROPERTIES INSTALL_RPATH ${Matlab_LIB_DIR})

endfunction()

function(custom_add_mex mex_name)
    # 
    # call syntax:
    # 
    #   custom_add_mex(<name>
    #       <src files>
    #       LINK_TO <additional libs>
    #       DOCUMENTATION <documentation file>
    #   )
    # 
    # The major differences between this and the original add_mex command are:
    # 
    # 1. The stripping of any _mexlib suffix to the exec_name
    # 2. Definition of MEX_LIB Definition
    # 3. The linking of the libut libmat and libmx library 
    # 4. The addition of Release LTO and 
    # 5. The addition of libraries to RPATH

    # parse input arguments
    set(oneValueArgs DOCUMENTATION)
    set(multiValueArgs LINK_TO)
    cmake_parse_arguments(custom_add_mex "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # processing name of target to strip _mexlib
    string(REGEX REPLACE "_mexlib$" "" mex_name_stripped ${mex_name})
    
    # Get Relevant MEX Libs
    get_mex_libs(Matlab_LINK_LIBS Matlab_LIB_DIR)
    
    # Add Mex Lib Target
    matlab_add_mex(
        NAME ${mex_name}
        SRC ${custom_add_mex_UNPARSED_ARGUMENTS}
        OUTPUT_NAME ${mex_name_stripped}
        LINK_TO ${Matlab_LINK_LIBS} ${custom_add_mex_LINK_TO}
        DOCUMENTATION ${custom_add_mex_DOCUMENTATION})

    # add MEX_LIB definition
    target_compile_definitions(${mex_name} PRIVATE MEX_LIB)

    # Set Compile and link flags
    set_target_compile_link_flags(${mex_name})

    # Set install rpath
    set_target_properties(${exec_name} PROPERTIES INSTALL_RPATH ${Matlab_LIB_DIR})
endfunction()

function(install_mex_exec target_name install_dir)
    # 
    # Function call:
    # 
    #   install_mex_exe(target_name, install_dir)
    #   
    install(TARGETS ${target_name}
      RUNTIME DESTINATION ${install_dir}
      CONFIGURATIONS "Release")
    
endfunction()

function(install_mex target_name install_dir)
    # 
    # Function call:
    # 
    #   install_mex(target_name, install_dir)
    #   
    install(TARGETS ${target_name}
      LIBRARY DESTINATION ${install_dir}
      RUNTIME DESTINATION ${install_dir}
      CONFIGURATIONS "Release")
    get_target_property(output_name ${target_name} OUTPUT_NAME)
    install( # install DOCUMENTATION
      FILES $<TARGET_FILE_DIR:${target_name}>/${output_name}.m 
      DESTINATION ${install_dir}
      CONFIGURATIONS "Release"
      OPTIONAL)
endfunction()
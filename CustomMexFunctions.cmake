include(BasicFuncs.cmake)

function(get_mex_libs libs_var_name libdir_var_name)
    if(Matlab_FOUND)
        # extract the containing library from the value of Matlab_MEX_LIBRARY
        get_filename_component(Matlab_LIB_DIR ${Matlab_MEX_LIBRARY} DIRECTORY)

        # edit the library names and add prefix lib- if in windows
        set(Matlab_LINK_LIBNAMES mex mx ut)
        if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
            foreach(Matlab_lib ${Matlab_LINK_LIBNAMES})
                list(APPEND Temp_Matlab_LINK_LIBS lib${Matlab_lib})
            endforeach()
        endif()
        set(Matlab_LINK_LIBS ${Temp_Matlab_LINK_LIBS})

        # for each of the libraries above, find it in the containing library
        # with full path
        foreach(Matlab_lib ${Temp_Matlab_LINK_LIBS})
            find_library(Temp_LIB_FULL_PATH
                NAMES ${Matlab_lib}
                PATHS ${Matlab_LIB_DIR})
            list(APPEND Matlab_LINK_LIBS_FULL ${Temp_LIB_FULL_PATH})
            unset(Temp_LIB_FULL_PATH CACHE)
        endforeach()
        message(STATUS "Matlab_LINK_LIBS = ${Matlab_LINK_LIBS_FULL}")
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
    # The major difference between this and the original
    # add_mex command is the linking of the libut library
    # , the addition of Release LTO and the addition of
    # libraries to RPATH

    # parsing input arguments
    set(multiValueArgs LINK_TO)
    cmake_parse_arguments(custom_add_mex_exec "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    
    # add MEX_EXE definition
    add_definitions(-DMEX_EXE)

    # add executable target with given source files
    add_executable(${exec_name} ${custom_add_mex_exec_UNPARSED_ARGUMENTS})
    
    # include directories
    target_include_directories(${exec_name} ${Matlab_INCLUDE_DIRS})
    
    # link libraries
    get_mex_libs(Matlab_LINK_LIBS, Matlab_LIB_DIR)
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
    # The major difference between this and the original
    # add_mex command is the linking of the libut library
    # , the addition of Release LTO and the addition of
    # libraries to RPATH

    # parse input arguments
    set(oneValueArgs DOCUMENTATION)
    set(multiValueArgs LINK_TO)
    cmake_parse_arguments(custom_add_mex "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    
    # add MEX_LIB definition
    add_definitions(-DMEX_LIB)

    get_mex_libs(Matlab_LINK_LIBS Matlab_LIB_DIR)
    matlab_add_mex(
        NAME ${mex_name}
        SRC ${custom_add_mex_UNPARSED_ARGUMENTS}
        LINK_TO ${Matlab_LINK_LIBS} ${custom_add_mex_LINK_TO}
        DOCUMENTATION ${custom_add_mex_DOCUMENTATION})

    # Set Compile and link flags
    set_target_compile_link_flags(${mex_name})

    # Set install rpath
    set_target_properties(${exec_name} PROPERTIES INSTALL_RPATH ${Matlab_LIB_DIR})
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
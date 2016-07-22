function(set_is_debug_def target_name)
    target_compile_definitions(
        ${target_name}
        PRIVATE
        $<$<CONFIG:Debug>:IS_DEBUG=1>
        $<$<CONFIG:Release>:IS_DEBUG=0>
        $<$<CONFIG:RelWithDebInfo>:IS_DEBUG=0>
        $<$<CONFIG:RelWithDebInfo>:IS_DEBUG=0>)
endfunction()

function(set_target_compile_link_flags target_name)
    if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        set(LTO_COMPILE_SWITCH "-GL")
        set(LTO_LINK_SWITCH "-LTCG")
    elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        set(LTO_COMPILE_SWITCH "-flto")
        set(LTO_LINK_SWITCH "-flto")

        # Making Use of gold linker
        # This step is necessary to enable LTO for Clang in Linux.
        # Even for GCC, it results in a faster link time.
        if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
            set(LTO_LINK_SWITCH "${LTO_LINK_SWITCH} -fuse-ld=gold")
        endif()
    endif()
    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        set(ADDITIONAL_COMPILE_OPTIONS "-std=c++11;-march=native")
    endif()
    target_compile_options(${target_name} 
        PRIVATE 
        ${ADDITIONAL_COMPILE_OPTIONS}
        $<$<CONFIG:Release>:
            ${LTO_COMPILE_SWITCH}>)
    set(LTO_OPTION $<$<CONFIG:Release>:${LTO_LINK_SWITCH}>)
    message(STATUS "LTO_OPTION = ${LTO_OPTION}")
    target_link_libraries (${target_name} PRIVATE $<$<CONFIG:Release>:${LTO_LINK_SWITCH}>)
    set_is_debug_def(${target_name})
endfunction()

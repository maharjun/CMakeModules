function(set_target_compile_link_flags target_name)
    if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        set(LTO_COMPILE_SWITCH "-GL")
        set(LTO_LINK_SWITCH "-LTCG")
    elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        set(LTO_COMPILE_SWITCH "-flto") # These variables are unset because I have not optimized for gcc yet
        set(LTO_LINK_SWITCH "-flto")
    endif()
    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        set(ADDITIONAL_COMPILE_OPTIONS "-std=c++11;-march=native")
        set(RELEASE_OPTIM_OPTION "-O3")
    endif()
    target_compile_options(${target_name} 
        PRIVATE 
        ${ADDITIONAL_COMPILE_OPTIONS}
        $<$<CONFIG:Release>:
            ${LTO_COMPILE_SWITCH}
            ${RELEASE_OPTIM_OPTION}>)
    set(LTO_OPTION $<$<CONFIG:Release>:${LTO_LINK_SWITCH}>)
    message(STATUS "LTO_OPTION = ${LTO_OPTION}")
    target_link_libraries (${target_name} $<$<CONFIG:Release>:${LTO_LINK_SWITCH}>)
endfunction()
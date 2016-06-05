function(enable_tbb target_name)
	if(TBB_FOUND)
		# include linking libraries
		target_link_libraries(
			${target_name} 
			PRIVATE 
			$<$<CONFIG:Debug>:${TBB_tbb_LIBRARY_DEBUG}>
			$<$<NOT:$<CONFIG:Debug>>:${TBB_tbb_LIBRARY_RELEASE}>
			$<$<CONFIG:Debug>:${TBB_tbbmalloc_LIBRARY_DEBUG}>
			$<$<NOT:$<CONFIG:Debug>>:${TBB_tbbmalloc_LIBRARY_RELEASE}>)

		# include include directories
		target_include_directories(
			${target_name}
			PRIVATE
			${TBB_INCLUDE_DIRS})
	else()
		# return error
		message(ERROR "TBB Does Not Exist")
	endif()
endfunction()
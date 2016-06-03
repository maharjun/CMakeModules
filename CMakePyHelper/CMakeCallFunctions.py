import subprocess
import shlex
import os


def CMakeGenCall(SourceDir, Generator=None, BuildConfig=None, Silent=True, *args, **kwargs):
    # Calls the following cmake command
    #
    # cmake [-G "<Generator>"] [-D CMAKE_BUILD_TYPE=<BuildConfig>]
    #       [-D keyword="<value>"] ....
    #       [arg[0]] ....
    #       "<SourceDir>"
    #
    # Note that the values to keywords must be unquoted strings. However for
    # the content of args, any necessary quotes must be contained in the same
    #
    # The Silent keyword arg suppresses the CMake command output.
    #
    # Returns Success of CMake generation (True if Successful)
    
    CMakeCallParts = ['cmake']
    
    # Add Generator and Build Configuration
    if Generator:
        CMakeCallParts.append('-G "{Generator}"'.format(Generator=Generator))
    if BuildConfig:
        CMakeCallParts.append('-D CMAKE_BUILD_TYPE={BuildConfig}'.format(BuildConfig=BuildConfig))

    # Add Definitions specified by kwargs
    for keyword in kwargs:
        CMakeCallParts.append('-D {KeyWord}="{Value}"'.format(KeyWord=keyword, Value=kwargs[keyword]))

    # Add Additional arguments specified in args
    for args in args:
        CMakeCallParts.append(str(args))

    # Add Source Directory
    CMakeCallParts.append("{SourceDir}".format(SourceDir=SourceDir))
    CMakeCmd = ' '.join(CMakeCallParts)

    # Calling Command
    if Silent:
        with open(os.devnull, 'w') as NullStream:
            CMakeOutput = subprocess.call(shlex.split(CMakeCmd), stdout=NullStream)
    else:
        CMakeOutput = subprocess.call(shlex.split(CMakeCmd))

    # Printing Status messages
    if not CMakeOutput:
        print("\nCMake build files successfully generated")
        isCMakeGenSuccess = True
    else:
        print("\nErrors occurred in the execution of the following command:")
        print()
        print("  {Command}".format(Command=CMakeCmd))
        isCMakeGenSuccess = False

    return isCMakeGenSuccess


def CMakeBuildCall(BuildDir, Target=None, BuildConfig=None, Silent=True):
    # Calls the following cmake command
    #
    # cmake --build "<BuildDir>" [--target "<Targett>"] [--config "<BuidConfig>"]
    #
    # The Silent option suppresses all non-error output from the cmake command
    #
    # returns success of build operation

    # Prepare call statement
    CMakeCallParts = ['cmake']
    CMakeCallParts.append('--build "{BuildDir}"'.format(BuildDir=BuildDir))

    if Target:
        CMakeCallParts.append('--target "{Target}"'.format(Target=Target))
    if BuildConfig:
        CMakeCallParts.append('--config "{BuildConfig}"'.format(BuildConfig=BuildConfig))

    CMakeBuildCmd = ' '.join(CMakeCallParts)
    
    # Perform Call
    if Silent:
        with open(os.devnull, 'w') as NullStream:
            CMakeBuildOutput = subprocess.call(shlex.split(CMakeBuildCmd), stdout=NullStream)
    else:
        CMakeBuildOutput = subprocess.call(shlex.split(CMakeBuildCmd))

    # Printing Status messages
    if not CMakeBuildOutput:
        print("\nCMake build and install successfully completed")
        print("Installed in:")
        print("\n  {Directory}".format(Directory=os.path.join(BuildDir, 'install')))
    else:
        print("\nErrors occurred in the execution of the following command:")
        print()
        print("  {Command}".format(Command=CMakeBuildCmd))
    
    return not CMakeBuildOutput

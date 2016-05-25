import subprocess
import shlex
import re
import platform


def getDefaultPlatformGen():
    #
    # This platform gets the default 64bit generator for the platform
    GetGenCall = "cmake -G"

    p = subprocess.Popen(
            shlex.split(GetGenCall),
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            universal_newlines=True)
    RawCMakeOutput = p.stdout.read()

    GeneratorListRe = re.compile(r"^.*?Generators\n(.*)$", re.DOTALL)
    NonGeneratorLinesRe = re.compile(r"^  \s+?.*(\n|\Z)", re.MULTILINE)
    GeneratorNamePortion = re.compile(r"^  (\S[^=]*?)(= .*)?$", re.MULTILINE)
    GeneratorListStr = re.sub(GeneratorListRe, r"\1", RawCMakeOutput)
    GeneratorListStr = re.sub(NonGeneratorLinesRe, r"", GeneratorListStr)
    GeneratorListStr = re.sub(GeneratorNamePortion, r"\1", GeneratorListStr)
    GeneratorListStr = str.splitlines(GeneratorListStr)
    GeneratorListStr = [s.strip() for s in GeneratorListStr]
    
    if platform.system() == "Windows":
        FilteredGenListStr = [Str for Str in GeneratorListStr if re.match(r"Visual Studio (11|12|14) [0-9]+ \[arch\]", Str)]
        print("\n".join(FilteredGenListStr))
        if not FilteredGenListStr:
            print(
                "\nThe cmake in Windows does not seem to have generators for Visual Studio 11, 12,"
                "\nor 14 for 64-bit generation")
        else:
            FinalGenerator = '{GenName}'.format(GenName=FilteredGenListStr[0])
            FinalGenerator = re.sub(
                r"(Visual Studio (11|12|14) [0-9]+ )\[arch\]\s*$",
                r"\1Win64",
                FinalGenerator)
    elif platform.system() == "Linux":
        FinalGenerator = '{GenName}'.format(GenName=GeneratorListStr[0])
    else:
        FinalGenerator = '{GenName}'.format(GenName=GeneratorListStr[0])
    
    return FinalGenerator

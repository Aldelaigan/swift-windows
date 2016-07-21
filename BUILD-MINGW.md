# Build - Swift for Windows (MinGW)

Environment
----------------

1. Microsoft Windows 10 (64bit)
2. Run in "Msys64 MinGW64 Shell" in ADMINISTRATOR mode
   (Do not use the OS default "Command Prompt")

Choose any directory for working directory
```
export WORKDIR=<Your working directory>
```

Install Packages
----------------------
```
pacman -S mingw-w64-x86_64-cmake       # 3.4.1-1
pacman -S mingw-w64-x86_64-ninja       # 1.6.0-1
pacman -S mingw-w64-x86_64-clang       # 3.8.0-3
pacman -S mingw-w64-x86_64-icu         # 57.1-1
pacman -S mingw-w64-x86_64-libxml2     # 2.9.4-1
pacman -S mingw-w64-x86_64-wineditline # 2.101-4
pacman -S mingw-w64-x86_64-pkg-config  # 0.29.1-1
pacman -S make                         # 4.1-4
pacman -S python                       # 3.4.3-3
pacman -S python2                      # 2.7.11-1
```

Patch gcc header
----------------
  
 - Undefine _GLIBCXX_HAVE_TLS in the header file **`c++config.h`**.
```
  Insert three lines below the line 980 of /usr/lib/gcc/x86_64-pc-msys/5.3.0/include/c++/x86_64-pc-msys/bits/c++config.h
     #define _GLIBCXX_HAVE_TLS 1
+    #if defined (__clang__)
+    #undef _GLIBCXX_HAVE_TLS
+    #endif
``` 

Download sources
----------------
```
  git clone https://github.com/tinysun212/swift-windows.git swift
  git clone https://github.com/tinysun212/swift-llvm-cygwin.git llvm
  git clone https://github.com/tinysun212/swift-clang-cygwin.git clang
  git clone https://github.com/apple/swift-cmark.git cmark

# Choose the proper YYYYMMDD from the tag list of the repository. 
  cd swift; git checkout swift-mingw-YYYYMMDD ; cd ..
  cd llvm; git checkout swift-mingw-YYYYMMDD ; cd ..
  cd clang; git checkout swift-mingw-YYYYMMDD ; cd ..
  cd cmark; git checkout 6873b; cd ..
```

Build cmark
-----------
```
mkdir -p $WORKDIR/build/NinjaMinGW/cmark
cd $WORKDIR/build/NinjaMinGW/cmark
cmake -G Ninja -D CMAKE_BUILD_TYPE=RELEASE -DCMAKE_C_COMPILER=clang  -DCMAKE_CXX_COMPILER=clang++ ../../../cmark
ninja

cd src
cp -p libcmark.dll.a libcmark.a
cp -p libcmark.a  $WORKDIR/swift/libcmark.a
```

Build clang
-----------
```
// To create the symbolic link, you should use the 'MKLINK.exe'
// Run "Command Prompt" in ADMINISTRATOR mode
(Command Prompt) set WORKDIR=<Your working directory>
(Command Prompt) cd %WORKDIR%/llvm/tools
(Command Prompt) mklink /d clang ..\..\clang

mkdir $WORKDIR/build/NinjaMinGW/llvm
cd $WORKDIR/build/NinjaMinGW/llvm
cmake -G Ninja -D CMAKE_BUILD_TYPE=RELEASE -DCMAKE_C_COMPILER=clang  -DCMAKE_CXX_COMPILER=clang++ ../../../llvm

ninja
// Ignore the build error for lib\libLTO.dll.a
export PATH=$WORKDIR/build/NinjaMinGW/llvm/bin:$PATH
```

Build Swift
-----------
```
// You already set environment variables WORKDIR and PATH
// and you will use the commands - cmake, python, ninja, llvm tools here.
// If new command prompt is opened, set environment again.
// set PATH=%WORKDIR%\build\NinjaMinGW\llvm\bin;%PATH%;C:\Program Files (x86)\CMake\bin;c:\mingw64\bin;c:\Tool
// set PKG_CONFIG_PATH=c:/pkg-config/conf

// Workaround for cmark
cp -p $WORKDIR/build/NinjaMinGW/cmark/src/libcmark.a $WORKDIR/swift
mkdir -p $WORKDIR/build/NinjaMinGW/swift/bin		
cp $WORKDIR/build/NinjaMinGW/cmark/src/libcmark.dll $WORKDIR/build/NinjaMinGW/swift/bin		

cd $WORKDIR/build/NinjaMinGW/swift

cmake -G "MSYS Makefiles" ../../../swift -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=clang  -DCMAKE_CXX_COMPILER=clang++ -DPKG_CONFIG_EXECUTABLE=/mingw64/bin/pkg-config -DICU_UC_INCLUDE_DIR=/mingw64/include -DICU_UC_LIBRARY=/mingw64/lib/libicuuc.dll.a -DICU_I18N_INCLUDE_DIR=/mingw64/include -DICU_I18N_LIBRARY=/mingw64/lib/libicuin.dll.a -DSWIFT_INCLUDE_DOCS=FALSE -DSWIFT_PATH_TO_CMARK_BUILD=$WORKDIR/build/NinjaMinGW/cmark -DSWIFT_PATH_TO_CMARK_SOURCE=$WORKDIR/cmark  ../../../swift

make -k
```
  
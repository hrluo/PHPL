
# Setting up CGAL and other CMake-dependent  libraries on Windows.
# Step 1: Installing CMake, MinGW and Python on Windows
1. Download and execute the [CMake Win32 Installer](http://www.cmake.org/download/). Make sure to set the PATH variable and install via administrator account during installation and make sure you have install the correct architecture version of the MinGW (32/64 bits) and CMake. 
CMake is an 'installer' that does all the automatic chores like copy and paste the correct files to correct places, if you like you can think of it as.
2. Download and install [mingw-w64](http://mingw-w64.yaxm.org/doku.php/download/mingw-builds). The default options work. Also add the mingw-w64 programs to the system PATH variable (eg. append this string `C:\Program Files (x86)\mingw-w64\i686-4.9.2-posix-dwarf-rt_v4-rev2\mingw32\bin`)
MinGW is a collection of the open-source softwares that are popular in Linux, which can now be run under windows, including an open-source C/C++ compiler known as GCC.
3. Download and install [Python 3.5 or later](https://www.python.org/). If you already have installed Python 3.5 or later, type in `cmd` the pip package manager `pip install Cython`. Alternatively, we install [Cython](http://cython.org/) by running the accompanying `setup.py`.

# Step 2: Installing boost libraries for  MinGW on Windows
***WARNING: Do not go to boost version >=1.66, which introduces a lot of new stuffs incompatible with CMake. [See this thread](https://stackoverflow.com/questions/42123509/cmake-finds-boost-but-the-imported-targets-not-available-for-boost-version/42124857#42124857)***

### Folder setup
1. Extract downloaded `tar.gz` boost source [Boost C++ Library](https://dl.bintray.com/boostorg/release/), e.g. `C:\Program Files\boost_1_66_0`.
Boost library is a collection of convenient C++ commands that many CMake dependent software executes on. 
3. Create a folder for Boost.Build installation, e.g. `C:\Program Files\boost-build`, this folder will be used for building Boost libraries. 
4. Create a folder within for building, i.e. `C:\Program Files\boost_1_66_0\build`.
5. Create a folder for installation, e.g. `C:\Program Files\boost`.
Alternatively, I followed this https://jaimes.net/718/how-to-install-the-c-boost-libraries-on-windows/

### GCC setup
1. Open Command Prompt.
2. Run `g++ --version` and make sure gcc is installed and added to the PATH correctly.
3. If the output contains g++ version number then GCC should be set up properly to run from command line and you can continue.

### Boost.Build setup
1. Open Command Prompt and navigate to `C:\Program Files\boost_1_66_0\tools\build`.
2. Run `bootstrap.bat gcc` and 
```
cd "C:\Path\to\Boost\tools\build"
.\bootstrap
.\b2 install -j4 --build-type=minimal --toolset=gcc
cd "..\.."
.\bootstrap
.\b2 install -j4 --build-type=minimal --toolset=gcc
```
3. Run `b2 install --prefix="C:\Program Files\boost-build" --toolset="gcc"`.
4. Add `C:\Program Files\boost-build\bin` to Windows environmental variable PATH.

### Boost building
1. Open Command Prompt and navigate to `C:\Program Files\boost_1_65_0`.
2. Run following commands to install the boost build
```
b2 --build-dir="C:\Program Files\boost_1_66_0\build" --prefix="C:\Program Files\boost" toolset=gcc install
```

### Python Project setup
1. Add include folder, i.e. `C:\Program Files\boost\include\boost-1_65`.
2. Add linker folder, i.e. `C:\Program Files\boost\lib`.
3. Link required libraries, e.g. `libboost_regex-mgw48-mt-1_65.a`.

# Step 3: CMake with MinGW setups
Before we install CGAL we need to `C:\Program Files\boost\include\boost-1_65` into PATH in any case CMake cannot detect the existence of BOOST libraries.
Navigate to the extracted folder of CGAL and execute the following commands:
If you use CMake-gui, tick the checkbox "Advanced" (between checkbox "Grouped" and button "Add Entry")and the checkbox "CGAL_Boost_USE_STATIC_LIBS".
```
cd "C:\Path\to\CGAL"
mkdir build
cd build

cmake -G "MinGW Makefiles" ..
	mingw32-make -j4 all
	mingw32-make -j4 install
	mingw32-make install_FindCGAL
```
The last three commands are optional and simply can be ignored if you are planning to use IDE to include CGAL libraries. ***Warning: CMake's commands and parameters are case-sensitive, so do not try, just copy and paste my codes.***
In any case CGAL fail to find BOOST libraries, showing 'unable to find boost_system boost_thread' etc,
**(Bruteforce solution)** just make a copy of the missing libraries under `C:\Program Files\boost\lib` and simply chop off any description about how it is compiled. (Do not worry about that, it is simply equivalent to change FindBOOST in CMake.) Run again.
**(Complicate solution)** You probably need a later version of CMake that has a better adaption to the naming rules of BOOST. From version 1.65 BOOST updates its naming rules for linkers so CMake cannot correctly identify them sometimes, try redo everything. [See this thread](https://stackoverflow.com/questions/42123509/cmake-finds-boost-but-the-imported-targets-not-available-for-boost-version/42124857#42124857)

# Step 4: Test if everything goes right
## Boost testing
Use following code

```
#include <boost/regex.hpp>
#include <iostream>
int main()
{
    std::string line;
    boost::regex pat( "^Subject: (Re: |Aw: )*(.*)" );

    while (std::cin)
    {
        std::getline(std::cin, line);
        boost::smatch matches;
        if (boost::regex_match(line, matches, pat))
            std::cout << matches[2] << std::endl;
    }
}

```
Add the following path to your includes list:
`C:/BOOST/include/boost-version`
Add the following path to your  **additional library directories**  list
`C:/BOOST/lib`
For example you type in cmd
`gcc test.cpp -IC:/BOOST/include/boost-1_65 -LC:/BOOST/lib`

All these complication above is due to the lack of package manager under MinGW, so probably a better solution is to go with MSYS2: https://ethiy.github.io/2017/01/04/CGAL/

# Reference
https://gist.github.com/sim642/29caef3cc8afaa273ce6#installing-boost-libraries-for-gcc-mingw-on-windows
https://github.com/tudelft3d/masbcpp/wiki/Building-on-Windows-with-CMake-and-MinGW
https://ethiy.github.io/2016/12/27/CGAL/
https://stackoverflow.com/questions/13280823/cmake-not-finding-boost
https://xinyustudio.wordpress.com/2012/07/18/setup-cgal-in-windows-7-step-by-step-tutorial/

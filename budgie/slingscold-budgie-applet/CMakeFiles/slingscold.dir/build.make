# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.10

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list


# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/nicholas/Dokumenter/git/slingscold/budgie/slingscold-budgie-applet

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/nicholas/Dokumenter/git/slingscold/budgie/slingscold-budgie-applet

# Include any dependencies generated for this target.
include CMakeFiles/slingscold.dir/depend.make

# Include the progress variables for this target.
include CMakeFiles/slingscold.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/slingscold.dir/flags.make

Slingscold.c: Slingscold.vala
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --blue --bold --progress-dir=/home/nicholas/Dokumenter/git/slingscold/budgie/slingscold-budgie-applet/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Generating Slingscold.c"
	/usr/bin/valac -C -b /home/nicholas/Dokumenter/git/slingscold/budgie/slingscold-budgie-applet -d /home/nicholas/Dokumenter/git/slingscold/budgie/slingscold-budgie-applet --pkg=gtk+-3.0 --pkg=gee-0.8 --pkg=gio-unix-2.0 --pkg=gio-2.0 --pkg=libpeas-gtk-1.0 --pkg=gobject-2.0 --pkg=budgie-1.0 /home/nicholas/Dokumenter/git/slingscold/budgie/slingscold-budgie-applet/Slingscold.vala

CMakeFiles/slingscold.dir/Slingscold.c.o: CMakeFiles/slingscold.dir/flags.make
CMakeFiles/slingscold.dir/Slingscold.c.o: Slingscold.c
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/nicholas/Dokumenter/git/slingscold/budgie/slingscold-budgie-applet/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Building C object CMakeFiles/slingscold.dir/Slingscold.c.o"
	/usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -o CMakeFiles/slingscold.dir/Slingscold.c.o   -c /home/nicholas/Dokumenter/git/slingscold/budgie/slingscold-budgie-applet/Slingscold.c

CMakeFiles/slingscold.dir/Slingscold.c.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing C source to CMakeFiles/slingscold.dir/Slingscold.c.i"
	/usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -E /home/nicholas/Dokumenter/git/slingscold/budgie/slingscold-budgie-applet/Slingscold.c > CMakeFiles/slingscold.dir/Slingscold.c.i

CMakeFiles/slingscold.dir/Slingscold.c.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling C source to assembly CMakeFiles/slingscold.dir/Slingscold.c.s"
	/usr/bin/cc $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -S /home/nicholas/Dokumenter/git/slingscold/budgie/slingscold-budgie-applet/Slingscold.c -o CMakeFiles/slingscold.dir/Slingscold.c.s

CMakeFiles/slingscold.dir/Slingscold.c.o.requires:

.PHONY : CMakeFiles/slingscold.dir/Slingscold.c.o.requires

CMakeFiles/slingscold.dir/Slingscold.c.o.provides: CMakeFiles/slingscold.dir/Slingscold.c.o.requires
	$(MAKE) -f CMakeFiles/slingscold.dir/build.make CMakeFiles/slingscold.dir/Slingscold.c.o.provides.build
.PHONY : CMakeFiles/slingscold.dir/Slingscold.c.o.provides

CMakeFiles/slingscold.dir/Slingscold.c.o.provides.build: CMakeFiles/slingscold.dir/Slingscold.c.o


# Object files for target slingscold
slingscold_OBJECTS = \
"CMakeFiles/slingscold.dir/Slingscold.c.o"

# External object files for target slingscold
slingscold_EXTERNAL_OBJECTS =

libslingscold.so: CMakeFiles/slingscold.dir/Slingscold.c.o
libslingscold.so: CMakeFiles/slingscold.dir/build.make
libslingscold.so: CMakeFiles/slingscold.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/home/nicholas/Dokumenter/git/slingscold/budgie/slingscold-budgie-applet/CMakeFiles --progress-num=$(CMAKE_PROGRESS_3) "Linking C shared library libslingscold.so"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/slingscold.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/slingscold.dir/build: libslingscold.so

.PHONY : CMakeFiles/slingscold.dir/build

CMakeFiles/slingscold.dir/requires: CMakeFiles/slingscold.dir/Slingscold.c.o.requires

.PHONY : CMakeFiles/slingscold.dir/requires

CMakeFiles/slingscold.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/slingscold.dir/cmake_clean.cmake
.PHONY : CMakeFiles/slingscold.dir/clean

CMakeFiles/slingscold.dir/depend: Slingscold.c
	cd /home/nicholas/Dokumenter/git/slingscold/budgie/slingscold-budgie-applet && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/nicholas/Dokumenter/git/slingscold/budgie/slingscold-budgie-applet /home/nicholas/Dokumenter/git/slingscold/budgie/slingscold-budgie-applet /home/nicholas/Dokumenter/git/slingscold/budgie/slingscold-budgie-applet /home/nicholas/Dokumenter/git/slingscold/budgie/slingscold-budgie-applet /home/nicholas/Dokumenter/git/slingscold/budgie/slingscold-budgie-applet/CMakeFiles/slingscold.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/slingscold.dir/depend


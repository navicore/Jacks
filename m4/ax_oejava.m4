# OnExtent, LLC created this file by modifying an original
# program, ax_jni_include_dir.m4.  Original program license:
#
#   Copyright (c) 2008 Don Anderson <dda@sleepycat.com>
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved. This file is offered as-is, without any
#   warranty.

AC_DEFUN([AX_OEJAVA],[

	if test "x$JAVA_HOME" = x; then
		AC_MSG_ERROR([JAVA_HOME is not set])
	fi

	AC_CHECK_PROG([JAVAC], [javac], [${JAVA_HOME}/bin/javac], ,[$JAVA_HOME/bin])
	AC_CHECK_PROG([JAVA], [java], [${JAVA_HOME}/bin/java], ,[$JAVA_HOME/bin])
	
	JNI_INCLUDE_DIRS="$JAVA_HOME/include"

	# get the likely subdirectories for system specific java includes
	case "$host_os" in
	bsdi*)          _JNI_INC_SUBDIRS="bsdos";;
	netbsd*)        _JNI_INC_SUBDIRS="netbsd";;
	linux*)         _JNI_INC_SUBDIRS="linux genunix";;
	osf*)           _JNI_INC_SUBDIRS="alpha";;
	solaris*)       _JNI_INC_SUBDIRS="solaris";;
	mingw*)		_JNI_INC_SUBDIRS="win32";;
	cygwin*)	_JNI_INC_SUBDIRS="win32";;
	*)              _JNI_INC_SUBDIRS="genunix";;
	esac
	
	# add any subdirectories that are present
	for JINCSUBDIR in $_JNI_INC_SUBDIRS
	do
		if test -d "$JAVA_HOME/include/$JINCSUBDIR"; then
			JNI_INCLUDE_DIRS="$JNI_INCLUDE_DIRS $JAVA_HOME/include/$JINCSUBDIR"
		fi
	done
	
	AC_MSG_RESULT([using java include dirs: $JNI_INCLUDE_DIRS])
])


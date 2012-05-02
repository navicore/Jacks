AC_PREREQ(2.60)
AC_INIT([Jacks Pre Alpha], [0.1.3], [info@onextent.com])
AC_DEFINE([OE_VERSION_MAJ],[0],[major version])
AC_DEFINE([OE_VERSION_MIN],[1],[minor version])
AC_DEFINE([OE_VERSION_UPT],[3],[update version])
AC_CONFIG_AUX_DIR([scripts])
AC_PROG_LIBTOOL
AM_INIT_AUTOMAKE( [-Wall] )
AM_CONFIG_HEADER(config.h)
AC_CONFIG_MACRO_DIR([m4])
if test "$INSTALL" = "${srcdir}/scripts/install-sh -c"; then
  INSTALL='\$(..)./scripts/install-sh -c'
fi
AM_PROG_CC_C_O
AC_PROG_CC_C99
AC_C_BIGENDIAN                                                                  
AC_PREFIX_DEFAULT(/usr/local/jacks)
AC_PROG_INSTALL

# Checks for typedefs, structures, and compiler characteristics.
AC_HEADER_STDBOOL
AC_C_INLINE
AC_TYPE_PID_T
AC_TYPE_SIZE_T
AC_CHECK_TYPES([ptrdiff_t])

# Checks for library functions.
    AC_FUNC_ERROR_AT_LINE
    AC_FUNC_FORK
    AC_FUNC_MALLOC
    AC_FUNC_MKTIME
    AC_FUNC_REALLOC
    AC_FUNC_STRCOLL
    AC_CHECK_FUNCS([floor gethostbyname gettimeofday localeconv memchr memset modf pow setlocale socket sqrt strchr strcspn strerror strpbrk strrchr strstr strtoul])


CFLAGS="-Wall -Wno-unused $CFLAGS"

#experiment, don't like it, remove it
CFLAGS="$CFLAGS -I/usr/pkg/include -I/usr/local/include -I/opt/local/include -I/usr/include"
LDFLAGS="$LDFLAGS -L/usr/pkg/lib -L/usr/local/lib -L/opt/local/lib -L/usr/lib"

_static_tests=no
AC_ARG_ENABLE([static-tests],
        [  --enable-static-tests   Use '-static' on unit tests. valgrind and gdb
                          don't like libtool scripts],
	[AC_MSG_RESULT([using --enable-static-tests])
    _static_tests=yes]
    )
if test x$_static_tests = xyes ; then
AC_SUBST(OE_TESTER_LDFLAGS, "-static")
AC_SUBST(OE_TESTER_CFLAGS, "")
else
AC_SUBST(OE_TESTER_LDFLAGS, "")
AC_SUBST(OE_TESTER_CFLAGS, "")
fi


#=============================================================================#
#                               configure jack                                #
#=============================================================================#
AX_OE_JACK()

#=============================================================================#
#                               configure compiler                            #
#=============================================================================#
echo "setting compiler flag variables.  build_vendor is $build_vendor build_os is $build_os"

OE_APP_CFLAGS=""
OE_LIB_CFLAGS="$CFLAGS"
OE_APP_LDFLAGS=""
OE_LIB_LDFLAGS="$OE_LIB_LDFLAGS -release 0.0"
case "$host_os" in
        darwin*)        OE_LIB_LDFLAGS="$OE_LIB_LDFLAGS" && OE_LIB_CFLAGS="$OE_LIB_CFLAGS";;
        *)              ;;
esac
AC_SUBST(OE_LIB_LDFLAGS)
AC_SUBST(OE_LIB_CFLAGS)
AC_SUBST(OE_APP_CFLAGS)
AC_SUBST(OE_APP_LDFLAGS)


#=============================================================================#
#                                                                             #
#                                                                             #
#                    configure scriping APIs via SWIG                         #
#                                                                             #
#                                                                             #
#=============================================================================#

case "$host_os" in
        darwin*)        OE_SHSUF=".dylib";;
        *)              OE_SHSUF=".so";;
esac
AC_SUBST([OE_SHSUF])


AX_PKG_SWIG(1.3.17, [], [AC_MSG_RESULT([SWIG not found.  This is fine unless you have modified any *.i files.]) ])
OE_LIST_OF_SCRIPTING_APIS_TO_BUILD=

#=============================================================================#
#                            configure perl support                           #
#=============================================================================#
# always make perl for now...
_with_perl=no
AC_ARG_WITH([perl],
        [  --with-perl             build perl api],
	[AC_MSG_RESULT([building --with-perl.])
    _with_perl=yes]
    )

if test x$_with_perl = xyes ; then

#AX_PERL_EXT_FLAGS([PERLXS_CFLAGS], [PERLXS_LDFLAGS])
#AC_SUBST([PERLXS_CFLAGS])
#AX_PERL_EXT_LDFLAGS([PERLXS_LDFLAGS], [PERLXS_LDFLAGS])
##AC_SUBST([PERLXS_CFLAGS])
#AC_SUBST([PERLXS_LDFLAGS])
#AX_PERL_EXT()
#if test x"$PERL" = x; then
#    AC_ERROR(["cannot find Perl"])
#fi
#AC_SUBST([PERL_EXT_CPPFLAGS])
#AC_SUBST([PERL_EXT_LDFLAGS])

AX_PERL_EXT_CFLAGS([PERLXS_CFLAGS])
AC_SUBST([PERLXS_CFLAGS])
AX_PERL_EXT_LDFLAGS([PERLXS_LDFLAGS])
AC_SUBST([PERLXS_LDFLAGS])

OE_LIST_OF_SCRIPTING_APIS_TO_BUILD="perl $OE_LIST_OF_SCRIPTING_APIS_TO_BUILD"
fi

_perl_module_install=yes
AC_ARG_ENABLE([perl-modinst],
        [  --enable-perl-modinst   Specify whether to install the perl
                          module into the site_perl dirs],
	[AC_MSG_RESULT([using --enable-perlmod-inst. installing perl module into site_perl])
    _perl_module_install=yes]
    )

if test x$_perl_module_install = xyes ; then
AM_CONDITIONAL(OE_INSTALL_PERL_MODULE, true)
else
AM_CONDITIONAL(OE_INSTALL_PERL_MODULE, false)
fi


#=============================================================================#
#                               configure lua                                 #
#=============================================================================#

CHECK_OE_LUA([],[AC_MSG_ERROR([can not find lua])])

_with_swig_lua=no
AC_ARG_WITH([lua],
        [  --with-lua              build lua api],
	[AC_MSG_RESULT([building --with-lua.])
    _with_swig_lua=yes]
    )

if test x$_with_swig_lua = xyes ; then
OE_LIST_OF_SCRIPTING_APIS_TO_BUILD="$OE_LIST_OF_SCRIPTING_APIS_TO_BUILD lua"
fi


#=============================================================================#
#                          configure python2 support                          #
#=============================================================================#
_with_python2=no

AC_ARG_WITH([python2],
        [  --with-python2           build python api],
	[AC_MSG_RESULT([building --with-python2.])
    _with_python2=yes]
    )

if test x$_with_python2 = xyes ; then
AX_PYTHON_DEVEL([>='2.1.0'])
AC_SUBST([PYTHON_CPPFLAGS])
AC_SUBST([PYTHON_LDFLAGS])
AC_SUBST([PYTHON_EXTRA_LIBS])
AC_SUBST([PYTHON_EXTRA_LDFLAGS])
OE_LIST_OF_SCRIPTING_APIS_TO_BUILD="$OE_LIST_OF_SCRIPTING_APIS_TO_BUILD python2"
fi


#=============================================================================#
#                           configure python3 support                         #
#=============================================================================#
_with_python3=no

AC_ARG_WITH([python3],
        [  --with-python3          build python api],
	[AC_MSG_RESULT([building --with-python3.])
    _with_python3=yes]
    )

if test x$_with_python3 = xyes ; then
AX_PYTHON_DEVEL([>='3.1.0'])
AC_SUBST([PYTHON_CPPFLAGS])
AC_SUBST([PYTHON_LDFLAGS])
AC_SUBST([PYTHON_EXTRA_LIBS])
AC_SUBST([PYTHON_EXTRA_LDFLAGS])
OE_LIST_OF_SCRIPTING_APIS_TO_BUILD="$OE_LIST_OF_SCRIPTING_APIS_TO_BUILD python3"
fi


#=============================================================================#
#                       configure python dist support                         #
#=============================================================================#
_python_module_install=yes
AC_ARG_ENABLE([python-modinst],
        [  --enable-python-modinst   Specify whether to install the python
                          module into site-packages],
    [AC_MSG_RESULT([using --enable-pythonmod-inst. installing pyton module site-packages])
    _python_module_install=yes]
    )

if test x$_python_module_install = xyes ; then
AM_CONDITIONAL(OE_INSTALL_PYTHON_MODULE, true)
else
AM_CONDITIONAL(OE_INSTALL_PYTHON_MODULE, false)
fi


#=============================================================================#
#                            configure ruby support                           #
#=============================================================================#
_with_ruby=no
AC_ARG_WITH([ruby],
        [  --with-ruby             build ruby api],
	[AC_MSG_RESULT([building --with-ruby.])
    _with_ruby=yes]
    )

if test x$_with_ruby = xyes ; then
AX_RUBY_DEVEL([])
AC_SUBST([RUBY_CPPFLAGS])
AC_SUBST([RUBY_LDFLAGS])
AC_SUBST([RUBY_EXTRA_LIBS])
OE_LIST_OF_SCRIPTING_APIS_TO_BUILD="$OE_LIST_OF_SCRIPTING_APIS_TO_BUILD ruby"
fi

AC_SUBST(OE_LIST_OF_SCRIPTING_APIS_TO_BUILD)

#=============================================================================#
#                                                                             #
#                               SWIG                                          #
#                                                                             #
#=============================================================================#
#                                                                             #
# if you are building any of the lang support api modules, you will be        #
# compiling swig-generated C code.  if you modify Jacks.i you must run the #
# 'make swig' target to regenerate the C source.  The output of swig, the C   #
# source, is checked into git so you do not need to have swig installed to    #
# build the system if you are not modifying the .i files.                     #
#                                                                             #
#=============================================================================#


#=============================================================================#
#                                                                             #
#                                                                             #
#                           output Makefile.in(s)                             #
#                                                                             #
#                                                                             #
#=============================================================================#

AC_OUTPUT(
        Makefile
        corelib/Makefile
        corelib/test/Makefile
        corelib/lfds/Makefile
        modules/Makefile
        modules/python2/Makefile
        modules/python2/example-clients/Makefile
        modules/python2/setup.py
        modules/python2/test/Makefile
        modules/python3/Makefile
        modules/python3/example-clients/Makefile
        modules/python3/setup.py
        modules/python3/test/Makefile
        modules/ruby/Makefile
        modules/ruby/example-clients/Makefile
        modules/ruby/test/Makefile
        modules/lua/Makefile
        modules/lua/test/Makefile
        modules/lua/example-clients/Makefile
        modules/perl/Makefile
        modules/perl/t/Makefile
        modules/perl/example-clients/Makefile
        modules/perl/jacks.pod
        modules/perl/Build.PL
        modules/perl/OeLinkBin.PL,
        echo timestamp > stamp-h
        )


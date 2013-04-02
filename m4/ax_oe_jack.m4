AC_DEFUN([AX_OE_JACK],
[
  JACK_CFLAGS=`pkg-config jack --cflags`
  AC_MSG_RESULT([jack cflags: $JACK_CFLAGS])
  JACK_LIBS=`pkg-config jack --libs`
  AC_MSG_RESULT([jack libs: $JACK_LIBS])

  AC_SEARCH_LIBS([jack_client_open],[jack],
      [JACK_LIBS="$JACK_LIBS $LIBS"],
      [AC_MSG_WARN([jack lib not found])]
      )
  AC_CHECK_HEADERS([jack/jack.h],
      [JACK_CFLAGS="$JACK_CFLAGS $CFLAGS"],
      [],
      [AC_MSG_WARN.h found. Please install and/or set CFLAGS and LDFLAGS])]
      )

  AC_SUBST(JACK_LIBS)
  AC_SUBST(JACK_CFLAGS)

])


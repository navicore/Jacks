# The contents of this file are subject to the Apache License
# Version 2.0 (the "License"); you may not use this file except in
# compliance with the License. You may obtain a copy of the License 
# from the file named COPYING and from http://www.apache.org/licenses/.
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 
# The Original Code is OeScript.
# 
# The Initial Developer of the Original Code is OnExtent, LLC.
# Portions created by OnExtent, LLC are Copyright (C) 2008-2009
# OnExtent, LLC. All Rights Reserved.

AC_DEFUN([AX_OPENSSL],
[
  AC_ARG_WITH([openssl-header],
      [  --with-openssl-header=PATH TO ssl.h],
      [OPENSSL_HEADER="$withval"]
      )

  AC_ARG_WITH([openssl-err-header],
      [  --with-openssl-header=PATH TO err.h],
      [OPENSSL_ERR_HEADER="$withval"]
      )

  AC_ARG_WITH([openssl-rand-header],
      [  --with-openssl-header=PATH TO rand.h],
      [OPENSSL_RAND_HEADER="$withval"]
      )

  #presuming if OPENSSL_HEADER overide is set that you know what you are doing
  if test -z $OPENSSL_HEADER ; then #override skipping

  old_LIBS="$LIBS"

  AC_CHECK_HEADERS([openssl/ssl.h],
      [OPENSSL_HEADER="openssl/ssl.h"],
      [
        AC_CHECK_HEADERS([ssl.h],
            [OPENSSL_HEADER="ssl.h"],
            [AC_MSG_WARN([no openssl ssl.h found. Please install and/or set CFLAGS and LDFLAGS])]
        )
      ]
      )

  AC_CHECK_HEADERS([openssl/err.h],
      [OPENSSL_ERR_HEADER="openssl/err.h"],
      [
        AC_CHECK_HEADERS([err.h],
            [OPENSSL_ERR_HEADER="err.h"],
            [AC_MSG_WARN([no openssl err.h found. Please install and/or set CFLAGS and LDFLAGS])]
        )
      ]
      )

  AC_CHECK_HEADERS([openssl/rand.h],
      [OPENSSL_RAND_HEADER="openssl/rand.h"],
      [
        AC_CHECK_HEADERS([rand.h],
            [OPENSSL_RAND_HEADER="rand.h"],
            [AC_MSG_WARN([no openssl rand.h found. Please install and/or set CFLAGS and LDFLAGS])]
        )
      ]
      )


  AC_SEARCH_LIBS([SSL_shutdown],[ssl],
      [OPENSSL_LIBS="$LIBS"],
      [AC_MSG_WARN([openssl lib not found])]
      )

  LIBS="$old_LIBS"

  fi #end override skipping

  if test -z $OPENSSL_HEADER ; then
    AM_CONDITIONAL(OE_USE_OPENSSL,false)
    AC_MSG_RESULT([openssl header not found])
    ifelse([$3], , :, [$3])
  else
    AM_CONDITIONAL(OE_USE_OPENSSL,true)
    AC_DEFINE([OE_USE_OPENSSL],[],[compile support for openssl])
    AC_DEFINE_UNQUOTED(OPENSSL_HEADER, ["$OPENSSL_HEADER"], ["openssl header"])
    AC_DEFINE_UNQUOTED(OPENSSL_ERR_HEADER, ["$OPENSSL_ERR_HEADER"], ["openssl err header"])
    AC_DEFINE_UNQUOTED(OPENSSL_RAND_HEADER, ["$OPENSSL_RAND_HEADER"], ["openssl rand header"])
    AC_SUBST([OPENSSL_HEADER])
    AC_SUBST([OPENSSL_ERR_HEADER])
    AC_SUBST([OPENSSL_RAND_HEADER])

    AC_SUBST(OPENSSL_LIBS)

    ifelse([$2], , :, [$2])
  fi
])


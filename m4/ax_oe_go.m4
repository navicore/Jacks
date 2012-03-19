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

AC_DEFUN([AX_OE_GO_DEVEL],
[AC_CHECK_PROG(GO_CONFIG,8g,8g)
if test -n "$GO_CONFIG"; then
  AC_MSG_CHECKING([for go installation])
  GO_CFLAGS=
  #GO_CFLAGS=`$R_CONFIG CMD config --cppflags`
  GO_LDFLAGS=
  #GO_LDFLAGS=`$R_CONFIG CMD config --ldflags`
  AC_MSG_RESULT([ GO_CFLAGS: $GO_CFLAGS GO_LDFLAGS: $GO_LDFLAGS])
else
  AC_MSG_ERROR([go installation not found])
fi
])


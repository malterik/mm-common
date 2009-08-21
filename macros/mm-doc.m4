## Copyright (c) 2009  Openismus GmbH  <http://www.openismus.com/>
##
## This file is part of mm-common.
##
## mm-common is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published
## by the Free Software Foundation, either version 2 of the License,
## or (at your option) any later version.
##
## mm-common is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with mm-common.  If not, see <http://www.gnu.org/licenses/>.

#serial 20090821

## _MM_CONFIG_DOCTOOL_DIR
##
## Query pkg-config for the location of the documentation utilities
## shared by the GNOME C++ bindings.  This is the code path invoked
## from MM_CONFIG_DOCTOOL_DIR when called without a directory name.
##
m4_define([_MM_CONFIG_DOCTOOL_DIR],
[dnl
AC_PROVIDE([$0])[]dnl
AC_REQUIRE([PKG_PROG_PKG_CONFIG])[]dnl
dnl
AC_MSG_CHECKING([location of documentation utilities])
AS_IF([test "x$MMDOCTOOLDIR" = x],
[
  mm_doctooldir=`$PKG_CONFIG --variable doctooldir glibmm-2.4 2>&AS_MESSAGE_LOG_FD`
  AS_IF([test "[$]?" -ne 0],
        [AC_MSG_ERROR([[not found
The required module glibmm could not be found on this system.  If you
are running a binary distribution and the glibmm package is installed,
make sure that any separate development package for glibmm is installed
as well.  If you built glibmm yourself, it may be necessary to adjust
the PKG_CONFIG_PATH environment variable for pkg-config to find it.
]])])
  AS_IF([test "x$mm_doctooldir" = x],
        [AC_MSG_ERROR([[not found
The glibmm module is available, but the installation of glibmm on this
machine is missing the shared documentation utilities of the GNOME C++
bindings.  It may be necessary to upgrade to a more recent release of
glibmm in order to build $PACKAGE_NAME.
]])])
  MMDOCTOOLDIR=$mm_doctooldir[]dnl
])
AC_MSG_RESULT([$MMDOCTOOLDIR])[]dnl
])

## MM_CONFIG_DOCTOOL_DIR([directory])
##
## Define the location of the documentation utilities shared by the
## GNOME C++ binding modules.  If the <directory> argument is given,
## it should name a directory relative to the toplevel directory of
## the source tree.
##
## The directory name is used by mm-common-prepare as the destination
## for copying the required files into the source tree.  If you make
## use of this feature in order to avoid a dependency on glibmm, make
## sure to include the installed files in the distribution tarball of
## your package.
##
AC_DEFUN([MM_CONFIG_DOCTOOL_DIR],
[dnl
AC_REQUIRE([_MM_PRE_INIT])[]dnl
m4_ifval([$1], [MMDOCTOOLDIR='[$]{top_srcdir}/$1'], [AC_REQUIRE([_MM_CONFIG_DOCTOOL_DIR])])
AC_SUBST([MMDOCTOOLDIR])[]dnl
])

## _MM_ARG_ENABLE_DOCUMENTATION
##
## Implementation of MM_ARG_ENABLE_DOCUMENTATION, pulled in indirectly
## through AC_REQUIRE() to make sure it is expanded only once.
##
m4_define([_MM_ARG_ENABLE_DOCUMENTATION],
[dnl
AC_PROVIDE([$0])[]dnl
dnl
AC_ARG_VAR([DOT], [path to dot utility])[]dnl
AC_ARG_VAR([DOXYGEN], [path to Doxygen utility])[]dnl
AC_ARG_VAR([XSLTPROC], [path to xsltproc utility])[]dnl
dnl
AC_PATH_PROG([DOT], [dot], [dot])
AC_PATH_PROG([DOXYGEN], [doxygen], [doxygen])
AC_PATH_PROG([XSLTPROC], [xsltproc], [xsltproc])
dnl
AC_ARG_ENABLE([documentation],
              [AS_HELP_STRING([--disable-documentation],
                              [do not build or install the documentation])],
              [ENABLE_DOCUMENTATION=$enableval],
              [ENABLE_DOCUMENTATION=auto])
AS_IF([test "x$ENABLE_DOCUMENTATION" != xno],
[
  mm_msg=
  AS_IF([test "x$PERL" = xperl],
        [mm_msg='Perl is required for installing the documentation.'],
        [test "x$USE_MAINTAINER_MODE" != xno],
  [
    for mm_prog in "$DOT" "$DOXYGEN" "$XSLTPROC"
    do
      AS_CASE([$mm_prog], [[dot|doxygen|xsltproc]], [dnl
mm_msg='The reference documentation cannot be generated
because the required tool '$mm_prog' could not be found.'
break])
    done
  ])
  AS_IF([test "x$mm_msg" = x],
        [ENABLE_DOCUMENTATION=yes],
        [test "x$ENABLE_DOCUMENTATION" = xyes],
        [AC_MSG_FAILURE([[$mm_msg]])],
        [AC_MSG_WARN([[$mm_msg]])])[]dnl
])
AM_CONDITIONAL([ENABLE_DOCUMENTATION], [test "x$ENABLE_DOCUMENTATION" = xyes])
AC_SUBST([DOXYGEN_TAGFILES], [[]])
AC_SUBST([DOCINSTALL_FLAGS], [[]])[]dnl
])

## MM_ARG_ENABLE_DOCUMENTATION
##
## Provide the --disable-documentation configure option.  By default,
## the documentation will be included in the build.  If not explicitly
## disabled, also check whether the necessary tools are installed, and
## abort if any are missing.
##
## The tools checked for are Perl, dot, Doxygen and xsltproc.  The
## substitution variables PERL, DOT, DOXYGEN and XSLTPROC are set to
## the command paths, unless overridden in the user environment.
##
## If the package provides the --enable-maintainer-mode option, the
## tools dot, Doxygen and xsltproc are mandatory only when maintainer
## mode is enabled.  Perl is required for the installdox utility even
## if not in maintainer mode.
##
AC_DEFUN([MM_ARG_ENABLE_DOCUMENTATION],
[dnl
AC_BEFORE([$0], [MM_ARG_WITH_TAGFILE_DOC])[]dnl
AC_REQUIRE([_MM_PRE_INIT])[]dnl
AC_REQUIRE([MM_PATH_PERL])[]dnl
AC_REQUIRE([MM_CONFIG_DOCTOOL_DIR])[]dnl
AC_REQUIRE([_MM_ARG_ENABLE_DOCUMENTATION])[]dnl
])

## _MM_ARG_WITH_TAGFILE_DOC(option-basename, pkg-variable, tagfilename, [module])
##
m4_define([_MM_ARG_WITH_TAGFILE_DOC],
[dnl
  AC_MSG_CHECKING([for $1 documentation])
  AC_ARG_WITH([$1-doc],
              [AS_HELP_STRING([[--with-$1-doc=[TAGFILE@]HTMLREFDIR]],
                              [Link to external $1 documentation]m4_ifval([$4], [[ [auto]]]))],
  [
    mm_htmlrefdir=`[expr "@$withval" : '.*@\(.*\)' 2>&]AS_MESSAGE_LOG_FD`
    mm_tagname=`[expr "/$withval" : '[^@]*[\\/]\([^\\/@]*\)@' 2>&]AS_MESSAGE_LOG_FD`
    mm_tagpath=`[expr "X$withval" : 'X\([^@]*\)@' 2>&]AS_MESSAGE_LOG_FD`
    test "x$mm_tagname" != x || mm_tagname="$3"
    test "x$mm_tagpath" != x || mm_tagpath=$mm_tagname[]dnl
  ], [
    mm_htmlrefdir=
    mm_tagname="$3"
    mm_tagpath=$mm_tagname[]dnl
  ])
  # Prepend working direcory if the tag file path starts with ./ or ../
  AS_CASE([$mm_tagpath], [[.[\\/]*|..[\\/]*]], [mm_tagpath=`pwd`/$mm_tagpath])

m4_ifval([$4], [dnl
  # If no local directory was specified, get the default from the .pc file
  AS_IF([test "x$mm_htmlrefdir" = x],
  [
    mm_htmlrefdir=`$PKG_CONFIG --variable=htmlrefdir "$4" 2>&AS_MESSAGE_LOG_FD`dnl
  ])
  # If the user specified a Web URL, allow it to override the public location
  AS_CASE([$mm_htmlrefdir], [[http://*|https://*]], [mm_htmlrefpub=$mm_htmlrefdir],
  [
    mm_htmlrefpub=`$PKG_CONFIG --variable=htmlrefpub "$4" 2>&AS_MESSAGE_LOG_FD`
    test "x$mm_htmlrefpub" != x || mm_htmlrefpub=$mm_htmlrefdir
    test "x$mm_htmlrefdir" != x || mm_htmlrefdir=$mm_htmlrefpub
  ])
  # The user-supplied tag-file name takes precedence if it includes the path
  AS_CASE([$mm_tagpath], [[*[\\/]*]],,
  [
    mm_doxytagfile=`$PKG_CONFIG --variable=doxytagfile "$4" 2>&AS_MESSAGE_LOG_FD`
    test "x$mm_doxytagfile" = x || mm_tagpath=$mm_doxytagfile
  ])
  # Remove trailing slashes and translate to URI
  mm_htmlrefpub=`[expr "X$mm_htmlrefpub" : 'X\(.*[^\\/]\)[\\/]*' 2>&]AS_MESSAGE_LOG_FD |\
                 [sed 's,[\\],/,g;s, ,%20,g;s,^/,file:///,' 2>&]AS_MESSAGE_LOG_FD`
])[]dnl
  mm_htmlrefdir=`[expr "X$mm_htmlrefdir" : 'X\(.*[^\\/]\)[\\/]*' 2>&]AS_MESSAGE_LOG_FD |\
                 [sed 's,[\\],/,g;s, ,%20,g;s,^/,file:///,' 2>&]AS_MESSAGE_LOG_FD`

  AC_MSG_RESULT([$mm_tagpath@$mm_htmlrefdir])

  AS_IF([test "x$USE_MAINTAINER_MODE" != xno && test ! -f "$mm_tagpath"],
        [AC_MSG_WARN([Doxygen tag file $3 not found])])
  AS_IF([test "x$mm_htmlrefdir" = x],
        [AC_MSG_WARN([Location of external $1 documentation not set])],
        [AS_IF([test "x$DOCINSTALL_FLAGS" = x],
               [DOCINSTALL_FLAGS="-l '$mm_tagname@$mm_htmlrefdir/'"],
               [DOCINSTALL_FLAGS="$DOCINSTALL_FLAGS -l '$mm_tagname@$mm_htmlrefdir/'"])])

  AS_IF([test "x$mm_$2" = x], [mm_val=$mm_tagpath], [mm_val="$mm_tagpath=$mm_$2"])
  AS_IF([test "x$DOXYGEN_TAGFILES" = x],
        [DOXYGEN_TAGFILES=[\]"$mm_val[\]"],
        [DOXYGEN_TAGFILES="$DOXYGEN_TAGFILES "[\]"$mm_val[\]"])[]dnl
])

## MM_ARG_WITH_TAGFILE_DOC(tagfilename, [module])
##
## Provide a --with-<tagfilebase>-doc=[/path/tagfile@]htmlrefdir configure
## option, which may be used to specify the location of a tag file and the
## path to the corresponding HTML reference documentation.  If the project
## provides the maintainer mode option and maintainer mode is not enabled,
## the user does not have to provide the full path to the tag file.  The
## full path is only required for rebuilding the documentation.
##
## If the optional <module> argument has been specified, and either the tag
## file or the HTML location have not been overridden by the user already,
## try to retrieve the missing paths automatically via pkg-config.  Also ask
## pkg-config for the URI to the online documentation, for use as the preset
## location when the documentation is generated.
##
## A warning message will be shown if the HTML path could not be determined.
## If maintainer mode is active, a warning is also displayed if the tag file
## could not be found.
##
## The results are appended to the substitution variables DOXYGEN_TAGFILES
## and DOCINSTALL_FLAGS, using the following format:
##
##  DOXYGEN_TAGFILES = "/path/tagfile=htmlrefpub" [...]
##  DOCINSTALL_FLAGS = -l 'tagfile@htmlrefdir' [...]
##
## The substitutions are intended to be used for the Doxygen configuration,
## and as argument list to the doc-install.pl or installdox utility.
##
AC_DEFUN([MM_ARG_WITH_TAGFILE_DOC],
[dnl
m4_assert([$# >= 1])[]dnl
m4_ifval([$2], [AC_REQUIRE([PKG_PROG_PKG_CONFIG])])[]dnl
AC_REQUIRE([MM_CONFIG_DOCTOOL_DIR])[]dnl
AC_REQUIRE([_MM_ARG_ENABLE_DOCUMENTATION])[]dnl
dnl
AS_IF([test "x$ENABLE_DOCUMENTATION" != xno],
      [_MM_ARG_WITH_TAGFILE_DOC(m4_quote(m4_bpatsubst([$1], [[+]*\([-+][0123456789]\|[._]\).*$])),
                                [htmlref]m4_ifval([$2], [[pub]], [[dir]]), [$1], [$2])])[]dnl
])

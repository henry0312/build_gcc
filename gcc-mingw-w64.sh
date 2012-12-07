#!/bin/bash

#----------------------------------------------------------------------------
#
#  Creating a cross Win32 and Win64 compiler
#    http://gcc.gnu.org/
#    http://mingw-w64.sourceforge.net/
#
#----------------------------------------------------------------------------

if [ "$1" = "-h" ] || [ "$1" = "--help" ] ; then
cat << EOF
Usage: ./configure [options]

options:
  -h, --help                    print this message

  --prefix=DIRNAME              specify the toplevel installation directory. [$HOME/local]

  --ncpu=NUM                    use NUM of cores/threads to compile with. [1]

  --threads=LIB                 compile with support for thread LIB (winpthreads, pthread-w32). [winpthreads]
  --languages=LANG1,LANG2,...   compile GCC with support for LANG (all, ada, c, c++,
                                fortran, go, java, objc, obj-c++). [c,c++]

  --with-openmp                 compile GCC with libgomp. Require a cross compiler already installed.

  --enable-static               compile a static only toolchain.
EOF
exit 1
fi

#-----------------------------------------------------------------------------

# Parse options
prefix="$HOME/local"
num_cpu="1"
threads_lib="winpthreads"
enabled_langs="c,c++"
openmp="no"
static_build=''

for opt; do
    optarg="${opt#*=}"
    case "$opt" in
        --prefix=* )
            prefix="$optarg"
            ;;
        --ncpu=* )
            num_cpu="$optarg"
            ;;
        --threads=* )
            threads_lib="$optarg"
            ;;
        --languages=* )
            enabled_langs="$optarg"
            ;;
        --with-openmp )
            openmp="yes"
            ;;
        --enable-static )
            static_build=('--disable-shared' '--enable-static')
            ;;
        * )
            echo "unknown option $opt"
            exit 1
            ;;
    esac
done

if [ "$num_cpu" -le "0" ] ; then
    num_cpu="1"
fi

if [ "$threads_lib" != "pthread-w32" ] && [ "$threads_lib" != "winpthreads" ] ; then
    threads_lib="winpthreads"
fi

# Load
source config.sh
source download.sh
source build_func.sh

# Init
if [ ! -d $build_dir ] ; then
    mkdir -p $build_dir
fi
if [ ! -d $tmp_dir ] ; then
    mkdir -p $tmp_dir
fi
if [ ! -d $src_dir ] ; then
    mkdir -p $src_dir
fi
if [ ! -d $patch_dir ] ; then
    mkdir -p $patch_dir
fi
if [ ! -d $opt_dir ] ; then
    mkdir -p $opt_dir
fi
download_src "cross"
download_patch "cross"

# Build package
# See http://gcc.gnu.org/install/prerequisites.html
build_gmp
build_mpfr
build_mpc
build_ppl
build_cloog_ppl
build_isl
build_cloog

# Build a cross compiler
export PATH=$prefix/bin:$PATH
for target in i686-w64-mingw32 x86_64-w64-mingw32
do
    if [ "$openmp" == "yes" ] ; then
        # Require a cross compiler already installed.
        build_threads
    fi

    build_binutils
    build_headers

    cd $prefix
    ln -s $target mingw
    cd $working_dir

    build_gcc1
    build_crt
    build_gcc2

    build_threads

    rm -fr build/* $prefix/mingw
done

# Clean
rm -fr $build_dir $tmp_dir $opt_dir

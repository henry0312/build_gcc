#!/bin/bash

#----------------------------------------------------------------------------
#
#  Build GCC
#    http://gcc.gnu.org/
#    http://gcc.gnu.org/install/
#
#----------------------------------------------------------------------------

if [ "$1" = "-h" ] || [ "$1" = "--help" ] ; then
cat << EOF
Usage: ./configure [options]

options:
  -h, --help                    print this message

  --prefix=DIRNAME              specify the toplevel installation directory. [$HOME/local]

  --ncpu=NUM                    use NUM of cores/threads to compile with. [1]

  --languages=LANG1,LANG2,...   compile GCC with support for LANG (all, ada, c, c++,
                                fortran, go, java, objc, obj-c++). [c,c++]
EOF
exit 1
fi

#-----------------------------------------------------------------------------

# Parse options
prefix="$HOME/local"
num_cpu="1"
enabled_langs="c,c++"

for opt; do
    optarg="${opt#*=}"
    case "$opt" in
        --prefix=* )
            prefix="$optarg"
            ;;
        --ncpu=* )
            num_cpu="$optarg"
            ;;
        --languages=* )
            enabled_langs="$optarg"
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
download_src
download_patch

# Build packages
# See http://gcc.gnu.org/install/prerequisites.html
build_gmp
build_mpfr
build_mpc
build_ppl
build_cloog_ppl
build_isl
build_cloog

# Build GCC
build_gcc

# Clean
rm -fr $build_dir $tmp_dir $opt_dir

download_src() {
    clear; echo "Download source"

    cd $src_dir

    # GCC
    wget -nc ftp://gcc.gnu.org/pub/gcc/releases/gcc-$gcc_ver/gcc-$gcc_ver.tar.bz2
    # GMP
    wget -nc ftp://ftp.gmplib.org/pub/gmp-$gmp_ver/gmp-$gmp_ver.tar.bz2
    # MPFR
    wget -nc http://www.mpfr.org/mpfr-current/mpfr-$mpfr_ver.tar.bz2
    # MPC
    wget -nc http://www.multiprecision.org/mpc/download/mpc-$mpc_ver.tar.gz
    # PPL
    wget -nc ftp://ftp.cs.unipr.it/pub/ppl/releases/$ppl_ver/ppl-$ppl_ver.tar.bz2
    # CLooG PPL
    wget -nc ftp://gcc.gnu.org/pub/gcc/infrastructure/cloog-ppl-$cloog_ppl_ver.tar.gz
    # CLooG
    wget -nc http://www.bastoul.net/cloog/pages/download/cloog-$cloog_ver.tar.gz
    # ISL
    wget -nc ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-$isl_ver.tar.bz2

    if [ "$1" = "cross" ] ; then
        # Binutils
        wget -nc ftp://ftp.gnu.org/gnu/binutils/binutils-$binutils_ver.tar.bz2
        # mingw-w64
        svn_mingw_w64

        if [ "$threads_lib" = "pthread-w32" ] ; then
            # Pthreads-w32
            wget -nc ftp://sourceware.org/pub/pthreads-win32/pthreads-w32-$pthreads_w32_ver-release.tar.gz
        else
            # winpthreads
            svn_winpthreads
        fi
    fi

    cd $working_dir
    return 0
}

download_patch() {
    clear; echo "Download patch"

    cd $patch_dir

    # MPFR
    wget -O mpfr_all.patch http://www.mpfr.org/mpfr-current/allpatches

    if [ "$1" = "cross" ] && [ "$threads_lib" = "pthread-w32" ] ; then
        # Pthreads-w32
        # See http://blog.k-tai-douga.com/article/39079027.html
        wget -nc http://abechin.sakura.ne.jp/sblo_files/k-tai-douga/ffmpeg/pthreads-20120527.diff
    fi

    cd $working_dir
    return 0
}

svn_mingw_w64() {
    if [ ! -d mingw-w64 ] ; then
        svn checkout http://mingw-w64.svn.sourceforge.net/svnroot/mingw-w64/trunk mingw-w64
    else
        cd mingw-w64
        svn update
        cd -
    fi
    return 0
}

svn_winpthreads() {
    if [ ! -d winpthreads ] ; then
        svn checkout http://mingw-w64.svn.sourceforge.net/svnroot/mingw-w64/experimental/winpthreads
    else
        cd winpthreads
        svn update
        cd -
    fi
    return 0
}

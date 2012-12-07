build_binutils() {
    clear; echo "Build Binutils $target"

    mkdir -p $build_dir/binutils
    cd $build_dir/binutils

    if [ ! -d $tmp_dir/binutils-$binutils_ver ] ; then
        tar xjvf $src_dir/binutils-$binutils_ver.tar.bz2 -C $tmp_dir/
    fi

    $tmp_dir/binutils-$binutils_ver/configure\
        --target=$target\
        --disable-multilib\
        --with-sysroot=$prefix\
        --prefix=$prefix\
        --with-windres\
        ${static_build[@]}

    make clean
    make -j $num_cpu || exit 1
    make install || exit 1

    cd $working_dir
    return 0
}

build_gmp() {
    clear; echo "Build GMP"

    mkdir -p $build_dir/gmp
    cd $build_dir/gmp

    if [ ! -d $tmp_dir/gmp-$gmp_ver ] ; then
        tar xjf $src_dir/gmp-$gmp_ver.tar.bz2 -C $tmp_dir/
    fi

    $tmp_dir/gmp-$gmp_ver/configure\
        --prefix=$opt_dir\
        --enable-cxx\
        --disable-shared\
        --enable-static

    make clean
    make -j $num_cpu || exit 1
    make -j $num_cpu check || exit 1
    make install-strip || exit 1

    cd $working_dir
    return 0
}

build_mpfr() {
    clear; echo "Build MPFR"

    mkdir -p $build_dir/mpfr
    cd $build_dir/mpfr

    # overwrite for patch
    tar xjvf $src_dir/mpfr-$mpfr_ver.tar.bz2 -C $tmp_dir/

    # Patch
    cd $tmp_dir/mpfr-$mpfr_ver
    patch -p1 < $patch_dir/mpfr_all.patch
    cd -

    $tmp_dir/mpfr-$mpfr_ver/configure\
        --prefix=$opt_dir\
        --with-gmp=$opt_dir\
        --disable-shared\
        --enable-static

    make clean
    make -j $num_cpu || exit 1
    make -j $num_cpu check || exit 1
    make install-strip || exit 1

    cd $working_dir
    return 0
}

build_mpc() {
    clear; echo "Build MPC"

    mkdir -p $build_dir/mpc
    cd $build_dir/mpc

    if [ ! -d $tmp_dir/mpc-$mpc_ver ] ; then
        tar xzvf $src_dir/mpc-$mpc_ver.tar.gz -C $tmp_dir/
    fi

    $tmp_dir/mpc-$mpc_ver/configure\
        --prefix=$opt_dir\
        --with-gmp=$opt_dir\
        --with-mpfr=$opt_dir\
        --disable-shared\
        --enable-static

    make clean
    make -j $num_cpu || exit 1
    make -j $num_cpu check || exit 1
    make install-strip || exit 1

    cd $working_dir
    return 0
}

build_ppl() {
    clear; echo "Build PPL"

    mkdir -p $build_dir/ppl
    cd $build_dir/ppl

    if [ ! -d $tmp_dir/ppl-$ppl_ver ] ; then
        tar xjvf $src_dir/ppl-$ppl_ver.tar.bz2 -C $tmp_dir/
    fi

    $tmp_dir/ppl-$ppl_ver/configure\
        --prefix=$opt_dir\
        --enable-optimization\
        --with-gmp=$opt_dir\
        --disable-shared\
        --enable-static

    make clean
    make -j $num_cpu || exit 1
    make install-strip || exit 1

    cd $working_dir
    return 0
}

build_cloog_ppl() {
    clear; echo "Build CLooG PPL"

    mkdir -p $build_dir/cloog_ppl
    cd $build_dir/cloog_ppl

    if [ ! -d $tmp_dir/cloog-ppl-$cloog_ppl_ver ] ; then
        tar xzvf $src_dir/cloog-ppl-$cloog_ppl_ver.tar.gz -C $tmp_dir/
    fi

    $tmp_dir/cloog-ppl-$cloog_ppl_ver/configure\
        --prefix=$opt_dir\
        --with-gmp=$opt_dir\
        --with-ppl=$opt_dir\
        --with-host-libstdcxx='-lstdc++'\
        --disable-shared\
        --enable-static

    make clean
    make -j $num_cpu || exit 1
    make install-strip || exit 1

    cd $working_dir
    return 0
}

build_isl() {
    clear; echo "Build ISL"

    mkdir -p $build_dir/isl
    cd $build_dir/isl

    if [ ! -d $tmp_dir/isl-$isl_ver ] ; then
        tar xjvf $src_dir/isl-$isl_ver.tar.bz2 -C $tmp_dir/
    fi

    $tmp_dir/isl-$isl_ver/configure\
        --prefix=$opt_dir\
        --with-gmp-prefix=$opt_dir\
        --with-piplib=no\
        --with-clang=no\
        --disable-shared\
        --enable-static

    make clean
    make -j $num_cpu || exit 1
    make install-strip || exit 1

    cd $working_dir
    return 0
}

build_cloog() {
    clear; echo "Build CLooG"

    mkdir -p $build_dir/cloog
    cd $build_dir/cloog

    if [ ! -d $tmp_dir/cloog-$cloog_ver ] ; then
        tar xzvf $src_dir/cloog-$cloog_ver.tar.gz -C $tmp_dir/
    fi

    $tmp_dir/cloog-$cloog_ver/configure\
        --prefix=$opt_dir\
        --with-gmp-prefix=$opt_dir\
        --with-isl-prefix=$opt_dir\
        --with-osl=no\
        --disable-shared\
        --enable-static

    make clean
    make -j $num_cpu || exit 1
    make install-strip || exit 1

    cd $working_dir
    return 0
}

build_headers() {
    clear; echo "mingw-w64-headers $target"

    mkdir -p $build_dir/headers
    cd $build_dir/headers

    $src_dir/mingw-w64/mingw-w64-headers/configure\
        --host=$target\
        --prefix=$prefix/$target\
        --enable-sdk=all

    make install || exit 1

    cd $working_dir
    return 0
}

build_crt() {
    clear; echo "mingw-w64-crt $target"

    mkdir -p $build_dir/crt
    cd $build_dir/crt

    $src_dir/mingw-w64/mingw-w64-crt/configure\
        --host=$target\
        --prefix=$prefix/$target\
        --with-sysroot=$prefix

    make -j $num_cpu || exit 1
    make install || exit 1

    cd $working_dir
    return 0
}

# Build for a native compiler
build_gcc() {
    clear; echo "Build GCC"

    case "$(uname)" in
        "Darwin" )
            local make_gcc="make bootstrap"
            local bootstrap="--enable-bootstrap"
            # See https://trac.macports.org/ticket/27237
            # See https://trac.macports.org/browser/trunk/dports/lang/gcc47/Portfile
            local enable_fully_dynamic_string=""
            ;;
        "Linux" )
            local make_gcc="make bootstrap"
            local bootstrap="--enable-bootstrap"
            local enable_fully_dynamic_string="--enable-fully-dynamic-string"
            ;;
        CYGWIN* )
            # Error: make bootstrap
            local make_gcc="make"
            local bootstrap="--disable-bootstrap"
            local enable_fully_dynamic_string="--enable-fully-dynamic-string"
            ;;
    esac

    mkdir -p $build_dir/gcc
    cd $build_dir/gcc

    if [ ! -d $tmp_dir/gcc-$gcc_ver ] ; then
        tar xjvf $src_dir/gcc-$gcc_ver.tar.bz2 -C $tmp_dir/
    fi

    # See http://gcc.gnu.org/install/configure.html
    # See http://gcc.gnu.org/onlinedocs/libstdc++/manual/configure.html
    $tmp_dir/gcc-$gcc_ver/configure\
        --prefix=$prefix\
        --with-local-prefix=$prefix\
        --disable-debug\
        --disable-multilib\
        --enable-threads\
        --enable-libgomp\
        $bootstrap\
        --enable-languages=$enabled_langs\
        --enable-stage1-checking\
        --disable-nls\
        --with-gmp=$opt_dir\
        --with-mpfr=$opt_dir\
        --with-mpc=$opt_dir\
        --with-ppl=$opt_dir\
        --disable-ppl-version-check\
        --with-host-libstdcxx="-lstdc++"\
        --with-cloog=$opt_dir\
        --enable-cloog-backend=isl\
        --disable-cloog-version-check\
        $enable_fully_dynamic_string\
        --enable-libstdcxx-time

    make clean
    $make_gcc -j $num_cpu || exit 1
    make install

    cd $working_dir
    return 0
}

# Build for a cross compiler
build_gcc1() {
    clear; echo "Build GCC on the 1st try $target"

    if [ "$openmp" = "yes" ] ; then
        local enable_libgomp="--enable-libgomp"
    fi

    case "$threads_lib" in
        "pthread-w32" )
            local enable_threads="--enable-threads=win32"
            ;;
        "winpthreads" )
            local enable_threads="--enable-threads=posix"
            ;;
    esac

    mkdir -p $build_dir/gcc
    cd $build_dir/gcc

    if [ ! -d $tmp_dir/gcc-$gcc_ver ] ; then
        tar xjvf $src_dir/gcc-$gcc_ver.tar.bz2 -C $tmp_dir/
    fi

    # See http://gcc.gnu.org/install/configure.html
    # See http://gcc.gnu.org/onlinedocs/libstdc++/manual/configure.html
    $tmp_dir/gcc-$gcc_ver/configure\
        --target=$target\
        --prefix=$prefix\
        --with-sysroot=$prefix\
        --disable-debug\
        --disable-multilib\
        $enable_threads\
        $enable_libgomp\
        --disable-bootstrap\
        --enable-languages=$enabled_langs\
        --enable-stage1-checking\
        --disable-nls\
        --with-gmp=$opt_dir\
        --with-mpfr=$opt_dir\
        --with-mpc=$opt_dir\
        --with-ppl=$opt_dir\
        --disable-ppl-version-check\
        --with-host-libstdcxx="-lstdc++"\
        --with-cloog=$opt_dir\
        --enable-cloog-backend=isl\
        --disable-cloog-version-check\
        --enable-fully-dynamic-string\
        ${static_build[@]}

    make clean
    make -j $num_cpu all-gcc || exit 1
    make install-gcc

    cd $working_dir
    return 0
}

# Build for a cross compiler
build_gcc2() {
    clear; echo "Build GCC on the 2nd try $target"

    cd $build_dir/gcc

    make -j $num_cpu || exit 1
    make install || exit 1

    cd $working_dir
    return 0
}

build_threads() {
    case "$threads_lib" in
        "pthread-w32" )
            build_pthreads_w32
            ;;
        "winpthreads" )
            build_winpthreads
            ;;
    esac
}

build_pthreads_w32() {
    clear; echo "Build Pthreads-w32 $target"

    # overwrite for patch
    tar xzvf $src_dir/pthreads-w32-$pthreads_w32_ver-release.tar.gz -C $build_dir/
    cd $build_dir/pthreads-w32-$pthreads_w32_ver-release

    # Patch
    # See http://blog.k-tai-douga.com/article/39079027.html
    patch -p1 < $patch_dir/pthreads-20120527.diff

    make CROSS=${target}- clean GC-static || exit 1
    if [ ! -d $prefix/$target/lib ] ; then
        mkdir -p $prefix/$target/lib/
    fi
    cp -f libpthreadGC2.a $prefix/$target/lib/libpthread.a
    if [ ! -d $prefix/$target/include ] ; then
        mkdir -p $prefix/$target/include
    fi
    cp -f pthread.h sched.h semaphore.h $prefix/$target/include/

    cd $working_dir
    return 0
}

build_winpthreads() {
    clear; echo "Build winpthreads $target"

    mkdir -p $build_dir/winpthreads
    cd $build_dir/winpthreads

    $src_dir/winpthreads/configure\
        --host=$target\
        --prefix=$prefix/$target\
        --disable-shared\
        --enable-static

    make || exit 1
    make install || exit 1

    cd $working_dir
    return 0
}

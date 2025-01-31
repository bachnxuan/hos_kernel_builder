#!/bin/bash
DIR=`readlink -f .`
MAIN=`readlink -f ${DIR}/..`
export CLANG_PATH=$MAIN/clang-tc/bin
export PATH=${BINUTILS_PATH}:${CLANG_PATH}:${PATH}
make -j4 CC='ccache clang' ARCH=arm64 LLVM=1 LLVM_IAS=1 O=out gki_defconfig

# Resources
THREAD="-j$(nproc --all)"

export CLANG_PATH=$MAIN/clang-tc/bin/
export PATH=${CLANG_PATH}:${PATH}
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=$MAIN/clang-tc/bin/aarch64-linux-gnu- CC=clang CXX=clang++

DEFCONFIG="gki_defconfig"

# Paths
KERNEL_DIR=`pwd`
ZIMAGE_DIR="$KERNEL_DIR/out/arch/arm64/boot"

# Vars
export ARCH=arm64
export SUBARCH=$ARCH
export KBUILD_BUILD_USER=nobody

DATE_START=$(date +"%s")

echo  "DEFCONFIG SET TO $DEFCONFIG"
echo "-------------------"
echo "Making Kernel:"
echo "-------------------"
echo

make CC="ccache clang" CXX="ccache clang++" LLVM=1 LLVM_IAS=1 O=out $DEFCONFIG
make CC='ccache clang' CXX="ccache clang++" LLVM=1 LLVM_IAS=1 AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip O=out $THREAD \
    CONFIG_MEDIATEK_CPUFREQ_DEBUG=m CONFIG_MTK_IPI=m CONFIG_MTK_TINYSYS_MCUPM_SUPPORT=m \
    CONFIG_MTK_MBOX=m CONFIG_RPMSG_MTK=m CONFIG_LTO_CLANG=y CONFIG_LTO_NONE=n \
    CONFIG_LTO_CLANG_THIN=y CONFIG_LTO_CLANG_FULL=n 2>&1 | tee kernel.log

echo
echo "-------------------"
echo "Build Completed in:"
echo "-------------------"
echo

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
ls -a $ZIMAGE_DIR

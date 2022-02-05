echo -e "\nStarting compilation...\n"
# ENV

CONFIG=vendor/sixteen_defconfig
KERNEL_DIR=$(pwd)
PARENT_DIR="$(dirname "$KERNEL_DIR")"
KERN_IMG="$KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb"
export KBUILD_BUILD_USER="hafizziq"
export KBUILD_BUILD_HOST="ubuntu"
export KBUILD_BUILD_TIMESTAMP="$(TZ=Asia/Kuala_Lumpur date)"
export PATH="$HOME/clang/proton/bin:$PATH"
export LD_LIBRARY_PATH="$HOME/clang/proton/lib:$LD_LIBRARY_PATH"
export KBUILD_COMPILER_STRING="$($HOME/clang/proton/bin/clang --version | head -n 1 | perl -pe 's/\((?:http|git).*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//' -e 's/^.*clang/clang/')"
export CROSS_COMPILE=$HOME/gcc/aarch64-linux-android-4.9/bin/aarch64-linux-android-
export CROSS_COMPILE_ARM32=$HOME/gcc/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-
export out=out

# let's clean the output first before building
if [ -d $out ]; then
 echo -e "Cleaning out leftovers...\n"
 rm -rf $out
fi;

mkdir -p $out

# Functions
clang_build () {
    make -j$(nproc --all) O=$out \
                          ARCH=arm64 \
                          CC="clang" \
                          AR="llvm-ar" \
                          NM="llvm-nm" \
                          LD="ld.lld" \
                          AS="llvm-as" \
                          STRIP="llvm-strip" \
                          OBJCOPY="llvm-objcopy" \
                          OBJDUMP="llvm-objdump" \
                          CLANG_TRIPLE=aarch64-linux-gnu- \
                          CROSS_COMPILE=$CROSS_COMPILE \
                          CROSS_COMPILE_ARM32=$CROSS_COMPILE_ARM32
}

# Build kernel
make O=$out ARCH=arm64 $CONFIG > /dev/null
echo -e "${bold}Compiling with CLANG${normal}\n$KBUILD_COMPILER_STRING"
clang_build
echo -e "\nKernel compiled succesfully!\n"
echo -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
exit 0

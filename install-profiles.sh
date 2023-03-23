#!/bin/sh -ex

LOG_DIR="install-logs""$@"
mkdir $LOG_DIR || true
mkdir $LOG_DIR/pts || true
mkdir $LOG_DIR/local || true

PTS="/usr/bin/time php /home/lucianp/git/phoronix-test-suite/pts-core/phoronix-test-suite.php debug-install"

echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

PTS_COMMAND="(trap 'kill 0' INT; "
# Omit the profiles in LLVM Build Speed as they need special treatment
for p in $(grep -v '#' categorized-profiles.txt | grep -v '/build-')
do
	# Skip z3 for now, it will be installed separately
	if [ "$p" = "local/z3" ]; then continue; fi

	PTS_COMMAND=$PTS_COMMAND"\$PTS $p 2>&1 | tee \$LOG_DIR/$p.log & "
done
PTS_COMMAND=$PTS_COMMAND"wait)"

eval $PTS_COMMAND

# Process the profiles in LLVM Build Speed
if [ $(grep -v '#' categorized-profiles.txt | grep '/build-' | wc -l) -gt 0 ]
then
	COMPILED_CLANG_PATH=/ssd/llvm-project-llvmorg-15.0.7
	(cd $COMPILED_CLANG_PATH && rm -rf build/ && ./build.sh)
fi

PTS_COMMAND="(trap 'kill 0' INT; "
for p in $(grep -v '#' categorized-profiles.txt | grep '/build-')
do
	PTS_COMMAND=$PTS_COMMAND"PATH='$COMPILED_CLANG_PATH/build/bin:$PATH' CC=$COMPILED_CLANG_PATH/build/bin/clang CXX=$COMPILED_CLANG_PATH/build/bin/clang++ \$PTS $p 2>&1 | tee \$LOG_DIR/$p.log & "
done
PTS_COMMAND=$PTS_COMMAND"wait)"
eval $PTS_COMMAND

# Install z3 separately because it needs some special grooming
subshell_flag=""
if [ "$@" != "-base" ]; then subshell_flag="$@"; fi
(export PATH="/git/llvm-ub-free/build/bin:$PATH" && \
	export CC="/git/llvm-ub-free/build/bin/clang" && \
	export CXX="/git/llvm-ub-free/build/bin/clang++" && \
	export CPPFLAGS="$subshell_flag" && \
	export CXXFLAGS="$subshell_flag" && \
	$PTS local/z3)

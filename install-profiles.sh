#!/usr/bin/bash -ex

CONCAT_FLAGS=`echo $@ | tr -d ' '`
LOG_DIR="install-logs""$CONCAT_FLAGS"
mkdir $LOG_DIR || true
mkdir $LOG_DIR/pts || true
mkdir $LOG_DIR/local || true

# Put CPUs is performance mode at the max frequency for compiling the benchmarks.
# For ARM it will be set to 1.00GHz before running the benchmarks.
if [[ $ENABLE_SUDO_CHECK = 1 && $(groups | grep -q sudoers) = 0 ]]
then
    sudo cpupower frequency-set \
	 -g performance \
	 --min `cpupower frequency-info | grep "hardware limits" | awk '{print $6,$7}' | tr -d ' '` \
	 --max `cpupower frequency-info | grep "hardware limits" | awk '{print $6,$7}' | tr -d ' '`
fi

for p in $(grep -v '#' categorized-profiles.txt); do
    $PTS debug-install $p 2>&1 | tee $LOG_DIR/$p.log
done

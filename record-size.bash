#!/usr/bin/bash

set -u

function collectBuildSizes() {
  local buildPath="$1"
  local sizePaths="$2"
  local resultPath="$buildPath/build-size.lst"
  if [[ -d $buildPath ]]; then
    du -b $(realpath "${buildPath}/${sizePaths}") > $resultPath && \
      gawk '{sum += $1} END{print sum " total"}' $resultPath >> $resultPath
  else
    echo "Directory $buildPath does not exist"
  fi
}

function collectSharedSizes() {
  local buildPath="$1"
  local resultPath="$buildPath/build-size.lst"
  if [[ -d $buildPath ]]; then
    find $buildPath -type f \( -name *.so* -or -name *.a \) | \
      xargs du -b > $resultPath && \
      gawk '{sum += $1} END{print sum " total"}' $resultPath >> $resultPath
  else
    echo "Directory $buildPath does not exist"
  fi
}

collectSharedSizes pts/aircrack-ng-1.3.0
collectSharedSizes pts/botan-1.6.0/Botan-2.17.3
collectBuildSizes pts/compress-7zip-1.11.0 CPP/7zip/Bundles/Alone2/_o/7zz
collectBuildSizes pts/compress-zstd-1.6.0 zstd-1.5.4/zstd
collectBuildSizes pts/draco-1.6.0 draco-1.5.6/build/draco_encoder-1.5.6
collectBuildSizes pts/encode-flac-1.8.1 flac_/bin/flac
collectBuildSizes pts/espeak-1.7.0 espeak_/bin/espeak-ng
collectBuildSizes pts/graphics-magick-2.1.0 gm_/bin/gm
collectBuildSizes pts/john-the-ripper-1.8.0 john-c7cacb14f5ed20aca56a52f1ac0cd4d5035084b6/run/john
collectBuildSizes pts/jpegxl-1.5.0 libjxl-0.7.0/build/tools/cjxl
collectBuildSizes pts/luajit-1.1.0 LuaJIT-Git/src/luajit
collectBuildSizes pts/mafft-1.6.2 mafft_/mafft
collectBuildSizes pts/ngspice-1.0.0 ngspice-34/src/ngspice
collectBuildSizes pts/openssl-3.1.0 openssl-3.1.0/apps/openssl
collectSharedSizes pts/rnnoise-1.0.2/rnnoise-git
collectBuildSizes pts/simdjson-2.0.1 simdjson-2.0.4/build/libsimdjson.a
collectBuildSizes pts/sqlite-speedtest-1.0.1 sqlite-version-3.46.0/speedtest1
collectBuildSizes pts/tjbench-1.2.0 libjpeg-turbo-2.1.0/build/tjbench
collectBuildSizes local/z3 z3_solver-4.14.0.0/core/build/z3

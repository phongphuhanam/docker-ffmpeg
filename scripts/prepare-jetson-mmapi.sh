#!/bin/bash
# Populates jetson-mmapi/ in this repo with the Jetson Multimedia API sample
# sources and the Tegra shared libraries needed to build libnvmpi. These are
# L4T-BSP-specific (tied to this exact device's L4T release) and are not
# available from any package repo, so Dockerfile.jetson expects them to
# already be sitting in the build context rather than fetching them itself.
#
# Usage: ./scripts/prepare-jetson-mmapi.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DEST="${REPO_ROOT}/jetson-mmapi"

MMAPI_SRC="/usr/src/jetson_multimedia_api"
TEGRA_LIB_DIR="/usr/lib/aarch64-linux-gnu/tegra"

if [ ! -d "${MMAPI_SRC}" ]; then
    echo "[E]: ${MMAPI_SRC} not found. Run this on a Jetson with the L4T Multimedia API installed." >&2
    exit 1
fi
if [ ! -d "${TEGRA_LIB_DIR}" ]; then
    echo "[E]: ${TEGRA_LIB_DIR} not found." >&2
    exit 1
fi

rm -rf "${DEST}"
mkdir -p "${DEST}/jetson_multimedia_api/samples/common" "${DEST}/jetson_multimedia_api/include" "${DEST}/tegra-libs"

echo "[i] copying jetson_multimedia_api/samples/common (only what libnvmpi needs)"
cp -a "${MMAPI_SRC}/samples/common/." "${DEST}/jetson_multimedia_api/samples/common/"
echo "[i] copying jetson_multimedia_api/include"
cp -a "${MMAPI_SRC}/include/." "${DEST}/jetson_multimedia_api/include/"

echo "[i] copying Tegra libraries needed at link/runtime"
for lib in libnvbuf_utils libnvv4l2 libnvos libnvrm libnvrm_gpu libnvrm_host1x libnvrm_mem libnvddk_2d_v2 libnvbufsurface libnvbufsurftransform libnvjpeg libnvvic libnvbuf_fdmap libnvmedia libnvrm_surface libcuda libnvcolorutil libnvdc libnvddk_vic libnvimp libnvparser libnvrm_chip libnvrm_stream libnvrm_sync libnvsciipc libnvsocsys libnvtvmr libnvvideo; do
    cp -a "${TEGRA_LIB_DIR}/${lib}.so"* "${DEST}/tegra-libs/" 2>/dev/null || true
done

echo "[i] done: ${DEST}"
du -sh "${DEST}"

SCRIPT="${BASH_SOURCE[0]}"
NUONSDK="`dirname "${SCRIPT}"`"
NUONSDK="`readlink -f "${NUONSDK}"`"
export NUONSDK
export VMLABS="${NUONSDK}/vmlabs"
export BUILDHOST=LINUX
export PATH="$PATH:${VMLABS}/bin/linux"

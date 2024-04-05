SCRIPT="${BASH_SOURCE[0]}"
NUONSDK="`dirname "${SCRIPT}"`"
NUONSDK="`readlink -f "${NUONSDK}"`"
export NUONSDK
export VMLABS="${NUONSDK}/vmlabs"
export VMBLESSDIR="${NUONSDK}/bless"
export VMHOSTARCH="i386"
export BUILDHOST=LINUX
export PATH="$PATH:${NUONSDK}/bin/linux:${VMLABS}/bin/linux"

echo ""
echo "Set up Nuon SDK at: ${NUONSDK}"
echo ""

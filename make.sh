#!/usr/bin/env sh
set -o errexit

readonly PROGNAME=$(basename "$0")
readonly PROGDIR=$(readlink -m "$(dirname "$0")")

URL=https://github.com/happyleavesaoc/python-snapcast
NAME=script.module.snapcast

if test -z $TMPDIR ; then
    TMPDIR=/tmp/
fi
VFILE=$(mktemp)


update_addon(){
    echo "# Update libs"
    BUILD=$(mktemp -d --tmpdir ${NAME}.XXX)
    DEST=${PROGDIR}/resources/lib
    test -d $DEST && rm -rf $DEST
    mkdir $DEST

    cd $BUILD
    git clone --quiet $URL

    cd python-snapcast
    VERSION=$(git tag | tail -1)
    echo $VERSION > $VFILE
    git checkout --quiet tags/${VERSION} -b v${VERSION}
    cp -r snapcast ${DEST}/
    cp LICENSE README.md ${DEST}/

    cd $PROGDIR
    rm -rf $BUILD
}

make_package(){
    echo "# Create package"
    VERSION=$(cat ${VFILE})

    perl -i -pe "s/(^\s*version=).*/\1\"${VERSION}\"/" ${PROGDIR}/addon.xml
    OUTPUT=${TMPDIR}/${NAME}-${VERSION}.zip
    cd ${PROGDIR}/..
    zip --quiet -r $OUTPUT $NAME
    echo "→ Addon available at : ${OUTPUT}"
}

update_addon
make_package
rm -f $VFILE

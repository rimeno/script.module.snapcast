#!/usr/bin/env sh
set -o errexit

PROGDIR=$(readlink -m "$(dirname "$0")")

GITHUB=happyleavesaoc/python-snapcast
NAME=script.module.snapcast

VERSION=$(curl -s https://api.github.com/repos/${GITHUB}/releases/latest | jq -r .tag_name)

if test -z "$TMPDIR" ; then
    TMPDIR=/tmp/
fi

update_addon(){
    echo "# Update addon version"
    sed -i "s/^\s*version=.*/    version=\"${VERSION}\"/g" "${PROGDIR}/addon.xml"
    echo "# Update libs"
    BUILD=$(mktemp -d --tmpdir ${NAME}.XXX)
    DEST=${PROGDIR}/resources/lib
    test -d "$DEST" && rm -rf "$DEST"
    mkdir "$DEST"

    cd "$BUILD"
    git clone --quiet --depth 1 --branch "${VERSION}" https://github.com/${GITHUB}

    cd python-snapcast
    cp -r snapcast "${DEST}"/
    cp LICENSE README.md "${DEST}"/

    cd "$PROGDIR"
    rm -rf "$BUILD"
}

make_package(){
    echo "# Create package"
    OUTPUT=${TMPDIR}/${NAME}-${VERSION}.zip
    cd "${PROGDIR}"/..
    zip --quiet -r "$OUTPUT" ./${NAME}/ -x '*.git*'
    echo "→ Addon available at : ${OUTPUT}"
}

update_addon
make_package

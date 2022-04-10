#!/bin/bash

URL="$1"; DIR="$2"; REF="$3"
GIT="git -C ${DIR}"
echo "Obtaining '${URL}' in '${DIR}' ..."

is_head () {
    $GIT ls-remote -q --heads --exit-code "android-9.0" "${REF}"
    return $?
}

is_tag () {
    $GIT ls-remote -q --tags --exit-code "android-9.0" "${REF}"
    return $?
}

update () {
    if is_head; then
        echo "Found branch, using its head"
        $GIT remote set-branches --add android-9.0 "${REF}" || exit "$?"
        $GIT fetch android-9.0 "${REF}" --depth=1 || exit "$?"
        SRC="origin/${REF}"
    elif is_tag; then
        echo "Found tag, using its head"
        $GIT fetch origin tag "${REF}" --depth=1 || exit "$?"
        SRC="${REF}"
    elif [ -z "${REF}" ]; then
        echo "No ref provided, using android-9.0 head"
        $GIT fetch android-9.0 "HEAD" --depth=1 || exit "$?"
        SRC="origin/HEAD"
    else
        echo "No such tag or branch, aborting!"
        exit 1
    fi
    $GIT checkout -f --detach "${SRC}" || exit "$?"
}

if [ ! -d "${DIR}" ]; then
    mkdir -p "${DIR}"
    $GIT clone "${URL}" . -n --depth=1 || exit "$?"
fi

update

echo "Done!"

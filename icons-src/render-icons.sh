#!/bin/bash
#
# This file is part of harbour-pipes.
# SPDX-FileCopyrightText: 2019-2025 Mirian Margiani
# SPDX-License-Identifier: GPL-3.0-or-later
#
# See https://github.com/Pretty-SFOS/opal/blob/main/snippets/opal-render-icons.md
# for documentation.
#
# @@@ keep this line: based on template v0.3.0
#
c__FOR_RENDER_LIB__="1.1.0"

# Run this script from the same directory where your icon sources are located,
# e.g. <app>/icon-src.
source ../libs/opal-render-icons.sh
cFORCE=false

echo "scrubbing svg sources..."
for i in raw/*.svg; do
    if [[ "$i" -nt "${i#raw/}" ]]; then
        scour "$i" > "${i#raw/}"
    fi
done

cMY_APP=harbour-pipes

cNAME="app icons"
cITEMS=("$cMY_APP@../icons/RESXxRESY")
cRESOLUTIONS=(86 108 128 172)
cTARGETS=(F1)
render_batch


cNAME="pipe icons"
mkdir -p "../qml/images"

cEXTRA_INKSCAPE_ARGS=(--actions=page-rotate:1)
do_render_single "pipe-a.svg" "114" "114" "../qml/images/pipe-1.png"
do_render_single "pipe-b.svg" "114" "114" "../qml/images/pipe-3.png"
do_render_single "pipe-c.svg" "114" "114" "../qml/images/pipe-7.png"
do_render_single "pipe-d.svg" "114" "114" "../qml/images/pipe-15.png"
do_render_single "pipe-e.svg" "114" "114" "../qml/images/pipe-10.png"

cEXTRA_INKSCAPE_ARGS=(--actions=page-rotate:2)
do_render_single "pipe-a.svg" "114" "114" "../qml/images/pipe-2.png"
do_render_single "pipe-b.svg" "114" "114" "../qml/images/pipe-6.png"
do_render_single "pipe-c.svg" "114" "114" "../qml/images/pipe-14.png"
do_render_single "pipe-e.svg" "114" "114" "../qml/images/pipe-5.png"

cEXTRA_INKSCAPE_ARGS=(--actions=page-rotate:3)
do_render_single "pipe-a.svg" "114" "114" "../qml/images/pipe-4.png"
do_render_single "pipe-b.svg" "114" "114" "../qml/images/pipe-12.png"
do_render_single "pipe-c.svg" "114" "114" "../qml/images/pipe-13.png"

cEXTRA_INKSCAPE_ARGS=(--actions=page-rotate:4)
do_render_single "pipe-a.svg" "114" "114" "../qml/images/pipe-8.png"
do_render_single "pipe-b.svg" "114" "114" "../qml/images/pipe-9.png"
do_render_single "pipe-c.svg" "114" "114" "../qml/images/pipe-11.png"

unset cEXTRA_INKSCAPE_ARGS

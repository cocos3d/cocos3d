#
# main.sh
#
# Created by Nikita Medvedev (@medvedNick) on 30.05.13.
# Copyright (c) 2013 Nikita Medvedev. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# http://en.wikipedia.org/wiki/MIT_License
#

#
# This is the example of exporter.py and converter.pl usage.
#

#!/bin/sh

# root directory of the pack. You can manually set all the directories
dir="$(dirname "$(cd "$(dirname "$0")"; pwd)")" # parent_dir(current_dir(this script))

# scripts paths
exporter_path="$dir/scripts/exporter.py"
converter_path="$dir/scripts/converter.pl"

# paths to models
blend_path="$dir/_blend"
dae_path="$dir/_dae"
pod_path="$dir/_pod"

# Blender and Collada2Pod
blender_path="/Applications/blender.app/Contents/MacOS/blender"
collada2pod_path="$dir/Collada2POD/MacOS_x86_32/Collada2POD"

# exporting models from Blender into .dae
"$blender_path" --background --python "$exporter_path" -- "$blend_path" "$dae_path" -exportLight=1 -exportCam=1

# converting .dae into .pod
perl "$converter_path" "$collada2pod_path" "$dae_path" "$pod_path"
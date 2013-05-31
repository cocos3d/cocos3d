#
# exporter.py
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
# The script exports multiple files from Blender into dae models. You need
# Blender to be installed on your Mac. You need to specify the following command line
# arguments: input directory (with blend files), output directory (for exported files),
# Blender's directory, this file's directory and flags to set export
# options (for light and camera)
#

import os
import sys
import glob
import bpy

if len(sys.argv) != 9:
    print("\nusage: <path to Blender> --background --python <path to this file (exporter.py)> -- <path to .blend files> <path to output directory> <export light flag: 0 or 1> <export camera flag: 0 or 1>\n")
else:
    for infile in glob.glob(os.path.join(sys.argv[5], '*.blend')):

        bpy.ops.object.select_all(action='SELECT')
        bpy.ops.object.delete()
        bpy.ops.wm.open_mainfile(filepath=infile)

        # if you do not want to include light sources from your models,
        if sys.argv[7] == '1':
            bpy.ops.object.select_by_type(extend=False, type='LAMP')
            bpy.ops.object.delete()

		# you may also do not want to include cameras
        if sys.argv[8] == '1':
            bpy.ops.object.select_by_type(extend=False, type='CAMERA')
            bpy.ops.object.delete()

        # not applying transforms could cause wrong rotation and scale in models
        bpy.ops.object.select_all(action='SELECT')
        bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)

        outfilename = os.path.splitext(os.path.split(infile)[1])[0] + ".dae"

        # if you have troubles with textures or bones in end model, you can
        # try changing these options
        bpy.ops.wm.collada_export(filepath=os.path.join(sys.argv[6], outfilename),
								  apply_modifiers=True,
								  include_armatures=True,
								  deform_bones_only=True,
								  include_uv_textures=True,
								  include_material_textures=True,
								  active_uv_only=True)
README!
----------------------

cocos3d 0.5.4

Copyright (c) 2010-2011 The Brenwill Workshop Ltd. All rights reserved.
http://www.brenwill.com

+++++++++++++++++++++++++++++++++++


IMPORTANT!!  You must perform the following to add the cocos3d source code into this project.

1) Open this project open in XCode 4.
2) Open a Finder window and browse to the location where you unzipped the cocos3d 0.5.4 distribution.
3) From the Finder window, drag the 'cocos3d 0.5.4/cocos3d' folder in the cocos3d distribution to
   the ___PROJECTNAMEASIDENTIFIER___ group folder immediately under the ___PROJECTNAMEASIDENTIFIER___ project in
   the Navigator area on the left side of your Xcode 4 project window.

4) In the dialog box that appears, make sure that the following options are all selected: 
     a) Copy items into destination group's folder (if needed)
     b) Create groups for any added folders
     c) Add to targets ___PROJECTNAMEASIDENTIFIER___


That's it! Your new cocos3d project will now compile.


If you're interested in why we have elected to have you take this step,
please read the following discussion.


Project Templates in Xcode 4
----------------------------

With the release of Xcode 4, Apple made major changes to the way that Project Templates are defined.

At present, Xcode 4 templates only define a single grouping level for organizing source code files
within a project. In our opinion, this is a significant setback, when compared to the ease with which
this could be done in Xcode 3.

cocos3d is designed to be modular, and will continue to get even more modular as we add particle
generators, physics engines, and pluggable file loading for various 3D editor file formats.
To make it easier for you to work with this modularity, the source code is organized into a
folder hierarchy that is several levels deep.

Including cocos3d in the Xcode 4 template, would require laying this out into many folders at a
single level, mixed in with the single level of cocos2d directories. It would become very difficult
for developers to keep track of the modularity designed into the cocos3d library.

With that in mind, we have elected to preserve the multi-level folder structure of the cocos3d source
code, by deciding not to include the cocos3d source code within this Xcode 4 project template, and
asking you as a developer to follow the steps above to import the cocos3d library into the cocos3d
Xcode 4 project template.

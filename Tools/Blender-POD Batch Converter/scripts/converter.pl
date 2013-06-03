#
# converter.pl
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
# The script converts multiple dae models into pod ones, using Collada2POD utility
# You need to specify the path to Collada2POD, input directory (with dae) and
# output directory (for converted pod files)
#

#!/usr/bin/perl

$num_args = $#ARGV + 1;
if ($num_args != 3) {
	print "\nusage: perl converter.pl <path to Collada2POD> <path to dae models> <path to output directory>'\n";
	exit;
}

my $collada = $ARGV[0];
my $in_dir = $ARGV[1];
my $out_dir = $ARGV[2];

opendir(DIR, $in_dir) or die $!;

if (!(-d "cgi-bin") || !(-e "cgi-bin")) {
	system("mkdir $out_dir");
}

while (my $file = readdir(DIR)) {
	
	next if ($file !~ m/\.dae/);
	
	$out_file = $file;
	$out_file =~ s/dae/pod/g;
	
	# to change Collada2POD options, add them into this string, for example:
	#$command = "\"$collada\" -i=\"$in_dir/$file\" -o=\"$out_dir/$out_file\" -ExportNormals=1 -SortVertices=1";
	$command = "\"$collada\" -i=\"$in_dir/$file\" -o=\"$out_dir/$out_file\"";
	system($command);
}

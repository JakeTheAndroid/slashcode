#!/usr/bin/perl -w
# This code is a part of Slash, and is released under the GPL.
# Copyright 1997-2005 by Open Source Technology Group. See README
# and COPYING for more information, or see http://slashcode.com/.
# $Id$

use strict;
use File::Spec::Functions;
use Slash;
use Slash::Display;
use Slash::Utility;

sub main {
	my $constants = getCurrentStatic();
	my $form = getCurrentForm();
	my $gSkin = getCurrentSkin();
	$ENV{REQUEST_URI} ||= '';

	# catch missing .shtml links and redirect
	# should only get here if static file not found
	if ($ENV{REQUEST_URI} =~ m{^/?\w+/(\d\d/\d\d/\d\d/\d+)\.shtml(?:\?(\S*))?$}) {
		my($sid, $extra) = ($1, $2);
		my $reader = getObject('Slash::DB', { db_type => 'reader' } );
		my $story = $reader->getStory($sid); # get section, check if story exists
		if ($story->{sid}) {
			my $skin = $reader->getSkin($story->{primaryskid});
			# if not in skin ... should be in articles
			for my $skinname ($skin->{name}, 'articles') {
				if (-e catfile($constants->{basedir}, $skinname, "$sid.shtml")) {
					my $url = "$gSkin->{rootdir}/$skinname/$sid.shtml";
					$url .= "?$extra" if $extra;
					redirect($url);
					return;
				}
			}
		}
	}

	emit404();
}

createEnvironment();
main();

1;

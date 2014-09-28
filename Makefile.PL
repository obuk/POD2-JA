# -*- mode: perl; coding: utf-8; tab-width: 4; -*-

use 5.010;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME          => 'POD2::JA',
	VERSION_FROM  => 'JA.pm',
	ABSTRACT_FROM => 'JA.pm',
	PREREQ_PM         => {
		'POD2::Plus' => 0.09,
	},
	AUTHOR        => 'KUBO, Koichi <k@obuk.org>',
	);

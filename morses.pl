#!/usr/bin/perl
# Attempt at morse code in perl
#
# Do:
# ./morses.pl | ~/Downloads/sox-14.3.1/sox -t raw -r 256000 -c 1 -e unsigned -b 16 - -d
#
# You can get sox-14.3.1 from http://cdn.dranarchy.com/sox-14.3.1-macosx.zip
# or from the sox website at http://sox.sourceforge.net/
#
# This is a dumb way to do this, but may make your PCM geek friends cringe.
#

use strict;
use warnings;
use Encode;

# $el is element length.  Basically, the absolute length of a 'dit'.
# All other formations depend on it.
# For instance, a dit actually consists of the tone for a dit, and a blank space
# the length of one dit.
# A dah consists of the length of three dits, plus a blank space the length of one dit.
# A letter space consists of the length of three dits, while a word space
# consists of the length of six dits.
# $el is in milliseconds.
my $el = 63;

my $presamplerate = 256000;
my $samplerate = $presamplerate/4;
my $frequency = 110;
my $amplitude = 64000;
my $low = 5;

sub Tone {
	my ($duration) = @_;
	# duration in milliseconds.  1000 milliseconds = 1 second
	# We need to convert this to make it useful
	my $durInSmplRate = ( $duration/1000 ) * $samplerate;
	for (my $i=0; $i<=$durInSmplRate; $i++) {
		my $j = $i % $frequency;
		if ($j) {
			print sprintf("%8LX",$amplitude);
#			print "1";
		} else {
			print sprintf("%8LX",$low);
#			print "-127";
		}
	}
}

sub NoTone {
	my ($duration) = @_;
	# duration in milliseconds.  1000 milliseconds = 1 second
	# We need to convert this to make it useful
	my $durInSmplRate = ( $duration/1000 ) * $samplerate;
	for (my $i=0; $i<=$durInSmplRate; $i++) {
		my $j = $i % $frequency;
		if ($j) {
			print sprintf("%8LX",$low);
#			print "1";
		} else {
			print sprintf("%8LX",$low);
#			print "0";
		}
	}
}

sub Dit {
	Tone($el);
	NoTone($el);
}

sub Dah {
	my $dash = $el*3;
	Tone($dash);
	NoTone($el);
}

sub LSpace {
	my $dash = $el*3;
	NoTone($dash);
}

sub WSpace {
	my $dash = $el*6;
	NoTone($dash);
}

# SOS sample audio
# S
Dit();
Dit();
Dit();
LSpace();
# O
Dah();
Dah();
Dah();
LSpace();
# S
Dit();
Dit();
Dit();
LSpace();

# Build the morse table, y0
my $morsetable;
$morsetable->{'a'} = '.-';
$morsetable->{'b'} = '-...';
$morsetable->{'c'} = '-.-.';
$morsetable->{'d'} = '-..';
$morsetable->{'e'} = '.';
$morsetable->{'f'} = '..-.';
$morsetable->{'g'} = '--.';
$morsetable->{'h'} = '....';
$morsetable->{'i'} = '..';
$morsetable->{'j'} = '.---';
$morsetable->{'k'} = '-.-';
$morsetable->{'l'} = '.-..';
$morsetable->{'m'} = '--';
$morsetable->{'n'} = '-.';
$morsetable->{'o'} = '---';
$morsetable->{'p'} = '.--.';
$morsetable->{'q'} = '--.-';
$morsetable->{'r'} = '.-.';
$morsetable->{'s'} = '...';
$morsetable->{'t'} = '-';
$morsetable->{'u'} = '..-';
$morsetable->{'v'} = '...-';
$morsetable->{'w'} = '.--';
$morsetable->{'x'} = '-..-';
$morsetable->{'y'} = '-.--';
$morsetable->{'z'} = '--..';
$morsetable->{'1'} = '.----';
$morsetable->{'2'} = '..---';
$morsetable->{'3'} = '...--';
$morsetable->{'4'} = '....-';
$morsetable->{'5'} = '.....';
$morsetable->{'6'} = '-....';
$morsetable->{'7'} = '--...';
$morsetable->{'8'} = '---..';
$morsetable->{'9'} = '----.';
$morsetable->{'0'} = '-----';
#$morsetable->{'period'} = '.-.-.-';
#$morsetable->{'comma'} = '--..--';
#$morsetable->{'qmark'} = '..--..';
#$morsetable->{'forslash'} = '--..--.';
#$morsetable->{'ampersat'} = '.--..-.';

# Attempt to convert special characters in morse code
#sub convertSpecial {
#	my $in = $_;
#	my @convtable;
#	push @convtable, [ '.', 'period' ];
#	push @convtable, [ ',', 'comma' ];
#	push @convtable, [ '?', 'qmark' ];
#	push @convtable, [ '/', 'forslash' ];
#	push @convtable, [ '@', 'ampersat' ];
#	
#	unless ( $in =~ /([a-z]|[0-9])/ ) {
#		my ($one,$conversion) = grep $in, @convtable;
#		$in = $conversion;
#	}
#	
#	return($in);
#}#

sub Letter {
	my ($character) = @_;
#	print $character."\n";
#	my $conversion = convertSpecial($character);
	my $conversion = $character;
	if ($conversion !~ /\ /) {
		my $curchar = $morsetable->{$conversion};
		my @morse = split(//, $curchar);
		for my $curmorse (@morse) {
			if ($curmorse =~ /-/) {
				Dah();
			} else {
				Dit();
			}
		}
	} else {
		WSpace();
	}
	LSpace();
}

#sub preprocess {
#	my $intext = $_;
#	my $intext =~ tr/[A-Z]/[a-z]/;
#	return($intext);
#}

while (<>) {
	chomp($_);
	my $text = $_;
	my @line = split(//, $text);
	for my $chara (@line) {
		Letter($chara);
	}
}
			

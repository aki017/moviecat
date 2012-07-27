#!/usr/bin/perl

use strict;
use warnings;
use Moviecat::Image;
use Term::ScreenColor;

my $scr = new Term::ScreenColor;
my $cw = int($scr->cols());
my $ch = int($scr->rows());
$scr->clrscr;

my $im = new Moviecat::Image();
$im->file($ARGV[0]);
my ($iw , $ih) = $im->getBounds();
$cw = (($scr->cols()/2)/$scr->rows() < $iw / $ih)? $scr->cols() : $scr->rows()*2/$ih*$iw;
$ch = (($scr->cols()/2)/$scr->rows() < $iw / $ih)? $scr->cols()/2*$ih/$iw :$scr->rows();

$im->width($cw);
$im->height($ch);
my @s = @{$im->getfullref()};
my $sh = @s -1;
my $sw = @{$s[0]} -1;
for my $j(0..$sh){
    my $l = "";
    for my $k(0..$sw){
        $l .=$s[$j][$k];
    }
    $scr->at($j, 0)->puts($l);
}
$scr->at($sh+1, 0)->puts( "$iw x $ih");

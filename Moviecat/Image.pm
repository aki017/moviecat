package Moviecat::Image;

use strict;
use warnings;
use GD;

my $file = 0;
my $width = 0;
my $height = 0;
my $gd;
sub new
{
    my $self = shift;
}

sub width
{
    my $self = shift;
    $width = shift;
    return $self;
}
sub height
{
    my $self = shift;
    $height = shift;
    return $self;
}
sub file
{
    my $self = shift;
    $file = shift;
    return $self;
}
sub getfullref
{
    my $self = shift;
    die "not found $file" unless (-e $file);
    my $gdold = GD::Image->new($file);
    my ($iw, $ih) = $gdold->getBounds();
    $gd = new GD::Image($width, $height, 1);
    $gd->copyResized( $gdold,  0,  0,  0,  0,  $width,  $height,  $iw,  $ih );
    $gd->trueColorToPalette(0,256-24-16);
    ($iw, $ih) = $gd->getBounds();
    #warn $gd->colorsTotal();
    my @array;
    $array[0][0]="";
    for my $index(0..216)
    {
        my ($r, $g, $b) = $gd->rgb($index);
        $array[0][0] .= sprintf("\x1b]4;%d;rgb:%2.2x/%2.2x/%2.2x\x1b\\",$index+16, $r, $g, $b);
    }
    my %colour=();
    for my $i(0..$height-1)
    {
        for my $j(0..$width-1)
        {
            my $index = $gd->getPixel($j, $i)+16;
            $array[$i][$j] .="\x1b[48;5;".$index."m ";
        }
    }
    return \@array;
                }
                sub getref
                {
                    my $self = shift;
                    die "not found $file" unless (-e $file);
                    $gd = GD::Image->new($file);
                    my @array;
                    my ($iw, $ih) = $gd->getBounds();
                    for my $i(0..$height-1)
                    {
                        for my $j(0..$width-1)
                        {
                            my $tmpindex = $gd->getPixel($j/$width*$iw, $i/$height*$ih);
                            $array[$i][$j] = "\x1b[48;5;".$self->_getcolor($tmpindex)."m ";#"\x1b[38;5;".$self->_getfor($tmpindex)."";
                        }
                    }
                    return \@array;
            }
            sub _getfullref
            {
                my $self = shift;
                die "not found $file" unless (-e $file);
                $gd = GD::Image->new($file);
                my @array;
                my ($iw, $ih) = $gd->getBounds();
                for my $i(0..$height-1)
                {
                    for my $j(0..$width-1)
                    {
                        my $tmpindex = $gd->getPixel($j/$width*$iw, $i/$height*$ih);
                        $array[$i][$j] = "\x1b[48;5;".$self->_getcolor($tmpindex)."m\x1b[38;5;".$self->_getfor($tmpindex)."";
                    }
                }
                return \@array;
        }
        sub savref
        {
            my $self = shift;
            my $savfile = shift;
            die "not found $savfile" unless (-e $savfile);
            $gd = GD::Image->new($file);
            open OUTFILE,  '>',  $savfile or die "file open error: $!";
            binmode OUTFILE;

            my ($iw, $ih) = $gd->getBounds();
            print OUTFILE pack "I", $height;
            print OUTFILE pack "I", $width;
            for my $i(0..$height-1)
            {
                for my $j(0..$width-1)
                {
                    my $tmpindex = $gd->getPixel($j/$width*$iw, $i/$height*$ih);
                    #$array[$i][$j] = "\x1b[48;5;".$self->_getcolor($tmpindex)."m ";#\x1b[38;5;".$self->_getfor($tmpindex)."";
                    print OUTFILE pack "C", $self->_getcolor($tmpindex);
                }
            }
            close OUTFILE;
            return 1;
        }
        sub loadref
        {
            my $self = shift;
            my $savfile = shift;
            open OUTFILE,  '<',  $savfile or die "file open error: $!";
            binmode OUTFILE;
            my $buf;
            my @array;
            die "eeror " unless  read(OUTFILE,  $b,  4);
            $height = unpack("I", $b);
            die "eeror " unless  read(OUTFILE,  $b,  4);
            $width = unpack("I", $b);
            for my $i(0..$height-1)
            {
                for my $j(0..$width-1)
                {
                    die "eeror $i $j __ $savfile" unless  read(OUTFILE,  $b,  1);
                    #die "test $b |" ;
                    $buf = unpack("C", $b);
                    $array[$i][$j] = "\x1b[48;5;${buf}m ";#\x1b[38;5;".$self->_getfor($tmpindex)."";
                }
            }
            close OUTFILE;
            return \@array;
    }

    sub _getcolor{
        my $self = shift;
        my ($r, $g, $b) = $gd->rgb(shift);

        # background colori only
        $r = int($r*3/128);
        $g = int($g*3/128);
        $b = int($b*3/128);
        return ( 16 + ($r * 36) + ($g * 6) + $b);

    }
    sub _getfor
    {
        my $self = shift;
        my @str = split(//, "#WMBRXVYIti+=;:,. 123456789");
        my ($r, $g, $b) = $gd->rgb(shift);

        my $mr = int($r*6/256)*256/6;
        my $mg = int($g*6/256)*256/6;
        my $mb = int($b*6/256)*256/6;
        my $s = $str[(abs($mr-$r)+abs($mg-$g)+abs($mb-$b))/128*15];
        my $nr = int($r*6/256);
        my $ng = int($g*6/256);
        my $nb = int($b*6/256);
        $r = $nr + (( $mr - $r)>0?1:-1);
        $g = $ng + (( $mg - $g)>0?1:-1);
        $b = $nb + (( $mb - $b)>0?1:-1);
        $r = 0 if $r<0;
        $g = 0 if $g<0;
        $b = 0 if $b<0;
        warn(" r=$r :: g=$g :: b=$b") if ( 16 + ($r * 36) + ($g * 6) + $b<=0);
        return "" . ( 16 + ($r * 36) + ($g * 6) + $b) . "m$s";

    }
    sub getBounds
    {
        my $self = shift;
        die "not found $file" unless (-e $file);
        $gd = GD::Image->new($file);
        return $gd->getBounds();
    }
    1;

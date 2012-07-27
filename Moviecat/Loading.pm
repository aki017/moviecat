package Moviecat::Loading;

use strict;
use warnings;



sub new {
    my $thing = shift;
    my $class = ref $thing || $thing;
    my $self  = bless { } => $class;
    my $scr = shift;

    $self->init($scr) if $self->can('init');
    $self;
}


sub init {
    my %default = (
        max=> 0,
        now=> 0,
        mes=> "init",
        col=>10,
        row=>0,
        cw=>0,
        ch=>0,
    );
    my $self = shift;
    my $scr = shift;
    $self->{$_} = $default{$_} for keys %default;

    $self->{scr} = $scr;
    $self->{row} = $scr->rows();
    $self->{col} = $scr->cols();
    $self->{cw} = $self->{col}/8;
    $self->{ch} = $self->{row}/6;
    $self;
}

sub max
{
    my $self = shift;
    $self->{max} = shift;
    return $self;
}

sub message
{
    my $self = shift;
    $self->{mes} = shift;
    return $self;
}
sub set
{
    my $self = shift;
    $self->{now} = shift;
    return $self;
}
sub print
{
    my $self = shift;
    my $step = int($self->{now})%14;
    for my $i(0..13){
        $self->_print( ($step+$i)%14 , $i);
    }

    my @w = ();

    for my $j (0..23)
    {
        $w[$j] = ($self->{now}/$self->{max});
        $w[$j] = 100 * ($w[$j])**($j/4);
        $w[$j] = $self->{col} * $self->_min($w[$j], 100) / 100;
    }
    $w[24] = 0;

    $self->{scr}->at(int($self->{row}/6*4.5-1) ,($self->{col}-length($self->{mes}))/2)->puts("\x1b[0m". $self->{mes});
    $self->{scr}->at(int($self->{row}/6*4.5) ,($self->{col}-6)/2)->puts("\x1b[0m". sprintf("%5.1f%%\n",  $self->{now}/$self->{max}*100));


    for my $j (0..23)
    {
        for my $i(int($self->{row}/6*5)..$self->{row})
        {
            #$scr->at($j,  0)->puts("\x1b[48;5;".(232+$j)."m"." "x($w[$j]));
            $self->{scr}->at($i,  $w[$j+1])->puts("\x1b[48;5;".(232+$j)."m"." "x($w[$j] - $w[$j+1]));
        }
    }

    return $self;
}

sub _print
{
    my $self = shift;
    my $pos = shift;
    my $val = shift;

    my @po = ( [1, 1], [1, 2], [1, 3], [1, 4], [1, 5], [1, 6], [2, 6], [3, 6], [3, 5], [3, 4], [3, 3], [3, 2], [3, 1], [2, 1]);
    my $count = 0;
    for my $i( $self->{ch}*$po[$pos][0]..$self->{ch}*($po[$pos][0]+1)-1)
    {
        $count++;
        $self->{scr}->at( $i , $self->{col}/ 8 *$po[$pos][1])->puts("\x1b[48;5;". (232 + $val)."m" . (" "x $self->{cw} ) );
    }
}

sub _min
{
    my $self = shift;
    my ($a, $b) = @_;
    return ($a <= $b) ? $a : $b;
}
sub _max
{
    my $self = shift;
    my ($a, $b) = @_;
    return ($a >= $b) ? $a : $b;
}
1;

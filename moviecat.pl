#!env perl

use strict;
use warnings;
use Moviecat::FFmpeg;
use Moviecat::Image;
use Moviecat::Loading;
use Term::ScreenColor;
use Data::Dumper;

my $scr = new Term::ScreenColor;
my $cw = int($scr->cols());
my $ch = int($scr->rows());
$scr->clrscr;

#FFmpegを使って画像生成
my $filename = $ARGV[0];
my $ff = new Moviecat::FFmpeg($filename);
my $long = $ff->getlong();
my $tmpi = 0;
mkdir ("/tmp/moviecat");
mkdir ("/tmp/moviecat/$filename");
my $loading = new Moviecat::Loading($scr);
$loading->max($long*10)->message("init")->set(0);
#$ff->makeAllImage("/tmp/moviecat/$filename/%d.png");
for my $i (0..($long*10))
{
    unless (-e "/tmp/moviecat/$filename/$i.png")
    {
        $loading->message("=== $i / ${long}0 ===")->set($i)->print;
        $ff->makeImage($i , "/tmp/moviecat/$filename/$i.png") ;
    }
}

my $im = new Moviecat::Image();
$im->width($cw);
$im->height($ch-5);
my @old = ();

my @sf = {};
$loading->max($long*10)->message("buffer")->set(0);

use Time::HiRes;
my $start = [ Time::HiRes::gettimeofday( ) ];
my $i =0;
while($i<=($long*10)-1)
{
    $i++;
    $i = ($i >=0)?$i:0;
    $tmpi = 0;
    while(0.1> Time::HiRes::tv_interval($start))
    {
        select undef, undef, undef, 0.01;
    }
    @{$start}[0] = Time::HiRes::tv_interval($start);
    $im->file("/tmp/moviecat/$filename/$i.png");
#    $sf[$i] = $im->getref();
#    $loading->message("=== $i / ${long}0 ===")->set($i)->print;
#}
#for my $i (1..($long*10))
#{
    my @s = @{$im->getref()};#@{$sf[$i]};
    my $sh = @s -1;
    my $sw = @{$s[0]} -1;
    for my $j(0..$sh){
        my $l = "";
        for my $k(0..$sw){
            if($k == 0)
            {
                $l .=$s[$j][$k];
            }
            elsif($s[$j][$k] eq $s[$j][$k-1])
            {
                $l .= " ";
            }else
            {
                $l .=$s[$j][$k];
            }
        }
        $scr->at($j, 0)->puts($l);
    }
    my $status_l ="$i  ".(int($i/($long*10)*100))."%";
    my $status_c = &gett($i, $long*10);
    my $status_r ="($filename)";
    my $status_all = $status_l . " "x (int( ($cw-1)/2 - length($status_c)/2 -length($status_l))).$status_c;
    $status_all .= " "x( $cw - length($status_all) - length($status_r)).$status_r;
    my $status ="\x1b[48;5;237m";
    for my $k(0..$cw)
    {
        $status .= substr($status_all, $k, 1);
        $status .="\x1b[48;5;247m" if($k/($cw-1)>$i/($long*10));
    }
    $scr->at($sh+1, 0)->puts($status);
    @old = ();
    foreach ( @s ){ push( @old,  [ @$_ ] ); }
    if ($scr->key_pressed()) {
        my $char = $scr->getch();
        if ($char eq "kl")
        {
            $i -= int($long*10/30);
        }
        elsif ($char eq "kr")
        {
            $i += int($long*10/30);
        }
        elsif($char eq "q")
        {
            for (my $red = 0; $red < 6; $red++) {
                for (my $green = 0; $green < 6; $green++) {
                    for (my $blue = 0; $blue < 6; $blue++) {
                        printf("\x1b]4;%d;rgb:%2.2x/%2.2x/%2.2x\x1b\\",
                            16 + ($red * 36) + ($green * 6) + $blue,
                            ($red ? ($red * 40 + 55) : 0),
                            ($green ? ($green * 40 + 55) : 0),
                            ($blue ? ($blue * 40 + 55) : 0));
                    }
                }
            }
            print "\x1b[0m\n";
            exit();
        };}
}
sub gett
{
    my $i = shift;
    my $j= shift;
    my $now = "";
    my $dur = "";
    if($j<1000)
    {
        $now = "".int($i/10).".".$i%10;
        $dur = "".int($j/10).".".$j%10;
    }
    else
    {
        $now = "".int($i/10/60).":".int($i/10%60);
        $dur = "".int($j/10/60).":".int($j/10%60);
    }
    return $now." / ".$dur;
}

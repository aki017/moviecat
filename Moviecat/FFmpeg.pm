package Moviecat::FFmpeg;

use strict;

my $self;
my $file;
sub new
{
    $self = shift;
    $file = shift;
    return $self;
}

sub getlong
{
    my @out = `ffmpeg -i $file 2>&1`;

    my ($hour,  $min,  $sec) = (0, 0, 0);

    foreach my $line(@out){

        $line =~ /Duration:\s+(\d+):(\d+):(\d+)(?:\.\d+)?\s*, /s;

        if($1){

            $hour = $1;

            $min = $2;

            $sec = $3;

            last;

        }
    }
    return ((($hour * 60 ) + $min ) * 60 + $sec);
}

sub makeImage
{
    my $self = shift;
    my ($ss, $uri) = @_;
    my $vframes = int($ss % 10) + 0;
    $ss = int ($ss / 10);

    # warn "ss=$ss vframes=$vframe uri=$uri \n";
    # warn "ffmpeg -ss ${ss}.${vframes} -i $file -f image2 $uri 2>&1";

    my @out = `ffmpeg -ss ${ss}.${vframes} -i $file -f image2 $uri 2>&1`;
    return $self;
}

sub makeAllImage
{
    my $self = shift;
    my ($uri) = @_;
    my @out = `ffmpeg -i $file -r 10 -f image2 $uri`;
    return $self;
}
1;

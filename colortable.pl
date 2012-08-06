#!/usr/bin/env perl

for ($color = 0; $color <=16; $color++) {
        print "\x1b[48;5;${color}m ".sprintf("%3d", $color)."   ";
        print "\x1b[48;5;0m\n" if(($color+1) %8 ==0);
}
    print "\n";
for($color =17;$color<256;$color++){
    print "\x1b[48;5;${color}m ".sprintf("%3d", $color)."   ";
    print "\x1b[48;5;0m\n" if (($color-15) %6 ==0);
    print "\x1b[48;5;0m\n" if (($color-15) %36 ==0);
}

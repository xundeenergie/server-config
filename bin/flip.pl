#!/usr/bin/perl

use strict;
use warnings;
use utf8;

binmode(STDOUT, ":utf8");

my %flipTable = (
    "a" => "\x{0250}",
    "b" => "q",
    "c" => "\x{0254}", 
    "d" => "p",
    "e" => "\x{01DD}",
    "f" => "\x{025F}", 
    "g" => "\x{0183}",
    "h" => "\x{0265}",
    "i" => "\x{0131}", 
    "j" => "\x{027E}",
    "k" => "\x{029E}",
    "l" => "|",
    "m" => "\x{026F}",
    "n" => "u",
    "o" => "o",
    "p" => "d",
    "q" => "b",
    "r" => "\x{0279}",
    "s" => "s",
    "t" => "\x{0287}",
    "u" => "n",
    "v" => "\x{028C}",
    "w" => "\x{028D}",
    "x" => "x",
    "y" => "\x{028E}",
    "z" => "z",
    "A" => "\x{0250}",
    "B" => "q",
    "C" => "\x{0254}", 
    "D" => "p",
    "E" => "\x{01DD}",
    "F" => "\x{025F}", 
    "G" => "\x{0183}",
    "H" => "\x{0265}",
    "I" => "\x{0131}", 
    "J" => "\x{027E}",
    "K" => "\x{029E}",
    "L" => "|",
    "M" => "\x{026F}",
    "N" => "u",
    "O" => "o",
    "P" => "d",
    "Q" => "b",
    "R" => "\x{0279}",
    "S" => "s",
    "T" => "\x{0287}",
    "U" => "n",
    "V" => "\x{028C}",
    "W" => "\x{028D}",
    "X" => "x",
    "Y" => "\x{028E}",
    "Z" => "z",
    "." => "\x{02D9}",
    "[" => "]",
    "'" => ",",
    "," => "'",
    "(" => ")",
    "{" => "}",
    "?" => "\x{00BF}", 
    "!" => "\x{00A1}",
    "\"" => ",",
    "<" => ">",
    "_" => "\x{203E}",
    ";" => "\x{061B}",
    "\x{203F}" => "\x{2040}",
    "\x{2045}" => "\x{2046}",
    "\x{2234}" => "\x{2235}",
    "\r" => "\n",
    " " => " "
);

while ( <> ) {
    my $string = reverse( $_ );
    while ($string =~ /(.)/g) {
        print $flipTable{$1};
    }
    print qq(\n);
}

use strict;
use warnings;

package Rno::DBI;
use parent "DBIx::Sunny";

package Rno::DBI::db;
use parent -norequire, "DBIx::Sunny::db";

# copid from DBIx::Sunny::dt#__set_comment
sub __set_comment {
    my $self = shift;
    my $query = shift;

    my $trace;
    my $i = 0;
    while ( my @caller = caller($i) ) {
        my $file = $caller[1];
        $file =~ s!\*/!*\//!g;
        $trace = "/* $file line $caller[2] */";
        last if $caller[0] ne ref($self) && $caller[0] !~ /^(:?DBIx?|DBD|Rno)\b/;
        $i++;
    }
    $query =~ s! ! $trace !;
    $query;
}

package Rno::DBI::st;
use parent -norequire, "DBIx::Sunny::st";

1;

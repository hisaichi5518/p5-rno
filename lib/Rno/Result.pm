package Rno::Result;
use strict;
use warnings;

sub new {
    my $class = shift;
    bless { @_ }, ref($class) || $class;
}

sub generate_column_accessors {
    my ($class, @columns) = @_;

    no strict "refs";
    for my $column (@columns) {
        *{$class . "::" . $column} = sub {
            my ($self, $val) = @_;
            if ($val) {
                $self->{columns}{$column} = $val;
                push @{$self->{dirty_columns} ||= []}, $column;
            }
            $self->{columns}{$column};
        };
    }
}

1;

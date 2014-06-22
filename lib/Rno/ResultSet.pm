package Rno::ResultSet;
use strict;
use warnings;
use Scalar::Util qw(blessed);

sub new {
    my $class = shift;
    bless {@_}, ref($class) || $class;
}

sub condition { shift->{condition} ||= [] }
sub options   { shift->{options}   ||= {} }

sub select {
    my $class = shift;

    my $new_options = {};
    if (@_ % 2) { # if having options.
        $new_options = pop @_;
    }

    my @new_condition = @_;
    if (blessed $class) {
        my $self = $class;
        unshift @new_condition, @{$self->condition};

        $new_options = {
            %{$self->options},
            %{$new_options},
        };
    }

    $class->new(
        condition => \@new_condition,
        options   => $new_options,
    );
}

1;

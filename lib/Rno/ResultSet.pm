package Rno::ResultSet;
use 5.10.1;
use strict;
use warnings;

use SQL::Maker;
use Class::Load;
use Carp qw(croak);
use List::Util qw(pairkeys);
use Scalar::Util qw(blessed);
use String::CamelCase qw(decamelize);

use Rno::DBI;
use Rno::Result;
use Rno::Exceptions;

sub connect_info {
    croak 'Method "connect_info" not implemented in subclass';
}

sub dbh {
    state $dbh = Rno::DBI->connect(shift->connect_info);
}

sub sql_maker {
    state $sm = SQL::Maker->new(driver => "mysql");
}

sub set_columns { # TODO: rename
    my ($class, @columns) = @_;

    my @column_names = pairkeys @columns;
    my $table_name   = $class->build_table_name;
    my $result_class = $class->build_result_class;

    no strict "refs";
    *{$class . "::columns"}      = sub { @columns      };
    *{$class . "::column_names"} = sub { @column_names };
    *{$class . "::table_name"}   = sub { $table_name   };
    *{$class . "::result_class"} = sub { $result_class };

    Class::Load::load_optional_class($result_class)
        or $class->generate_result_class;

    $result_class->generate_column_accessors(@column_names);
}

sub generate_result_class {
    my ($class) = @_;

    no strict 'refs';
    @{$class->result_class . "::ISA"} = ("Rno::Result");
}

sub build_table_name {
    my ($class) = blessed($_[0]) || $_[0];

    my $name = (split "::", $class)[-1];
    decamelize($name);
}

sub build_result_class {
    my ($self) = @_;
    my $class = blessed($self) || $self;

    $class =~ s/ResultSet/Result/;
    $class;
}

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

sub all {
    my ($self) = @_;

    my ($sql, @bind) = $self->sql_maker->select(
        $self->table_name,
        [map { $self->table_name . "." .  $_ } $self->column_names],
        $self->condition,
        $self->options,
    );

    my $rows = $self->dbh->select_all($sql, @bind);
    map { bless { columns => $_ }, $self->result_class } @$rows;
}

sub first {
    my ($self) = @_;
    ($self->all)[0];
}

sub single {
    my ($self, @conditions) = @_;

    my ($sql, @bind) = $self->sql_maker->select(
        $self->table_name,
        [map { $self->table_name . "." .  $_ } $self->column_names],
        [@{$self->condition}, @conditions],
        {%{$self->options}, limit => 1},
    );

    if (my $raw_row = $self->dbh->select_row($sql, @bind)) {
        return bless { %$raw_row }, $self->result_class;
    }

    Rno::Exception::NotFoundResult->throw;
}

1;

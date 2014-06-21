package Rno::ResultSet;
use 5.16.1;
use strict;
use warnings;
use Carp qw(croak);
use Rno::DBI;
use String::CamelCase qw(decamelize);
use SQL::Maker;
use List::Util qw(pairkeys);
use Mouse;

has conditions => (
    is => "ro",
    isa => "ArrayRef",
    default => sub { +[] },
);

has options => (
    is => "ro",
    isa => "HashRef",
    default => sub { +{} },
);

no Mouse;

sub connect_info {
    croak "you must override Rno::ResultSet#connect_info";
}

sub dbh {
    my ($class) = @_;
    state $dbh = $class->new_dbh;
}

sub query_builder {
    my ($class) = @_;
    state $query_builder = $class->new_query_builder;
}

sub new_dbh {
    my ($class) = @_;
    my ($dsn, $user, $pass, $attr) = $class->connect_info;
    Rno::DBI->connect($dsn, $user, $pass, $attr);
}

sub new_query_builder {
    my ($class) = @_;
    SQL::Maker->new(driver => "mysql");
}

sub name {
    my ($class) = @_;
    $class = ref $class if blessed $class;

    my $name = (split "::", $class)[-1];
    decamelize($name);
}

sub set_columns {
    my ($class, @columns) = @_;

    no strict "refs";
    *{$class . "::COLUMNS"} = sub { \@columns };
}

sub select {
    my $class = shift;
    my $options  = {};
    if (@_ % 2) {
        $options = pop @_;
    }
    my (@conditions) = @_;

    if (blessed $class) {
        my $self = $class;
        unshift @conditions, @{$self->conditions};
    }

    $class->new(
        conditions => \@conditions,
        options    => $options,
    );
}

sub single {
    my ($class, @conditions) = @_;

    if (blessed $class && !@conditions) {
        return $class->select({limit => 1})->first;
    }

    $class->select(@conditions, {limit => 1})->first;
}

sub all {
    my ($self) = @_;

    my ($sql, @bind) = $self->query_builder->select(
        $self->name,
        [map { $self->name . "." .  $_ } pairkeys @{$self->COLUMNS}],
        $self->conditions,
        $self->options,
    );

    my $rows = $self->dbh->select_all($sql, @bind);
    map { bless { columns => $_ }, $self->result_class } @$rows;
}

sub first {
    my ($self) = @_;
    my ($row) = $self->all;
    $row;
}

sub result_class {
    my ($self) = @_;
    my $class = do {
        if (blessed $self) {
            ref $self;
        }
        else {
            $self;
        }
    };

    "$class\::Result";
}

1;

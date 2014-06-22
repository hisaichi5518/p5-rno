package t::Util;
use strict;
use warnings;
use utf8;
use parent "Exporter";
use DBIx::Sunny;

our @EXPORT = qw(
    setup_database
);

sub import {
    my ($class, @args) = @_;
    strict->import;
    warnings->import;
    utf8->import;

    require Test::More;
    Test::More->export_to_level(1);

    require Test::Deep;
    Test::Deep->export_to_level(1);

    require Test::Deep::Matcher;
    Test::Deep::Matcher->export_to_level(1);

    $class->export_to_level(1, $class, @args);
}

my $mysqld;
sub setup_database {
    $mysqld = Test::mysqld->new(
        my_cnf => {
            'skip-networking' => '',
        },
    ) or return;

    my $dbh = DBIx::Sunny->connect($mysqld->dsn(dbname => "test"));

    $dbh->do(q{
        CREATE TABLE foo (
            id INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
            name VARCHAR(10)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8
    });
    $dbh->query(q{INSERT INTO foo (name) VALUES(?)}, "is name");

    $mysqld;
}
1;

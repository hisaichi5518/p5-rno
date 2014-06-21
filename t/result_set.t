use t::Util;
use Test::mysqld;

my $MYSQLD = Test::mysqld->new(
    my_cnf => {
        'skip-networking' => '',
    },
) or plan skip_all => $Test::mysqld::errstr;

package MyApp::DB::ResultSet {
    use Mouse;
    extends "Rno::ResultSet";
    no Mouse;

    sub connect_info {
        return $MYSQLD->dsn(dbname => "test");
    }
};

package MyApp::DB::Foo {
    use Mouse;
    extends "MyApp::DB::ResultSet";
    no Mouse;

    __PACKAGE__->set_columns(
        id => {
            type => "INTEGER",
            size => 12,
        },
        name => {
            type => "VARCHAR",
            size => 12,
        },
    );
};

my $dbh = MyApp::DB::ResultSet->dbh;
$dbh->do(q{CREATE TABLE foo (
    id INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(10)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
});
$dbh->query(q{INSERT INTO foo (name) VALUES(?)}, "is name");

subtest "Foo.columns" => sub {
    my $columns = MyApp::DB::Foo->COLUMNS;

    cmp_deeply $columns, [
        id => {
            type => "INTEGER",
            size => 12,
        },
        name => {
            type => "VARCHAR",
            size => 12,
        },
    ];
};

subtest "Foo.name" => sub {
    my $name = MyApp::DB::Foo->name;
    is $name, "foo";
};

subtest "Foo.select" => sub {
    my $foo_rs1 = MyApp::DB::Foo->select(
        name => "is name",
    );
    cmp_deeply $foo_rs1->conditions, [
        name => "is name",
    ];

    my $foo_rs2 = $foo_rs1->select(
        hoge => "hogehoge",
    );

    isnt $foo_rs1, $foo_rs2;
    cmp_deeply $foo_rs1->conditions, [
        name => "is name",
    ];
    cmp_deeply $foo_rs2->conditions, [
        name => "is name",
        hoge => "hogehoge",
    ];
};

subtest "foo_rs.all" => sub {
    my $foo_rs = MyApp::DB::Foo->select(
        name => "is name",
    );
    my ($row) = $foo_rs->all;
    isa_ok $row, "MyApp::DB::Foo::Result";
};

subtest "foo_rs.first" => sub {
    my $foo_rs = MyApp::DB::Foo->select(
        name => "is name",
    );
    my $row = $foo_rs->first;
    isa_ok $row, "MyApp::DB::Foo::Result";
};

subtest "foo_rs.single" => sub {
    my $foo_rs = MyApp::DB::Foo->select(
        name => "is name",
    );
    my $row = $foo_rs->single;
    isa_ok $row, "MyApp::DB::Foo::Result";
};

subtest "Foo.single(...)" => sub {
    my $row = MyApp::DB::Foo->single(
        name => "is name",
    );

    isa_ok $row, "MyApp::DB::Foo::Result";
};

done_testing;

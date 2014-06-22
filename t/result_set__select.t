use t::Util;
use t::Schema;

subtest "select: where" => sub {
    my $city_rs = City->select(ID => 1);
    cmp_deeply $city_rs->condition, [
        "ID" => 1,
    ];
    cmp_deeply $city_rs->options, {};
};

subtest "select: option" => sub {
    my $city_rs = City->select({order_by => "ID"});
    cmp_deeply $city_rs->condition, [];
    cmp_deeply $city_rs->options, {order_by => "ID"};
};

subtest "select: where and option" => sub {
    my $city_rs = City->select(ID => 1, {order_by => "ID"});
    cmp_deeply $city_rs->condition, [
        "ID" => 1,
    ];
    cmp_deeply $city_rs->options, {order_by => "ID"};
};

subtest "select: where and options => where" => sub {
    my $city_rs = City->select(
        ID => 1,
        {order_by => "ID"},
    )->select(
        Name => "Kabul",
    );

    cmp_deeply $city_rs->condition, [
        ID    => 1,
        Name => "Kabul",
    ];
    cmp_deeply $city_rs->options, {order_by => "ID"};
};

subtest "select: override options" => sub {
    my $city_rs = City->select(
        ID => 1,
        {order_by => "ID", limit => 1},
    )->select(
        Name => "Kabul",
        {order_by => "Name", limit => 2},
    );

    cmp_deeply $city_rs->options, {
        order_by => "Name",
        limit    => 2,
    };
};

my $MYSQLD = setup_database;

subtest "dbh: city_dbh and country_dbh is same dbh." => sub {
    my $city_dbh    = City->dbh;
    my $country_dbh = Country->dbh;

    is "$city_dbh", "$country_dbh";
};

subtest "column/column_names" => sub {
    ok +City->columns;
    ok +City->column_names;
};

subtest "City.all" => sub {
    plan skip_all => 'City.all is TODO.';
    my @rows = City->all;
    is @rows, 1;
};

subtest "city_rs.all: without condition" => sub {
    my @rows = City->select->all;
    is @rows, 1;
};

subtest "city_rs.all: with condition: matched" => sub {
    my @rows = City->select(ID => 1)->all;
    is @rows, 1;
};

subtest "city_rs.all: with condition: not match" => sub {
    my @rows = City->select(ID => 2)->all;
    is @rows, 0;
};


subtest "city_rs.first without condition" => sub {
    my $row = City->select->first;
    isa_ok $row, "City";
};

subtest "city_rs.first: with condition: matched" => sub {
    my $row = City->select(ID => 1)->first;
    isa_ok $row, "City";
};

subtest "city_rs.first: with condition: not match" => sub {
    my $row = City->select(ID => 2)->first;
    is $row, undef;
};


subtest "city_rs.single without condition" => sub {
    my $row = City->select->single;
    isa_ok $row, "City";
};

subtest "city_rs.single: with condition: matched" => sub {
    my $row = City->select(ID => 1)->single;
    isa_ok $row, "City";
};

subtest "city_rs.single: with condition: not match" => sub {
    eval { City->select(ID => 2)->single };
    isa_ok $@, "Rno::Exception::NotFoundResult";
};

subtest "City.single(...) without condition" => sub {
    plan skip_all => 'City.single is TODO.';

    my $row = City->single;
    isa_ok $row, "City";
};

subtest "City.single(...): with condition: matched" => sub {
    plan skip_all => 'City.single is TODO.';

    my $row = City->single(ID => 1);
    isa_ok $row, "City";
};

subtest "City.single(...): with condition: not match" => sub {
    plan skip_all => 'City.single is TODO.';

    eval { City->single(ID => 2) };
    isa_ok $@, "Rno::Exception::NotFoundResult";
};

done_testing;

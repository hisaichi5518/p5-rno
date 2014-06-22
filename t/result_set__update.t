use t::Util;

my $MYSQLD = setup_database;

subtest "city_rs.update(...)" => sub {
    ok +City->select(ID => 1)->update(
        ID => 2,
    );

    eval { City->select(ID => 1)->single };
    isa_ok $@, "Rno::Exception::NotFoundResult";

    ok +City->select(ID => 2)->single;
};

subtest "City.update(...)" => sub {
    ok +City->update(
        ID => 3,
    );

    eval { City->select(ID => 2)->single };
    isa_ok $@, "Rno::Exception::NotFoundResult";

    ok +City->select(ID => 3)->single;
};

done_testing;

use t::Util;

my $MYSQLD = setup_database;

subtest "city_rs.delete" => sub {
    ok +CountryLanguage->select(Language => "Balochi")->delete;

    eval { CountryLanguage->select(Language => "Balochi")->single };
    isa_ok $@, "Rno::Exception::NotFoundResult";

    ok +CountryLanguage->all;
};

subtest "Country.delete" => sub {
    ok +Country->delete;

    eval { Country->select(Code => "AFG")->single };
    isa_ok $@, "Rno::Exception::NotFoundResult";

    ok !Country->all;
};

done_testing;

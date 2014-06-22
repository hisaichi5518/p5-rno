use t::Util;

package Test::Rno {
    use parent "Rno::Result";
}

subtest "new" => sub {
    my $t = Test::Rno->new;
    isa_ok $t, "Test::Rno";

    my $t2 = $t->new;
    isa_ok $t2, "Test::Rno";
};

subtest "generate_column_accessors" => sub {
    Test::Rno->generate_column_accessors("fuga", "hoge");
    my $t = Test::Rno->new;

    ok $t->can('fuga');
    ok $t->can('hoge');

    ok $t->fuga("fuga");
    ok $t->hoge("hoge");

    is $t->fuga, "fuga";
    is $t->hoge, "hoge";
};

done_testing;

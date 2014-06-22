requires 'perl', '5.008001';

requires "Carp";
requires "SQL::Maker";
requires "List::Util";
requires "String::CamelCase";
requires "Module::Find";
requires "Exception::Tiny";
requires "parent";
requires "DBIx::Sunny";
requires "Scalar::Util";

on 'test' => sub {
    requires 'Test::More', '0.98';
};

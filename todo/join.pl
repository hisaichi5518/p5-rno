use strict;
use warnings;
use Data::Dumper;

package City {
    use parent "Rno::ResultSet";

    __PACKAGE__->set_columns(
        ID          => {},
        Name        => {},
        CountryCode => {},
        District    => {},
        Population  => {},
    );

    __PACKAGE__->belongs_to(
        "contry" => "Country",
        ["City.CountryCode" => "Contry.Code"],
    );
};

package Country {
    use parent "Rno::ResultSet";

    __PACKAGE__->set_columns(
        Code           => {},
        Name           => {},
        Continent      => {},
        Region         => {},
        SurfaceArea    => {},
        IndepYear      => {},
        Population     => {},
        LifeExpectancy => {},
        GNP            => {},
        GNPOld         => {},
        LocalName      => {},
        GovernmentForm => {},
        HeadOfState    => {},
        Capital        => {},
        Code2          => {},
    );

    __PACKAGE__->has_many(
        "cities" => "City",
        ["Contry.Code" => "City.CountryCode"],
    );

    __PACKAGE__->has_many(
        "languages" => "ContryLanguage",
        ["Contry.Code" => "ContryLanguage.CountryCode"],
    );
};

package CountryLanguage {
    use parent "Rno::ResultSet";

    __PACKAGE__->set_columns(
        CountryCode => {},
        Language    => {},
        IsOfficial  => {},
        Percentage  => {},
    );

    __PACKAGE__->belongs_to(
        "contry" => "Country",
        ["ContryLanguage.CountryCode" => "Contry.Code"],
    );
};

{
    my $city_rs = City->search(ID => 1)->prefetch("contry");
    my $row     = $city_rs->single;

    warn Dumper $row;
    warn Dumper $row->contry;

    warn Dumper $row->is_prefetched("contry");
};

{
    my $city_rs = City->search(ID => 1)->prefetch("contry" => "languages");
    my $row     = $city_rs->single;

    warn Dumper $row;
    warn Dumper $row->contry;
    warn Dumper [$row->contry->languages->all];

    warn Dumper $row->is_prefetched("contry");
    warn Dumper $row->contry->is_prefetched("languages");
};

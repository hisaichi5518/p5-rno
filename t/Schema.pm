package t::Schema {};
package t::Schema::ResultSet {
    use parent "Rno::ResultSet";
    # see t::Util#setup_database
};

package City {
    use parent -norequire, "t::Schema::ResultSet", "Rno::Result";

    __PACKAGE__->set_columns(
        ID          => {},
        Name        => {},
        CountryCode => {},
        District    => {},
        Population  => {},
    );
};

package Country {
    use parent -norequire, "t::Schema::ResultSet", "Rno::Result";

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
};

package CountryLanguage {
    use parent -norequire, "t::Schema::ResultSet", "Rno::Result";

    __PACKAGE__->set_columns(
        CountryCode => {},
        Language    => {},
        IsOfficial  => {},
        Percentage  => {},
    );
};

1;

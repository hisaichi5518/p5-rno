package t::Util;
use strict;
use warnings;
use utf8;
use parent "Exporter";
use DBIx::Sunny;
use Test::mysqld;
use t::Schema;

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

    $dbh->do($_) for split ";\n", <<"...";
CREATE TABLE `City` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` char(35) NOT NULL DEFAULT '',
  `CountryCode` char(3) NOT NULL DEFAULT '',
  `District` char(20) NOT NULL DEFAULT '',
  `Population` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  KEY `CountryCode` (`CountryCode`)
) ENGINE=InnoDB AUTO_INCREMENT=4080 DEFAULT CHARSET=latin1;

CREATE TABLE `Country` (
  `Code` char(3) NOT NULL DEFAULT '',
  `Name` char(52) NOT NULL DEFAULT '',
  `Continent` enum('Asia','Europe','North America','Africa','Oceania','Antarctica','South America') NOT NULL DEFAULT 'Asia',
  `Region` char(26) NOT NULL DEFAULT '',
  `SurfaceArea` float(10,2) NOT NULL DEFAULT '0.00',
  `IndepYear` smallint(6) DEFAULT NULL,
  `Population` int(11) NOT NULL DEFAULT '0',
  `LifeExpectancy` float(3,1) DEFAULT NULL,
  `GNP` float(10,2) DEFAULT NULL,
  `GNPOld` float(10,2) DEFAULT NULL,
  `LocalName` char(45) NOT NULL DEFAULT '',
  `GovernmentForm` char(45) NOT NULL DEFAULT '',
  `HeadOfState` char(60) DEFAULT NULL,
  `Capital` int(11) DEFAULT NULL,
  `Code2` char(2) NOT NULL DEFAULT '',
  PRIMARY KEY (`Code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `CountryLanguage` (
  `CountryCode` char(3) NOT NULL DEFAULT '',
  `Language` char(30) NOT NULL DEFAULT '',
  `IsOfficial` enum('T','F') NOT NULL DEFAULT 'F',
  `Percentage` float(4,1) NOT NULL DEFAULT '0.0',
  PRIMARY KEY (`CountryCode`,`Language`),
  KEY `CountryCode` (`CountryCode`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO `City` (`ID`, `Name`, `CountryCode`, `District`, `Population`)
VALUES (1,'Kabul','AFG','Kabol',1780000);

INSERT INTO `Country` (
    `Code`,
    `Name`,
    `Continent`,
    `Region`,
    `SurfaceArea`,
    `IndepYear`,
    `Population`,
    `LifeExpectancy`,
    `GNP`,
    `GNPOld`,
    `LocalName`,
    `GovernmentForm`,
    `HeadOfState`,
    `Capital`,
    `Code2`
) VALUES (
    'AFG',
    'Afghanistan',
    'Asia',
    'Southern and Central Asia',
    652090.00,
    1919,
    22720000,
    45.9,
    5976.00,
    NULL,
    'Afganistan/Afqanestan',
    'Islamic Emirate',
    'Mohammad Omar',
    1,
    'AF'
);

INSERT INTO `CountryLanguage` (`CountryCode`, `Language`, `IsOfficial`, `Percentage`)
VALUES
    ('AFG','Balochi','F',0.9),
    ('AFG','Dari','T',32.1),
    ('AFG','Pashto','T',52.4),
    ('AFG','Turkmenian','F',1.9),
    ('AFG','Uzbek','F',8.8);
...

package t::Schema::ResultSet {
    sub connect_info {
        $mysqld->dsn(dbname => "test");
    }
}

    $mysqld;
}
1;

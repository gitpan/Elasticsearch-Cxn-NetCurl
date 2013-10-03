
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "A Cxn implementation which uses Net::Cul",
  "AUTHOR" => "Clinton Gormley <drtech\@cpan.org>",
  "BUILD_REQUIRES" => {
    "Test::More" => "0.98"
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Elasticsearch-Cxn-NetCurl",
  "EXE_FILES" => [],
  "LICENSE" => "apache",
  "NAME" => "Elasticsearch::Cxn::NetCurl",
  "PREREQ_PM" => {
    "Elasticsearch" => "0.74",
    "Elasticsearch::Role::Cxn::HTTP" => 0,
    "Moo" => 0,
    "Net::Curl::Easy" => 0,
    "Try::Tiny" => 0,
    "namespace::clean" => 0
  },
  "TEST_REQUIRES" => {
    "Data::Dumper" => 0,
    "Elasticsearch::Bulk" => 0,
    "Elasticsearch::Scroll" => 0,
    "Exporter" => 0,
    "File::Basename" => 0,
    "Log::Any::Adapter" => 0,
    "Log::Any::Adapter::Callback" => 0,
    "Sub::Exporter" => 0,
    "Test::Deep" => 0,
    "Test::Exception" => 0,
    "Test::More" => 0,
    "YAML" => 0,
    "lib" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "VERSION" => "0.02",
  "test" => {
    "TESTS" => "t/*.t t/10_Basic/*.t t/20_Serializer/*.t t/30_Logger/*.t t/40_Transport/*.t t/50_Cxn_Pool/*.t t/60_Cxn/*.t t/70_Helper/*.t t/90_Client_Spec/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  my $tr = delete $WriteMakefileArgs{TEST_REQUIRES};
  my $br = $WriteMakefileArgs{BUILD_REQUIRES};
  for my $mod ( keys %$tr ) {
    if ( exists $br->{$mod} ) {
      $br->{$mod} = $tr->{$mod} if $tr->{$mod} > $br->{$mod};
    }
    else {
      $br->{$mod} = $tr->{$mod};
    }
  }
}

unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);




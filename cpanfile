requires "Elasticsearch" => "0.73";
requires "Elasticsearch::Role::Cxn::HTTP" => "0";
requires "Moo" => "0";
requires "Net::Curl::Easy" => "0";
requires "Try::Tiny" => "0";
requires "namespace::clean" => "0";
recommends "JSON::XS" => "0";
recommends "URI::Escape::XS" => "0";

on 'build' => sub {
  requires "Test::More" => "0.98";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "6.30";
};

on 'develop' => sub {
  requires "Test::Pod" => "1.41";
};

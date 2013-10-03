package Elasticsearch::Cxn::NetCurl;

use Moo;
with 'Elasticsearch::Role::Cxn::HTTP';

use Elasticsearch 0.74 ();
use Try::Tiny;
use Net::Curl::Easy qw(/^CURL/);

our $VERSION = '0.02';

use namespace::clean;

has '+ping_timeout'          => ( default => 1 );
has '+sniff_request_timeout' => ( default => 1 );

#===================================
sub perform_request {
#===================================
    my ( $self, $params ) = @_;
    my $uri    = $self->build_uri($params);
    my $method = $params->{method};

    my $handle = $self->handle;
    $handle->reset;

    $handle->setopt( CURLOPT_HEADER, 0 );

    # $handle->setopt( CURLOPT_VERBOSE, 1 );

    $handle->setopt( CURLOPT_URL,           $uri );
    $handle->setopt( CURLOPT_CUSTOMREQUEST, $method );
    $handle->setopt( CURLOPT_TIMEOUT_MS,
        1000 * ( $params->{timeout} || $self->request_timeout ) );

    my %headers = ( Expect => '', %{ $self->default_headers } );

    my $data = $params->{data};
    if ( defined $data ) {
        $headers{'Content-Type'}
            = $params->{mime_type} || $self->serializer->mime_type;
        $handle->setopt( CURLOPT_POSTFIELDS,    $data );
        $handle->setopt( CURLOPT_POSTFIELDSIZE, length $data );
    }

    $handle->setopt( CURLOPT_HTTPHEADER,
        [ map { "$_: " . $headers{$_} } keys %headers ] );

    if ( $self->is_https ) {
        $handle->setopt( CURLOPT_SSL_VERIFYPEER, 0 );
        $handle->setopt( CURLOPT_SSL_VERIFYHOST, 0 );
    }

    my $content = my $head = my $msg = '';
    $handle->setopt( CURLOPT_WRITEDATA,  \$content );
    $handle->setopt( CURLOPT_HEADERDATA, \$head );

    my $code;
    try {
        $handle->perform;
        $code = $handle->getinfo(CURLINFO_RESPONSE_CODE);
    }
    catch {
        $code = 509;
        $msg  = ( 0 + $_ ) . ": $_";
        $msg . ", " . $handle->error
            if $handle->error;
        undef $content;
    };

    my ($ce) = ( $head =~ /^Content-Encoding: (\w+)/smi );

    return $self->process_response(
        $params,     # request
        $code,       # code
        $msg,        # msg
        $content,    # body
        $ce          # encoding,
    );
}

#===================================
sub error_from_text {
#===================================
    local $_ = $_[2];
    shift;
    return
          m/^7:/  ? 'Cxn'
        : m/^28:/ ? 'Timeout'
        : m/^55:/ ? 'ContentLength'
        :           'Request';

}

#===================================
sub _build_handle {
#===================================
    my $self   = shift;
    my $handle = Net::Curl::Easy->new;
    $handle->setopt( CURLOPT_HEADER,  0 );
    $handle->setopt( CURLOPT_VERBOSE, 1 );
    return $handle;
}

1;

# ABSTRACT: A Cxn implementation which uses Net::Cul

__END__

=pod

=head1 NAME

Elasticsearch::Cxn::NetCurl - A Cxn implementation which uses Net::Cul

=head1 VERSION

version 0.02

=head1 DESCRIPTION

Provides an HTTP Cxn class based on L<Net::Curl>.
The C<NetCurl> Cxn class is very fast and uses persistent connections but
requires XS and libcurl.

This class does L<Elasticsearch::Role::Cxn::HTTP>, whose documentation
provides more information.

This module overrides the defaults from L<Elasticsearch::Role::Cxn> as
sub-second timeouts don't work on all platforms.  Defaults are:

=over

=item * C<ping_timeout>: C<1> second

=item * C<sniff_request_timeout>: C<1> second

=back

=head1 SEE ALSO

=over

=item * L<Elasticsearch::Role::Cxn::HTTP>

=item * L<Elasticsearch::Cxn::LWP>

=item * L<Elasticsearch::Cxn::HTTPTiny>

=back

=head1 BUGS

This is a stable API but this implemenation is new. Watch this space
for new releases.

If you have any suggestions for improvements, or find any bugs, please report
them to L<http://github.com/elasticsearch/elasticsearch-perl-netcurl/issues>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Elasticsearch::Cxn::NetCurl

You can also look for information at:

=over 4

=item * GitHub

L<http://github.com/elasticsearch/elasticsearch-perl-netcurl>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Elasticsearch::Cxn::NetCurl>

=item * Search MetaCPAN

L<https://metacpan.org/module/Elasticsearch::Cxn::NetCurl>

=item * IRC

The L<#elasticsearch|irc://irc.freenode.net/elasticsearch> channel on
C<irc.freenode.net>.

=item * Mailing list

The main L<Elasticsearch mailing list|http://www.elasticsearch.org/community/forum/>.

=back

=head1 AUTHOR

Clinton Gormley <drtech@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2013 by Elasticsearch BV.

This is free software, licensed under:

  The Apache License, Version 2.0, January 2004

=cut

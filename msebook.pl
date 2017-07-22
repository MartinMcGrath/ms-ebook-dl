#!/usr/bin/perl

use strict;
use warnings;
no warnings 'utf8';
use Mojo::UserAgent;

my $ebookURL =
'https://blogs.msdn.microsoft.com/mssmallbiz/2017/07/11/largest-free-microsoft-ebook-giveaway-im-giving-away-millions-of-free-microsoft-ebooks-again-including-windows-10-office-365-office-2016-power-bi-azure-windows-8-1-office-2013-sharepo/';

=head1 NAME

ms-ebook-dl - Download free Microsoft ebooks

=head1 DESCRIPTION

A quick hack using L<Mojolicious> to download and properly name a bunch of free
ebooks from Microsoft.

=head1 INSTALLATION

Ensure you have an up to date L<Mojolicious> isntalled:

C<cpanm Mojolicious>

Clone the repo:

C<git clone https://github.com/MartinMcGrath/ms-ebook-dl>

=head1 LICENSE

This is released under the Artistic 
License. See L<perlartistic>.

=head1 AUTHOR

marto L<https://github.com/MartinMcGrath/>

=head1 SEE ALSO

L<http://perlmonks.org/?node_id=1195726>

L<https://blogs.msdn.microsoft.com/mssmallbiz/2017/07/11/largest-free-microsoft-ebook-giveaway-im-giving-away-millions-of-free-microsoft-ebooks-again-including-windows-10-office-365-office-2016-power-bi-azure-windows-8-1-office-2013-sharepo/>
=cut

my $ua = Mojo::UserAgent->new;
print "Get page\n";
my $res = $ua->get( $ebookURL )->res;

# css selector we want the first table witin the entry-content div, skipping 
# the first row which is a header, but not a 'th' tag.

my $selector = 'div.entry-content table:first-of-type tr:not(:first-of-type)';

warn "Parse page\n";
$res->dom->find( $selector )->each( sub{
    my $category = $_->children->[0]->all_text;
    my $title    = $_->children->[1]->all_text;
    my $url      = $_->children->[2]->at('a')->attr('href');
    my $type     = $_->children->[2]->at('a')->all_text;

    # download each file
    print "downloading: $title\n";
    # create category directory unless it already exists
    mkdir $category unless( -d $category );
    $ua->max_redirects(5)
      ->get( $url )
      ->result->content->asset->move_to($category . '/' . $title . '.' . $type);
    # play nice
    # play nice
    sleep(7);
});

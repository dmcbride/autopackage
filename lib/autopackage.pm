package autopackage;
use strict;
use warnings;

# ABSTRACT: Automatically set your package based on how your module was loaded.

=head1 SYNOPOSIS

    use autopackage;

=head1 DESCRIPTION

Ever have seriously deep package structure?  And then typos between the
file/pathname and the package name in your module?  This happens to me all
the time.  And, worse, I sometimes need to re-seat a module - moving it from
one namespace to another.  Guess what happens then: I forget to change the
package line.  And then it takes me 5 minutes to figure out why it's not
working (it used to take longer, but it happens so often now I generally
figure it out sooner).

Lo and behold, a pragma.  Simply C<use autopackage;> at the top of your
module, and you get your package declared for you at runtime.  Don't specify
the package anymore, and you can't end up with a misspelling.

This really works well for plugins where the name of the module is
figured out dynamically anyway, other modules are harder to rename.  But
it still can be useful there as it's one less thing to change.

=head1 BUGS

If your @INC has two paths inside each other, stop it.  But if you have to,
this may confuse this module.  It scans your @INC to figure out what to
eliminate from the filename, and if two paths in @INC overlap, it may
get this wrong.

For example, if you have @INC with C</foo> and C</foo/bar>, in that order,
and your module is C</foo/bar/MyModule.pm>, autopackage will think that
the package name should be C<bar::MyModule> when it's really
C<MyModule>.  If your @INC is reversed, this bug shouldn't show up.

=head1 AUTHOR

Darin McBride, C<< <dmcbride at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-autopackage at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=autopackage>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc autopackage


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=autopackage>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/autopackage>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/autopackage>

=item * Search CPAN

L<http://search.cpan.org/dist/autopackage/>

=back

=head1 COPYRIGHT

    Copyright (c) 2012, Darin McBride. All Rights Reserved.
    This module is free software. It may be used, redistributed
    and/or modified under the same terms as Perl itself.

=cut

use Filter::Simple sub {

    # figure out where we're called from
    my ($i, $pkg, $filename) = (0);
    do {
        ($pkg, $filename) = caller($i++);
    } while ($pkg =~ /^Filter/);

    # figure out where it got loaded in @INC.
    for my $inc (@INC)
    {
        if (substr($filename, 0, length($inc)) eq $inc)
        {
            $pkg = substr($filename, length($inc)+1);
            $pkg =~ s<[/\\]><::>g;
            $pkg =~ s<\.pm$><>i; # can this be uppercase on some platforms?
            last;
        }
    }

    s/^/package $pkg;/;
};

1;

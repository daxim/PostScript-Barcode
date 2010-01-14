package PostScript::Barcode;
use 5.010;
use utf8;
use strict;
use warnings FATAL => 'all';
use Alien::BWIPP;
use Devel::Refcount qw();
use Moose::Role qw(requires has);
use GSAPI qw();

our $VERSION = '0.003';

my $singleton_gsapi_instance = GSAPI::new_instance;
has '_gsapi_instance' => (is => 'ro', isa => 'Ref', default => sub {return \$singleton_gsapi_instance;},);

has 'data'      => (is => 'rw', isa => 'Str',           required => 1,);
has 'pack_data' => (is => 'rw', isa => 'Bool',          default  => 1,);
has 'move_to'   => (is => 'rw', isa => 'ArrayRef[Num]', default  => sub {return [0, 0];},);
has 'translate' => (is => 'rw', isa => 'ArrayRef[Num]',);
has 'scale'     => (is => 'rw', isa => 'ArrayRef[Num]',);

has '_post_script_source_bounding_box' => (is => 'rw', isa => 'Str',       lazy_build => 1,);
has 'bounding_box'                     => (is => 'rw', isa => 'ArrayRef[Num]',);
has '_post_script_source_header'       => (is => 'rw', isa => 'Str',       lazy_build => 1,);
has '_short_package_name'              => (is => 'ro', isa => 'Str',       lazy_build => 1,);
has '_alien_bwipp_class'               => (is => 'ro', isa => 'ClassName', lazy_build => 1,);

sub _build__post_script_source_header {
    my ($self) = @_;
    return "%!PS-Adobe-2.0 EPSF-2.0\n" . $self->_post_script_source_bounding_box;
}

sub _build__post_script_source_bounding_box {
    my ($self) = @_;
    return "%%BoundingBox: @{$self->bounding_box}\n";
}

sub _build__short_package_name {
    my ($self) = @_;
    my $package_name = $self->meta->name;
    $package_name =~ s{\A .* (?:'|::)}{}msx;    # keep last part
    return $package_name;
}

sub _build__alien_bwipp_class {
    my ($self) = @_;
    return 'Alien::BWIPP::' . $self->_short_package_name;
}

sub _post_script_source_appendix {
    my ($self) = @_;
    my @own_attributes_with_value = grep {
        $_->type_constraint->name =~ qr/\A PostScript::Barcode::Types/msx && $self ->${\$_->name}
    } $self->meta->get_all_attributes;
    my @bool_options = map {$_->name} grep {
        $_->type_constraint->equals('PostScript::Barcode::Types::Bool')
    } @own_attributes_with_value;
    my @compound_options = map {$_->name . '=' . $self ->${\$_->name}} grep {
        !$_->type_constraint->equals('PostScript::Barcode::Types::Bool')
    } @own_attributes_with_value;

    return sprintf "gsave %s %s %u %u moveto %s (%s) %s grestore showpage\n",
        ($self->translate ? "@{$self->translate} translate" : q{}),
        ($self->scale ? "@{$self->scale} scale" : q{}),
        @{$self->move_to},
        ($self->pack_data ? '<' . unpack('H*', $self->data) . '>' : '(' . $self->data . ')'),
        "@bool_options @compound_options",
        $self->_short_package_name;
}

sub post_script_source_code {
    my ($self) = @_;
    return
        $self->_post_script_source_header
      . $self->_alien_bwipp_class->new->post_script_source_code
      . $self->_post_script_source_appendix;
}

sub gsapi_init_options {
    my ($self, %params) = @_;

    my %defaults = (
        -dGraphicsAlphaBits => 4,
        -dTextAlphaBits     => 4,
        -sDEVICE            => 'pngalpha',
        -sOutputFile        => '-',
    );
    my %boolean_defaults = map {$_ => 1} qw(-dBATCH -dEPSCrop -dNOPAUSE -dQUIET -dSAFER),
        sprintf('-g%ux%u', $self->bounding_box->[-2], $self->bounding_box->[-1]);

    for my $option (keys %defaults) {
        $params{$option} = $defaults{$option} unless exists $params{$option};
    }

    my @gsapi_init_options;

    for my $option (keys %boolean_defaults) {
        unless (exists $params{$option} && !defined $params{$option}) {
            push @gsapi_init_options, $option;
        }
    }

    for my $option (keys %params) {
        push @gsapi_init_options, $option . '=' . $params{$option};
    }

    return @gsapi_init_options;
}

sub render {
    my ($self, %params) = @_;

    GSAPI::init_with_args(
        ${$self->_gsapi_instance}, $self->meta->name, $self->gsapi_init_options(%params),
    );

    GSAPI::run_string(${$self->_gsapi_instance}, $self->post_script_source_code);
    return;
}

sub DEMOLISH {
    my ($self) = @_;
    if (3 == Devel::Refcount::refcount(${$self->_gsapi_instance})) {
        GSAPI::exit(${$self->_gsapi_instance});
        GSAPI::delete_instance(${$self->_gsapi_instance});
    }
    return;
}

1;

__END__

=encoding UTF-8

=head1 NAME

PostScript::Barcode - barcode writer


=head1 VERSION

This document describes C<PostScript::Barcode> version C<0.003>.


=head1 SYNOPSIS

    # This is abstract, do not use directly.


=head1 DESCRIPTION

By itself alone, this role does nothing useful. Use one of the classes
residing under this namespace.


=head1 INTERFACE

=head2 Attributes

=head3 C<data>

Type C<Str>, B<required> attribute, data to be encoded into a barcode.

=head3 C<pack_data>

Type C<Bool>, whether data is encoded into PostScript hex notation. Default
is true.

=head3 C<move_to>

Type C<ArrayRef[Num]>, position where the barcode is placed initially.
Default is C<[0, 0]>, which is the lower left hand of a document.

=head3 C<translate>

Type C<ArrayRef[Num]>, vector by which the barcode position is shifted.

=head3 C<scale>

Type C<ArrayRef[Num]>, vector by which the barcode is resized.

=head3 C<bounding_box>

Type C<ArrayRef[Num]>, coordinates of the EPS document bounding box.

=head2 Methods

=head3 C<post_script_source_code>

Returns EPS source code of the barcode as string.

=head3 C<render>

    $barcode->render(-sDEVICE => 'pnggray', -sOutputFile => 'out.png',);

Takes a hash of initialisation options, see L<GSAPI/"init_with_args"> and
L<http://ghostscript.com/doc/current/Use.htm#Invoking>. Default is
C<< qw(-dBATCH -dEPSCrop -dNOPAUSE -dQUIET -dSAFER -gI<x>xI<y>
-dGraphicsAlphaBits=4 -dTextAlphaBits=4 -sDEVICE=pngalpha -sOutputFile=-) >>,
meaning the barcode is rendered as transparent PNG with anti-aliasing to
STDOUT, with the image size automatically taken from the L</"bounding_box">.


=head1 EXPORTS

Nothing.


=head1 DIAGNOSTICS

None.


=head1 CONFIGURATION AND ENVIRONMENT

C<PostScript::Barcode> requires no configuration files or environment
variables.


=head1 DEPENDENCIES

=head2 Configure time

Perl 5.10, L<Module::Build>

=head2 Run time

=head3 core modules

Perl 5.10

=head3 CPAN modules

L<Alien::BWIPP>, L<GSAPI>, L<Moose>, L<Moose::Role>, L<Moose::Util::TypeConstraints>


=head1 INCOMPATIBILITIES

None reported.


=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
L<http://github.com/daxim/PostScript-Barcode/issues>,
or send an email to the maintainer.


=head1 TO DO

=over

=item add classes for the other barcodes

=item rework GSAPI init options passing

=back

Suggest more future plans by L<filing a bug|/"BUGS AND LIMITATIONS">.


=head1 AUTHOR

=head2 Distribution maintainer

Lars Dɪᴇᴄᴋᴏᴡ C<< <daxim@cpan.org> >>

=head2 Contributors

See file F<AUTHORS>.


=head1 LICENCE AND COPYRIGHT

Copyright © 2009 Lars Dɪᴇᴄᴋᴏᴡ C<< <daxim@cpan.org> >>

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl 5.10.0.

=head2 Disclaimer of warranty

This library is distributed in the hope that it will be useful, but without
any warranty; without even the implied warranty of merchantability or fitness
for a particular purpose.


=head1 ACKNOWLEDGEMENTS

I wish to thank C<rillian> on Freenode. Without your help, I would not have
got this project off the ground.


=head1 SEE ALSO

L<irc://irc.freenode.net/ghostscript>

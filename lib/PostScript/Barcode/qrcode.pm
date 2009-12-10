package PostScript::Barcode::qrcode;
use 5.010;
use utf8;
use strict;
use warnings FATAL => 'all';
use Moose qw(with has);
use PostScript::Barcode::Types qw();

with qw(PostScript::Barcode);

our $VERSION = '0.002';

has 'parse'   => (is => 'rw', isa => 'PostScript::Barcode::Types::Bool',);
has 'eclevel' => (is => 'rw', isa => 'PostScript::Barcode::Types::Enum::qrcode::eclevel',);
has 'version' => (is => 'rw', isa => 'PostScript::Barcode::Types::Enum::qrcode::version',);
has 'format'  => (is => 'rw', isa => 'PostScript::Barcode::Types::Enum::qrcode::format',);
has 'raw'     => (is => 'rw', isa => 'PostScript::Barcode::Types::Bool',);

sub BUILD {
    my ($self) = @_;
    my $size;
    {
        my $abc = $self->_alien_bwipp_class->new;
        my $eclevel = $self->eclevel // 'M'; #/
        my $smallest_symbol_version;
        {
            state $index = 0;
            for (@{$abc->smallest_symbol_version->{$eclevel}}) {
                last if $abc->smallest_symbol_version->{$eclevel}[$index] > length $self->data;
                $index++;
            }
            $smallest_symbol_version = $index;
            $smallest_symbol_version++;
        }
        $size = 2 * $abc->metrics->{$smallest_symbol_version}{size};
    }
    $self->bounding_box([
        0,
        0,
        $size * ($self->scale ? $self->scale->[0] : 1) + ($self->translate ? $self->translate->[0] : 0),
        $size * ($self->scale ? $self->scale->[1] : 1) + ($self->translate ? $self->translate->[1] : 0),
    ]);
}

1;

__END__

=encoding UTF-8

=head1 NAME

PostScript::Barcode::qrcode - QR code


=head1 VERSION

This document describes C<PostScript::Barcode::qrcode> version C<0.002>.


=head1 SYNOPSIS

    use PostScript::Barcode::qrcode qw();
    my $barcode = PostScript::Barcode::qrcode->new(data => 'foo bar');
    $barcode->render;


=head1 DESCRIPTION

Attributes are described at
L<http://groups.google.com/group/postscriptbarcode/web/Code+39-2>.


=head1 INTERFACE

=head2 Attributes

In addition to L<PostScript::Barcode/"Attributes">:

=head3 C<parse>

Type C<Bool>

=head3 C<eclevel>

Type C<PostScript::Barcode::Types::Enum::qrcode::eclevel>

=head3 C<version>

Type C<PostScript::Barcode::Types::Enum::qrcode::version>

=head3 C<format>

Type C<PostScript::Barcode::Types::Enum::qrcode::format>

=head3 C<raw>

Type C<Bool>

package PostScript::Barcode::qrcode;
use 5.010;
use utf8;
use strict;
use warnings FATAL => 'all';
use Moose qw(with has);
use Moose::Util::TypeConstraints qw(enum);

with qw(PostScript::Barcode);

our $VERSION = '0.001';

enum 'Enum_qrcode_eclevel' => qw(L M Q H);
enum 'Enum_qrcode_version' => (qw(M1 M2 M3 M4), 1..40);
enum 'Enum_qrcode_format' => qw(full micro);

has 'parse'   => (is => 'rw', isa => 'Bool',);
has 'eclevel' => (is => 'rw', isa => 'Enum_qrcode_eclevel',);
has 'version' => (is => 'rw', isa => 'Enum_qrcode_version',);
has 'format'  => (is => 'rw', isa => 'Enum_qrcode_format',);
has 'raw'     => (is => 'rw', isa => 'Bool',);

sub post_script_source_appendix {
    my ($self) = @_;
    return sprintf "gsave %s %s %u %u moveto %s (%s) qrcode grestore showpage\n",
        ($self->translate ? "@{$self->translate} translate" : q{}),
        ($self->scale ? "@{$self->scale} scale" : q{}),
        @{$self->move_to},
        ($self->pack_data ? '<' . unpack('H*', $self->data) . '>' : '(' . $self->data . ')'),
        (
            (join q{}, map {"$_ "} grep {$self->$_} qw(parse raw))
          . (join q{ }, map {$_ . '=' . $self->$_} grep {$self->$_} qw(eclevel version format))
        );
}

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

This document describes C<PostScript::Barcode::qrcode> version C<0.001>.


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

=head3 C<version>

=head3 C<format>

=head3 C<raw>

Type C<Bool>

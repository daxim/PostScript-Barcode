package PostScript::Barcode::azteccode;
use 5.010;
use utf8;
use strict;
use warnings FATAL => 'all';
use Moose qw(with has);
use PostScript::Barcode::Types qw();

with qw(PostScript::Barcode);

our $VERSION = '0.002';

has 'parse'      => (is => 'rw', isa => 'PostScript::Barcode::Types::Bool',);
has 'eclevel'    => (is => 'rw', isa => 'PostScript::Barcode::Types::Num',);
has 'ecaddchars' => (is => 'rw', isa => 'PostScript::Barcode::Types::Num',);
has 'layers'     => (is => 'rw', isa => 'PostScript::Barcode::Types::Num',);
has 'format'     => (is => 'rw', isa => 'PostScript::Barcode::Types::Enum::azteccode::format',);
has 'readerinit' => (is => 'rw', isa => 'PostScript::Barcode::Types::Bool',);
has 'raw'        => (is => 'rw', isa => 'PostScript::Barcode::Types::Bool',);

sub BUILD {
    my ($self) = @_;
    my %metrics = (
        1    => 30,
        7    => 38,
        20   => 46,
        34   => 54,
        53   => 62,
        62   => 74,
        87   => 82,
        115  => 90,
        145  => 98,
        179  => 106,
        215  => 114,
        255  => 122,
        298  => 134,
        344  => 142,
        394  => 150,
        445  => 158,
        502  => 166,
        559  => 174,
        622  => 182,
        687  => 190,
        754  => 202,
        825  => 210,
        898  => 218,
        975  => 226,
        1055 => 234,
        1138 => 242,
        1223 => 250,
        1313 => 262,
        1406 => 270,
        1501 => 278,
        1600 => 286,
        1702 => 294,
        1805 => 302,
    );

    unless ($self->bounding_box) {
        my $size;
        my @order = sort {$a <=> $b} keys %metrics;
        for my $data_length (@order) {
            last if $data_length > length $self->data;
            $size = $metrics{$data_length};
        }
        $self->bounding_box([
            0,
            0,
            $size * ($self->scale ? $self->scale->[0] : 1) + ($self->translate ? $self->translate->[0] : 0),
            $size * ($self->scale ? $self->scale->[1] : 1) + ($self->translate ? $self->translate->[1] : 0),
        ]);
    }
    return;
}

1;

__END__

=encoding UTF-8

=head1 NAME

PostScript::Barcode::azteccode - Aztec Code


=head1 VERSION

This document describes C<PostScript::Barcode::azteccode> version C<0.002>.


=head1 SYNOPSIS

    use PostScript::Barcode::azteccode qw();
    my $barcode = PostScript::Barcode::azteccode->new(data => 'foo bar');
    $barcode->render;


=head1 DESCRIPTION

Attributes are described at
L<http://groups.google.com/group/postscriptbarcode/web/aztec-code>.


=head1 INTERFACE

=head2 Attributes

In addition to L<PostScript::Barcode/"Attributes">:

=head3 C<parse>

Type C<Bool>

=head3 C<eclevel>

Type C<Num>

=head3 C<ecaddchars>

Type C<Num>

=head3 C<layers>

Type C<Num>

=head3 C<format>

Type C<PostScript::Barcode::Types::Enum::azteccode::format>

=head3 C<readerinit>

Type C<Bool>

=head3 C<raw>

Type C<Bool>

package PostScript::Barcode::datamatrix;
use 5.010;
use utf8;
use strict;
use warnings FATAL => 'all';
use Moose qw(with has);
use PostScript::Barcode::Meta::Types qw();

with qw(PostScript::Barcode);

our $VERSION = '0.003';

has 'parse'    => (is => 'rw', isa => 'PostScript::Barcode::Meta::Types::Bool',);
has 'encoding' => (is => 'rw', isa => 'PostScript::Barcode::Meta::Types::Enum::datamatrix::encoding',);
has 'rows'     => (is => 'rw', isa => 'PostScript::Barcode::Meta::Types::Num',);
has 'columns'  => (is => 'rw', isa => 'PostScript::Barcode::Meta::Types::Num',);
has 'raw'      => (is => 'rw', isa => 'PostScript::Barcode::Meta::Types::Bool',);

sub BUILD {
    my ($self) = @_;
    my %metrics = (
        0    => 15,
        2    => 18,
        4    => 21,
        7    => 24,
        11   => 27,
        17   => 30,
        21   => 33,
        29   => 36,
        35   => 39,
        43   => 48,
        61   => 54,
        85   => 60,
        113  => 66,
        143  => 72,
        173  => 78,
        203  => 96,
        278  => 108,
        366  => 120,
        454  => 132,
        574  => 144,
        694  => 156,
        815  => 180,
        1049 => 198,
        1303 => 216,
    );

    unless ($self->bounding_box) {
        my $size = $metrics{0};
        my @order = sort {$a <=> $b} keys %metrics;
        for my $data_length (@order) {
            last if $data_length > length $self->data;
            $size = $metrics{$data_length};
        }
        $self->bounding_box([[0, 0], [
                $size * ($self->scale ? $self->scale->[0] : 1) + ($self->translate ? $self->translate->[0] : 0),
                $size * ($self->scale ? $self->scale->[1] : 1) + ($self->translate ? $self->translate->[1] : 0),
        ]]);
    }
    return;
}

1;

__END__

=encoding UTF-8

=head1 NAME

PostScript::Barcode::datamatrix - Data Matrix


=head1 VERSION

This document describes C<PostScript::Barcode::datamatrix> version C<0.003>.


=head1 SYNOPSIS

    use PostScript::Barcode::datamatrix qw();
    my $barcode = PostScript::Barcode::datamatrix->new(data => 'foo bar');
    $barcode->render;


=head1 DESCRIPTION

Attributes are described at
L<http://groups.google.com/group/postscriptbarcode/web/data-matrix>.


=head1 INTERFACE

=head2 Attributes

In addition to L<PostScript::Barcode/"Attributes">:

=head3 C<parse>

Type C<Bool>

=head3 C<encoding>

Type C<PostScript::Barcode::Meta::Types::Enum::datamatrix::encoding>

=head3 C<rows>

Type C<Num>

=head3 C<columns>

Type C<Num>

=head3 C<raw>

Type C<Bool>

package PostScript::Barcode::Types;
use 5.010;
use utf8;
use strict;
use warnings FATAL => 'all';
use Moose::Util::TypeConstraints qw(enum);

our $VERSION = '0.001';

enum 'PostScript::Barcode::Types::Enum::azteccode::format' => qw(full compact rune);
enum 'PostScript::Barcode::Types::Enum::qrcode::eclevel'   => qw(L M Q H);
enum 'PostScript::Barcode::Types::Enum::qrcode::version'   => (qw(M1 M2 M3 M4), 1 .. 40);
enum 'PostScript::Barcode::Types::Enum::qrcode::format'    => qw(full micro);

1;

__END__

=encoding UTF-8

=head1 NAME

PostScript::Barcode::Types - extended type constraints


=head1 VERSION

This document describes C<PostScript::Barcode::Types> version C<0.001>.


=head1 SYNOPSIS

    use PostScript::Barcode::Types qw();


=head1 DESCRIPTION

Creates the following type constraints.

=head2 PostScript::Barcode::Types::Enum::azteccode::format

Type C<Enum>: C<qw(full compact rune)>

=head2 PostScript::Barcode::Types::Enum::qrcode::eclevel

Type C<Enum>: C<qw(L M Q H)>

=head2 PostScript::Barcode::Types::Enum::qrcode::version

Type C<Enum>: C<qw(M1 M2 M3 M4), 1 .. 40>

=head2 PostScript::Barcode::Types::Enum::qrcode::format

Type C<Enum>: C<qw(full micro)>

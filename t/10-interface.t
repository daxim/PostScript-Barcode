#!perl
use strict;
use warnings FATAL   => 'all';
use Capture::Tiny qw(capture);
use Image::Size qw(imgsize);
use PostScript::Barcode::qrcode qw();
use Test::More tests => 2;

my $barcode = PostScript::Barcode::qrcode->new(
    data => '123456789012345678901234567890123456789012345678901234567890',
);
ok($barcode);

my ($stdout) = capture {
    $barcode->render;
};

TODO: {
    local $TODO = 'bounding box works on command-line, but not by API';
    is_deeply [imgsize(\$stdout)], [(66) x 2], 'image size';
}

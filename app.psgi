use FindBin;
use lib "$FindBin::Bin/local/lib/perl5";
use lib "$FindBin::Bin/lib";
use File::Basename;
use Plack::Builder;
use Isucon5f::Web;
use Cache::Memcached::Fast;
use Sereal;

my $root_dir = File::Basename::dirname(__FILE__);

my $decoder = Sereal::Decoder->new();
my $encoder = Sereal::Encoder->new();
my $app = Isucon5f::Web->psgi($root_dir);
builder {
    enable 'ReverseProxy';
    enable 'Static',
        path => qr!^/(?:(?:css|fonts|js)/|favicon\.ico$)!,
        root => File::Basename::dirname($root_dir) . '/static';
    enable 'Session::Simple',
        store => Cache::Memcached::Fast->new({
            servers => [ { address => "203.104.208.240:11211",noreply=>0} ],
            serialize_methods => [ sub { $encoder->encode($_[0])}, 
                                   sub { $decoder->decode($_[0])} ],
        }),
        httponly => 1,
        cookie_name => "isu5_session",
        keep_empty => 0;
#    enable 'Session::Cookie',
#        session_key => "airisu_session",
#        secret => $ENV{ISUCON5_SESSION_SECRET} || 'tonymoris',
#    ;
    $app;
};

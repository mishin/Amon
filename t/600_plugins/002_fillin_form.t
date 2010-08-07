use strict;
use warnings;
use Test::More;
use Test::Requires 'HTML::FillInForm';
use File::Spec;
use File::Temp qw/tempdir/;

BEGIN {
    $INC{'MyApp/Web/Dispatcher.pm'} = __FILE__;
    $INC{'MyApp.pm'} = __FILE__;
}

my $tmp = tempdir(CLEANUP => 1);

{
    package MyApp;
    use Amon2 -base;
    __PACKAGE__->config({
        'Tfall::Text::MicroTemplate::File' => {
            include_path => [$tmp],
        },
    });

    package MyApp::Web;
    use Amon2::Web -base => (
        view_class => 'Text::MicroTemplate::File',
    );
    __PACKAGE__->load_plugins(
        'FillInForm' => {},
    );
}

my $c = MyApp::Web->bootstrap();

{
    open my $fh, '>', File::Spec->catfile($tmp, 'hoge.mt') or die $!;
    print $fh <<'...';
<html>
<head>
</head>
<body>
<form action="/" method="post">
<input type="text" name="body" />
<input type="submit" name="post" />
</form>
</body>
</html>
...
    close $fh;
}

my $res = $c->render('hoge.mt')->fillin_form({body => "hello"});
like $res->body(), qr{<input value="hello" name="body" type="text" />};
done_testing;

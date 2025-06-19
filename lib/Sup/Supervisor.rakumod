use Sup::GenServer;
use Sup::GenServer::Traits;
unit role Sup::Supervisor does Sup::GenServer;

my enum Sup::Strategy is export <OneForOne OneForAll RestForOne>;

has @.initial;
has %.blocks;
has Sup::Strategy $.strategy = OneForOne;
has $.max-restart = Inf;

method TWEAK(:@initial, |) {
    for @initial {
        $.add-child: $_
    }
}

method add-child(&block) is castable {
    my $child = $.spawn-link: &block;
    %!blocks{$child.pid} = &block;
    $child
}

method link-restart($child) {
    $.terminate: "max-restart exceeded" unless $!max-restart;
    $.add-child: $_ with %!blocks{$child.pid}:delete
}

multi method apply-strategy(::?CLASS:D $ where { .strategy eq OneForOne }: $child) {
    my $index = @.links.first: $child, :k;
    $.link-restart: $_ for @.links.splice: $index, 1, ();
}

multi method apply-strategy(::?CLASS:D $ where { .strategy eq OneForAll }: $child) {
    $.link-restart: $_ for @.links.splice: 0, @.links.elems
}

multi method apply-strategy(::?CLASS:D $ where { .strategy eq RestForOne }: $child) {
    my $index = @.links.first: $child, :k;
    $.link-restart: $_ for @.links.splice: $index, @.links.elems - $index, ();
}

multi method CMD("terminate", :$cause, :$from where { %.links-set{$from} }, |) is hidden-from-backtrace {
    note "Child { $from.gist } terminated, restarting...";
    $!max-restart--;
    $.apply-strategy: $from
}

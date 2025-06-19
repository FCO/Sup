use Sup::Process;
unit role Sup::GenServer does Sup::Process;

method call(Str() $name, |c) {
    $.after-started;
    my Promise $prom .= new;
    $.send: "call", :resp($prom), :$name, :capture(c);
    return await $prom
}

method cast(Str() $name, |c) {
    $.after-started;
    my Promise $prom .= new;
    $.send: "cast", :resp($prom), :$name, :capture(c);
    $prom
}

method run is hidden-from-backtrace {
    loop {
        $.receive:
            sub ("call", :$resp!, :$name!, Capture :$capture!) is hidden-from-backtrace {
                my &meth = $.^find_method($name);
                my &orig = &meth.orig;
                $resp.keep: orig self, |$capture
            },
            sub ("cast", :$resp!, :$name!, Capture :$capture!) is hidden-from-backtrace {
                my &meth = $.^find_method($name);
                my &orig = &meth.orig;
                $resp.keep: orig self, |$capture
            }
        ;
    }
}

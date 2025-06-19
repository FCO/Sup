unit role Sup::Process does Awaitable is export;
use CX::Terminated;

my enum Status <Running Stopped>;
state UInt $next-id = 0;

has UInt         $.pid      = $next-id++;
has Channel      $.chan    .= new;
has Promise      $.loop     = self!run-loop;
has Status       $.status   = Running;
has Promise      $.running .= kept;
has              &.code;
has Sup::Process @.links;
has              $.cause;

method get-await-handle { $.loop.get-await-handle }

multi method WHICH(::?CLASS:D:) {
    ValueObjAt.new: "{self.^name}|{$!pid}"
}

multi method gist(::?CLASS:D:) {
    "<{ self.^name }|{ $!pid }>"
}

method started {
    $!status eq Running
}

method stop {
    $!status = Stopped;
}

method run {
    self.after-started;
    &!code.()
}

method !run-loop is hidden-from-backtrace {
    start {
        my $*OTP-PROC = self;
        CATCH {
            default {
                self.terminate: $_
            }
        }
        CONTROL {
            when CX::Terminated {}
            default {
                self.terminate: "Unknown control exception: {.^name}"
            }
        }
        self.run;
        self.terminate: "shutdown";
        self.flush;
    }
}

proto method CMD(Str, |) is hidden-from-backtrace {*}
multi method CMD("terminate", :$cause, :$from, :$to) is hidden-from-backtrace {
    $.stop;
    $!chan.close;
    for @!links {
        next unless .started;
        .terminate: |($_ with $cause), :$from, :to($_)
    }
    # done
    CX::Terminated.new(process => self).throw
}

multi method CMD("suspend") is hidden-from-backtrace {
    $!running .= new;
}

multi method CMD("resume") is hidden-from-backtrace {
    $!running.keep
}

method !cmd-candidates(Capture $c) {
    my %index = $.^mro.map({.^name}).kv.reverse;
    |self.^find_method("CMD").candidates
        .grep({ so .cando: \(self, |$c) })
        .sort({ %index{.signature.params.head.type.^name} })
        .map: -> &block { sub (|c) is hidden-from-backtrace { block self, |c } }
    ;
}

method flush {
    while $.receive(:!block).defined {}
}

method links-set {
    @!links.Set;
}

method link(Sup::Process $link, Bool :$reciprocate = True) {
    $link.link: self, :!reciprocate if $reciprocate; 
    return if %.links-set{$link};
    @!links.push: $link
}

method spawn-link(&code) {
    my Promise $running .= new;
    my $link = Sup::Process.new: :&code, :$running;
    $.link: $link;
    $running.keep;
    $link
}

method receive(*@options, Bool :$block = True) is hidden-from-backtrace {
    CATCH {
        default { .say }
    }
    CX::Terminated.new(process => self).throw if $block && !$.started;
    my $msg = $block ?? $!chan.receive !! $!chan.poll;
    my @cmds = |@options, |self!cmd-candidates($msg);
    my &cmd = @cmds.first: -> &cmd { so &cmd.cando: $msg }
    if &cmd {
        cmd |$msg;
    } elsif @options {
        warn "No option was matched for receive";
        CX::Terminated.new(process => self).throw
    }
    $msg
}

method send(|c) {
    return unless $.started;
    $!chan.send: c;
    c
}

method after-started {
    await $!running
}

method suspend {
    $.after-started;
    $.send: "suspend";
}

method resume {
    $.send: "resume";
}

method terminate($cause?, :$from = self, :$to = self) {
    $.after-started;
    $.send: "terminate", :$cause, :$from, :$to;
}

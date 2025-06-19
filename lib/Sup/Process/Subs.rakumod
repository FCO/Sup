use Sup::Process;
unit module Sup::Process::Subs;

sub spawn(&code) is export {
    Sup::Process.new: :&code
}

sub self-proc is export {
    $*OTP-PROC // die "Outside a Sup::Process"
}

sub receive(|c) is export {
    self-proc.receive: |c
}

sub pid is export {
    self-proc.pid
}

sub repl is export {
    await spawn(&CORE::repl).loop
}

sub link(Sup::Process:D $proc) is export {
    self-proc.link: $proc
}

sub spawn-link(&code) is export {
    self-proc.spawn-link: &code
}



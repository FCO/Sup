unit class CX::Terminated is X::Control;

has $.process;

method message {
    "process {$!process.gist} terminated"
}

unit module Sup::GenServer::Traits;
use Sup::WithOrig;

multi trait_mod:<is>(Method $m, :$callable) is export {
    my &orig = $m.clone;
    $m.wrap: method (|c) {
        $.call: $m.name, |c
    }
    $m does Sup::WithOrig(&orig)
}

multi trait_mod:<is>(Method $m, :$castable) is export {
    my &orig = $m.clone;
    $m.wrap: method (|c) {
        $.cast: $m.name, |c
    }
    $m does Sup::WithOrig(&orig)
}



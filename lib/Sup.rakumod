
sub EXPORT(--> Map()) {
    use Sup::Process::Subs;
    use Sup::Supervisor::Subs;
    use Sup::Supervisor;
    use Sup::GenServer::Traits;
    use Sup::GenServer;

    Sup::Process::Subs::EXPORT::ALL::,
    Sup::Supervisor::Subs::EXPORT::ALL::,
    Sup::GenServer::Traits::EXPORT::ALL::,
    GenServer => Sup::GenServer,
    Supervisor => Sup::Supervisor,
}


=begin pod

=head1 NAME

Sup - Something related to Erlang's OTP

=head1 SYNOPSIS

=begin code :lang<raku>

use Sup;

class Cache does GenServer {
    has %.data;
    method get(Str() $key) is callable {
        %!data{$key}
    }
    method delete(Str() $key) is callable {
        %!data{$key}:delete
    }
    method set(Str() $key, \value) is castable {
        %!data{$key} = value
    }
}

supervisor { Cache.new }

=end code

=head1 DESCRIPTION

Sup is something related to Erlang's OTP

=head1 AUTHOR

Fernando Corrêa de Oliveira <fco@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2025 Fernando Corrêa de Oliveira

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod


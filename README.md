[![Actions Status](https://github.com/FCO/Sup/actions/workflows/test.yml/badge.svg)](https://github.com/FCO/Sup/actions)

NAME
====

Sup - Something related to Erlang's OTP

SYNOPSIS
========

```raku
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
```

DESCRIPTION
===========

Sup is something related to Erlang's OTP

AUTHOR
======

Fernando Corrêa de Oliveira <fco@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2025 Fernando Corrêa de Oliveira

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.


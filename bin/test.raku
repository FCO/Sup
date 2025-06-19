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

my $c = Cache.new;

for 42, 13, 3.14 -> $num {
    await $c.set: "bla", $num;
    say $c.get: "bla";
}

start {
    await Promise.in: 5;
    say "after 5s";
    $c.resume
}

$c.suspend;

for 42, 13, 3.14 -> $num {
    await $c.set: "bla", $num;
    say $c.get: "bla";
}
$c.delete: "bla";
$c.terminate;
await $c.loop;


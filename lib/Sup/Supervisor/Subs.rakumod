use Sup::Supervisor;
unit module Sup::Supervisor::Subs;

sub supervisor(*@initial, |c) is export {
    Sup::Supervisor.new: :@initial, |c
}

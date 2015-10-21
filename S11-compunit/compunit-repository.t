use v6;
use Test;

plan 5;

for <need loaded>.combinations[0 .. *-2] {
    throws-like "class :: does CompUnit::Repository \{ { $_.map({"method {$_}() \{\}"}).join(';') } \}", X::AdHoc;
}

eval-lives-ok 'class MyRepo does CompUnit::Repository { method need() { }; method loaded() { } }';

ok $*REPO ~~ CompUnit::Repository;

# vim: ft=perl6


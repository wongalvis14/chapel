function foo(i : int = 1, j : float = 2.0, k : string = "three") {
  writeln("foo of ", i, ", ", j, ", ", k);
}

foo(4, 5.0, "six");
foo(4, 5.0);
foo(4);
foo();

function foo(type t, i : t) {
  writeln("The function foo has been called with actual value ", i);
}

var i : int = 2;

foo(int, i);

var j : float = 3.2;

foo(float, j);

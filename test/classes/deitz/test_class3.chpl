class foo {
  var i : int;
  var f : float;
}

var y : foo = foo(i=12,f=18.2);

writeln("y: (", y.i, ", ", y.f, ")");

union C {
  var x : int;
}

union D {
  var x : int;
  var y : int;
}

function f(a : C) {
  return 1;
}

var b = D();

writeln(f(b));

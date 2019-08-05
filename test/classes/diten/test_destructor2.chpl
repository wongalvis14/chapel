class C {
  var a, b: int;
}

record R {
// private:
  var c: unmanaged C;
  var c2: unmanaged C?;
// public:
  proc init(a:int, b:int) {
    writeln("R");
    c = new unmanaged C(a, b);
  }
  proc deinit() {
    writeln("~R");
    delete c;
  }
}

config var iters = 2;

proc main {
  for i in 1..#iters {
    var r = new R(1,2);
    writeln(i);
  }
}

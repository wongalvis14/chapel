class C {
  var x : int;
  function foo() {
    writeln("foo of ", x);
  }
  function bar() {
    writeln("bar of ", x);
    this.foo();
  }
}

var c = C();
c.foo();
c.bar();

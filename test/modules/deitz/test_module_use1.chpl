module red {
  var x : int = 8;
}

module blue {
  var y : int = 4;

  use red;

  function main() {
    writeln("y is ", y);
    writeln("x is ", x);
  }
}

config var n: int = 16;

function main() {
  const D: domain(1) = [1..n];
  var A: [D] int;

  forall i in D {
    A(i) = i;
  }

  writeln("A is: ", A);
}

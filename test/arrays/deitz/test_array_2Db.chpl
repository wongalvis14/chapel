var d : domain(2) = [1..3, 1..3];
var a : [d] int;

forall ij:(int,int) in d {
  a(ij(1),ij(2)) = (ij(1)-1)*3 + ij(2);
}

forall ij:(int,int) in d {
  writeln(a(ij(1),ij(2)));
}

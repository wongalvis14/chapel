var myFirstInt: int = 999;
var myFirstFloat: float = 99.9;
var mySecondInt: int;

var f: file = file(filename = "freadIntFloat.txt", mode = "r");

f.open;
fread(f, myFirstInt, myFirstFloat, mySecondInt);

writeln(myFirstInt);
writeln(myFirstFloat);
writeln(mySecondInt);

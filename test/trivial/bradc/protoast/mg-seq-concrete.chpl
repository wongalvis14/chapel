-- problem size to run:

enum classVals {S, W, A, B, C, D, O};

const probSize: [S..O] int = (32, 64, 256, 256, 512, 1024, 256);
const numIters: [S..O] int = (4, 40, 4, 20, 20, 50, 4);
const checksum: [S..O] float  = (0.0000530770700573,
                                 0.00000000000000000250391406439,
                                 0.000002433365309,
                                 0.00000180056440132,
                                 0.000000570674826298,
                                 0.000000000158327506043,
                                 0.0);

config const Class: classVals = S;


-- problem size parameters:

config const n: int = probSize(Class);
config const nx: int = n;
config const ny: int = n;
config const nz: int = n;

config const numLevels: int = lg2(n);

config const nit: int = numIters(Class);


-- checksum:

config const verifyValue: float = checksum(Class);


-- other control variables:

config const warmup: bool = true;
config const verbose: bool = false;
config const debug: bool = false;


-- help for coefficient arrays:

type coeff: [0..3] float;


-- domains:

const Levels: domain(1) = (1..numLevels);
const Base: domain(3) = (1..nx, 1..ny, 1..nz);
const Hier: [lvl in Levels] domain(Base) = Base by -2**(lvl-1);
const Stencil: domain(3) = (-1..1, -1..1, -1..1);


-- Entry point:

var initTimer: timer;
var benchTimer: timer;

initTimer.start();
  -- main arrays:
  var V: [Base] float;
  var U: [lvl in Levels] [Hier(lvl)] float;
  var R: [lvl in Levels] [Hier(lvl)] float;

  initializeMG();
  warmupMG(V, U, R);
initTimer.stop();

benchTimer.start();
  var rnm2: float = computeMG(V, U, R);
benchTimer.stop();

printResults(rnm2, initTimer.read(), benchTimer.read());


-- Top-level functions:

function initializeMG(out V: [Base] float,
                      out U, R: [lvl in Levels] [Hier(lvl)] float) {
  writeln(" NAS Parallel Benchmarks 2.4 (Chapel version) - MG Benchmark");
  writeln(" Size: ", nx, "x", ny, "x", nz);
  writeln(" Iterations: ", nit);
  writeln();

  initArrays(V, U, R);
}


function warmupMG(inout V: [Base] float,
                  inout U, R: [lvl in Levels] [Hier(lvl)] float) {
  if (warmup) {
    mg3P(V, U, R);
    resid(R(1), V, U(1));

    initArrays(V, U, R);
  }
}


function computeMG(in V: [Base] float,
                   inout U, R: [lvl in Levels] [Hier(lvl)] float): float {
  resid(R(1), V, U(1));
  norm2u3(R(1));
  for it in (1..nit) {
    mg3P(V, U, R);
    resid(R(1), V, U(1));
  }
  rnm2 = norm2u3(R(1))(1);

  return rnm2;
}


function printResults(const rnm2, inittime, runtime: float) {
  var verified: bool;

  if (verifyValue != 0.0) {
    const epsilon: float = 0.00000001;  -- BLC: 1.e-8;
    const delta: float = rnm2 - verifyValue;

    if (abs(delta) <= epsilon) {
      writeln(" VERIFICATION SUCCESSFUL ");
      writeln(" L2 Norm is ", rnm2);
      writeln(" Error is ", delta);
    } else {
      writeln(" VERIFICATION FAILED");
      writeln(" L2 norm is ", rnm2);
      writeln(" The correct L2 Norm is ", verifyValue);
    }
  } else {
    verified = false;
    writeln(" Problem size unknown");
    writeln(" NO VERIFICATION PERFORMED");
  }
  writeln(" MG Benchmark Completed.");
  writeln(" Size = ", nx, "x", ny, "x", nz);
  writeln(" Iterations = ", nit);
  writeln(" Time in seconds = ", runtime);
  writeln(" Mop/s total = ???");
  writeln(" Operation type = floating point");
  write("Verification = ");
  if (verified) {
    writeln("   SUCCESSFUL");
  } else {
    writeln(" UNSUCCESSFUL");
  }
  writeln(" Version = 2.4");
}


-- Work for a single iteration:

function mg3P(inout V: [Base] float,
              inout U, R: [lvl in Levels] [Hier(lvl)] float) {
  -- project up the hierarchy
  for lvl in (2..numLevels) {
    rprj3(R(lvl), R(lvl-1));
  }

  -- compute at the top of the hierarchy
  U(numLevels) = 0.0;
  psinv(U(numLevels), R(numLevels));

  -- interpolate down the hierarchy
  for lvl in (2..numLevels-1) by -1 {
    U(lvl) = 0.0;
    interp(U(lvl), U(lvl+1));
    resid(R(lvl), R(lvl), U(lvl));
    psinv(U(lvl), R(lvl));
  }

  -- compute at the bottom of the hierarchy
  interp(U(1), U(2));
  resid(R(1), V, U(1));
  psinv(U(1), R(1));
}


-- Here's the meat: the four stencil routines:

function psinv(inout U: [?DUR] float,
               const R: [DUR] float) {
  static const c: coeff = initCValues();
  static const c3d: [(i,j,k) in Stencil] float = c((i!=0) + (j!=0) + (k!=0));

  const Rstr: [1..3] int = DUR.stride;

  U += [ijk in DUR] sum reduce [off in Stencil] (c3d * R(ijk + Rstr*off));
}


function resid(out R: [?DUR] float,
               const V, U: [DUR] float) {
  static const a: coeff = (-8.0/3.0, 0.0, 1.0/6.0, 1.0/12.0);
  static const a3d: [(i,j,k) in Stencil] float = a((i!=0) + (j!=0) + (k!=0));

  const Ustr: [1..3] int = DUR.stride;

  R = V - [ijk in DUR] sum reduce [off in Stencil] (a3d * U(ijk + Ustr*off));
}


function rprj3(out S: [] float,
               in R: [?DR] float) {
  static const w: coeff = (0.5, 0.25, 0.125, 0.0625);
  static const w3d: [(i,j,k) in Stencil] float = w((i!=0) + (j!=0) + (k!=0));

  const Rstr: [1..3] int = R.stride;

  S = [ijk in DR] sum reduce [off in Stencil] (w3d * R(ijk + Rstr*off));
}


function interp(out R: [?DR] float,
                const S: [?DS] float) {
  static const IDom: domain(3) = (-1..0, -1..0, -1..0);
  static const IStn: [(i,j,k) in IDom] domain(3) = (i..0, j..0, k..0);
  static const w: [ijk in IDom] float = 1.0 / IStn.size();

  const Rstr: [1..3] int = DR.stride;
  const Sstr: [1..3] int = DS.stride;

  forall ioff in IDom {
    [ijk in DS] R(ijk + Rstr*ioff) 
               += w(ioff) * sum reduce [off in IStn(ioff)] S(ijk + Sstr*off);
  }
}


-- Calculates approximate norms:

function norm2u3(const R: [] float): (float, float) {
  const rnm2: float = sqrt((sum reduce R**2)/(nx*ny*nz));
  const rnmu: float = max reduce abs(R);

  return (rnm2, rnmu);
}


-- Setup stuff

function initArrays(out V: [Base] float,
                    out U, R: [lvl in Levels] [Hier(lvl)] float) {
  -- conservatively, one might want to do "V=0.0; U=0.0; R=0.0; zran3(V);", 
  -- but the following is minimal:
  zran3(V);
  U(1) = 0.0;

  V.outOfBounds(wrap);
  U.outOfBounds(wrap);
  R.outOfBounds(wrap);
}


function zran3(out V: [Base] float) {
  const ncharge: int = 10;
  var POS: [1..ncharge] index(Base);
  var NEG: [1..ncharge] index(Base);

  V = [i,j,k in Base] longRandlc((i-1) + (j-1)*nx + (k-1)*nx*ny);

  -- BLC: would make sense to replace this with a user-defined reduction
  for i in (1..ncharge) {
    POS(i) = maxloc reduce V;
    NEG(i) = minloc reduce V;
  }

  V = 0.0;
  for i in (1..ncharge) {
    V(POS(i)) =  1.0;
    V(NEG(i)) = -1.0;
  }
}


-- random number generators

function longRandlc(const n: int): float {
  static const s: float = 314159265.0;
  static const arand: float = 5.0**13;

  var kk: int = n;
  var t1: float = s;
  var t2: float = arand;
  var t3: float;

  while (kk != 0) {
    var ik: int = kk / 2;
    if (2*ik != kk) {
      t3 = randlc(t1, t2);
    }
    if (kk > 0) {
      t3 = randlc(t2, t2);
    }
    kk = ik;
  }

  return randlc(t1, arand);
}


function randlc(inout x: float,
                const a: float): float {
  static const r23: float = 0.5**23;
  static const t23: float = 2**23;
  static const r46: float = 0.5**46;
  static const t46: float = 2**46;

  var t1, t2, t3, t4, a1, a2, x1, x2, y : float;

  t1 = r23 * x;
  a1 = t1: int;
  a2 = a - t23 * a1;

  t1 = r23 * x;
  x1 = t1: int;
  x2 = x - t23 * x1;
  t1 = a1 * x2 + a2 * x1;
  t2 = (r23 * t1): int;
  y = t1 - t23 * t2;
  t3 = t23 * y + a2 * x2;
  t3 = (r46 * t3): int;
  x = t3 - t46 * t4;

  return r46 * x;
}


-- help with coefficients

function initCValues(const Class: classVals): coeff {
  if (Class == A or Class == S or Class == W) {
    return (-3.0/8.0,  1.0/32.0, -1.0/64.0, 0.0);
  } else {
    return (-3.0/17.0, 1.0/33.0, -1.0/61.0, 0.0);
  }
}



-- simple math helper function:

function lg2(const x: int): int {
  var lg: int = -1;
  while (x) {
    x *= 2;
    lg += 1;
  }
  return lg;
}

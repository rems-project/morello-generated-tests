# Automatically generated test suite for Morello

This repository contains a set of tests that was automatically generated from a
formal specification of the Morello architecture.  Each test consists of a
sequence of instructions under test (mostly randomly chosen, but occasionally
with one instruction fixed to improve coverage) and a harness that constructs
the state required to run those instructions and check some relevant parts of
the post-state to detect failures.

The tests are intended to cover most of the new Morello instruction behaviour
and to some extent the processor exceptions that can occur as a result.  They
don't cover other aspects of the system behaviour; in particular, only a very
basic address translation configuration is used.

More information about the test generation can be found in section 7 of [this
technical report](https://www.cl.cam.ac.uk/techreports/UCAM-CL-TR-959.html),
"Model-based test generation".

## Important notes

* These tests are not official and not complete - you should not regard passing
  tests as an indication that that Morello has been successfully implemented.
  Instead, test failures indicate an inconsistency between the test and an
  implementation to be investigated, rather than an error in a particular
  implementation.
* There are several possible reasons for a test failure, including: an
  implementation error, an error in the formal specification, an issue outside
  the scope of the formal specification, an error in our tools for processing
  the specification, or an error in our test harness.  During our development
  of the test generator we have seen all of these.
* To obtain more definitive information about the Morello architecture, see
  Arm's [Architectural Reference Manual Supplement for
  Morello](https://developer.arm.com/documentation/ddi0606/latest).

## Acknowledgements

This work was partially supported by the UK Government Industrial Strategy
Challenge Fund (ISCF) under the Digital Security by Design (DSbD) Programme, to
deliver a DSbDtech enabled digital platform (grant 105694), ERC AdG 789108
ELVER, EPSRC programme grant EP/K008528/1 REMS, Arm iCASE awards, EPSRC IAA KTF
funding, the Isaac Newton Trust, the UK Higher Education Innovation Fund
(HEIF), Thales E-Security, Microsoft Research Cambridge, Arm Limited, Google,
Google DeepMind, HP Enterprise, and the Gates Cambridge Trust.

Approved for public release; distribution is unlimited. This work was supported
by the Defense Advanced Research Projects Agency (DARPA) and the Air Force
Research Laboratory (AFRL), under contracts FA8750-10-C-0237 (“CTSRD”),
FA8750-11-C-0249 (“MRC2”), HR0011-18-C-0016 (“ECATS”), and FA8650-18-C-7809
(“CIFV”), as part of the DARPA CRASH, MRC, and SSITH research programs. The
views, opinions, and/or findings contained in this report are those of the
authors and should not be interpreted as representing the official views or
policies of the Department of Defense or the U.S. Government.

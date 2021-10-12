These tests each consist of 9 randomly chosen instructions, where only
the middle instruction is allowed (but not required) to fault.  The
test harness jumps to EL0 before the sequence is executed, and if a
fault is taken a few harness instructions check whether the test is
complete before continuing.

The tests are named

  test-<set>-<sequence>-<variant>.elf

For each instruction sequence a variant is produced for every path
through the specification of the middle instruction for which the
solver was able to construct a suitable test, including faults.

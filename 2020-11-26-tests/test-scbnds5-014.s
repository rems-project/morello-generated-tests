.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0xd1, 0x0f, 0xc0, 0xda, 0x0f, 0xac, 0x48, 0xf8, 0x20, 0x00, 0xc2, 0xc2, 0xdf, 0x32, 0x64, 0xb8
	.byte 0x5d, 0x62, 0x60, 0xb4, 0x40, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000001000500000000000013a6
	/* C1 */
	.octa 0x800000041000000000018009
	/* C2 */
	.octa 0x7ff8
	/* C4 */
	.octa 0x0
	/* C22 */
	.octa 0xc0000000000100050000000000001df8
	/* C29 */
	.octa 0xffffffffffffffff
final_cap_values:
	/* C0 */
	.octa 0x800fc0061000000000018009
	/* C1 */
	.octa 0x800000041000000000018009
	/* C2 */
	.octa 0x7ff8
	/* C4 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C22 */
	.octa 0xc0000000000100050000000000001df8
	/* C29 */
	.octa 0xffffffffffffffff
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000620070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword final_cap_values + 80
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xdac00fd1 // rev:aarch64/instrs/integer/arithmetic/rev Rd:17 Rn:30 opc:11 1011010110000000000:1011010110000000000 sf:1
	.inst 0xf848ac0f // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:15 Rn:0 11:11 imm9:010001010 0:0 opc:01 111000:111000 size:11
	.inst 0xc2c20020 // 0xc2c20020
	.inst 0xb86432df // stset:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:22 00:00 opc:011 o3:0 Rs:4 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0xb460625d // cbz:aarch64/instrs/branch/conditional/compare Rt:29 imm19:0110000001100010010 op:0 011010:011010 sf:1
	.inst 0xc2c21140
	.zero 1048552
.text
.global preamble
preamble:
	/* Ensure Morello is on */
	mov x0, 0x200
	msr cptr_el3, x0
	isb
	/* Set exception handler */
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	mov x0, #0xff
	msr mair_el3, x0
	ldr x0, =0x0d001519
	msr tcr_el3, x0
	isb
	tlbi alle3
	dsb sy
	isb
	/* Write tags to memory */
	ldr x0, =initial_tag_locations
	mov x1, #1
tag_init_loop:
	ldr x2, [x0], #8
	cbz x2, tag_init_end
	.inst 0xc2400043 // ldr c3, [x2, #0]
	.inst 0xc2c18063 // sctag c3, c3, c1
	.inst 0xc2000043 // str c3, [x2, #0]
	b tag_init_loop
tag_init_end:
	/* Write general purpose registers */
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400601 // ldr c1, [x16, #1]
	.inst 0xc2400a02 // ldr c2, [x16, #2]
	.inst 0xc2400e04 // ldr c4, [x16, #3]
	.inst 0xc2401216 // ldr c22, [x16, #4]
	.inst 0xc240161d // ldr c29, [x16, #5]
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82601150 // ldr c16, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc240020a // ldr c10, [x16, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240060a // ldr c10, [x16, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400a0a // ldr c10, [x16, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400e0a // ldr c10, [x16, #3]
	.inst 0xc2caa481 // chkeq c4, c10
	b.ne comparison_fail
	.inst 0xc240120a // ldr c10, [x16, #4]
	.inst 0xc2caa5e1 // chkeq c15, c10
	b.ne comparison_fail
	.inst 0xc240160a // ldr c10, [x16, #5]
	.inst 0xc2caa6c1 // chkeq c22, c10
	b.ne comparison_fail
	.inst 0xc2401a0a // ldr c10, [x16, #6]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001430
	ldr x1, =check_data0
	ldr x2, =0x00001438
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001df8
	ldr x1, =check_data1
	ldr x2, =0x00001dfc
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400018
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	/* Done print message */
	/* turn off MMU */
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	isb
	ldr x0, =fail_message
write_tube:
	ldr x1, =trickbox
write_tube_loop:
	ldrb w2, [x0], #1
	strb w2, [x1]
	b write_tube_loop
ok_message:
	.ascii "OK\n\004"
fail_message:
	.ascii "FAILED\n\004"

.section vector_table, #alloc, #execinstr
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail

	/* Translation table, single entry, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000701
	.fill 4088, 1, 0

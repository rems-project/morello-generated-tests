.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0xe9, 0x13, 0x4e, 0xe2, 0x0b, 0xfc, 0x1e, 0x48, 0x43, 0x27, 0xbf, 0x9b, 0xcc, 0x7b, 0xdd, 0xc2
	.byte 0x2b, 0x84, 0x73, 0xb9, 0xe2, 0x1f, 0x2e, 0x12, 0x02, 0x04, 0xba, 0xf9, 0xde, 0x51, 0xad, 0xe2
	.byte 0xfe, 0x2b, 0xc1, 0x1a, 0xb0, 0x5b, 0x44, 0x71, 0x60, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000300050000000000001c52
	/* C1 */
	.octa 0x8000000000070006ffffffffffffdc7c
	/* C9 */
	.octa 0x0
	/* C14 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x40000000000300050000000000001c52
	/* C1 */
	.octa 0x8000000000070006ffffffffffffdc7c
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x43a100010000000000000001
	/* C14 */
	.octa 0x1000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000005400000700ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe24e13e9 // ASTURH-R.RI-32 Rt:9 Rn:31 op2:00 imm9:011100001 V:0 op1:01 11100010:11100010
	.inst 0x481efc0b // stlxrh:aarch64/instrs/memory/exclusive/single Rt:11 Rn:0 Rt2:11111 o0:1 Rs:30 0:0 L:0 0010000:0010000 size:01
	.inst 0x9bbf2743 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:3 Rn:26 Ra:9 o0:0 Rm:31 01:01 U:1 10011011:10011011
	.inst 0xc2dd7bcc // SCBNDS-C.CI-S Cd:12 Cn:30 1110:1110 S:1 imm6:111010 11000010110:11000010110
	.inst 0xb973842b // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:11 Rn:1 imm12:110011100001 opc:01 111001:111001 size:10
	.inst 0x122e1fe2 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:2 Rn:31 imms:000111 immr:101110 N:0 100100:100100 opc:00 sf:0
	.inst 0xf9ba0402 // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:0 imm12:111010000001 opc:10 111001:111001 size:11
	.inst 0xe2ad51de // ASTUR-V.RI-S Rt:30 Rn:14 op2:00 imm9:011010101 V:1 op1:10 11100010:11100010
	.inst 0x1ac12bfe // asrv:aarch64/instrs/integer/shift/variable Rd:30 Rn:31 op2:10 0010:0010 Rm:1 0011010110:0011010110 sf:0
	.inst 0x71445bb0 // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:16 Rn:29 imm12:000100010110 sh:1 0:0 10001:10001 S:1 op:1 sf:0
	.inst 0xc2c21260
	.zero 1048532
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a1 // ldr c1, [x13, #1]
	.inst 0xc24009a9 // ldr c9, [x13, #2]
	.inst 0xc2400dae // ldr c14, [x13, #3]
	/* Vector registers */
	mrs x13, cptr_el3
	bfc x13, #10, #1
	msr cptr_el3, x13
	isb
	ldr q30, =0x0
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =initial_SP_EL3_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2c1d1bf // cpy c31, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x3085103d
	msr SCTLR_EL3, x13
	ldr x13, =0x4
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x8260326d // ldr c13, [c19, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x8260126d // ldr c13, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001b3 // ldr c19, [x13, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc24005b3 // ldr c19, [x13, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc24009b3 // ldr c19, [x13, #2]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400db3 // ldr c19, [x13, #3]
	.inst 0xc2d3a461 // chkeq c3, c19
	b.ne comparison_fail
	.inst 0xc24011b3 // ldr c19, [x13, #4]
	.inst 0xc2d3a521 // chkeq c9, c19
	b.ne comparison_fail
	.inst 0xc24015b3 // ldr c19, [x13, #5]
	.inst 0xc2d3a561 // chkeq c11, c19
	b.ne comparison_fail
	.inst 0xc24019b3 // ldr c19, [x13, #6]
	.inst 0xc2d3a581 // chkeq c12, c19
	b.ne comparison_fail
	.inst 0xc2401db3 // ldr c19, [x13, #7]
	.inst 0xc2d3a5c1 // chkeq c14, c19
	b.ne comparison_fail
	.inst 0xc24021b3 // ldr c19, [x13, #8]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0x0
	mov x19, v30.d[0]
	cmp x13, x19
	b.ne comparison_fail
	ldr x13, =0x0
	mov x19, v30.d[1]
	cmp x13, x19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010dc
	ldr x1, =check_data1
	ldr x2, =0x000010e0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010e8
	ldr x1, =check_data2
	ldr x2, =0x000010ea
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001c52
	ldr x1, =check_data3
	ldr x2, =0x00001c54
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
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

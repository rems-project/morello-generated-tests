.section data0, #alloc, #write
	.byte 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x10, 0x00, 0x00
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x02, 0x04, 0x08, 0x20
.data
check_data2:
	.byte 0xbf, 0x00, 0xc0, 0xda, 0x40, 0xf9, 0xcf, 0xc2, 0x06, 0xfc, 0xdf, 0x48, 0x5b, 0x40, 0xc2, 0xc2
	.byte 0x80, 0x61, 0xbe, 0x82, 0x3f, 0x74, 0x4e, 0xe2, 0x78, 0x98, 0x3f, 0x22, 0x90, 0xff, 0x00, 0x08
	.byte 0x1e, 0x72, 0x21, 0x2c, 0x52, 0x13, 0xa2, 0x38, 0xa0, 0x12, 0xc2, 0xc2
.data
check_data3:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x800000006101a088000000000040a001
	/* C2 */
	.octa 0x100010000000000000000
	/* C3 */
	.octa 0x400000
	/* C10 */
	.octa 0x1400000000000000000001000
	/* C12 */
	.octa 0x400000000003000767ffe00000000000
	/* C16 */
	.octa 0x2000
	/* C24 */
	.octa 0x4000000000000000000000000000
	/* C26 */
	.octa 0x1000
	/* C28 */
	.octa 0x1000
	/* C30 */
	.octa 0x9800200000001000
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x800000006101a088000000000040a001
	/* C2 */
	.octa 0x100010000000000000000
	/* C3 */
	.octa 0x400000
	/* C6 */
	.octa 0x20
	/* C10 */
	.octa 0x1400000000000000000001000
	/* C12 */
	.octa 0x400000000003000767ffe00000000000
	/* C16 */
	.octa 0x2000
	/* C18 */
	.octa 0x0
	/* C24 */
	.octa 0x4000000000000000000000000000
	/* C26 */
	.octa 0x1000
	/* C27 */
	.octa 0x100010000000000000000
	/* C28 */
	.octa 0x1000
	/* C30 */
	.octa 0x9800200000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc800000000010005007f800000e00001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 16
	.dword final_cap_values + 96
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xdac000bf // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:31 Rn:5 101101011000000000000:101101011000000000000 sf:1
	.inst 0xc2cff940 // SCBNDS-C.CI-S Cd:0 Cn:10 1110:1110 S:1 imm6:011111 11000010110:11000010110
	.inst 0x48dffc06 // ldarh:aarch64/instrs/memory/ordered Rt:6 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xc2c2405b // SCVALUE-C.CR-C Cd:27 Cn:2 000:000 opc:10 0:0 Rm:2 11000010110:11000010110
	.inst 0x82be6180 // ASTR-R.RRB-32 Rt:0 Rn:12 opc:00 S:0 option:011 Rm:30 1:1 L:0 100000101:100000101
	.inst 0xe24e743f // ALDURH-R.RI-32 Rt:31 Rn:1 op2:01 imm9:011100111 V:0 op1:01 11100010:11100010
	.inst 0x223f9878 // STLXP-R.CR-C Ct:24 Rn:3 Ct2:00110 1:1 Rs:31 1:1 L:0 001000100:001000100
	.inst 0x0800ff90 // stlxrb:aarch64/instrs/memory/exclusive/single Rt:16 Rn:28 Rt2:11111 o0:1 Rs:0 0:0 L:0 0010000:0010000 size:00
	.inst 0x2c21721e // stnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:30 Rn:16 Rt2:11100 imm7:1000010 L:0 1011000:1011000 opc:00
	.inst 0x38a21352 // ldclrb:aarch64/instrs/memory/atomicops/ld Rt:18 Rn:26 00:00 opc:001 0:0 Rs:2 1:1 R:0 A:1 111000:111000 size:00
	.inst 0xc2c212a0
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c1 // ldr c1, [x22, #0]
	.inst 0xc24006c2 // ldr c2, [x22, #1]
	.inst 0xc2400ac3 // ldr c3, [x22, #2]
	.inst 0xc2400eca // ldr c10, [x22, #3]
	.inst 0xc24012cc // ldr c12, [x22, #4]
	.inst 0xc24016d0 // ldr c16, [x22, #5]
	.inst 0xc2401ad8 // ldr c24, [x22, #6]
	.inst 0xc2401eda // ldr c26, [x22, #7]
	.inst 0xc24022dc // ldr c28, [x22, #8]
	.inst 0xc24026de // ldr c30, [x22, #9]
	/* Vector registers */
	mrs x22, cptr_el3
	bfc x22, #10, #1
	msr cptr_el3, x22
	isb
	ldr q28, =0x20080402
	ldr q30, =0x0
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30851035
	msr SCTLR_EL3, x22
	ldr x22, =0x4
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032b6 // ldr c22, [c21, #3]
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	.inst 0x826012b6 // ldr c22, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30851035
	msr SCTLR_EL3, x22
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002d5 // ldr c21, [x22, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc24006d5 // ldr c21, [x22, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400ad5 // ldr c21, [x22, #2]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400ed5 // ldr c21, [x22, #3]
	.inst 0xc2d5a461 // chkeq c3, c21
	b.ne comparison_fail
	.inst 0xc24012d5 // ldr c21, [x22, #4]
	.inst 0xc2d5a4c1 // chkeq c6, c21
	b.ne comparison_fail
	.inst 0xc24016d5 // ldr c21, [x22, #5]
	.inst 0xc2d5a541 // chkeq c10, c21
	b.ne comparison_fail
	.inst 0xc2401ad5 // ldr c21, [x22, #6]
	.inst 0xc2d5a581 // chkeq c12, c21
	b.ne comparison_fail
	.inst 0xc2401ed5 // ldr c21, [x22, #7]
	.inst 0xc2d5a601 // chkeq c16, c21
	b.ne comparison_fail
	.inst 0xc24022d5 // ldr c21, [x22, #8]
	.inst 0xc2d5a641 // chkeq c18, c21
	b.ne comparison_fail
	.inst 0xc24026d5 // ldr c21, [x22, #9]
	.inst 0xc2d5a701 // chkeq c24, c21
	b.ne comparison_fail
	.inst 0xc2402ad5 // ldr c21, [x22, #10]
	.inst 0xc2d5a741 // chkeq c26, c21
	b.ne comparison_fail
	.inst 0xc2402ed5 // ldr c21, [x22, #11]
	.inst 0xc2d5a761 // chkeq c27, c21
	b.ne comparison_fail
	.inst 0xc24032d5 // ldr c21, [x22, #12]
	.inst 0xc2d5a781 // chkeq c28, c21
	b.ne comparison_fail
	.inst 0xc24036d5 // ldr c21, [x22, #13]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check vector registers */
	ldr x22, =0x20080402
	mov x21, v28.d[0]
	cmp x22, x21
	b.ne comparison_fail
	ldr x22, =0x0
	mov x21, v28.d[1]
	cmp x22, x21
	b.ne comparison_fail
	ldr x22, =0x0
	mov x21, v30.d[0]
	cmp x22, x21
	b.ne comparison_fail
	ldr x22, =0x0
	mov x21, v30.d[1]
	cmp x22, x21
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
	ldr x0, =0x00001f08
	ldr x1, =check_data1
	ldr x2, =0x00001f10
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0040a0e8
	ldr x1, =check_data3
	ldr x2, =0x0040a0ea
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
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

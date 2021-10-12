.section data0, #alloc, #write
	.byte 0x01, 0x10, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0xfe, 0x9b, 0xfe, 0xc2, 0x5f, 0x31, 0xc0, 0xc2, 0xa1, 0xd3, 0xc6, 0xc2, 0x00, 0xc5, 0x40, 0xb1
	.byte 0x15, 0x4a, 0xde, 0xc2, 0x1b, 0x66, 0xdf, 0xc2, 0x3f, 0x40, 0x3d, 0xb8, 0xa2, 0xc7, 0x5b, 0xb6
	.byte 0x61, 0x11, 0x7f, 0xc8, 0x6e, 0x82, 0xd7, 0xc2, 0x00, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x80000000000
	/* C10 */
	.octa 0x600120010000000000000001
	/* C11 */
	.octa 0x1000
	/* C16 */
	.octa 0xc00020020000000000000000
	/* C23 */
	.octa 0x1
	/* C29 */
	.octa 0x800000000000000000001000
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0x1000
	/* C2 */
	.octa 0x80000000000
	/* C4 */
	.octa 0x0
	/* C10 */
	.octa 0x600120010000000000000001
	/* C11 */
	.octa 0x1000
	/* C16 */
	.octa 0xc00020020000000000000000
	/* C21 */
	.octa 0x400020020000000000000000
	/* C23 */
	.octa 0x1
	/* C27 */
	.octa 0xc00020020000000000000000
	/* C29 */
	.octa 0x800000000000000000001000
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20808000000640070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2fe9bfe // SUBS-R.CC-C Rd:30 Cn:31 100110:100110 Cm:30 11000010111:11000010111
	.inst 0xc2c0315f // GCLEN-R.C-C Rd:31 Cn:10 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0xc2c6d3a1 // CLRPERM-C.CI-C Cd:1 Cn:29 100:100 perm:110 1100001011000110:1100001011000110
	.inst 0xb140c500 // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:0 Rn:8 imm12:000000110001 sh:1 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0xc2de4a15 // UNSEAL-C.CC-C Cd:21 Cn:16 0010:0010 opc:01 Cm:30 11000010110:11000010110
	.inst 0xc2df661b // CPYVALUE-C.C-C Cd:27 Cn:16 001:001 opc:11 0:0 Cm:31 11000010110:11000010110
	.inst 0xb83d403f // stsmax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:100 o3:0 Rs:29 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0xb65bc7a2 // tbz:aarch64/instrs/branch/conditional/test Rt:2 imm14:01111000111101 b40:01011 op:0 011011:011011 b5:1
	.inst 0xc87f1161 // ldxp:aarch64/instrs/memory/exclusive/pair Rt:1 Rn:11 Rt2:00100 o0:0 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.inst 0xc2d7826e // SCTAG-C.CR-C Cd:14 Cn:19 000:000 0:0 10:10 Rm:23 11000010110:11000010110
	.inst 0xc2c21300
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
	.inst 0xc24002c2 // ldr c2, [x22, #0]
	.inst 0xc24006ca // ldr c10, [x22, #1]
	.inst 0xc2400acb // ldr c11, [x22, #2]
	.inst 0xc2400ed0 // ldr c16, [x22, #3]
	.inst 0xc24012d7 // ldr c23, [x22, #4]
	.inst 0xc24016dd // ldr c29, [x22, #5]
	.inst 0xc2401ade // ldr c30, [x22, #6]
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30851035
	msr SCTLR_EL3, x22
	ldr x22, =0x0
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82603316 // ldr c22, [c24, #3]
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	.inst 0x82601316 // ldr c22, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
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
	.inst 0xc24002d8 // ldr c24, [x22, #0]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc24006d8 // ldr c24, [x22, #1]
	.inst 0xc2d8a441 // chkeq c2, c24
	b.ne comparison_fail
	.inst 0xc2400ad8 // ldr c24, [x22, #2]
	.inst 0xc2d8a481 // chkeq c4, c24
	b.ne comparison_fail
	.inst 0xc2400ed8 // ldr c24, [x22, #3]
	.inst 0xc2d8a541 // chkeq c10, c24
	b.ne comparison_fail
	.inst 0xc24012d8 // ldr c24, [x22, #4]
	.inst 0xc2d8a561 // chkeq c11, c24
	b.ne comparison_fail
	.inst 0xc24016d8 // ldr c24, [x22, #5]
	.inst 0xc2d8a601 // chkeq c16, c24
	b.ne comparison_fail
	.inst 0xc2401ad8 // ldr c24, [x22, #6]
	.inst 0xc2d8a6a1 // chkeq c21, c24
	b.ne comparison_fail
	.inst 0xc2401ed8 // ldr c24, [x22, #7]
	.inst 0xc2d8a6e1 // chkeq c23, c24
	b.ne comparison_fail
	.inst 0xc24022d8 // ldr c24, [x22, #8]
	.inst 0xc2d8a761 // chkeq c27, c24
	b.ne comparison_fail
	.inst 0xc24026d8 // ldr c24, [x22, #9]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	.inst 0xc2402ad8 // ldr c24, [x22, #10]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
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

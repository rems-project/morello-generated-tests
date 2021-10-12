.section data0, #alloc, #write
	.zero 512
	.byte 0x0c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3568
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0xfd, 0x78, 0xb9, 0x9b, 0xcf, 0x2f, 0x3f, 0x22, 0xc0, 0x33, 0x4e, 0x38, 0xaf, 0x73, 0x39, 0x78
	.byte 0xdd, 0x67, 0x71, 0xe2, 0xf0, 0xab, 0xc1, 0xc2, 0x25, 0x1c, 0x18, 0xb8, 0xe2, 0x17, 0x66, 0xaa
	.byte 0x20, 0xa8, 0xdd, 0xc2, 0xbb, 0x10, 0xc7, 0xc2, 0xa0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x200f
	/* C5 */
	.octa 0x4000000000
	/* C7 */
	.octa 0x80
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0x80000000000100050000000000001200
final_cap_values:
	/* C0 */
	.octa 0x1f90
	/* C1 */
	.octa 0x1f90
	/* C5 */
	.octa 0x4000000000
	/* C7 */
	.octa 0x80
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0xc
	/* C16 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C27 */
	.octa 0x4000000000
	/* C29 */
	.octa 0x1200
	/* C30 */
	.octa 0x80000000000100050000000000001200
initial_SP_EL3_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200620070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword final_cap_values + 64
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9bb978fd // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:29 Rn:7 Ra:30 o0:0 Rm:25 01:01 U:1 10011011:10011011
	.inst 0x223f2fcf // STXP-R.CR-C Ct:15 Rn:30 Ct2:01011 0:0 Rs:31 1:1 L:0 001000100:001000100
	.inst 0x384e33c0 // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:30 00:00 imm9:011100011 0:0 opc:01 111000:111000 size:00
	.inst 0x783973af // lduminh:aarch64/instrs/memory/atomicops/ld Rt:15 Rn:29 00:00 opc:111 0:0 Rs:25 1:1 R:0 A:0 111000:111000 size:01
	.inst 0xe27167dd // ALDUR-V.RI-H Rt:29 Rn:30 op2:01 imm9:100010110 V:1 op1:01 11100010:11100010
	.inst 0xc2c1abf0 // 0xc2c1abf0
	.inst 0xb8181c25 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:5 Rn:1 11:11 imm9:110000001 0:0 opc:00 111000:111000 size:10
	.inst 0xaa6617e2 // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:2 Rn:31 imm6:000101 Rm:6 N:1 shift:01 01010:01010 opc:01 sf:1
	.inst 0xc2dda820 // EORFLGS-C.CR-C Cd:0 Cn:1 1010:1010 opc:10 Rm:29 11000010110:11000010110
	.inst 0xc2c710bb // RRLEN-R.R-C Rd:27 Rn:5 100:100 opc:00 11000010110001110:11000010110001110
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
	ldr x19, =initial_cap_values
	.inst 0xc2400261 // ldr c1, [x19, #0]
	.inst 0xc2400665 // ldr c5, [x19, #1]
	.inst 0xc2400a67 // ldr c7, [x19, #2]
	.inst 0xc2400e6b // ldr c11, [x19, #3]
	.inst 0xc240126f // ldr c15, [x19, #4]
	.inst 0xc2401679 // ldr c25, [x19, #5]
	.inst 0xc2401a7e // ldr c30, [x19, #6]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =initial_SP_EL3_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2c1d27f // cpy c31, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30851037
	msr SCTLR_EL3, x19
	ldr x19, =0x0
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032b3 // ldr c19, [c21, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x826012b3 // ldr c19, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400275 // ldr c21, [x19, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400675 // ldr c21, [x19, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400a75 // ldr c21, [x19, #2]
	.inst 0xc2d5a4a1 // chkeq c5, c21
	b.ne comparison_fail
	.inst 0xc2400e75 // ldr c21, [x19, #3]
	.inst 0xc2d5a4e1 // chkeq c7, c21
	b.ne comparison_fail
	.inst 0xc2401275 // ldr c21, [x19, #4]
	.inst 0xc2d5a561 // chkeq c11, c21
	b.ne comparison_fail
	.inst 0xc2401675 // ldr c21, [x19, #5]
	.inst 0xc2d5a5e1 // chkeq c15, c21
	b.ne comparison_fail
	.inst 0xc2401a75 // ldr c21, [x19, #6]
	.inst 0xc2d5a601 // chkeq c16, c21
	b.ne comparison_fail
	.inst 0xc2401e75 // ldr c21, [x19, #7]
	.inst 0xc2d5a721 // chkeq c25, c21
	b.ne comparison_fail
	.inst 0xc2402275 // ldr c21, [x19, #8]
	.inst 0xc2d5a761 // chkeq c27, c21
	b.ne comparison_fail
	.inst 0xc2402675 // ldr c21, [x19, #9]
	.inst 0xc2d5a7a1 // chkeq c29, c21
	b.ne comparison_fail
	.inst 0xc2402a75 // ldr c21, [x19, #10]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0x0
	mov x21, v29.d[0]
	cmp x19, x21
	b.ne comparison_fail
	ldr x19, =0x0
	mov x21, v29.d[1]
	cmp x19, x21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001116
	ldr x1, =check_data0
	ldr x2, =0x00001118
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001200
	ldr x1, =check_data1
	ldr x2, =0x00001202
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000012e3
	ldr x1, =check_data2
	ldr x2, =0x000012e4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f90
	ldr x1, =check_data3
	ldr x2, =0x00001f94
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
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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

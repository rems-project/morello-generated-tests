.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x22, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0x0a, 0xb8, 0xd5, 0xc2, 0xfc, 0xa8, 0xdf, 0xc2, 0x41, 0x30, 0xc2, 0xc2, 0x01, 0x7c, 0x29, 0xc2
	.byte 0x3f, 0x7d, 0x45, 0x9b, 0x20, 0xfc, 0x3e, 0x9b, 0xb3, 0x9a, 0xfb, 0xc2, 0x53, 0xfc, 0x9f, 0xc8
	.byte 0x5f, 0xb7, 0x0c, 0xa2, 0x49, 0xcc, 0x00, 0xbc, 0x20, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000ffffffffffff73d0
	/* C1 */
	.octa 0x220000000000000000000000
	/* C2 */
	.octa 0x1200
	/* C7 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C26 */
	.octa 0x1000
	/* C27 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x220000000000000000000000
	/* C2 */
	.octa 0x120c
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0x73fb73d0ffffffffffff73d0
	/* C19 */
	.octa 0x1
	/* C21 */
	.octa 0x0
	/* C26 */
	.octa 0x1cb0
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000000007000700ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d5b80a // SCBNDS-C.CI-C Cd:10 Cn:0 1110:1110 S:0 imm6:101011 11000010110:11000010110
	.inst 0xc2dfa8fc // EORFLGS-C.CR-C Cd:28 Cn:7 1010:1010 opc:10 Rm:31 11000010110:11000010110
	.inst 0xc2c23041 // CHKTGD-C-C 00001:00001 Cn:2 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xc2297c01 // STR-C.RIB-C Ct:1 Rn:0 imm12:101001011111 L:0 110000100:110000100
	.inst 0x9b457d3f // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:31 Rn:9 Ra:11111 0:0 Rm:5 10:10 U:0 10011011:10011011
	.inst 0x9b3efc20 // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:0 Rn:1 Ra:31 o0:1 Rm:30 01:01 U:0 10011011:10011011
	.inst 0xc2fb9ab3 // SUBS-R.CC-C Rd:19 Cn:21 100110:100110 Cm:27 11000010111:11000010111
	.inst 0xc89ffc53 // stlr:aarch64/instrs/memory/ordered Rt:19 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0xa20cb75f // STR-C.RIAW-C Ct:31 Rn:26 01:01 imm9:011001011 0:0 opc:00 10100010:10100010
	.inst 0xbc00cc49 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:9 Rn:2 11:11 imm9:000001100 0:0 opc:00 111100:111100 size:10
	.inst 0xc2c21320
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400601 // ldr c1, [x16, #1]
	.inst 0xc2400a02 // ldr c2, [x16, #2]
	.inst 0xc2400e07 // ldr c7, [x16, #3]
	.inst 0xc2401215 // ldr c21, [x16, #4]
	.inst 0xc240161a // ldr c26, [x16, #5]
	.inst 0xc2401a1b // ldr c27, [x16, #6]
	/* Vector registers */
	mrs x16, cptr_el3
	bfc x16, #10, #1
	msr cptr_el3, x16
	isb
	ldr q9, =0x0
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	ldr x16, =0x0
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82603330 // ldr c16, [c25, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x82601330 // ldr c16, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	isb
	/* Check processor flags */
	mrs x16, nzcv
	ubfx x16, x16, #28, #4
	mov x25, #0xf
	and x16, x16, x25
	cmp x16, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400219 // ldr c25, [x16, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc2400619 // ldr c25, [x16, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400a19 // ldr c25, [x16, #2]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400e19 // ldr c25, [x16, #3]
	.inst 0xc2d9a4e1 // chkeq c7, c25
	b.ne comparison_fail
	.inst 0xc2401219 // ldr c25, [x16, #4]
	.inst 0xc2d9a541 // chkeq c10, c25
	b.ne comparison_fail
	.inst 0xc2401619 // ldr c25, [x16, #5]
	.inst 0xc2d9a661 // chkeq c19, c25
	b.ne comparison_fail
	.inst 0xc2401a19 // ldr c25, [x16, #6]
	.inst 0xc2d9a6a1 // chkeq c21, c25
	b.ne comparison_fail
	.inst 0xc2401e19 // ldr c25, [x16, #7]
	.inst 0xc2d9a741 // chkeq c26, c25
	b.ne comparison_fail
	.inst 0xc2402219 // ldr c25, [x16, #8]
	.inst 0xc2d9a761 // chkeq c27, c25
	b.ne comparison_fail
	.inst 0xc2402619 // ldr c25, [x16, #9]
	.inst 0xc2d9a781 // chkeq c28, c25
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x0
	mov x25, v9.d[0]
	cmp x16, x25
	b.ne comparison_fail
	ldr x16, =0x0
	mov x25, v9.d[1]
	cmp x16, x25
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
	ldr x0, =0x00001200
	ldr x1, =check_data1
	ldr x2, =0x00001208
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000120c
	ldr x1, =check_data2
	ldr x2, =0x00001210
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000019c0
	ldr x1, =check_data3
	ldr x2, =0x000019d0
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

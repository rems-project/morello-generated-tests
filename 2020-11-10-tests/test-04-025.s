.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x82, 0x27, 0xc0, 0x1a, 0x1e, 0xb4, 0xe1, 0xe2, 0xa2, 0xeb, 0xd2, 0xc2, 0x22, 0xec, 0x94, 0xe2
	.byte 0x01, 0xc3, 0xbf, 0x78, 0x5e, 0x50, 0xc0, 0xc2, 0xa2, 0x66, 0x5b, 0x38, 0x7f, 0x98, 0xe2, 0xc2
	.byte 0xfa, 0x07, 0x38, 0x9b, 0x20, 0x08, 0xc0, 0xda, 0x60, 0x11, 0xc2, 0xc2
.data
check_data3:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xfe5
	/* C1 */
	.octa 0x1802
	/* C3 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x800000000001000700000000004ffffe
	/* C24 */
	.octa 0x800000000201c0050000000000001000
	/* C29 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x800000000001000700000000004fffb4
	/* C24 */
	.octa 0x800000000201c0050000000000001000
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004804d0040000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000100700430000000000000003
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x1ac02782 // lsrv:aarch64/instrs/integer/shift/variable Rd:2 Rn:28 op2:01 0010:0010 Rm:0 0011010110:0011010110 sf:0
	.inst 0xe2e1b41e // ALDUR-V.RI-D Rt:30 Rn:0 op2:01 imm9:000011011 V:1 op1:11 11100010:11100010
	.inst 0xc2d2eba2 // CTHI-C.CR-C Cd:2 Cn:29 1010:1010 opc:11 Rm:18 11000010110:11000010110
	.inst 0xe294ec22 // ASTUR-C.RI-C Ct:2 Rn:1 op2:11 imm9:101001110 V:0 op1:10 11100010:11100010
	.inst 0x78bfc301 // ldaprh:aarch64/instrs/memory/ordered-rcpc Rt:1 Rn:24 110000:110000 Rs:11111 111000101:111000101 size:01
	.inst 0xc2c0505e // GCVALUE-R.C-C Rd:30 Cn:2 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0x385b66a2 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:2 Rn:21 01:01 imm9:110110110 0:0 opc:01 111000:111000 size:00
	.inst 0xc2e2987f // SUBS-R.CC-C Rd:31 Cn:3 100110:100110 Cm:2 11000010111:11000010111
	.inst 0x9b3807fa // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:26 Rn:31 Ra:1 o0:0 Rm:24 01:01 U:0 10011011:10011011
	.inst 0xdac00820 // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:0 Rn:1 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2c21160
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
	.inst 0xc2400a03 // ldr c3, [x16, #2]
	.inst 0xc2400e12 // ldr c18, [x16, #3]
	.inst 0xc2401215 // ldr c21, [x16, #4]
	.inst 0xc2401618 // ldr c24, [x16, #5]
	.inst 0xc2401a1d // ldr c29, [x16, #6]
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30851037
	msr SCTLR_EL3, x16
	ldr x16, =0x0
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82603170 // ldr c16, [c11, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x82601170 // ldr c16, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
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
	mov x11, #0xf
	and x16, x16, x11
	cmp x16, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc240020b // ldr c11, [x16, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc240060b // ldr c11, [x16, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc2400a0b // ldr c11, [x16, #2]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc2400e0b // ldr c11, [x16, #3]
	.inst 0xc2cba461 // chkeq c3, c11
	b.ne comparison_fail
	.inst 0xc240120b // ldr c11, [x16, #4]
	.inst 0xc2cba641 // chkeq c18, c11
	b.ne comparison_fail
	.inst 0xc240160b // ldr c11, [x16, #5]
	.inst 0xc2cba6a1 // chkeq c21, c11
	b.ne comparison_fail
	.inst 0xc2401a0b // ldr c11, [x16, #6]
	.inst 0xc2cba701 // chkeq c24, c11
	b.ne comparison_fail
	.inst 0xc2401e0b // ldr c11, [x16, #7]
	.inst 0xc2cba741 // chkeq c26, c11
	b.ne comparison_fail
	.inst 0xc240220b // ldr c11, [x16, #8]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	.inst 0xc240260b // ldr c11, [x16, #9]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x0
	mov x11, v30.d[0]
	cmp x16, x11
	b.ne comparison_fail
	ldr x16, =0x0
	mov x11, v30.d[1]
	cmp x16, x11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001750
	ldr x1, =check_data1
	ldr x2, =0x00001760
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
	ldr x0, =0x004ffffe
	ldr x1, =check_data3
	ldr x2, =0x004fffff
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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

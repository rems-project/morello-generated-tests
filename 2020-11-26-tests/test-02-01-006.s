.section data0, #alloc, #write
	.zero 3344
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x10, 0x00, 0x00, 0x00
	.zero 720
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x10, 0x00, 0x00, 0x00
.data
check_data6:
	.byte 0x94, 0x02, 0xa3, 0xf8, 0x41, 0xe4, 0x81, 0x9a, 0x9f, 0x21, 0x45, 0xe2, 0xe1, 0xf6, 0x05, 0x78
	.byte 0xe0, 0xdf, 0xdf, 0xe2, 0x42, 0x7f, 0x53, 0x9b, 0xa3, 0x52, 0xa1, 0xe2, 0x64, 0xad, 0x68, 0x62
	.byte 0x1d, 0x5b, 0x39, 0x39, 0xfe, 0xf3, 0x81, 0x82, 0x20, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C11 */
	.octa 0x900000000000c0000000000000002000
	/* C12 */
	.octa 0x1bdb
	/* C20 */
	.octa 0xc00000004004000a0000000000001000
	/* C21 */
	.octa 0x1be8
	/* C23 */
	.octa 0x400000002001c0050000000000001000
	/* C24 */
	.octa 0x400000005804025c0000000000000804
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x800000000000000000000000
	/* C11 */
	.octa 0x10200000000000000000000000
	/* C12 */
	.octa 0x1bdb
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x1be8
	/* C23 */
	.octa 0x400000002001c005000000000000105f
	/* C24 */
	.octa 0x400000005804025c0000000000000804
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1200
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0100000400200d30000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001d10
	.dword 0x0000000000001d20
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf8a30294 // ldadd:aarch64/instrs/memory/atomicops/ld Rt:20 Rn:20 00:00 opc:000 0:0 Rs:3 1:1 R:0 A:1 111000:111000 size:11
	.inst 0x9a81e441 // csinc:aarch64/instrs/integer/conditional/select Rd:1 Rn:2 o2:1 0:0 cond:1110 Rm:1 011010100:011010100 op:0 sf:1
	.inst 0xe245219f // ASTURH-R.RI-32 Rt:31 Rn:12 op2:00 imm9:001010010 V:0 op1:01 11100010:11100010
	.inst 0x7805f6e1 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:23 01:01 imm9:001011111 0:0 opc:00 111000:111000 size:01
	.inst 0xe2dfdfe0 // ALDUR-C.RI-C Ct:0 Rn:31 op2:11 imm9:111111101 V:0 op1:11 11100010:11100010
	.inst 0x9b537f42 // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:2 Rn:26 Ra:11111 0:0 Rm:19 10:10 U:0 10011011:10011011
	.inst 0xe2a152a3 // ASTUR-V.RI-S Rt:3 Rn:21 op2:00 imm9:000010101 V:1 op1:10 11100010:11100010
	.inst 0x6268ad64 // LDNP-C.RIB-C Ct:4 Rn:11 Ct2:01011 imm7:1010001 L:1 011000100:011000100
	.inst 0x39395b1d // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:29 Rn:24 imm12:111001010110 opc:00 111001:111001 size:00
	.inst 0x8281f3fe // ASTRB-R.RRB-B Rt:30 Rn:31 opc:00 S:1 option:111 Rm:1 0:0 L:0 100000101:100000101
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e2 // ldr c2, [x7, #0]
	.inst 0xc24004e3 // ldr c3, [x7, #1]
	.inst 0xc24008eb // ldr c11, [x7, #2]
	.inst 0xc2400cec // ldr c12, [x7, #3]
	.inst 0xc24010f4 // ldr c20, [x7, #4]
	.inst 0xc24014f5 // ldr c21, [x7, #5]
	.inst 0xc24018f7 // ldr c23, [x7, #6]
	.inst 0xc2401cf8 // ldr c24, [x7, #7]
	.inst 0xc24020fd // ldr c29, [x7, #8]
	.inst 0xc24024fe // ldr c30, [x7, #9]
	/* Vector registers */
	mrs x7, cptr_el3
	bfc x7, #10, #1
	msr cptr_el3, x7
	isb
	ldr q3, =0x0
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =initial_SP_EL3_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2c1d0ff // cpy c31, c7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x3085103d
	msr SCTLR_EL3, x7
	ldr x7, =0x4
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82603327 // ldr c7, [c25, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x82601327 // ldr c7, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30851035
	msr SCTLR_EL3, x7
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000f9 // ldr c25, [x7, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc24004f9 // ldr c25, [x7, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc24008f9 // ldr c25, [x7, #2]
	.inst 0xc2d9a461 // chkeq c3, c25
	b.ne comparison_fail
	.inst 0xc2400cf9 // ldr c25, [x7, #3]
	.inst 0xc2d9a481 // chkeq c4, c25
	b.ne comparison_fail
	.inst 0xc24010f9 // ldr c25, [x7, #4]
	.inst 0xc2d9a561 // chkeq c11, c25
	b.ne comparison_fail
	.inst 0xc24014f9 // ldr c25, [x7, #5]
	.inst 0xc2d9a581 // chkeq c12, c25
	b.ne comparison_fail
	.inst 0xc24018f9 // ldr c25, [x7, #6]
	.inst 0xc2d9a681 // chkeq c20, c25
	b.ne comparison_fail
	.inst 0xc2401cf9 // ldr c25, [x7, #7]
	.inst 0xc2d9a6a1 // chkeq c21, c25
	b.ne comparison_fail
	.inst 0xc24020f9 // ldr c25, [x7, #8]
	.inst 0xc2d9a6e1 // chkeq c23, c25
	b.ne comparison_fail
	.inst 0xc24024f9 // ldr c25, [x7, #9]
	.inst 0xc2d9a701 // chkeq c24, c25
	b.ne comparison_fail
	.inst 0xc24028f9 // ldr c25, [x7, #10]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc2402cf9 // ldr c25, [x7, #11]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check vector registers */
	ldr x7, =0x0
	mov x25, v3.d[0]
	cmp x7, x25
	b.ne comparison_fail
	ldr x7, =0x0
	mov x25, v3.d[1]
	cmp x7, x25
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
	ldr x0, =0x000012d0
	ldr x1, =check_data1
	ldr x2, =0x000012e0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000165a
	ldr x1, =check_data2
	ldr x2, =0x0000165b
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001cd0
	ldr x1, =check_data3
	ldr x2, =0x00001cd4
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001d00
	ldr x1, =check_data4
	ldr x2, =0x00001d02
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001d10
	ldr x1, =check_data5
	ldr x2, =0x00001d30
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
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

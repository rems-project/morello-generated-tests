.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x80, 0x2c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 48
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x0c, 0xdf, 0x27, 0xe2, 0x0d, 0xb4, 0x8a, 0xe2, 0x31, 0xb3, 0xc4, 0xc2, 0x1f, 0x50, 0xc0, 0xc2
	.byte 0x15, 0xc1, 0xbf, 0x78, 0xc8, 0xe7, 0x1d, 0x78, 0xfe, 0x0b, 0xde, 0xc2, 0x1f, 0x62, 0xe2, 0x38
	.byte 0x20, 0x00, 0x5f, 0xd6
.data
check_data4:
	.byte 0x2a, 0x49, 0x49, 0xfa, 0x60, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 2
.data
check_data6:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000027000f000000000000100d
	/* C1 */
	.octa 0x400100
	/* C2 */
	.octa 0x0
	/* C8 */
	.octa 0x402c80
	/* C16 */
	.octa 0x1100
	/* C24 */
	.octa 0x8000000023020000000000000047ff73
	/* C25 */
	.octa 0x1000
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x800000000027000f000000000000100d
	/* C1 */
	.octa 0x400100
	/* C2 */
	.octa 0x0
	/* C8 */
	.octa 0x402c80
	/* C13 */
	.octa 0x0
	/* C16 */
	.octa 0x1100
	/* C17 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C24 */
	.octa 0x8000000023020000000000000047ff73
	/* C25 */
	.octa 0x1000
	/* C30 */
	.octa 0x7ef000000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000006000200fffffffc000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword 0x0000000000001020
	.dword initial_cap_values + 0
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe227df0c // ALDUR-V.RI-Q Rt:12 Rn:24 op2:11 imm9:001111101 V:1 op1:00 11100010:11100010
	.inst 0xe28ab40d // ALDUR-R.RI-32 Rt:13 Rn:0 op2:01 imm9:010101011 V:0 op1:10 11100010:11100010
	.inst 0xc2c4b331 // LDCT-R.R-_ Rt:17 Rn:25 100:100 opc:01 11000010110001001:11000010110001001
	.inst 0xc2c0501f // GCVALUE-R.C-C Rd:31 Cn:0 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0x78bfc115 // ldaprh:aarch64/instrs/memory/ordered-rcpc Rt:21 Rn:8 110000:110000 Rs:11111 111000101:111000101 size:01
	.inst 0x781de7c8 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:8 Rn:30 01:01 imm9:111011110 0:0 opc:00 111000:111000 size:01
	.inst 0xc2de0bfe // SEAL-C.CC-C Cd:30 Cn:31 0010:0010 opc:00 Cm:30 11000010110:11000010110
	.inst 0x38e2621f // ldumaxb:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:16 00:00 opc:110 0:0 Rs:2 1:1 R:1 A:1 111000:111000 size:00
	.inst 0xd65f0020 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:1 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 220
	.inst 0xfa49492a // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1010 0:0 Rn:9 10:10 cond:0100 imm5:01001 111010010:111010010 op:1 sf:1
	.inst 0xc2c21160
	.zero 1048312
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
	ldr x18, =initial_cap_values
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc2400641 // ldr c1, [x18, #1]
	.inst 0xc2400a42 // ldr c2, [x18, #2]
	.inst 0xc2400e48 // ldr c8, [x18, #3]
	.inst 0xc2401250 // ldr c16, [x18, #4]
	.inst 0xc2401658 // ldr c24, [x18, #5]
	.inst 0xc2401a59 // ldr c25, [x18, #6]
	.inst 0xc2401e5e // ldr c30, [x18, #7]
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30851037
	msr SCTLR_EL3, x18
	ldr x18, =0xc
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82603172 // ldr c18, [c11, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x82601172 // ldr c18, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	isb
	/* Check processor flags */
	mrs x18, nzcv
	ubfx x18, x18, #28, #4
	mov x11, #0xf
	and x18, x18, x11
	cmp x18, #0xa
	b.ne comparison_fail
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc240024b // ldr c11, [x18, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc240064b // ldr c11, [x18, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc2400a4b // ldr c11, [x18, #2]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc2400e4b // ldr c11, [x18, #3]
	.inst 0xc2cba501 // chkeq c8, c11
	b.ne comparison_fail
	.inst 0xc240124b // ldr c11, [x18, #4]
	.inst 0xc2cba5a1 // chkeq c13, c11
	b.ne comparison_fail
	.inst 0xc240164b // ldr c11, [x18, #5]
	.inst 0xc2cba601 // chkeq c16, c11
	b.ne comparison_fail
	.inst 0xc2401a4b // ldr c11, [x18, #6]
	.inst 0xc2cba621 // chkeq c17, c11
	b.ne comparison_fail
	.inst 0xc2401e4b // ldr c11, [x18, #7]
	.inst 0xc2cba6a1 // chkeq c21, c11
	b.ne comparison_fail
	.inst 0xc240224b // ldr c11, [x18, #8]
	.inst 0xc2cba701 // chkeq c24, c11
	b.ne comparison_fail
	.inst 0xc240264b // ldr c11, [x18, #9]
	.inst 0xc2cba721 // chkeq c25, c11
	b.ne comparison_fail
	.inst 0xc2402a4b // ldr c11, [x18, #10]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x18, =0x0
	mov x11, v12.d[0]
	cmp x18, x11
	b.ne comparison_fail
	ldr x18, =0x0
	mov x11, v12.d[1]
	cmp x18, x11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001040
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010b8
	ldr x1, =check_data1
	ldr x2, =0x000010bc
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001101
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400024
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400100
	ldr x1, =check_data4
	ldr x2, =0x00400108
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00402c80
	ldr x1, =check_data5
	ldr x2, =0x00402c82
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0047fff0
	ldr x1, =check_data6
	ldr x2, =0x00480000
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
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

.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x87, 0xf7, 0x06, 0x86, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 720
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x01, 0x00, 0x00
	.zero 1312
	.byte 0x99, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0xfe
	.zero 2016
.data
check_data0:
	.byte 0x02, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x01, 0x00, 0x00
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 16
	.byte 0x99, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0xfe
.data
check_data5:
	.byte 0x7f, 0x01, 0x26, 0xf8, 0xf9, 0x13, 0x78, 0x78, 0x0d, 0xd6, 0x5a, 0xd0, 0x8f, 0x32, 0xc4, 0xc2
.data
check_data6:
	.byte 0x36, 0x7c, 0xd4, 0x62, 0xff, 0x64, 0x17, 0xbc, 0x06, 0xa6, 0xf2, 0xe2, 0xfa, 0xff, 0x5f, 0x88
	.byte 0xf0, 0x93, 0xc0, 0xc2, 0xbd, 0xe0, 0xce, 0xca, 0x40, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x90000000001100070000000000001050
	/* C6 */
	.octa 0x79f9087d00000002
	/* C7 */
	.octa 0x40000000008140050000000000001020
	/* C11 */
	.octa 0x1000
	/* C16 */
	.octa 0x1806
	/* C20 */
	.octa 0x900000006006000e0000000000001800
	/* C24 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0x900000000011000700000000000012d0
	/* C6 */
	.octa 0x79f9087d00000002
	/* C7 */
	.octa 0x40000000008140050000000000000f96
	/* C11 */
	.octa 0x1000
	/* C13 */
	.octa 0xb5ec2000
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x1
	/* C20 */
	.octa 0x900000006006000e0000000000001800
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0x2
	/* C26 */
	.octa 0x2
	/* C30 */
	.octa 0x20008000000080080000000000400010
initial_SP_EL3_value:
	.octa 0x80000000000300070000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005801000000ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000012d0
	.dword 0x00000000000012e0
	.dword 0x0000000000001810
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 192
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf826017f // stadd:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:11 00:00 opc:000 o3:0 Rs:6 1:1 R:0 A:0 00:00 V:0 111:111 size:11
	.inst 0x787813f9 // ldclrh:aarch64/instrs/memory/atomicops/ld Rt:25 Rn:31 00:00 opc:001 0:0 Rs:24 1:1 R:1 A:0 111000:111000 size:01
	.inst 0xd05ad60d // ADRDP-C.ID-C Rd:13 immhi:101101011010110000 P:0 10000:10000 immlo:10 op:1
	.inst 0xc2c4328f // LDPBLR-C.C-C Ct:15 Cn:20 100:100 opc:01 11000010110001000:11000010110001000
	.zero 136
	.inst 0x62d47c36 // LDP-C.RIBW-C Ct:22 Rn:1 Ct2:11111 imm7:0101000 L:1 011000101:011000101
	.inst 0xbc1764ff // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:31 Rn:7 01:01 imm9:101110110 0:0 opc:00 111100:111100 size:10
	.inst 0xe2f2a606 // ALDUR-V.RI-D Rt:6 Rn:16 op2:01 imm9:100101010 V:1 op1:11 11100010:11100010
	.inst 0x885ffffa // ldaxr:aarch64/instrs/memory/exclusive/single Rt:26 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:10
	.inst 0xc2c093f0 // GCTAG-R.C-C Rd:16 Cn:31 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0xcacee0bd // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:29 Rn:5 imm6:111000 Rm:14 N:0 shift:11 01010:01010 opc:10 sf:1
	.inst 0xc2c21040
	.zero 1048396
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
	ldr x10, =initial_cap_values
	.inst 0xc2400141 // ldr c1, [x10, #0]
	.inst 0xc2400546 // ldr c6, [x10, #1]
	.inst 0xc2400947 // ldr c7, [x10, #2]
	.inst 0xc2400d4b // ldr c11, [x10, #3]
	.inst 0xc2401150 // ldr c16, [x10, #4]
	.inst 0xc2401554 // ldr c20, [x10, #5]
	.inst 0xc2401958 // ldr c24, [x10, #6]
	/* Vector registers */
	mrs x10, cptr_el3
	bfc x10, #10, #1
	msr cptr_el3, x10
	isb
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =initial_SP_EL3_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2c1d15f // cpy c31, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x3085103f
	msr SCTLR_EL3, x10
	ldr x10, =0xc
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x2, =pcc_return_ddc_capabilities
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0x8260304a // ldr c10, [c2, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x8260104a // ldr c10, [c2, #1]
	.inst 0x82602042 // ldr c2, [c2, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400142 // ldr c2, [x10, #0]
	.inst 0xc2c2a421 // chkeq c1, c2
	b.ne comparison_fail
	.inst 0xc2400542 // ldr c2, [x10, #1]
	.inst 0xc2c2a4c1 // chkeq c6, c2
	b.ne comparison_fail
	.inst 0xc2400942 // ldr c2, [x10, #2]
	.inst 0xc2c2a4e1 // chkeq c7, c2
	b.ne comparison_fail
	.inst 0xc2400d42 // ldr c2, [x10, #3]
	.inst 0xc2c2a561 // chkeq c11, c2
	b.ne comparison_fail
	.inst 0xc2401142 // ldr c2, [x10, #4]
	.inst 0xc2c2a5a1 // chkeq c13, c2
	b.ne comparison_fail
	.inst 0xc2401542 // ldr c2, [x10, #5]
	.inst 0xc2c2a5e1 // chkeq c15, c2
	b.ne comparison_fail
	.inst 0xc2401942 // ldr c2, [x10, #6]
	.inst 0xc2c2a601 // chkeq c16, c2
	b.ne comparison_fail
	.inst 0xc2401d42 // ldr c2, [x10, #7]
	.inst 0xc2c2a681 // chkeq c20, c2
	b.ne comparison_fail
	.inst 0xc2402142 // ldr c2, [x10, #8]
	.inst 0xc2c2a6c1 // chkeq c22, c2
	b.ne comparison_fail
	.inst 0xc2402542 // ldr c2, [x10, #9]
	.inst 0xc2c2a701 // chkeq c24, c2
	b.ne comparison_fail
	.inst 0xc2402942 // ldr c2, [x10, #10]
	.inst 0xc2c2a721 // chkeq c25, c2
	b.ne comparison_fail
	.inst 0xc2402d42 // ldr c2, [x10, #11]
	.inst 0xc2c2a741 // chkeq c26, c2
	b.ne comparison_fail
	.inst 0xc2403142 // ldr c2, [x10, #12]
	.inst 0xc2c2a7c1 // chkeq c30, c2
	b.ne comparison_fail
	/* Check vector registers */
	ldr x10, =0x0
	mov x2, v6.d[0]
	cmp x10, x2
	b.ne comparison_fail
	ldr x10, =0x0
	mov x2, v6.d[1]
	cmp x10, x2
	b.ne comparison_fail
	ldr x10, =0x0
	mov x2, v31.d[0]
	cmp x10, x2
	b.ne comparison_fail
	ldr x10, =0x0
	mov x2, v31.d[1]
	cmp x10, x2
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001024
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000012d0
	ldr x1, =check_data2
	ldr x2, =0x000012f0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001730
	ldr x1, =check_data3
	ldr x2, =0x00001738
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001800
	ldr x1, =check_data4
	ldr x2, =0x00001820
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400010
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400098
	ldr x1, =check_data6
	ldr x2, =0x004000b4
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
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

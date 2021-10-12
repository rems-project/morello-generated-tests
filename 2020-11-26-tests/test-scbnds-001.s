.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 32
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x16, 0x30, 0x66, 0xad, 0xfd, 0xdc, 0x9d, 0xb9, 0x5f, 0xf1, 0xc5, 0xc2, 0x40, 0xaf, 0xc7, 0x69
	.byte 0xe3, 0xf7, 0xe6, 0xe2, 0x20, 0x00, 0xc2, 0xc2, 0x22, 0x7c, 0x9f, 0x88, 0x15, 0x74, 0x1f, 0x4b
	.byte 0xdf, 0x53, 0x83, 0x5a, 0x25, 0xa1, 0xdd, 0xc2, 0xc0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2000
	/* C1 */
	.octa 0x800000020000000000001bf8
	/* C2 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x3fff800000000000000000000000
	/* C10 */
	.octa 0x0
	/* C26 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0xdbf81bf80000000000001bf8
	/* C1 */
	.octa 0x800000020000000000001bf8
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x3fff800000000000000000000000
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x3fff800000000000000000000000
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C21 */
	.octa 0x1bf8
	/* C26 */
	.octa 0x103c
	/* C29 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x80000000407c00980000000000000f91
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005e040bfc00ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xad663016 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:22 Rn:0 Rt2:01100 imm7:1001100 L:1 1011010:1011010 opc:10
	.inst 0xb99ddcfd // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:29 Rn:7 imm12:011101110111 opc:10 111001:111001 size:10
	.inst 0xc2c5f15f // CVTPZ-C.R-C Cd:31 Rn:10 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0x69c7af40 // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:0 Rn:26 Rt2:01011 imm7:0001111 L:1 1010011:1010011 opc:01
	.inst 0xe2e6f7e3 // ALDUR-V.RI-D Rt:3 Rn:31 op2:01 imm9:001101111 V:1 op1:11 11100010:11100010
	.inst 0xc2c20020 // 0xc2c20020
	.inst 0x889f7c22 // stllr:aarch64/instrs/memory/ordered Rt:2 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0x4b1f7415 // sub_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:21 Rn:0 imm6:011101 Rm:31 0:0 shift:00 01011:01011 S:0 op:1 sf:0
	.inst 0x5a8353df // csinv:aarch64/instrs/integer/conditional/select Rd:31 Rn:30 o2:0 0:0 cond:0101 Rm:3 011010100:011010100 op:1 sf:0
	.inst 0xc2dda125 // CLRPERM-C.CR-C Cd:5 Cn:9 000:000 1:1 10:10 Rm:29 11000010110:11000010110
	.inst 0xc2c211c0
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
	.inst 0xc24009a2 // ldr c2, [x13, #2]
	.inst 0xc2400da7 // ldr c7, [x13, #3]
	.inst 0xc24011a9 // ldr c9, [x13, #4]
	.inst 0xc24015aa // ldr c10, [x13, #5]
	.inst 0xc24019ba // ldr c26, [x13, #6]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =initial_SP_EL3_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2c1d1bf // cpy c31, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30851037
	msr SCTLR_EL3, x13
	ldr x13, =0x0
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031cd // ldr c13, [c14, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x826011cd // ldr c13, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x14, #0x8
	and x13, x13, x14
	cmp x13, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001ae // ldr c14, [x13, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc24005ae // ldr c14, [x13, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc24009ae // ldr c14, [x13, #2]
	.inst 0xc2cea441 // chkeq c2, c14
	b.ne comparison_fail
	.inst 0xc2400dae // ldr c14, [x13, #3]
	.inst 0xc2cea4a1 // chkeq c5, c14
	b.ne comparison_fail
	.inst 0xc24011ae // ldr c14, [x13, #4]
	.inst 0xc2cea4e1 // chkeq c7, c14
	b.ne comparison_fail
	.inst 0xc24015ae // ldr c14, [x13, #5]
	.inst 0xc2cea521 // chkeq c9, c14
	b.ne comparison_fail
	.inst 0xc24019ae // ldr c14, [x13, #6]
	.inst 0xc2cea541 // chkeq c10, c14
	b.ne comparison_fail
	.inst 0xc2401dae // ldr c14, [x13, #7]
	.inst 0xc2cea561 // chkeq c11, c14
	b.ne comparison_fail
	.inst 0xc24021ae // ldr c14, [x13, #8]
	.inst 0xc2cea6a1 // chkeq c21, c14
	b.ne comparison_fail
	.inst 0xc24025ae // ldr c14, [x13, #9]
	.inst 0xc2cea741 // chkeq c26, c14
	b.ne comparison_fail
	.inst 0xc24029ae // ldr c14, [x13, #10]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0x0
	mov x14, v3.d[0]
	cmp x13, x14
	b.ne comparison_fail
	ldr x13, =0x0
	mov x14, v3.d[1]
	cmp x13, x14
	b.ne comparison_fail
	ldr x13, =0x0
	mov x14, v12.d[0]
	cmp x13, x14
	b.ne comparison_fail
	ldr x13, =0x0
	mov x14, v12.d[1]
	cmp x13, x14
	b.ne comparison_fail
	ldr x13, =0x0
	mov x14, v22.d[0]
	cmp x13, x14
	b.ne comparison_fail
	ldr x13, =0x0
	mov x14, v22.d[1]
	cmp x13, x14
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
	ldr x0, =0x0000103c
	ldr x1, =check_data1
	ldr x2, =0x00001044
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001bf8
	ldr x1, =check_data2
	ldr x2, =0x00001bfc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001cc0
	ldr x1, =check_data3
	ldr x2, =0x00001ce0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ddc
	ldr x1, =check_data4
	ldr x2, =0x00001de0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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

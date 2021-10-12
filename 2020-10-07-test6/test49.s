.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x1a
.data
check_data1:
	.byte 0x43, 0x30, 0xc2, 0xc2, 0x61, 0x91, 0xe8, 0x6d, 0x00, 0xc1, 0xb2, 0x82, 0xb2, 0x27, 0x9e, 0x1a
	.byte 0xe0, 0xb4, 0x56, 0xb8, 0xa0, 0x00, 0x3f, 0xd6
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xe7, 0x0b, 0xc0, 0xda, 0x00, 0x13, 0xc2, 0xc2
.data
check_data4:
	.byte 0xe0, 0x20, 0x59, 0xfa, 0x41, 0xab, 0x55, 0x38, 0xc0, 0x53, 0xc2, 0xc2
.data
check_data5:
	.zero 16
.data
check_data6:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1a000000
	/* C2 */
	.octa 0x200000008000a008000000000044000c
	/* C5 */
	.octa 0x404000
	/* C7 */
	.octa 0x800000000001000500000000004ffff8
	/* C8 */
	.octa 0x1012
	/* C11 */
	.octa 0x80000000000720010000000000480180
	/* C18 */
	.octa 0xffffffee
	/* C26 */
	.octa 0x4000c0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x200000008000a008000000000044000c
	/* C5 */
	.octa 0x404000
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x1012
	/* C11 */
	.octa 0x80000000000720010000000000480008
	/* C18 */
	.octa 0x400006
	/* C26 */
	.octa 0x4000c0
	/* C30 */
	.octa 0x200080009001c0050000000000400019
initial_RDDC_EL0_value:
	.octa 0x80000000000100050000000000000001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001001c0050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword final_cap_values + 144
	.dword initial_RDDC_EL0_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c23043 // BLRR-C-C 00011:00011 Cn:2 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x6de89161 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:1 Rn:11 Rt2:00100 imm7:1010001 L:1 1011011:1011011 opc:01
	.inst 0x82b2c100 // ASTR-R.RRB-32 Rt:0 Rn:8 opc:00 S:0 option:110 Rm:18 1:1 L:0 100000101:100000101
	.inst 0x1a9e27b2 // csinc:aarch64/instrs/integer/conditional/select Rd:18 Rn:29 o2:1 0:0 cond:0010 Rm:30 011010100:011010100 op:0 sf:0
	.inst 0xb856b4e0 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:7 01:01 imm9:101101011 0:0 opc:01 111000:111000 size:10
	.inst 0xd63f00a0 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:5 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 16360
	.inst 0xdac00be7 // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:7 Rn:31 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2c21300
	.zero 245764
	.inst 0xfa5920e0 // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0000 0:0 Rn:7 00:00 cond:0010 Rm:25 111010010:111010010 op:1 sf:1
	.inst 0x3855ab41 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:26 10:10 imm9:101011010 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c253c0 // RET-C-C 00000:00000 Cn:30 100:100 opc:10 11000010110000100:11000010110000100
	.zero 786408
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x15, cptr_el3
	orr x15, x15, #0x200
	msr cptr_el3, x15
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e2 // ldr c2, [x15, #1]
	.inst 0xc24009e5 // ldr c5, [x15, #2]
	.inst 0xc2400de7 // ldr c7, [x15, #3]
	.inst 0xc24011e8 // ldr c8, [x15, #4]
	.inst 0xc24015eb // ldr c11, [x15, #5]
	.inst 0xc24019f2 // ldr c18, [x15, #6]
	.inst 0xc2401dfa // ldr c26, [x15, #7]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30850032
	msr SCTLR_EL3, x15
	ldr x15, =0x88
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	ldr x15, =initial_RDDC_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc28b432f // msr RDDC_EL0, c15
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x8260330f // ldr c15, [c24, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260130f // ldr c15, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x24, #0xf
	and x15, x15, x24
	cmp x15, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001f8 // ldr c24, [x15, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc24005f8 // ldr c24, [x15, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc24009f8 // ldr c24, [x15, #2]
	.inst 0xc2d8a441 // chkeq c2, c24
	b.ne comparison_fail
	.inst 0xc2400df8 // ldr c24, [x15, #3]
	.inst 0xc2d8a4a1 // chkeq c5, c24
	b.ne comparison_fail
	.inst 0xc24011f8 // ldr c24, [x15, #4]
	.inst 0xc2d8a4e1 // chkeq c7, c24
	b.ne comparison_fail
	.inst 0xc24015f8 // ldr c24, [x15, #5]
	.inst 0xc2d8a501 // chkeq c8, c24
	b.ne comparison_fail
	.inst 0xc24019f8 // ldr c24, [x15, #6]
	.inst 0xc2d8a561 // chkeq c11, c24
	b.ne comparison_fail
	.inst 0xc2401df8 // ldr c24, [x15, #7]
	.inst 0xc2d8a641 // chkeq c18, c24
	b.ne comparison_fail
	.inst 0xc24021f8 // ldr c24, [x15, #8]
	.inst 0xc2d8a741 // chkeq c26, c24
	b.ne comparison_fail
	.inst 0xc24025f8 // ldr c24, [x15, #9]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check vector registers */
	ldr x15, =0x0
	mov x24, v1.d[0]
	cmp x15, x24
	b.ne comparison_fail
	ldr x15, =0x0
	mov x24, v1.d[1]
	cmp x15, x24
	b.ne comparison_fail
	ldr x15, =0x0
	mov x24, v4.d[0]
	cmp x15, x24
	b.ne comparison_fail
	ldr x15, =0x0
	mov x24, v4.d[1]
	cmp x15, x24
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
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x00400018
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0040001a
	ldr x1, =check_data2
	ldr x2, =0x0040001b
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00404000
	ldr x1, =check_data3
	ldr x2, =0x00404008
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0044000c
	ldr x1, =check_data4
	ldr x2, =0x00440018
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00480008
	ldr x1, =check_data5
	ldr x2, =0x00480018
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004ffff8
	ldr x1, =check_data6
	ldr x2, =0x004ffffc
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
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

	.balign 128
vector_table:
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

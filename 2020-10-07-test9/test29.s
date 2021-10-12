.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x52, 0x48, 0x81, 0xf9, 0x5f, 0x24, 0xce, 0x9a, 0x41, 0x30, 0xc2, 0xc2, 0x5e, 0x74, 0x47, 0xbc
	.byte 0xc4, 0x71, 0x3b, 0x54, 0x0b, 0xcc, 0xee, 0xc2, 0xe1, 0x18, 0x59, 0x82, 0xfb, 0x14, 0x16, 0x78
	.byte 0x1f, 0xbc, 0x5b, 0xb8, 0x01, 0x2a, 0xc1, 0x1a, 0x60, 0x10, 0xc2, 0xc2
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 4
.data
check_data5:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x901000004101c0000000000000480861
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x4c4088
	/* C7 */
	.octa 0x40000000000700070000000000001000
	/* C14 */
	.octa 0xffffb79f
	/* C27 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x48081c
	/* C2 */
	.octa 0x4c40ff
	/* C7 */
	.octa 0xf61
	/* C11 */
	.octa 0x0
	/* C14 */
	.octa 0xffffb79f
	/* C27 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200060080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000003000700ffe00000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf9814852 // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:18 Rn:2 imm12:000001010010 opc:10 111001:111001 size:11
	.inst 0x9ace245f // lsrv:aarch64/instrs/integer/shift/variable Rd:31 Rn:2 op2:01 0010:0010 Rm:14 0011010110:0011010110 sf:1
	.inst 0xc2c23041 // CHKTGD-C-C 00001:00001 Cn:2 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xbc47745e // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:30 Rn:2 01:01 imm9:001110111 0:0 opc:01 111100:111100 size:10
	.inst 0x543b71c4 // b_cond:aarch64/instrs/branch/conditional/cond cond:0100 0:0 imm19:0011101101110001110 01010100:01010100
	.inst 0xc2eecc0b // ALDR-C.RRB-C Ct:11 Rn:0 1:1 L:1 S:0 option:110 Rm:14 11000010111:11000010111
	.inst 0x825918e1 // ASTR-R.RI-32 Rt:1 Rn:7 op:10 imm9:110010001 L:0 1000001001:1000001001
	.inst 0x781614fb // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:27 Rn:7 01:01 imm9:101100001 0:0 opc:00 111000:111000 size:01
	.inst 0xb85bbc1f // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:0 11:11 imm9:110111011 0:0 opc:01 111000:111000 size:10
	.inst 0x1ac12a01 // asrv:aarch64/instrs/integer/shift/variable Rd:1 Rn:16 op2:10 0010:0010 Rm:1 0011010110:0011010110 sf:0
	.inst 0xc2c21060
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x13, cptr_el3
	orr x13, x13, #0x200
	msr cptr_el3, x13
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a1 // ldr c1, [x13, #1]
	.inst 0xc24009a2 // ldr c2, [x13, #2]
	.inst 0xc2400da7 // ldr c7, [x13, #3]
	.inst 0xc24011ae // ldr c14, [x13, #4]
	.inst 0xc24015bb // ldr c27, [x13, #5]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30850032
	msr SCTLR_EL3, x13
	ldr x13, =0x0
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x8260306d // ldr c13, [c3, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x8260106d // ldr c13, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x3, #0xf
	and x13, x13, x3
	cmp x13, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001a3 // ldr c3, [x13, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc24005a3 // ldr c3, [x13, #1]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc24009a3 // ldr c3, [x13, #2]
	.inst 0xc2c3a4e1 // chkeq c7, c3
	b.ne comparison_fail
	.inst 0xc2400da3 // ldr c3, [x13, #3]
	.inst 0xc2c3a561 // chkeq c11, c3
	b.ne comparison_fail
	.inst 0xc24011a3 // ldr c3, [x13, #4]
	.inst 0xc2c3a5c1 // chkeq c14, c3
	b.ne comparison_fail
	.inst 0xc24015a3 // ldr c3, [x13, #5]
	.inst 0xc2c3a761 // chkeq c27, c3
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0x0
	mov x3, v30.d[0]
	cmp x13, x3
	b.ne comparison_fail
	ldr x13, =0x0
	mov x3, v30.d[1]
	cmp x13, x3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001644
	ldr x1, =check_data1
	ldr x2, =0x00001648
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
	ldr x0, =0x0047c000
	ldr x1, =check_data3
	ldr x2, =0x0047c010
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0048081c
	ldr x1, =check_data4
	ldr x2, =0x00480820
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004c4088
	ldr x1, =check_data5
	ldr x2, =0x004c408c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
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

.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x0b, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 3
.data
check_data5:
	.byte 0xee, 0xd3, 0x4e, 0xfa, 0xc1, 0x33, 0x02, 0xb8, 0xa0, 0x94, 0x93, 0x38, 0x3d, 0xd0, 0xc0, 0xc2
	.byte 0x97, 0x21, 0xc2, 0xc2, 0x21, 0x98, 0x27, 0x39, 0x7f, 0x7d, 0xc1, 0x82, 0x27, 0x10, 0xc5, 0xc2
	.byte 0xff, 0x9b, 0x2c, 0x79, 0x5f, 0x7c, 0x3f, 0x42, 0xa0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xb00
	/* C2 */
	.octa 0x40000000000500070000000000001ffe
	/* C5 */
	.octa 0x1100
	/* C11 */
	.octa 0x800000000005000700000000000009fc
	/* C12 */
	.octa 0x2000700060000000000000000
	/* C30 */
	.octa 0xfdd
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xb00
	/* C2 */
	.octa 0x40000000000500070000000000001ffe
	/* C5 */
	.octa 0x1039
	/* C7 */
	.octa 0xb00
	/* C11 */
	.octa 0x800000000005000700000000000009fc
	/* C12 */
	.octa 0x2000700060000000000000000
	/* C23 */
	.octa 0x25ffe00000000000000000000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0xfdd
initial_SP_EL3_value:
	.octa 0x1b2
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000600270000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000002140050080000000000003
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xfa4ed3ee // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1110 0:0 Rn:31 00:00 cond:1101 Rm:14 111010010:111010010 op:1 sf:1
	.inst 0xb80233c1 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:30 00:00 imm9:000100011 0:0 opc:00 111000:111000 size:10
	.inst 0x389394a0 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:5 01:01 imm9:100111001 0:0 opc:10 111000:111000 size:00
	.inst 0xc2c0d03d // GCPERM-R.C-C Rd:29 Cn:1 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0xc2c22197 // SCBNDSE-C.CR-C Cd:23 Cn:12 000:000 opc:01 0:0 Rm:2 11000010110:11000010110
	.inst 0x39279821 // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:1 imm12:100111100110 opc:00 111001:111001 size:00
	.inst 0x82c17d7f // ALDRH-R.RRB-32 Rt:31 Rn:11 opc:11 S:1 option:011 Rm:1 0:0 L:1 100000101:100000101
	.inst 0xc2c51027 // CVTD-R.C-C Rd:7 Cn:1 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0x792c9bff // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:31 imm12:101100100110 opc:00 111001:111001 size:01
	.inst 0x423f7c5f // ASTLRB-R.R-B Rt:31 Rn:2 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xc2c212a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x17, cptr_el3
	orr x17, x17, #0x200
	msr cptr_el3, x17
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
	ldr x17, =initial_cap_values
	.inst 0xc2400221 // ldr c1, [x17, #0]
	.inst 0xc2400622 // ldr c2, [x17, #1]
	.inst 0xc2400a25 // ldr c5, [x17, #2]
	.inst 0xc2400e2b // ldr c11, [x17, #3]
	.inst 0xc240122c // ldr c12, [x17, #4]
	.inst 0xc240163e // ldr c30, [x17, #5]
	/* Set up flags and system registers */
	mov x17, #0x00000000
	msr nzcv, x17
	ldr x17, =initial_SP_EL3_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2c1d23f // cpy c31, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
	ldr x17, =0x4
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032b1 // ldr c17, [c21, #3]
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	.inst 0x826012b1 // ldr c17, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c21220 // br c17
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	/* Check processor flags */
	mrs x17, nzcv
	ubfx x17, x17, #28, #4
	mov x21, #0xf
	and x17, x17, x21
	cmp x17, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400235 // ldr c21, [x17, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400635 // ldr c21, [x17, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400a35 // ldr c21, [x17, #2]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400e35 // ldr c21, [x17, #3]
	.inst 0xc2d5a4a1 // chkeq c5, c21
	b.ne comparison_fail
	.inst 0xc2401235 // ldr c21, [x17, #4]
	.inst 0xc2d5a4e1 // chkeq c7, c21
	b.ne comparison_fail
	.inst 0xc2401635 // ldr c21, [x17, #5]
	.inst 0xc2d5a561 // chkeq c11, c21
	b.ne comparison_fail
	.inst 0xc2401a35 // ldr c21, [x17, #6]
	.inst 0xc2d5a581 // chkeq c12, c21
	b.ne comparison_fail
	.inst 0xc2401e35 // ldr c21, [x17, #7]
	.inst 0xc2d5a6e1 // chkeq c23, c21
	b.ne comparison_fail
	.inst 0xc2402235 // ldr c21, [x17, #8]
	.inst 0xc2d5a7a1 // chkeq c29, c21
	b.ne comparison_fail
	.inst 0xc2402635 // ldr c21, [x17, #9]
	.inst 0xc2d5a7c1 // chkeq c30, c21
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
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001101
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000014e6
	ldr x1, =check_data2
	ldr x2, =0x000014e7
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000017fe
	ldr x1, =check_data3
	ldr x2, =0x00001800
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ffc
	ldr x1, =check_data4
	ldr x2, =0x00001fff
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
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

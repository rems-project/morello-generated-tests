.section data0, #alloc, #write
	.byte 0xfe, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xfe, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x3e, 0x58, 0xd9, 0xc2, 0x01, 0xb0, 0x5c, 0xa2, 0xc7, 0xe3, 0x5e, 0x7a, 0xfe, 0x03, 0xbe, 0x9b
	.byte 0x43, 0xa0, 0xc9, 0xc2, 0xdf, 0x7b, 0xc1, 0xc2, 0xc0, 0x9f, 0x82, 0x78, 0x05, 0x93, 0xc5, 0xc2
	.byte 0x3f, 0x14, 0x09, 0x38, 0x1f, 0xaa, 0x19, 0xb8, 0xe0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1035
	/* C1 */
	.octa 0x10008120070000000000000800
	/* C2 */
	.octa 0x3fff800000000000000000000000
	/* C16 */
	.octa 0x1072
	/* C24 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x208f
	/* C2 */
	.octa 0x3fff800000000000000000000000
	/* C3 */
	.octa 0x3fff800000000000000000000000
	/* C5 */
	.octa 0xc0000000000080080000000000000000
	/* C16 */
	.octa 0x1072
	/* C24 */
	.octa 0x0
	/* C30 */
	.octa 0x105e
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000008780af0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000080080000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d9583e // ALIGNU-C.CI-C Cd:30 Cn:1 0110:0110 U:1 imm6:110010 11000010110:11000010110
	.inst 0xa25cb001 // LDUR-C.RI-C Ct:1 Rn:0 00:00 imm9:111001011 0:0 opc:01 10100010:10100010
	.inst 0x7a5ee3c7 // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0111 0:0 Rn:30 00:00 cond:1110 Rm:30 111010010:111010010 op:1 sf:0
	.inst 0x9bbe03fe // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:30 Rn:31 Ra:0 o0:0 Rm:30 01:01 U:1 10011011:10011011
	.inst 0xc2c9a043 // CLRPERM-C.CR-C Cd:3 Cn:2 000:000 1:1 10:10 Rm:9 11000010110:11000010110
	.inst 0xc2c17bdf // SCBNDS-C.CI-S Cd:31 Cn:30 1110:1110 S:1 imm6:000010 11000010110:11000010110
	.inst 0x78829fc0 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:30 11:11 imm9:000101001 0:0 opc:10 111000:111000 size:01
	.inst 0xc2c59305 // CVTD-C.R-C Cd:5 Rn:24 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0x3809143f // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:1 01:01 imm9:010010001 0:0 opc:00 111000:111000 size:00
	.inst 0xb819aa1f // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:16 10:10 imm9:110011010 0:0 opc:00 111000:111000 size:10
	.inst 0xc2c212e0
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
	.inst 0xc2400db0 // ldr c16, [x13, #3]
	.inst 0xc24011b8 // ldr c24, [x13, #4]
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
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032ed // ldr c13, [c23, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x826012ed // ldr c13, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
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
	mov x23, #0xf
	and x13, x13, x23
	cmp x13, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001b7 // ldr c23, [x13, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc24005b7 // ldr c23, [x13, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc24009b7 // ldr c23, [x13, #2]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400db7 // ldr c23, [x13, #3]
	.inst 0xc2d7a461 // chkeq c3, c23
	b.ne comparison_fail
	.inst 0xc24011b7 // ldr c23, [x13, #4]
	.inst 0xc2d7a4a1 // chkeq c5, c23
	b.ne comparison_fail
	.inst 0xc24015b7 // ldr c23, [x13, #5]
	.inst 0xc2d7a601 // chkeq c16, c23
	b.ne comparison_fail
	.inst 0xc24019b7 // ldr c23, [x13, #6]
	.inst 0xc2d7a701 // chkeq c24, c23
	b.ne comparison_fail
	.inst 0xc2401db7 // ldr c23, [x13, #7]
	.inst 0xc2d7a7c1 // chkeq c30, c23
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
	ldr x0, =0x0000105e
	ldr x1, =check_data1
	ldr x2, =0x00001060
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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

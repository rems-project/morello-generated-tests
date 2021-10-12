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
	.byte 0x08, 0x1c, 0x00, 0x00
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0x82, 0x48, 0xdf, 0xc2, 0x42, 0xfc, 0x3f, 0x42, 0x21, 0x84, 0xca, 0xc2, 0xe1, 0x13, 0x97, 0xf8
	.byte 0xd8, 0x6b, 0xd1, 0xc2, 0x23, 0x0f, 0x7d, 0x82, 0x0a, 0x54, 0x4c, 0xa2, 0xe7, 0x1d, 0x09, 0x38
	.byte 0x5f, 0x93, 0x13, 0xf8, 0x1f, 0x52, 0xc1, 0xc2, 0x60, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x901000000001000700000000000017e0
	/* C1 */
	.octa 0x70000000000000000
	/* C4 */
	.octa 0x1c08
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0xa0460000000000000000
	/* C15 */
	.octa 0x40000000000100070000000000001c00
	/* C25 */
	.octa 0x1000
	/* C26 */
	.octa 0x40000000008600170000000000001407
	/* C30 */
	.octa 0x3fff800000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x90100000000100070000000000002430
	/* C1 */
	.octa 0x70000000000000000
	/* C2 */
	.octa 0x1c08
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x1c08
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C15 */
	.octa 0x40000000000100070000000000001c91
	/* C25 */
	.octa 0x1000
	/* C26 */
	.octa 0x40000000008600170000000000001407
	/* C30 */
	.octa 0x3fff800000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004080c0840000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000014070005000000000000c001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2df4882 // UNSEAL-C.CC-C Cd:2 Cn:4 0010:0010 opc:01 Cm:31 11000010110:11000010110
	.inst 0x423ffc42 // ASTLR-R.R-32 Rt:2 Rn:2 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xc2ca8421 // CHKSS-_.CC-C 00001:00001 Cn:1 001:001 opc:00 1:1 Cm:10 11000010110:11000010110
	.inst 0xf89713e1 // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:31 00:00 imm9:101110001 0:0 opc:10 111000:111000 size:11
	.inst 0xc2d16bd8 // ORRFLGS-C.CR-C Cd:24 Cn:30 1010:1010 opc:01 Rm:17 11000010110:11000010110
	.inst 0x827d0f23 // ALDR-R.RI-64 Rt:3 Rn:25 op:11 imm9:111010000 L:1 1000001001:1000001001
	.inst 0xa24c540a // LDR-C.RIAW-C Ct:10 Rn:0 01:01 imm9:011000101 0:0 opc:01 10100010:10100010
	.inst 0x38091de7 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:7 Rn:15 11:11 imm9:010010001 0:0 opc:00 111000:111000 size:00
	.inst 0xf813935f // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:26 00:00 imm9:100111001 0:0 opc:00 111000:111000 size:11
	.inst 0xc2c1521f // CFHI-R.C-C Rd:31 Cn:16 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xc2c21260
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x27, cptr_el3
	orr x27, x27, #0x200
	msr cptr_el3, x27
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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400761 // ldr c1, [x27, #1]
	.inst 0xc2400b64 // ldr c4, [x27, #2]
	.inst 0xc2400f67 // ldr c7, [x27, #3]
	.inst 0xc240136a // ldr c10, [x27, #4]
	.inst 0xc240176f // ldr c15, [x27, #5]
	.inst 0xc2401b79 // ldr c25, [x27, #6]
	.inst 0xc2401f7a // ldr c26, [x27, #7]
	.inst 0xc240237e // ldr c30, [x27, #8]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
	ldr x27, =0x4
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x8260327b // ldr c27, [c19, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x8260127b // ldr c27, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	/* Check processor flags */
	mrs x27, nzcv
	ubfx x27, x27, #28, #4
	mov x19, #0xf
	and x27, x27, x19
	cmp x27, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400373 // ldr c19, [x27, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc2400773 // ldr c19, [x27, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400b73 // ldr c19, [x27, #2]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400f73 // ldr c19, [x27, #3]
	.inst 0xc2d3a461 // chkeq c3, c19
	b.ne comparison_fail
	.inst 0xc2401373 // ldr c19, [x27, #4]
	.inst 0xc2d3a481 // chkeq c4, c19
	b.ne comparison_fail
	.inst 0xc2401773 // ldr c19, [x27, #5]
	.inst 0xc2d3a4e1 // chkeq c7, c19
	b.ne comparison_fail
	.inst 0xc2401b73 // ldr c19, [x27, #6]
	.inst 0xc2d3a541 // chkeq c10, c19
	b.ne comparison_fail
	.inst 0xc2401f73 // ldr c19, [x27, #7]
	.inst 0xc2d3a5e1 // chkeq c15, c19
	b.ne comparison_fail
	.inst 0xc2402373 // ldr c19, [x27, #8]
	.inst 0xc2d3a721 // chkeq c25, c19
	b.ne comparison_fail
	.inst 0xc2402773 // ldr c19, [x27, #9]
	.inst 0xc2d3a741 // chkeq c26, c19
	b.ne comparison_fail
	.inst 0xc2402b73 // ldr c19, [x27, #10]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001340
	ldr x1, =check_data0
	ldr x2, =0x00001348
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000017e0
	ldr x1, =check_data1
	ldr x2, =0x000017f0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001c08
	ldr x1, =check_data2
	ldr x2, =0x00001c0c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001c91
	ldr x1, =check_data3
	ldr x2, =0x00001c92
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001e80
	ldr x1, =check_data4
	ldr x2, =0x00001e88
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
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
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

.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x10, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x1e, 0x04, 0x61, 0x82, 0x26, 0x80, 0x92, 0x38, 0x35, 0x01, 0x88, 0xd8, 0xa3, 0x33, 0xc2, 0xc2
	.byte 0x3f, 0x50, 0xc0, 0xc2, 0xc2, 0xe1, 0x88, 0xb8, 0x16, 0x2c, 0xd3, 0x38, 0xfd, 0x13, 0x18, 0xa8
	.byte 0x24, 0x20, 0x7a, 0x82, 0xfc, 0x13, 0xc1, 0xc2, 0x00, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
check_data6:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x13cd
	/* C1 */
	.octa 0x900000000001000500000000004fe5c0
	/* C4 */
	.octa 0x0
	/* C14 */
	.octa 0x110e
	/* C29 */
	.octa 0x20000000a001c0050000000000400010
final_cap_values:
	/* C0 */
	.octa 0x12ff
	/* C1 */
	.octa 0x900000000001000500000000004fe5c0
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C14 */
	.octa 0x110e
	/* C22 */
	.octa 0x0
	/* C28 */
	.octa 0xffffffffffffc000
	/* C29 */
	.octa 0x20000000a001c0050000000000400010
	/* C30 */
	.octa 0x20008000800700060000000000400011
initial_RDDC_EL0_value:
	.octa 0xc00000007fee00080000000000000001
initial_RSP_EL0_value:
	.octa 0x7600f0000000000000e80
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000004009100400ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword final_cap_values + 16
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword initial_RDDC_EL0_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x8261041e // ALDRB-R.RI-B Rt:30 Rn:0 op:01 imm9:000010000 L:1 1000001001:1000001001
	.inst 0x38928026 // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:6 Rn:1 00:00 imm9:100101000 0:0 opc:10 111000:111000 size:00
	.inst 0xd8880135 // prfm_lit:aarch64/instrs/memory/literal/general Rt:21 imm19:1000100000000001001 011000:011000 opc:11
	.inst 0xc2c233a3 // BLRR-C-C 00011:00011 Cn:29 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xc2c0503f // GCVALUE-R.C-C Rd:31 Cn:1 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0xb888e1c2 // ldursw:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:14 00:00 imm9:010001110 0:0 opc:10 111000:111000 size:10
	.inst 0x38d32c16 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:22 Rn:0 11:11 imm9:100110010 0:0 opc:11 111000:111000 size:00
	.inst 0xa81813fd // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:29 Rn:31 Rt2:00100 imm7:0110000 L:0 1010000:1010000 opc:10
	.inst 0x827a2024 // ALDR-C.RI-C Ct:4 Rn:1 op:00 imm9:110100010 L:1 1000001001:1000001001
	.inst 0xc2c113fc // GCLIM-R.C-C Rd:28 Cn:31 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0xc2c21200
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x11, cptr_el3
	orr x11, x11, #0x200
	msr cptr_el3, x11
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
	ldr x11, =initial_cap_values
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400561 // ldr c1, [x11, #1]
	.inst 0xc2400964 // ldr c4, [x11, #2]
	.inst 0xc2400d6e // ldr c14, [x11, #3]
	.inst 0xc240117d // ldr c29, [x11, #4]
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x3085003a
	msr SCTLR_EL3, x11
	ldr x11, =0x80
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	ldr x11, =initial_RDDC_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc28b432b // msr RDDC_EL0, c11
	ldr x11, =initial_RSP_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc28f416b // msr RSP_EL0, c11
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x8260320b // ldr c11, [c16, #3]
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	.inst 0x8260120b // ldr c11, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400170 // ldr c16, [x11, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc2400570 // ldr c16, [x11, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400970 // ldr c16, [x11, #2]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400d70 // ldr c16, [x11, #3]
	.inst 0xc2d0a481 // chkeq c4, c16
	b.ne comparison_fail
	.inst 0xc2401170 // ldr c16, [x11, #4]
	.inst 0xc2d0a4c1 // chkeq c6, c16
	b.ne comparison_fail
	.inst 0xc2401570 // ldr c16, [x11, #5]
	.inst 0xc2d0a5c1 // chkeq c14, c16
	b.ne comparison_fail
	.inst 0xc2401970 // ldr c16, [x11, #6]
	.inst 0xc2d0a6c1 // chkeq c22, c16
	b.ne comparison_fail
	.inst 0xc2401d70 // ldr c16, [x11, #7]
	.inst 0xc2d0a781 // chkeq c28, c16
	b.ne comparison_fail
	.inst 0xc2402170 // ldr c16, [x11, #8]
	.inst 0xc2d0a7a1 // chkeq c29, c16
	b.ne comparison_fail
	.inst 0xc2402570 // ldr c16, [x11, #9]
	.inst 0xc2d0a7c1 // chkeq c30, c16
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
	ldr x0, =0x0000119c
	ldr x1, =check_data1
	ldr x2, =0x000011a0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000012ff
	ldr x1, =check_data2
	ldr x2, =0x00001300
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000013dd
	ldr x1, =check_data3
	ldr x2, =0x000013de
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004fe4e8
	ldr x1, =check_data5
	ldr x2, =0x004fe4e9
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004fffe0
	ldr x1, =check_data6
	ldr x2, =0x004ffff0
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
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
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

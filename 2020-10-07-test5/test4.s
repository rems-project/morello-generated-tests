.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x09
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0xdf, 0x7d, 0x00, 0x28, 0x60, 0x62, 0x95, 0x82, 0x1e, 0x70, 0xf7, 0xe2, 0xfc, 0x63, 0xde, 0xc2
	.byte 0xe0, 0x8b, 0xbd, 0x02, 0x2a, 0xc0, 0x00, 0x7c, 0xa0, 0x52, 0xc1, 0xc2, 0x57, 0x10, 0xc5, 0xc2
	.byte 0x0f, 0x18, 0xfe, 0xc2, 0x20, 0x7c, 0xdf, 0x88, 0x80, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000005f8900010000000000002009
	/* C1 */
	.octa 0x1f40
	/* C2 */
	.octa 0x0
	/* C14 */
	.octa 0x1004
	/* C19 */
	.octa 0x40000000000500070000000000000000
	/* C21 */
	.octa 0x1140
	/* C30 */
	.octa 0x50000000000000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1f40
	/* C2 */
	.octa 0x0
	/* C14 */
	.octa 0x1004
	/* C15 */
	.octa 0x50000000000000
	/* C19 */
	.octa 0x40000000000500070000000000000000
	/* C21 */
	.octa 0x1140
	/* C23 */
	.octa 0x0
	/* C28 */
	.octa 0x120030050000000000000
	/* C30 */
	.octa 0x50000000000000
initial_SP_EL3_value:
	.octa 0x120030040000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000480000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000400100040000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x28007ddf // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:31 Rn:14 Rt2:11111 imm7:0000000 L:0 1010000:1010000 opc:00
	.inst 0x82956260 // ASTRB-R.RRB-B Rt:0 Rn:19 opc:00 S:0 option:011 Rm:21 0:0 L:0 100000101:100000101
	.inst 0xe2f7701e // ASTUR-V.RI-D Rt:30 Rn:0 op2:00 imm9:101110111 V:1 op1:11 11100010:11100010
	.inst 0xc2de63fc // SCOFF-C.CR-C Cd:28 Cn:31 000:000 opc:11 0:0 Rm:30 11000010110:11000010110
	.inst 0x02bd8be0 // SUB-C.CIS-C Cd:0 Cn:31 imm12:111101100010 sh:0 A:1 00000010:00000010
	.inst 0x7c00c02a // stur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:10 Rn:1 00:00 imm9:000001100 0:0 opc:00 111100:111100 size:01
	.inst 0xc2c152a0 // CFHI-R.C-C Rd:0 Cn:21 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xc2c51057 // CVTD-R.C-C Rd:23 Cn:2 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0xc2fe180f // CVT-C.CR-C Cd:15 Cn:0 0110:0110 0:0 0:0 Rm:30 11000010111:11000010111
	.inst 0x88df7c20 // ldlar:aarch64/instrs/memory/ordered Rt:0 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0xc2c21180
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
	.inst 0xc2400b62 // ldr c2, [x27, #2]
	.inst 0xc2400f6e // ldr c14, [x27, #3]
	.inst 0xc2401373 // ldr c19, [x27, #4]
	.inst 0xc2401775 // ldr c21, [x27, #5]
	.inst 0xc2401b7e // ldr c30, [x27, #6]
	/* Vector registers */
	mrs x27, cptr_el3
	bfc x27, #10, #1
	msr cptr_el3, x27
	isb
	ldr q10, =0x0
	ldr q30, =0x0
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =initial_SP_EL3_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2c1d37f // cpy c31, c27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
	ldr x27, =0x0
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x8260319b // ldr c27, [c12, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x8260119b // ldr c27, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
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
	mov x12, #0xf
	and x27, x27, x12
	cmp x27, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc240036c // ldr c12, [x27, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc240076c // ldr c12, [x27, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc2400b6c // ldr c12, [x27, #2]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc2400f6c // ldr c12, [x27, #3]
	.inst 0xc2cca5c1 // chkeq c14, c12
	b.ne comparison_fail
	.inst 0xc240136c // ldr c12, [x27, #4]
	.inst 0xc2cca5e1 // chkeq c15, c12
	b.ne comparison_fail
	.inst 0xc240176c // ldr c12, [x27, #5]
	.inst 0xc2cca661 // chkeq c19, c12
	b.ne comparison_fail
	.inst 0xc2401b6c // ldr c12, [x27, #6]
	.inst 0xc2cca6a1 // chkeq c21, c12
	b.ne comparison_fail
	.inst 0xc2401f6c // ldr c12, [x27, #7]
	.inst 0xc2cca6e1 // chkeq c23, c12
	b.ne comparison_fail
	.inst 0xc240236c // ldr c12, [x27, #8]
	.inst 0xc2cca781 // chkeq c28, c12
	b.ne comparison_fail
	.inst 0xc240276c // ldr c12, [x27, #9]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check vector registers */
	ldr x27, =0x0
	mov x12, v10.d[0]
	cmp x27, x12
	b.ne comparison_fail
	ldr x27, =0x0
	mov x12, v10.d[1]
	cmp x27, x12
	b.ne comparison_fail
	ldr x27, =0x0
	mov x12, v30.d[0]
	cmp x27, x12
	b.ne comparison_fail
	ldr x27, =0x0
	mov x12, v30.d[1]
	cmp x27, x12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001004
	ldr x1, =check_data0
	ldr x2, =0x0000100c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001140
	ldr x1, =check_data1
	ldr x2, =0x00001141
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f40
	ldr x1, =check_data2
	ldr x2, =0x00001f44
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f4c
	ldr x1, =check_data3
	ldr x2, =0x00001f4e
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f80
	ldr x1, =check_data4
	ldr x2, =0x00001f88
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

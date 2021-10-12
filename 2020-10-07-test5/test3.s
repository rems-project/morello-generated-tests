.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x22, 0x58, 0xc8, 0xc2, 0x09, 0x78, 0xd0, 0x38, 0x31, 0x10, 0x67, 0x6a, 0x3f, 0x44, 0xdf, 0xc2
	.byte 0x21, 0x04, 0xd9, 0xc2, 0xa2, 0xa0, 0x93, 0x38, 0x8a, 0x4d, 0x24, 0xb0, 0x02, 0x50, 0x51, 0x39
	.byte 0x7e, 0xd1, 0x19, 0x29, 0xc2, 0x03, 0x0f, 0xba, 0x00, 0x13, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1ba8
	/* C1 */
	.octa 0x31ef7007fffffffffe001
	/* C5 */
	.octa 0x4ff7c4
	/* C7 */
	.octa 0xe0000
	/* C11 */
	.octa 0x1ee8
	/* C20 */
	.octa 0x0
	/* C25 */
	.octa 0x51aeb00a01f0e00000000
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x1ba8
	/* C1 */
	.octa 0x31ef7007fffffffffe001
	/* C5 */
	.octa 0x4ff7c4
	/* C7 */
	.octa 0xe0000
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x48db1000
	/* C11 */
	.octa 0x1ee8
	/* C17 */
	.octa 0xffff0001
	/* C20 */
	.octa 0x0
	/* C25 */
	.octa 0x51aeb00a01f0e00000000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x2000000400200010000000000000001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 96
	.dword final_cap_values + 16
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c85822 // ALIGNU-C.CI-C Cd:2 Cn:1 0110:0110 U:1 imm6:010000 11000010110:11000010110
	.inst 0x38d07809 // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:9 Rn:0 10:10 imm9:100000111 0:0 opc:11 111000:111000 size:00
	.inst 0x6a671031 // bics:aarch64/instrs/integer/logical/shiftedreg Rd:17 Rn:1 imm6:000100 Rm:7 N:1 shift:01 01010:01010 opc:11 sf:0
	.inst 0xc2df443f // CSEAL-C.C-C Cd:31 Cn:1 001:001 opc:10 0:0 Cm:31 11000010110:11000010110
	.inst 0xc2d90421 // BUILD-C.C-C Cd:1 Cn:1 001:001 opc:00 0:0 Cm:25 11000010110:11000010110
	.inst 0x3893a0a2 // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:5 00:00 imm9:100111010 0:0 opc:10 111000:111000 size:00
	.inst 0xb0244d8a // ADRDP-C.ID-C Rd:10 immhi:010010001001101100 P:0 10000:10000 immlo:01 op:1
	.inst 0x39515002 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:0 imm12:010001010100 opc:01 111001:111001 size:00
	.inst 0x2919d17e // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:30 Rn:11 Rt2:10100 imm7:0110011 L:0 1010010:1010010 opc:00
	.inst 0xba0f03c2 // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:2 Rn:30 000000:000000 Rm:15 11010000:11010000 S:1 op:0 sf:1
	.inst 0xc2c21300
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
	.inst 0xc2400b65 // ldr c5, [x27, #2]
	.inst 0xc2400f67 // ldr c7, [x27, #3]
	.inst 0xc240136b // ldr c11, [x27, #4]
	.inst 0xc2401774 // ldr c20, [x27, #5]
	.inst 0xc2401b79 // ldr c25, [x27, #6]
	.inst 0xc2401f7e // ldr c30, [x27, #7]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =initial_SP_EL3_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2c1d37f // cpy c31, c27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30850032
	msr SCTLR_EL3, x27
	ldr x27, =0x0
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x8260331b // ldr c27, [c24, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x8260131b // ldr c27, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
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
	mov x24, #0x3
	and x27, x27, x24
	cmp x27, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400378 // ldr c24, [x27, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc2400778 // ldr c24, [x27, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400b78 // ldr c24, [x27, #2]
	.inst 0xc2d8a4a1 // chkeq c5, c24
	b.ne comparison_fail
	.inst 0xc2400f78 // ldr c24, [x27, #3]
	.inst 0xc2d8a4e1 // chkeq c7, c24
	b.ne comparison_fail
	.inst 0xc2401378 // ldr c24, [x27, #4]
	.inst 0xc2d8a521 // chkeq c9, c24
	b.ne comparison_fail
	.inst 0xc2401778 // ldr c24, [x27, #5]
	.inst 0xc2d8a541 // chkeq c10, c24
	b.ne comparison_fail
	.inst 0xc2401b78 // ldr c24, [x27, #6]
	.inst 0xc2d8a561 // chkeq c11, c24
	b.ne comparison_fail
	.inst 0xc2401f78 // ldr c24, [x27, #7]
	.inst 0xc2d8a621 // chkeq c17, c24
	b.ne comparison_fail
	.inst 0xc2402378 // ldr c24, [x27, #8]
	.inst 0xc2d8a681 // chkeq c20, c24
	b.ne comparison_fail
	.inst 0xc2402778 // ldr c24, [x27, #9]
	.inst 0xc2d8a721 // chkeq c25, c24
	b.ne comparison_fail
	.inst 0xc2402b78 // ldr c24, [x27, #10]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001aaf
	ldr x1, =check_data0
	ldr x2, =0x00001ab0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001fb4
	ldr x1, =check_data1
	ldr x2, =0x00001fbc
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffc
	ldr x1, =check_data2
	ldr x2, =0x00001ffd
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
	ldr x0, =0x004ff6fe
	ldr x1, =check_data4
	ldr x2, =0x004ff6ff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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

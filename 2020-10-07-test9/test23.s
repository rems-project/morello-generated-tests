.section data0, #alloc, #write
	.zero 16
	.byte 0x00, 0xa0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.byte 0x00, 0xa0, 0x00, 0x00
.data
check_data1:
	.byte 0x00, 0x04, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20
.data
check_data3:
	.byte 0xf5, 0x83, 0xde, 0xc2, 0xfe, 0xf3, 0xc6, 0xc2, 0xbe, 0x96, 0x59, 0xb8, 0x2a, 0x14, 0x13, 0xf8
	.byte 0x22, 0x60, 0x9a, 0xda, 0xdf, 0xa2, 0xc1, 0xc2, 0x1e, 0xd8, 0x44, 0xb8, 0x7e, 0x1b, 0xfe, 0xc2
	.byte 0x32, 0x7c, 0x00, 0xb8, 0x22, 0x45, 0x82, 0xda, 0xa0, 0x10, 0xc2, 0xc2
.data
check_data4:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xfc3
	/* C1 */
	.octa 0x1800
	/* C10 */
	.octa 0x2000000000000000
	/* C18 */
	.octa 0x400
	/* C22 */
	.octa 0x3fff800000000000000000000000
	/* C27 */
	.octa 0x787ff0080000000008001
	/* C30 */
	.octa 0x1
final_cap_values:
	/* C0 */
	.octa 0xfc3
	/* C1 */
	.octa 0x1738
	/* C10 */
	.octa 0x2000000000000000
	/* C18 */
	.octa 0x400
	/* C21 */
	.octa 0x4050a1
	/* C22 */
	.octa 0x3fff800000000000000000000000
	/* C27 */
	.octa 0x787ff0080000000008001
	/* C30 */
	.octa 0x787ff000000000000a000
initial_SP_EL3_value:
	.octa 0x800000000000000000405108
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20808000001100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000300070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2de83f5 // SCTAG-C.CR-C Cd:21 Cn:31 000:000 0:0 10:10 Rm:30 11000010110:11000010110
	.inst 0xc2c6f3fe // CLRPERM-C.CI-C Cd:30 Cn:31 100:100 perm:111 1100001011000110:1100001011000110
	.inst 0xb85996be // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:21 01:01 imm9:110011001 0:0 opc:01 111000:111000 size:10
	.inst 0xf813142a // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:10 Rn:1 01:01 imm9:100110001 0:0 opc:00 111000:111000 size:11
	.inst 0xda9a6022 // csinv:aarch64/instrs/integer/conditional/select Rd:2 Rn:1 o2:0 0:0 cond:0110 Rm:26 011010100:011010100 op:1 sf:1
	.inst 0xc2c1a2df // CLRPERM-C.CR-C Cd:31 Cn:22 000:000 1:1 10:10 Rm:1 11000010110:11000010110
	.inst 0xb844d81e // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:0 10:10 imm9:001001101 0:0 opc:01 111000:111000 size:10
	.inst 0xc2fe1b7e // CVT-C.CR-C Cd:30 Cn:27 0110:0110 0:0 0:0 Rm:30 11000010111:11000010111
	.inst 0xb8007c32 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:18 Rn:1 11:11 imm9:000000111 0:0 opc:00 111000:111000 size:10
	.inst 0xda824522 // csneg:aarch64/instrs/integer/conditional/select Rd:2 Rn:9 o2:1 0:0 cond:0100 Rm:2 011010100:011010100 op:1 sf:1
	.inst 0xc2c210a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x7, cptr_el3
	orr x7, x7, #0x200
	msr cptr_el3, x7
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004e1 // ldr c1, [x7, #1]
	.inst 0xc24008ea // ldr c10, [x7, #2]
	.inst 0xc2400cf2 // ldr c18, [x7, #3]
	.inst 0xc24010f6 // ldr c22, [x7, #4]
	.inst 0xc24014fb // ldr c27, [x7, #5]
	.inst 0xc24018fe // ldr c30, [x7, #6]
	/* Set up flags and system registers */
	mov x7, #0x90000000
	msr nzcv, x7
	ldr x7, =initial_SP_EL3_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2c1d0ff // cpy c31, c7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	ldr x7, =0x0
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030a7 // ldr c7, [c5, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x826010a7 // ldr c7, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	/* Check processor flags */
	mrs x7, nzcv
	ubfx x7, x7, #28, #4
	mov x5, #0x9
	and x7, x7, x5
	cmp x7, #0x9
	b.ne comparison_fail
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000e5 // ldr c5, [x7, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc24004e5 // ldr c5, [x7, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc24008e5 // ldr c5, [x7, #2]
	.inst 0xc2c5a541 // chkeq c10, c5
	b.ne comparison_fail
	.inst 0xc2400ce5 // ldr c5, [x7, #3]
	.inst 0xc2c5a641 // chkeq c18, c5
	b.ne comparison_fail
	.inst 0xc24010e5 // ldr c5, [x7, #4]
	.inst 0xc2c5a6a1 // chkeq c21, c5
	b.ne comparison_fail
	.inst 0xc24014e5 // ldr c5, [x7, #5]
	.inst 0xc2c5a6c1 // chkeq c22, c5
	b.ne comparison_fail
	.inst 0xc24018e5 // ldr c5, [x7, #6]
	.inst 0xc2c5a761 // chkeq c27, c5
	b.ne comparison_fail
	.inst 0xc2401ce5 // ldr c5, [x7, #7]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001014
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001738
	ldr x1, =check_data1
	ldr x2, =0x0000173c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001808
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
	ldr x0, =0x00405108
	ldr x1, =check_data4
	ldr x2, =0x0040510c
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
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
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

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
	.zero 8
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x54, 0xfc, 0xdf, 0xc8, 0x40, 0x51, 0x51, 0xa2, 0x40, 0x8c, 0x1c, 0xfc, 0xa0, 0x58, 0xaf, 0xb9
	.byte 0x3f, 0xf2, 0xba, 0x82, 0xfd, 0x8b, 0xc9, 0xc2, 0x73, 0xa8, 0xc1, 0xc2, 0xc0, 0x03, 0x3f, 0xd6
.data
check_data5:
	.byte 0x37, 0x41, 0xc2, 0x82, 0xc0, 0x2f, 0xde, 0x9a, 0xe0, 0x11, 0xc2, 0xc2
.data
check_data6:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0xc000000040000ffa0000000000001238
	/* C3 */
	.octa 0x3fff800000000000000000000000
	/* C5 */
	.octa 0x8000000000070007ffffffffffffe0b0
	/* C9 */
	.octa 0x30000000000000400
	/* C10 */
	.octa 0x801000000007a037000000000040c00b
	/* C17 */
	.octa 0xfffb302000800004
	/* C26 */
	.octa 0x133f7ffe00380
	/* C30 */
	.octa 0x400040
final_cap_values:
	/* C0 */
	.octa 0x20001080000000
	/* C2 */
	.octa 0xc000000040000ffa0000000000001200
	/* C3 */
	.octa 0x3fff800000000000000000000000
	/* C5 */
	.octa 0x8000000000070007ffffffffffffe0b0
	/* C9 */
	.octa 0x30000000000000400
	/* C10 */
	.octa 0x801000000007a037000000000040c00b
	/* C17 */
	.octa 0xfffb302000800004
	/* C20 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C26 */
	.octa 0x133f7ffe00380
	/* C29 */
	.octa 0x10000000000000000
	/* C30 */
	.octa 0x20008000820700070000000000400021
initial_SP_EL3_value:
	.octa 0x10000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000020700070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000417002300fffffffffee001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc8dffc54 // ldar:aarch64/instrs/memory/ordered Rt:20 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0xa2515140 // LDUR-C.RI-C Ct:0 Rn:10 00:00 imm9:100010101 0:0 opc:01 10100010:10100010
	.inst 0xfc1c8c40 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:0 Rn:2 11:11 imm9:111001000 0:0 opc:00 111100:111100 size:11
	.inst 0xb9af58a0 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:5 imm12:101111010110 opc:10 111001:111001 size:10
	.inst 0x82baf23f // ASTR-R.RRB-32 Rt:31 Rn:17 opc:00 S:1 option:111 Rm:26 1:1 L:0 100000101:100000101
	.inst 0xc2c98bfd // CHKSSU-C.CC-C Cd:29 Cn:31 0010:0010 opc:10 Cm:9 11000010110:11000010110
	.inst 0xc2c1a873 // EORFLGS-C.CR-C Cd:19 Cn:3 1010:1010 opc:10 Rm:1 11000010110:11000010110
	.inst 0xd63f03c0 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:30 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 32
	.inst 0x82c24137 // ALDRB-R.RRB-B Rt:23 Rn:9 opc:00 S:0 option:010 Rm:2 0:0 L:1 100000101:100000101
	.inst 0x9ade2fc0 // rorv:aarch64/instrs/integer/shift/variable Rd:0 Rn:30 op2:11 0010:0010 Rm:30 0011010110:0011010110 sf:1
	.inst 0xc2c211e0
	.zero 1048500
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
	.inst 0xc2400362 // ldr c2, [x27, #0]
	.inst 0xc2400763 // ldr c3, [x27, #1]
	.inst 0xc2400b65 // ldr c5, [x27, #2]
	.inst 0xc2400f69 // ldr c9, [x27, #3]
	.inst 0xc240136a // ldr c10, [x27, #4]
	.inst 0xc2401771 // ldr c17, [x27, #5]
	.inst 0xc2401b7a // ldr c26, [x27, #6]
	.inst 0xc2401f7e // ldr c30, [x27, #7]
	/* Vector registers */
	mrs x27, cptr_el3
	bfc x27, #10, #1
	msr cptr_el3, x27
	isb
	ldr q0, =0x0
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
	ldr x27, =0x84
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031fb // ldr c27, [c15, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x826011fb // ldr c27, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
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
	mov x15, #0xf
	and x27, x27, x15
	cmp x27, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc240036f // ldr c15, [x27, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240076f // ldr c15, [x27, #1]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc2400b6f // ldr c15, [x27, #2]
	.inst 0xc2cfa461 // chkeq c3, c15
	b.ne comparison_fail
	.inst 0xc2400f6f // ldr c15, [x27, #3]
	.inst 0xc2cfa4a1 // chkeq c5, c15
	b.ne comparison_fail
	.inst 0xc240136f // ldr c15, [x27, #4]
	.inst 0xc2cfa521 // chkeq c9, c15
	b.ne comparison_fail
	.inst 0xc240176f // ldr c15, [x27, #5]
	.inst 0xc2cfa541 // chkeq c10, c15
	b.ne comparison_fail
	.inst 0xc2401b6f // ldr c15, [x27, #6]
	.inst 0xc2cfa621 // chkeq c17, c15
	b.ne comparison_fail
	.inst 0xc2401f6f // ldr c15, [x27, #7]
	.inst 0xc2cfa681 // chkeq c20, c15
	b.ne comparison_fail
	.inst 0xc240236f // ldr c15, [x27, #8]
	.inst 0xc2cfa6e1 // chkeq c23, c15
	b.ne comparison_fail
	.inst 0xc240276f // ldr c15, [x27, #9]
	.inst 0xc2cfa741 // chkeq c26, c15
	b.ne comparison_fail
	.inst 0xc2402b6f // ldr c15, [x27, #10]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc2402f6f // ldr c15, [x27, #11]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check vector registers */
	ldr x27, =0x0
	mov x15, v0.d[0]
	cmp x27, x15
	b.ne comparison_fail
	ldr x27, =0x0
	mov x15, v0.d[1]
	cmp x27, x15
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
	ldr x0, =0x00001200
	ldr x1, =check_data1
	ldr x2, =0x00001208
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001238
	ldr x1, =check_data2
	ldr x2, =0x00001240
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001801
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400020
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400040
	ldr x1, =check_data5
	ldr x2, =0x0040004c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0040bf20
	ldr x1, =check_data6
	ldr x2, =0x0040bf30
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

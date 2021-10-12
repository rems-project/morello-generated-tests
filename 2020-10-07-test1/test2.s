.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x5c, 0x11, 0x00, 0x00
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x0e, 0x14, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x5c, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 8
.data
check_data6:
	.zero 1
.data
check_data7:
	.byte 0x49, 0xd2, 0x21, 0x8b, 0x60, 0x7d, 0xdf, 0x08, 0x00, 0xd9, 0x93, 0x92, 0x82, 0xc1, 0xa5, 0x82
	.byte 0x5d, 0xb0, 0xc0, 0xc2, 0x3b, 0x27, 0x75, 0x69, 0x3e, 0xe0, 0xcb, 0x3c, 0x7e, 0x34, 0x05, 0xf8
	.byte 0x21, 0x12, 0x3f, 0xe2, 0x41, 0x88, 0x08, 0xa8, 0xe0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x140e
	/* C2 */
	.octa 0x115c
	/* C3 */
	.octa 0x1004
	/* C5 */
	.octa 0xff8
	/* C11 */
	.octa 0x1bda
	/* C12 */
	.octa 0x40000000400000040000000000000008
	/* C17 */
	.octa 0x40000000000300070000000000002000
	/* C25 */
	.octa 0x2000
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xffffffffffff6137
	/* C1 */
	.octa 0x140e
	/* C2 */
	.octa 0x115c
	/* C3 */
	.octa 0x1057
	/* C5 */
	.octa 0xff8
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x1bda
	/* C12 */
	.octa 0x40000000400000040000000000000008
	/* C17 */
	.octa 0x40000000000300070000000000002000
	/* C25 */
	.octa 0x2000
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000006002000400ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x8b21d249 // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:9 Rn:18 imm3:100 option:110 Rm:1 01011001:01011001 S:0 op:0 sf:1
	.inst 0x08df7d60 // ldlarb:aarch64/instrs/memory/ordered Rt:0 Rn:11 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x9293d900 // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:0 imm16:1001111011001000 hw:00 100101:100101 opc:00 sf:1
	.inst 0x82a5c182 // ASTR-R.RRB-32 Rt:2 Rn:12 opc:00 S:0 option:110 Rm:5 1:1 L:0 100000101:100000101
	.inst 0xc2c0b05d // GCSEAL-R.C-C Rd:29 Cn:2 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0x6975273b // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:27 Rn:25 Rt2:01001 imm7:1101010 L:1 1010010:1010010 opc:01
	.inst 0x3ccbe03e // ldur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:30 Rn:1 00:00 imm9:010111110 0:0 opc:11 111100:111100 size:00
	.inst 0xf805347e // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:3 01:01 imm9:001010011 0:0 opc:00 111000:111000 size:11
	.inst 0xe23f1221 // ASTUR-V.RI-B Rt:1 Rn:17 op2:00 imm9:111110001 V:1 op1:00 11100010:11100010
	.inst 0xa8088841 // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:1 Rn:2 Rt2:00010 imm7:0010001 L:0 1010000:1010000 opc:10
	.inst 0xc2c211e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x22, cptr_el3
	orr x22, x22, #0x200
	msr cptr_el3, x22
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c1 // ldr c1, [x22, #0]
	.inst 0xc24006c2 // ldr c2, [x22, #1]
	.inst 0xc2400ac3 // ldr c3, [x22, #2]
	.inst 0xc2400ec5 // ldr c5, [x22, #3]
	.inst 0xc24012cb // ldr c11, [x22, #4]
	.inst 0xc24016cc // ldr c12, [x22, #5]
	.inst 0xc2401ad1 // ldr c17, [x22, #6]
	.inst 0xc2401ed9 // ldr c25, [x22, #7]
	.inst 0xc24022de // ldr c30, [x22, #8]
	/* Vector registers */
	mrs x22, cptr_el3
	bfc x22, #10, #1
	msr cptr_el3, x22
	isb
	ldr q1, =0x0
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
	ldr x22, =0x4
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031f6 // ldr c22, [c15, #3]
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	.inst 0x826011f6 // ldr c22, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002cf // ldr c15, [x22, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc24006cf // ldr c15, [x22, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc2400acf // ldr c15, [x22, #2]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc2400ecf // ldr c15, [x22, #3]
	.inst 0xc2cfa461 // chkeq c3, c15
	b.ne comparison_fail
	.inst 0xc24012cf // ldr c15, [x22, #4]
	.inst 0xc2cfa4a1 // chkeq c5, c15
	b.ne comparison_fail
	.inst 0xc24016cf // ldr c15, [x22, #5]
	.inst 0xc2cfa521 // chkeq c9, c15
	b.ne comparison_fail
	.inst 0xc2401acf // ldr c15, [x22, #6]
	.inst 0xc2cfa561 // chkeq c11, c15
	b.ne comparison_fail
	.inst 0xc2401ecf // ldr c15, [x22, #7]
	.inst 0xc2cfa581 // chkeq c12, c15
	b.ne comparison_fail
	.inst 0xc24022cf // ldr c15, [x22, #8]
	.inst 0xc2cfa621 // chkeq c17, c15
	b.ne comparison_fail
	.inst 0xc24026cf // ldr c15, [x22, #9]
	.inst 0xc2cfa721 // chkeq c25, c15
	b.ne comparison_fail
	.inst 0xc2402acf // ldr c15, [x22, #10]
	.inst 0xc2cfa761 // chkeq c27, c15
	b.ne comparison_fail
	.inst 0xc2402ecf // ldr c15, [x22, #11]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc24032cf // ldr c15, [x22, #12]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check vector registers */
	ldr x22, =0x0
	mov x15, v1.d[0]
	cmp x22, x15
	b.ne comparison_fail
	ldr x22, =0x0
	mov x15, v1.d[1]
	cmp x22, x15
	b.ne comparison_fail
	ldr x22, =0x0
	mov x15, v30.d[0]
	cmp x22, x15
	b.ne comparison_fail
	ldr x22, =0x0
	mov x15, v30.d[1]
	cmp x22, x15
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
	ldr x0, =0x00001008
	ldr x1, =check_data1
	ldr x2, =0x00001010
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011e8
	ldr x1, =check_data2
	ldr x2, =0x000011f8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000014d0
	ldr x1, =check_data3
	ldr x2, =0x000014e0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001bde
	ldr x1, =check_data4
	ldr x2, =0x00001bdf
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001fac
	ldr x1, =check_data5
	ldr x2, =0x00001fb4
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001ff1
	ldr x1, =check_data6
	ldr x2, =0x00001ff2
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400000
	ldr x1, =check_data7
	ldr x2, =0x0040002c
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
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

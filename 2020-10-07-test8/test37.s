.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xda, 0x10, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x82, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0xd0, 0x97, 0x4a, 0x78, 0x71, 0x7f, 0x50, 0x9b, 0xe2, 0x2b, 0x3f, 0x0b, 0x53, 0x69, 0x92, 0xb8
	.byte 0xc0, 0x7f, 0x1f, 0x42, 0xad, 0x52, 0xa2, 0x02, 0x82, 0x28, 0xba, 0x28, 0x38, 0x00, 0xc0, 0x5a
	.byte 0x9f, 0x27, 0x05, 0xb8, 0xb8, 0x21, 0xde, 0x1a, 0xc0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x820000000000000000
	/* C4 */
	.octa 0x40000000600000010000000000001004
	/* C10 */
	.octa 0x800000000007001700000000000010da
	/* C21 */
	.octa 0x14000c0000000004d58006200
	/* C28 */
	.octa 0x40000000401a090000000000000018e0
	/* C30 */
	.octa 0x80000000000100070000000000001220
final_cap_values:
	/* C0 */
	.octa 0x820000000000000000
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x40000000600000010000000000000fd4
	/* C10 */
	.octa 0x800000000007001700000000000010da
	/* C13 */
	.octa 0x14000c0000000004d5800596c
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x14000c0000000004d58006200
	/* C24 */
	.octa 0xb2d800
	/* C28 */
	.octa 0x40000000401a09000000000000001932
	/* C30 */
	.octa 0x800000000001000700000000000012c9
initial_SP_EL3_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000640070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000400002870000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x784a97d0 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:16 Rn:30 01:01 imm9:010101001 0:0 opc:01 111000:111000 size:01
	.inst 0x9b507f71 // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:17 Rn:27 Ra:11111 0:0 Rm:16 10:10 U:0 10011011:10011011
	.inst 0x0b3f2be2 // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:2 Rn:31 imm3:010 option:001 Rm:31 01011001:01011001 S:0 op:0 sf:0
	.inst 0xb8926953 // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:19 Rn:10 10:10 imm9:100100110 0:0 opc:10 111000:111000 size:10
	.inst 0x421f7fc0 // ASTLR-C.R-C Ct:0 Rn:30 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0x02a252ad // SUB-C.CIS-C Cd:13 Cn:21 imm12:100010010100 sh:0 A:1 00000010:00000010
	.inst 0x28ba2882 // stp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:2 Rn:4 Rt2:01010 imm7:1110100 L:0 1010001:1010001 opc:00
	.inst 0x5ac00038 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:24 Rn:1 101101011000000000000:101101011000000000000 sf:0
	.inst 0xb805279f // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:28 01:01 imm9:001010010 0:0 opc:00 111000:111000 size:10
	.inst 0x1ade21b8 // lslv:aarch64/instrs/integer/shift/variable Rd:24 Rn:13 op2:00 0010:0010 Rm:30 0011010110:0011010110 sf:0
	.inst 0xc2c211c0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x26, cptr_el3
	orr x26, x26, #0x200
	msr cptr_el3, x26
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
	ldr x26, =initial_cap_values
	.inst 0xc2400340 // ldr c0, [x26, #0]
	.inst 0xc2400744 // ldr c4, [x26, #1]
	.inst 0xc2400b4a // ldr c10, [x26, #2]
	.inst 0xc2400f55 // ldr c21, [x26, #3]
	.inst 0xc240135c // ldr c28, [x26, #4]
	.inst 0xc240175e // ldr c30, [x26, #5]
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =initial_SP_EL3_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2c1d35f // cpy c31, c26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
	ldr x26, =0x4
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031da // ldr c26, [c14, #3]
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	.inst 0x826011da // ldr c26, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc240034e // ldr c14, [x26, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc240074e // ldr c14, [x26, #1]
	.inst 0xc2cea441 // chkeq c2, c14
	b.ne comparison_fail
	.inst 0xc2400b4e // ldr c14, [x26, #2]
	.inst 0xc2cea481 // chkeq c4, c14
	b.ne comparison_fail
	.inst 0xc2400f4e // ldr c14, [x26, #3]
	.inst 0xc2cea541 // chkeq c10, c14
	b.ne comparison_fail
	.inst 0xc240134e // ldr c14, [x26, #4]
	.inst 0xc2cea5a1 // chkeq c13, c14
	b.ne comparison_fail
	.inst 0xc240174e // ldr c14, [x26, #5]
	.inst 0xc2cea601 // chkeq c16, c14
	b.ne comparison_fail
	.inst 0xc2401b4e // ldr c14, [x26, #6]
	.inst 0xc2cea621 // chkeq c17, c14
	b.ne comparison_fail
	.inst 0xc2401f4e // ldr c14, [x26, #7]
	.inst 0xc2cea661 // chkeq c19, c14
	b.ne comparison_fail
	.inst 0xc240234e // ldr c14, [x26, #8]
	.inst 0xc2cea6a1 // chkeq c21, c14
	b.ne comparison_fail
	.inst 0xc240274e // ldr c14, [x26, #9]
	.inst 0xc2cea701 // chkeq c24, c14
	b.ne comparison_fail
	.inst 0xc2402b4e // ldr c14, [x26, #10]
	.inst 0xc2cea781 // chkeq c28, c14
	b.ne comparison_fail
	.inst 0xc2402f4e // ldr c14, [x26, #11]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x0000100c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001220
	ldr x1, =check_data1
	ldr x2, =0x00001222
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001550
	ldr x1, =check_data2
	ldr x2, =0x00001560
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000018e0
	ldr x1, =check_data3
	ldr x2, =0x000018e4
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
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

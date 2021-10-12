.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x00, 0x00, 0x3f, 0xd6, 0x00
.data
check_data3:
	.byte 0x61, 0x09, 0xc0, 0xda, 0xee, 0x03, 0x1e, 0xf9, 0x60, 0x97, 0xd5, 0x29, 0x80, 0xfc, 0x1d, 0x78
	.byte 0xc1, 0xff, 0xdf, 0x08, 0x41, 0x10, 0xc2, 0xc2, 0xe1, 0x87, 0xc2, 0xc2, 0x5f, 0x12, 0xc0, 0xc2
	.byte 0xfe, 0xd8, 0xd1, 0xc2, 0xa0, 0x13, 0xc2, 0xc2
.data
check_data4:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x408810
	/* C2 */
	.octa 0x8006c00700ffffffffc00001
	/* C4 */
	.octa 0x1801
	/* C7 */
	.octa 0x8001200f0000000000000001
	/* C14 */
	.octa 0x200000
	/* C18 */
	.octa 0x70000000000000000
	/* C27 */
	.octa 0x499804
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x8006c00700ffffffffc00001
	/* C4 */
	.octa 0x17e0
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x8001200f0000000000000001
	/* C14 */
	.octa 0x200000
	/* C18 */
	.octa 0x70000000000000000
	/* C27 */
	.octa 0x4998b0
	/* C30 */
	.octa 0x8001200f0000000800000000
initial_SP_EL3_value:
	.octa 0x4001c002ffffffffffffd800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001ffb00070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000300040000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd63f0000 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:0 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 34828
	.inst 0xdac00961 // rev:aarch64/instrs/integer/arithmetic/rev Rd:1 Rn:11 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xf91e03ee // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:14 Rn:31 imm12:011110000000 opc:00 111001:111001 size:11
	.inst 0x29d59760 // ldp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:0 Rn:27 Rt2:00101 imm7:0101011 L:1 1010011:1010011 opc:00
	.inst 0x781dfc80 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:4 11:11 imm9:111011111 0:0 opc:00 111000:111000 size:01
	.inst 0x08dfffc1 // ldarb:aarch64/instrs/memory/ordered Rt:1 Rn:30 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xc2c21041 // CHKSLD-C-C 00001:00001 Cn:2 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xc2c287e1 // CHKSS-_.CC-C 00001:00001 Cn:31 001:001 opc:00 1:1 Cm:2 11000010110:11000010110
	.inst 0xc2c0125f // GCBASE-R.C-C Rd:31 Cn:18 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0xc2d1d8fe // ALIGNU-C.CI-C Cd:30 Cn:7 0110:0110 U:1 imm6:100011 11000010110:11000010110
	.inst 0xc2c213a0
	.zero 1013704
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x28, cptr_el3
	orr x28, x28, #0x200
	msr cptr_el3, x28
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
	ldr x28, =initial_cap_values
	.inst 0xc2400380 // ldr c0, [x28, #0]
	.inst 0xc2400782 // ldr c2, [x28, #1]
	.inst 0xc2400b84 // ldr c4, [x28, #2]
	.inst 0xc2400f87 // ldr c7, [x28, #3]
	.inst 0xc240138e // ldr c14, [x28, #4]
	.inst 0xc2401792 // ldr c18, [x28, #5]
	.inst 0xc2401b9b // ldr c27, [x28, #6]
	/* Set up flags and system registers */
	mov x28, #0x00000000
	msr nzcv, x28
	ldr x28, =initial_SP_EL3_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc2c1d39f // cpy c31, c28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30850032
	msr SCTLR_EL3, x28
	ldr x28, =0x4
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x29, =pcc_return_ddc_capabilities
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0x826033bc // ldr c28, [c29, #3]
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	.inst 0x826013bc // ldr c28, [c29, #1]
	.inst 0x826023bd // ldr c29, [c29, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	/* Check processor flags */
	mrs x28, nzcv
	ubfx x28, x28, #28, #4
	mov x29, #0xf
	and x28, x28, x29
	cmp x28, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc240039d // ldr c29, [x28, #0]
	.inst 0xc2dda401 // chkeq c0, c29
	b.ne comparison_fail
	.inst 0xc240079d // ldr c29, [x28, #1]
	.inst 0xc2dda421 // chkeq c1, c29
	b.ne comparison_fail
	.inst 0xc2400b9d // ldr c29, [x28, #2]
	.inst 0xc2dda441 // chkeq c2, c29
	b.ne comparison_fail
	.inst 0xc2400f9d // ldr c29, [x28, #3]
	.inst 0xc2dda481 // chkeq c4, c29
	b.ne comparison_fail
	.inst 0xc240139d // ldr c29, [x28, #4]
	.inst 0xc2dda4a1 // chkeq c5, c29
	b.ne comparison_fail
	.inst 0xc240179d // ldr c29, [x28, #5]
	.inst 0xc2dda4e1 // chkeq c7, c29
	b.ne comparison_fail
	.inst 0xc2401b9d // ldr c29, [x28, #6]
	.inst 0xc2dda5c1 // chkeq c14, c29
	b.ne comparison_fail
	.inst 0xc2401f9d // ldr c29, [x28, #7]
	.inst 0xc2dda641 // chkeq c18, c29
	b.ne comparison_fail
	.inst 0xc240239d // ldr c29, [x28, #8]
	.inst 0xc2dda761 // chkeq c27, c29
	b.ne comparison_fail
	.inst 0xc240279d // ldr c29, [x28, #9]
	.inst 0xc2dda7c1 // chkeq c30, c29
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001400
	ldr x1, =check_data0
	ldr x2, =0x00001408
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000017e0
	ldr x1, =check_data1
	ldr x2, =0x000017e2
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400005
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00408810
	ldr x1, =check_data3
	ldr x2, =0x00408838
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004998b0
	ldr x1, =check_data4
	ldr x2, =0x004998b8
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
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
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

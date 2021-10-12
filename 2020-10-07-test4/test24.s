.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x01, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0xdc, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0xc0, 0x08, 0x10, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0xbe, 0x4d, 0x45, 0x2b, 0xc1, 0xc7, 0x00, 0x11, 0x9e, 0xf4, 0x02, 0x82, 0xc8, 0x7f, 0x27, 0x02
	.byte 0xef, 0x16, 0x46, 0xa2, 0xde, 0xeb, 0xba, 0xf8, 0x22, 0xf1, 0xc5, 0xc2, 0xc1, 0x7e, 0x1f, 0x42
	.byte 0x1e, 0x94, 0x9a, 0x62, 0x01, 0x30, 0xc2, 0xc2, 0x60, 0x12, 0xc2, 0xc2
.data
check_data2:
	.byte 0x00, 0xdc, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0xc0, 0x08, 0x10, 0x00, 0x00
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xcc0
	/* C5 */
	.octa 0xff000000
	/* C9 */
	.octa 0x0
	/* C13 */
	.octa 0xdff0
	/* C22 */
	.octa 0x400000004004000c0000000000001000
	/* C23 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x1010
	/* C1 */
	.octa 0x10001
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0xff000000
	/* C8 */
	.octa 0x1008c0070000000000000000e5df
	/* C9 */
	.octa 0x0
	/* C13 */
	.octa 0xdff0
	/* C15 */
	.octa 0x0
	/* C22 */
	.octa 0x400000004004000c0000000000001000
	/* C23 */
	.octa 0x1610
	/* C30 */
	.octa 0x1008c0070000000000000000dc00
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xb0108000000080100000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000007000a00fffffffffc0000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 64
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x2b454dbe // adds_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:30 Rn:13 imm6:010011 Rm:5 0:0 shift:01 01011:01011 S:1 op:0 sf:0
	.inst 0x1100c7c1 // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:1 Rn:30 imm12:000000110001 sh:0 0:0 10001:10001 S:0 op:0 sf:0
	.inst 0x8202f49e // LDR-C.I-C Ct:30 imm17:00001011110100100 1000001000:1000001000
	.inst 0x02277fc8 // ADD-C.CIS-C Cd:8 Cn:30 imm12:100111011111 sh:0 A:0 00000010:00000010
	.inst 0xa24616ef // LDR-C.RIAW-C Ct:15 Rn:23 01:01 imm9:001100001 0:0 opc:01 10100010:10100010
	.inst 0xf8baebde // prfm_reg:aarch64/instrs/memory/single/general/register Rt:30 Rn:30 10:10 S:0 option:111 Rm:26 1:1 opc:10 111000:111000 size:11
	.inst 0xc2c5f122 // CVTPZ-C.R-C Cd:2 Rn:9 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0x421f7ec1 // ASTLR-C.R-C Ct:1 Rn:22 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0x629a941e // STP-C.RIBW-C Ct:30 Rn:0 Ct2:00101 imm7:0110101 L:0 011000101:011000101
	.inst 0xc2c23001 // CHKTGD-C-C 00001:00001 Cn:0 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xc2c21260
	.zero 96788
	.inst 0x0000dc00
	.zero 4
	.inst 0xc0070000
	.inst 0x00001008
	.zero 951728
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x12, cptr_el3
	orr x12, x12, #0x200
	msr cptr_el3, x12
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
	ldr x12, =initial_cap_values
	.inst 0xc2400180 // ldr c0, [x12, #0]
	.inst 0xc2400585 // ldr c5, [x12, #1]
	.inst 0xc2400989 // ldr c9, [x12, #2]
	.inst 0xc2400d8d // ldr c13, [x12, #3]
	.inst 0xc2401196 // ldr c22, [x12, #4]
	.inst 0xc2401597 // ldr c23, [x12, #5]
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	ldr x12, =0x0
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x8260326c // ldr c12, [c19, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x8260126c // ldr c12, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	/* Check processor flags */
	mrs x12, nzcv
	ubfx x12, x12, #28, #4
	mov x19, #0xf
	and x12, x12, x19
	cmp x12, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400193 // ldr c19, [x12, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc2400593 // ldr c19, [x12, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400993 // ldr c19, [x12, #2]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400d93 // ldr c19, [x12, #3]
	.inst 0xc2d3a4a1 // chkeq c5, c19
	b.ne comparison_fail
	.inst 0xc2401193 // ldr c19, [x12, #4]
	.inst 0xc2d3a501 // chkeq c8, c19
	b.ne comparison_fail
	.inst 0xc2401593 // ldr c19, [x12, #5]
	.inst 0xc2d3a521 // chkeq c9, c19
	b.ne comparison_fail
	.inst 0xc2401993 // ldr c19, [x12, #6]
	.inst 0xc2d3a5a1 // chkeq c13, c19
	b.ne comparison_fail
	.inst 0xc2401d93 // ldr c19, [x12, #7]
	.inst 0xc2d3a5e1 // chkeq c15, c19
	b.ne comparison_fail
	.inst 0xc2402193 // ldr c19, [x12, #8]
	.inst 0xc2d3a6c1 // chkeq c22, c19
	b.ne comparison_fail
	.inst 0xc2402593 // ldr c19, [x12, #9]
	.inst 0xc2d3a6e1 // chkeq c23, c19
	b.ne comparison_fail
	.inst 0xc2402993 // ldr c19, [x12, #10]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001030
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00417a40
	ldr x1, =check_data2
	ldr x2, =0x00417a50
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
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

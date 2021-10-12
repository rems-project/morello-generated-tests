.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0xc1, 0x07, 0xc0, 0x5a, 0xe0, 0x86, 0x73, 0xa9, 0x5f, 0x00, 0xc0, 0xda, 0xc1, 0x2a, 0xd0, 0x1a
	.byte 0x00, 0x0e, 0x8b, 0x38, 0x5e, 0x04, 0x02, 0x1b, 0xe0, 0x39, 0xae, 0x30, 0x02, 0x9c, 0x41, 0x38
	.byte 0xec, 0xbb, 0x5a, 0xba, 0x44, 0xc2, 0x00, 0x78, 0xa0, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C4 */
	.octa 0x0
	/* C16 */
	.octa 0x10ca
	/* C18 */
	.octa 0x1ff0
	/* C23 */
	.octa 0x10e0
final_cap_values:
	/* C0 */
	.octa 0x176e
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C16 */
	.octa 0x117a
	/* C18 */
	.octa 0x1ff0
	/* C23 */
	.octa 0x10e0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x2000800000061ade0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000600902040000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x5ac007c1 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:1 Rn:30 opc:01 1011010110000000000:1011010110000000000 sf:0
	.inst 0xa97386e0 // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:0 Rn:23 Rt2:00001 imm7:1100111 L:1 1010010:1010010 opc:10
	.inst 0xdac0005f // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:31 Rn:2 101101011000000000000:101101011000000000000 sf:1
	.inst 0x1ad02ac1 // asrv:aarch64/instrs/integer/shift/variable Rd:1 Rn:22 op2:10 0010:0010 Rm:16 0011010110:0011010110 sf:0
	.inst 0x388b0e00 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:16 11:11 imm9:010110000 0:0 opc:10 111000:111000 size:00
	.inst 0x1b02045e // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:30 Rn:2 Ra:1 o0:0 Rm:2 0011011000:0011011000 sf:0
	.inst 0x30ae39e0 // ADR-C.I-C Rd:0 immhi:010111000111001111 P:1 10000:10000 immlo:01 op:0
	.inst 0x38419c02 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:2 Rn:0 11:11 imm9:000011001 0:0 opc:01 111000:111000 size:00
	.inst 0xba5abbec // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1100 0:0 Rn:31 10:10 cond:1011 imm5:11010 111010010:111010010 op:0 sf:1
	.inst 0x7800c244 // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:4 Rn:18 00:00 imm9:000001100 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c213a0
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
	.inst 0xc2400164 // ldr c4, [x11, #0]
	.inst 0xc2400570 // ldr c16, [x11, #1]
	.inst 0xc2400972 // ldr c18, [x11, #2]
	.inst 0xc2400d77 // ldr c23, [x11, #3]
	/* Set up flags and system registers */
	mov x11, #0x80000000
	msr nzcv, x11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	ldr x11, =0x8
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x29, =pcc_return_ddc_capabilities
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0x826033ab // ldr c11, [c29, #3]
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	.inst 0x826013ab // ldr c11, [c29, #1]
	.inst 0x826023bd // ldr c29, [c29, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	/* Check processor flags */
	mrs x11, nzcv
	ubfx x11, x11, #28, #4
	mov x29, #0xf
	and x11, x11, x29
	cmp x11, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc240017d // ldr c29, [x11, #0]
	.inst 0xc2dda401 // chkeq c0, c29
	b.ne comparison_fail
	.inst 0xc240057d // ldr c29, [x11, #1]
	.inst 0xc2dda441 // chkeq c2, c29
	b.ne comparison_fail
	.inst 0xc240097d // ldr c29, [x11, #2]
	.inst 0xc2dda481 // chkeq c4, c29
	b.ne comparison_fail
	.inst 0xc2400d7d // ldr c29, [x11, #3]
	.inst 0xc2dda601 // chkeq c16, c29
	b.ne comparison_fail
	.inst 0xc240117d // ldr c29, [x11, #4]
	.inst 0xc2dda641 // chkeq c18, c29
	b.ne comparison_fail
	.inst 0xc240157d // ldr c29, [x11, #5]
	.inst 0xc2dda6e1 // chkeq c23, c29
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001018
	ldr x1, =check_data0
	ldr x2, =0x00001028
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000117a
	ldr x1, =check_data1
	ldr x2, =0x0000117b
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000176e
	ldr x1, =check_data2
	ldr x2, =0x0000176f
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffc
	ldr x1, =check_data3
	ldr x2, =0x00001ffe
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

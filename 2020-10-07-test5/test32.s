.section data0, #alloc, #write
	.zero 1280
	.byte 0x08, 0x14, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2800
.data
check_data0:
	.byte 0xa0
.data
check_data1:
	.byte 0x08, 0x14, 0x00, 0x00
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x14, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0xe2, 0xf7, 0x58, 0xb8, 0x4c, 0xa5, 0x1c, 0xe2, 0x47, 0x69, 0x79, 0x82, 0x54, 0xd4, 0x99, 0xa9
	.byte 0xd7, 0x33, 0xc7, 0xc2, 0xfe, 0xcf, 0x22, 0xb1, 0x62, 0x14, 0x52, 0x82, 0xa1, 0x7e, 0x9f, 0x88
	.byte 0x06, 0x08, 0xc0, 0x5a, 0x74, 0x26, 0xd0, 0x1a, 0x40, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
check_data6:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x4000000060000a440000000000001100
	/* C10 */
	.octa 0x800000004662c66c0000000000480000
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x1400
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x15a0
	/* C3 */
	.octa 0x4000000060000a440000000000001100
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0x800000004662c66c0000000000480000
	/* C12 */
	.octa 0x0
	/* C21 */
	.octa 0x1400
	/* C23 */
	.octa 0xffffffffffffffff
	/* C30 */
	.octa 0x1942
initial_SP_EL3_value:
	.octa 0x1100
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200100060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000004000040000ffffffffffff1f
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb858f7e2 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:2 Rn:31 01:01 imm9:110001111 0:0 opc:01 111000:111000 size:10
	.inst 0xe21ca54c // ALDURB-R.RI-32 Rt:12 Rn:10 op2:01 imm9:111001010 V:0 op1:00 11100010:11100010
	.inst 0x82796947 // ALDR-R.RI-32 Rt:7 Rn:10 op:10 imm9:110010110 L:1 1000001001:1000001001
	.inst 0xa999d454 // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:20 Rn:2 Rt2:10101 imm7:0110011 L:0 1010011:1010011 opc:10
	.inst 0xc2c733d7 // RRMASK-R.R-C Rd:23 Rn:30 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0xb122cffe // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:30 Rn:31 imm12:100010110011 sh:0 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0x82521462 // ASTRB-R.RI-B Rt:2 Rn:3 op:01 imm9:100100001 L:0 1000001001:1000001001
	.inst 0x889f7ea1 // stllr:aarch64/instrs/memory/ordered Rt:1 Rn:21 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0x5ac00806 // rev:aarch64/instrs/integer/arithmetic/rev Rd:6 Rn:0 opc:10 1011010110000000000:1011010110000000000 sf:0
	.inst 0x1ad02674 // lsrv:aarch64/instrs/integer/shift/variable Rd:20 Rn:19 op2:01 0010:0010 Rm:16 0011010110:0011010110 sf:0
	.inst 0xc2c21240
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x5, cptr_el3
	orr x5, x5, #0x200
	msr cptr_el3, x5
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a1 // ldr c1, [x5, #0]
	.inst 0xc24004a3 // ldr c3, [x5, #1]
	.inst 0xc24008aa // ldr c10, [x5, #2]
	.inst 0xc2400cb4 // ldr c20, [x5, #3]
	.inst 0xc24010b5 // ldr c21, [x5, #4]
	.inst 0xc24014be // ldr c30, [x5, #5]
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =initial_SP_EL3_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2c1d0bf // cpy c31, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	ldr x5, =0x4
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82603245 // ldr c5, [c18, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x82601245 // ldr c5, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	/* Check processor flags */
	mrs x5, nzcv
	ubfx x5, x5, #28, #4
	mov x18, #0xf
	and x5, x5, x18
	cmp x5, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000b2 // ldr c18, [x5, #0]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc24004b2 // ldr c18, [x5, #1]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc24008b2 // ldr c18, [x5, #2]
	.inst 0xc2d2a461 // chkeq c3, c18
	b.ne comparison_fail
	.inst 0xc2400cb2 // ldr c18, [x5, #3]
	.inst 0xc2d2a4e1 // chkeq c7, c18
	b.ne comparison_fail
	.inst 0xc24010b2 // ldr c18, [x5, #4]
	.inst 0xc2d2a541 // chkeq c10, c18
	b.ne comparison_fail
	.inst 0xc24014b2 // ldr c18, [x5, #5]
	.inst 0xc2d2a581 // chkeq c12, c18
	b.ne comparison_fail
	.inst 0xc24018b2 // ldr c18, [x5, #6]
	.inst 0xc2d2a6a1 // chkeq c21, c18
	b.ne comparison_fail
	.inst 0xc2401cb2 // ldr c18, [x5, #7]
	.inst 0xc2d2a6e1 // chkeq c23, c18
	b.ne comparison_fail
	.inst 0xc24020b2 // ldr c18, [x5, #8]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001221
	ldr x1, =check_data0
	ldr x2, =0x00001222
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001500
	ldr x1, =check_data1
	ldr x2, =0x00001504
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001804
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000019a0
	ldr x1, =check_data3
	ldr x2, =0x000019b0
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
	ldr x0, =0x0047ffca
	ldr x1, =check_data5
	ldr x2, =0x0047ffcb
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00480658
	ldr x1, =check_data6
	ldr x2, =0x0048065c
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
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
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

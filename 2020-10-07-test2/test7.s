.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 16
	.byte 0x00, 0x14, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x4c
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xe2, 0x8a, 0xc4, 0xc2, 0xaa, 0x1b, 0x02, 0x9b, 0x02, 0x34, 0x77, 0x82, 0x02, 0x00, 0x36, 0x62
	.byte 0x1c, 0x10, 0xc7, 0xc2, 0x1b, 0x20, 0xdd, 0xc2, 0xe1, 0xfd, 0x3f, 0x42, 0x02, 0x89, 0xde, 0xc2
	.byte 0xa2, 0x72, 0xc0, 0xc2, 0x23, 0x19, 0xf6, 0xc2, 0x40, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4c000000000000000000000000001400
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x100070040000000006000
	/* C8 */
	.octa 0x17081f000000024800e001
	/* C9 */
	.octa 0x6000f0000000000e00001
	/* C15 */
	.octa 0x1000
	/* C21 */
	.octa 0x200070000000000000000
	/* C22 */
	.octa 0xe04001
	/* C23 */
	.octa 0x320070000000000000001
	/* C30 */
	.octa 0x807080f000000024800e000
final_cap_values:
	/* C0 */
	.octa 0x4c000000000000000000000000001400
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x6000f0000000000e04001
	/* C4 */
	.octa 0x100070040000000006000
	/* C8 */
	.octa 0x17081f000000024800e001
	/* C9 */
	.octa 0x6000f0000000000e00001
	/* C15 */
	.octa 0x1000
	/* C21 */
	.octa 0x200070000000000000000
	/* C22 */
	.octa 0xe04001
	/* C23 */
	.octa 0x320070000000000000001
	/* C28 */
	.octa 0x1400
	/* C30 */
	.octa 0x807080f000000024800e000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000a0100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000003000600ffe00000006001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 128
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c48ae2 // CHKSSU-C.CC-C Cd:2 Cn:23 0010:0010 opc:10 Cm:4 11000010110:11000010110
	.inst 0x9b021baa // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:10 Rn:29 Ra:6 o0:0 Rm:2 0011011000:0011011000 sf:1
	.inst 0x82773402 // ALDRB-R.RI-B Rt:2 Rn:0 op:01 imm9:101110011 L:1 1000001001:1000001001
	.inst 0x62360002 // STNP-C.RIB-C Ct:2 Rn:0 Ct2:00000 imm7:1101100 L:0 011000100:011000100
	.inst 0xc2c7101c // RRLEN-R.R-C Rd:28 Rn:0 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0xc2dd201b // SCBNDSE-C.CR-C Cd:27 Cn:0 000:000 opc:01 0:0 Rm:29 11000010110:11000010110
	.inst 0x423ffde1 // ASTLR-R.R-32 Rt:1 Rn:15 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xc2de8902 // CHKSSU-C.CC-C Cd:2 Cn:8 0010:0010 opc:10 Cm:30 11000010110:11000010110
	.inst 0xc2c072a2 // GCOFF-R.C-C Rd:2 Cn:21 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0xc2f61923 // CVT-C.CR-C Cd:3 Cn:9 0110:0110 0:0 0:0 Rm:22 11000010111:11000010111
	.inst 0xc2c21240
	.zero 1048532
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
	.inst 0xc2400581 // ldr c1, [x12, #1]
	.inst 0xc2400984 // ldr c4, [x12, #2]
	.inst 0xc2400d88 // ldr c8, [x12, #3]
	.inst 0xc2401189 // ldr c9, [x12, #4]
	.inst 0xc240158f // ldr c15, [x12, #5]
	.inst 0xc2401995 // ldr c21, [x12, #6]
	.inst 0xc2401d96 // ldr c22, [x12, #7]
	.inst 0xc2402197 // ldr c23, [x12, #8]
	.inst 0xc240259e // ldr c30, [x12, #9]
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
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x8260324c // ldr c12, [c18, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x8260124c // ldr c12, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
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
	mov x18, #0xf
	and x12, x12, x18
	cmp x12, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400192 // ldr c18, [x12, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400592 // ldr c18, [x12, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400992 // ldr c18, [x12, #2]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400d92 // ldr c18, [x12, #3]
	.inst 0xc2d2a461 // chkeq c3, c18
	b.ne comparison_fail
	.inst 0xc2401192 // ldr c18, [x12, #4]
	.inst 0xc2d2a481 // chkeq c4, c18
	b.ne comparison_fail
	.inst 0xc2401592 // ldr c18, [x12, #5]
	.inst 0xc2d2a501 // chkeq c8, c18
	b.ne comparison_fail
	.inst 0xc2401992 // ldr c18, [x12, #6]
	.inst 0xc2d2a521 // chkeq c9, c18
	b.ne comparison_fail
	.inst 0xc2401d92 // ldr c18, [x12, #7]
	.inst 0xc2d2a5e1 // chkeq c15, c18
	b.ne comparison_fail
	.inst 0xc2402192 // ldr c18, [x12, #8]
	.inst 0xc2d2a6a1 // chkeq c21, c18
	b.ne comparison_fail
	.inst 0xc2402592 // ldr c18, [x12, #9]
	.inst 0xc2d2a6c1 // chkeq c22, c18
	b.ne comparison_fail
	.inst 0xc2402992 // ldr c18, [x12, #10]
	.inst 0xc2d2a6e1 // chkeq c23, c18
	b.ne comparison_fail
	.inst 0xc2402d92 // ldr c18, [x12, #11]
	.inst 0xc2d2a781 // chkeq c28, c18
	b.ne comparison_fail
	.inst 0xc2403192 // ldr c18, [x12, #12]
	.inst 0xc2d2a7c1 // chkeq c30, c18
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
	ldr x0, =0x000012c0
	ldr x1, =check_data1
	ldr x2, =0x000012e0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001573
	ldr x1, =check_data2
	ldr x2, =0x00001574
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

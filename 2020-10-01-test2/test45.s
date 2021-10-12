.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x40, 0xf3, 0xc5, 0xc2, 0x5f, 0x31, 0x03, 0xd5, 0x19, 0x7f, 0xda, 0x9b, 0xc1, 0xff, 0x3f, 0x42
	.byte 0x1e, 0x4c, 0xc7, 0x78, 0xc1, 0x7d, 0x9f, 0x08, 0x45, 0x90, 0xc0, 0xc2, 0x47, 0xd8, 0x78, 0x79
	.byte 0xe1, 0x8f, 0x7f, 0x69, 0xc1, 0xea, 0xc1, 0xc2, 0xa0, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 2
.data
check_data5:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x480000
	/* C14 */
	.octa 0x1ffe
	/* C26 */
	.octa 0x101008
	/* C30 */
	.octa 0x400000000003000700000000000017f8
final_cap_values:
	/* C0 */
	.octa 0x4c207c
	/* C2 */
	.octa 0x480000
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C14 */
	.octa 0x1ffe
	/* C26 */
	.octa 0x101008
	/* C30 */
	.octa 0x0
initial_csp_value:
	.octa 0x1020
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000007c1030000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c5f340 // CVTPZ-C.R-C Cd:0 Rn:26 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0xd503315f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:0001 11010101000000110011:11010101000000110011
	.inst 0x9bda7f19 // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:25 Rn:24 Ra:11111 0:0 Rm:26 10:10 U:1 10011011:10011011
	.inst 0x423fffc1 // ASTLR-R.R-32 Rt:1 Rn:30 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x78c74c1e // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:0 11:11 imm9:001110100 0:0 opc:11 111000:111000 size:01
	.inst 0x089f7dc1 // stllrb:aarch64/instrs/memory/ordered Rt:1 Rn:14 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2c09045 // GCTAG-R.C-C Rd:5 Cn:2 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0x7978d847 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:7 Rn:2 imm12:111000110110 opc:01 111001:111001 size:01
	.inst 0x697f8fe1 // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:1 Rn:31 Rt2:00011 imm7:1111111 L:1 1010010:1010010 opc:01
	.inst 0xc2c1eac1 // CTHI-C.CR-C Cd:1 Cn:22 1010:1010 opc:11 Rm:1 11000010110:11000010110
	.inst 0xc2c212a0
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
	.inst 0xc28ec001 // msr cvbar_el3, c1
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
	.inst 0xc2400181 // ldr c1, [x12, #0]
	.inst 0xc2400582 // ldr c2, [x12, #1]
	.inst 0xc240098e // ldr c14, [x12, #2]
	.inst 0xc2400d9a // ldr c26, [x12, #3]
	.inst 0xc240119e // ldr c30, [x12, #4]
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =initial_csp_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2c1d19f // cpy c31, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30850038
	msr SCTLR_EL3, x12
	ldr x12, =0x8
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032ac // ldr c12, [c21, #3]
	.inst 0xc28b412c // msr ddc_el3, c12
	isb
	.inst 0x826012ac // ldr c12, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr ddc_el3, c12
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400195 // ldr c21, [x12, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400595 // ldr c21, [x12, #1]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400995 // ldr c21, [x12, #2]
	.inst 0xc2d5a461 // chkeq c3, c21
	b.ne comparison_fail
	.inst 0xc2400d95 // ldr c21, [x12, #3]
	.inst 0xc2d5a4a1 // chkeq c5, c21
	b.ne comparison_fail
	.inst 0xc2401195 // ldr c21, [x12, #4]
	.inst 0xc2d5a4e1 // chkeq c7, c21
	b.ne comparison_fail
	.inst 0xc2401595 // ldr c21, [x12, #5]
	.inst 0xc2d5a5c1 // chkeq c14, c21
	b.ne comparison_fail
	.inst 0xc2401995 // ldr c21, [x12, #6]
	.inst 0xc2d5a741 // chkeq c26, c21
	b.ne comparison_fail
	.inst 0xc2401d95 // ldr c21, [x12, #7]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000101c
	ldr x1, =check_data0
	ldr x2, =0x00001024
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000017f8
	ldr x1, =check_data1
	ldr x2, =0x000017fc
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
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
	ldr x0, =0x00481c6c
	ldr x1, =check_data4
	ldr x2, =0x00481c6e
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004c207c
	ldr x1, =check_data5
	ldr x2, =0x004c207e
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr ddc_el3, c12
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

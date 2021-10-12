.section data0, #alloc, #write
	.zero 256
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3824
.data
check_data0:
	.byte 0x00, 0x10
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x63, 0x13, 0xc2, 0xc2
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x58, 0x20, 0x96, 0x78, 0x1b, 0x50, 0xc1, 0xc2, 0xc2, 0x4b, 0xc7, 0x78, 0x41, 0xf8, 0x61, 0x38
	.byte 0x1f, 0xb8, 0x36, 0x3d, 0x45, 0xf8, 0x5f, 0x39, 0x80, 0xd1, 0xc5, 0xc2, 0xc4, 0xbb, 0xc5, 0xc2
	.byte 0xe2, 0x50, 0x59, 0xd3, 0x20, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1250
	/* C1 */
	.octa 0xffe
	/* C2 */
	.octa 0x408000
	/* C12 */
	.octa 0x0
	/* C27 */
	.octa 0x200080000007a03f000000000040c004
	/* C30 */
	.octa 0x10000000000000000000000108c
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x1005097108c000000000000108c
	/* C5 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x10000000000000000000000108c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000c0000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000004140050080000000000001
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
	.inst 0xc2c21363 // BRR-C-C 00011:00011 Cn:27 100:100 opc:00 11000010110000100:11000010110000100
	.zero 49152
	.inst 0x78962058 // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:24 Rn:2 00:00 imm9:101100010 0:0 opc:10 111000:111000 size:01
	.inst 0xc2c1501b // CFHI-R.C-C Rd:27 Cn:0 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0x78c74bc2 // ldtrsh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:30 10:10 imm9:001110100 0:0 opc:11 111000:111000 size:01
	.inst 0x3861f841 // ldrb_reg:aarch64/instrs/memory/single/general/register Rt:1 Rn:2 10:10 S:1 option:111 Rm:1 1:1 opc:01 111000:111000 size:00
	.inst 0x3d36b81f // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:31 Rn:0 imm12:110110101110 opc:00 111101:111101 size:00
	.inst 0x395ff845 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:5 Rn:2 imm12:011111111110 opc:01 111001:111001 size:00
	.inst 0xc2c5d180 // CVTDZ-C.R-C Cd:0 Rn:12 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0xc2c5bbc4 // SCBNDS-C.CI-C Cd:4 Cn:30 1110:1110 S:0 imm6:001011 11000010110:11000010110
	.inst 0xd35950e2 // ubfm:aarch64/instrs/integer/bitfield Rd:2 Rn:7 imms:010100 immr:011001 N:1 100110:100110 opc:10 sf:1
	.inst 0xc2c21320
	.zero 999380
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x18, cptr_el3
	orr x18, x18, #0x200
	msr cptr_el3, x18
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
	ldr x18, =initial_cap_values
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc2400641 // ldr c1, [x18, #1]
	.inst 0xc2400a42 // ldr c2, [x18, #2]
	.inst 0xc2400e4c // ldr c12, [x18, #3]
	.inst 0xc240125b // ldr c27, [x18, #4]
	.inst 0xc240165e // ldr c30, [x18, #5]
	/* Vector registers */
	mrs x18, cptr_el3
	bfc x18, #10, #1
	msr cptr_el3, x18
	isb
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30850032
	msr SCTLR_EL3, x18
	ldr x18, =0x4
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82603332 // ldr c18, [c25, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x82601332 // ldr c18, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc2400259 // ldr c25, [x18, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc2400659 // ldr c25, [x18, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400a59 // ldr c25, [x18, #2]
	.inst 0xc2d9a481 // chkeq c4, c25
	b.ne comparison_fail
	.inst 0xc2400e59 // ldr c25, [x18, #3]
	.inst 0xc2d9a4a1 // chkeq c5, c25
	b.ne comparison_fail
	.inst 0xc2401259 // ldr c25, [x18, #4]
	.inst 0xc2d9a581 // chkeq c12, c25
	b.ne comparison_fail
	.inst 0xc2401659 // ldr c25, [x18, #5]
	.inst 0xc2d9a701 // chkeq c24, c25
	b.ne comparison_fail
	.inst 0xc2401a59 // ldr c25, [x18, #6]
	.inst 0xc2d9a761 // chkeq c27, c25
	b.ne comparison_fail
	.inst 0xc2401e59 // ldr c25, [x18, #7]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check vector registers */
	ldr x18, =0x0
	mov x25, v31.d[0]
	cmp x18, x25
	b.ne comparison_fail
	ldr x18, =0x0
	mov x25, v31.d[1]
	cmp x18, x25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001100
	ldr x1, =check_data0
	ldr x2, =0x00001102
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000017fe
	ldr x1, =check_data1
	ldr x2, =0x000017ff
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
	ldr x2, =0x00400004
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00407f62
	ldr x1, =check_data4
	ldr x2, =0x00407f64
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0040c004
	ldr x1, =check_data5
	ldr x2, =0x0040c02c
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
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
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

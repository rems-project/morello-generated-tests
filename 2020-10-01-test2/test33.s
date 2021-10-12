.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data3:
	.byte 0x1d, 0x77, 0xd0, 0x38, 0x40, 0x00, 0x3f, 0xd6
.data
check_data4:
	.byte 0xf8, 0x6b, 0xb5, 0x3c, 0xdf, 0xf9, 0x1b, 0x9b, 0x61, 0x50, 0x3f, 0x0b, 0x5f, 0x14, 0x63, 0x8a
	.byte 0x3c, 0xe5, 0x9e, 0xb8, 0xc0, 0x17, 0xc0, 0x5a, 0x42, 0x4e, 0x36, 0x0b, 0xca, 0x09, 0x39, 0xc2
	.byte 0x60, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x401008
	/* C9 */
	.octa 0x4e0000
	/* C10 */
	.octa 0x4000000000000000000000000000
	/* C14 */
	.octa 0xffffffffffff3810
	/* C21 */
	.octa 0x7c8
	/* C24 */
	.octa 0x1a00
final_cap_values:
	/* C0 */
	.octa 0x8
	/* C9 */
	.octa 0x4dffee
	/* C10 */
	.octa 0x4000000000000000000000000000
	/* C14 */
	.octa 0xffffffffffff3810
	/* C21 */
	.octa 0x7c8
	/* C24 */
	.octa 0x1907
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x400008
initial_csp_value:
	.octa 0x838
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000301c0050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc80000000003000700ffe00000002000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x38d0771d // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:24 01:01 imm9:100000111 0:0 opc:11 111000:111000 size:00
	.inst 0xd63f0040 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:2 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 4096
	.inst 0x3cb56bf8 // str_reg_fpsimd:aarch64/instrs/memory/single/simdfp/register Rt:24 Rn:31 10:10 S:0 option:011 Rm:21 1:1 opc:10 111100:111100 size:00
	.inst 0x9b1bf9df // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:31 Rn:14 Ra:30 o0:1 Rm:27 0011011000:0011011000 sf:1
	.inst 0x0b3f5061 // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:1 Rn:3 imm3:100 option:010 Rm:31 01011001:01011001 S:0 op:0 sf:0
	.inst 0x8a63145f // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:2 imm6:000101 Rm:3 N:1 shift:01 01010:01010 opc:00 sf:1
	.inst 0xb89ee53c // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:28 Rn:9 01:01 imm9:111101110 0:0 opc:10 111000:111000 size:10
	.inst 0x5ac017c0 // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:0 Rn:30 op:1 10110101100000000010:10110101100000000010 sf:0
	.inst 0x0b364e42 // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:2 Rn:18 imm3:011 option:010 Rm:22 01011001:01011001 S:0 op:0 sf:0
	.inst 0xc23909ca // STR-C.RIB-C Ct:10 Rn:14 imm12:111001000010 L:0 110000100:110000100
	.inst 0xc2c21260
	.zero 1044436
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x7, cptr_el3
	orr x7, x7, #0x200
	msr cptr_el3, x7
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e2 // ldr c2, [x7, #0]
	.inst 0xc24004e9 // ldr c9, [x7, #1]
	.inst 0xc24008ea // ldr c10, [x7, #2]
	.inst 0xc2400cee // ldr c14, [x7, #3]
	.inst 0xc24010f5 // ldr c21, [x7, #4]
	.inst 0xc24014f8 // ldr c24, [x7, #5]
	/* Vector registers */
	mrs x7, cptr_el3
	bfc x7, #10, #1
	msr cptr_el3, x7
	isb
	ldr q24, =0x10000000000000000000000
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =initial_csp_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2c1d0ff // cpy c31, c7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30850032
	msr SCTLR_EL3, x7
	ldr x7, =0xc
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x82603267 // ldr c7, [c19, #3]
	.inst 0xc28b4127 // msr ddc_el3, c7
	isb
	.inst 0x82601267 // ldr c7, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr ddc_el3, c7
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000f3 // ldr c19, [x7, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc24004f3 // ldr c19, [x7, #1]
	.inst 0xc2d3a521 // chkeq c9, c19
	b.ne comparison_fail
	.inst 0xc24008f3 // ldr c19, [x7, #2]
	.inst 0xc2d3a541 // chkeq c10, c19
	b.ne comparison_fail
	.inst 0xc2400cf3 // ldr c19, [x7, #3]
	.inst 0xc2d3a5c1 // chkeq c14, c19
	b.ne comparison_fail
	.inst 0xc24010f3 // ldr c19, [x7, #4]
	.inst 0xc2d3a6a1 // chkeq c21, c19
	b.ne comparison_fail
	.inst 0xc24014f3 // ldr c19, [x7, #5]
	.inst 0xc2d3a701 // chkeq c24, c19
	b.ne comparison_fail
	.inst 0xc24018f3 // ldr c19, [x7, #6]
	.inst 0xc2d3a781 // chkeq c28, c19
	b.ne comparison_fail
	.inst 0xc2401cf3 // ldr c19, [x7, #7]
	.inst 0xc2d3a7a1 // chkeq c29, c19
	b.ne comparison_fail
	.inst 0xc24020f3 // ldr c19, [x7, #8]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check vector registers */
	ldr x7, =0x0
	mov x19, v24.d[0]
	cmp x7, x19
	b.ne comparison_fail
	ldr x7, =0x1000000
	mov x19, v24.d[1]
	cmp x7, x19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001a00
	ldr x1, =check_data1
	ldr x2, =0x00001a01
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001c30
	ldr x1, =check_data2
	ldr x2, =0x00001c40
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400008
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00401008
	ldr x1, =check_data4
	ldr x2, =0x0040102c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004e0000
	ldr x1, =check_data5
	ldr x2, =0x004e0004
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
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr ddc_el3, c7
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

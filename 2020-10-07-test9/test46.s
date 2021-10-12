.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x5e, 0x13, 0x82, 0x0b, 0xe1, 0x7f, 0x42, 0x82, 0x50, 0x40, 0x1a, 0xb8, 0xc2, 0x38, 0x60, 0xc2
	.byte 0x1f, 0x78, 0x00, 0x1b, 0xe0, 0x73, 0xc2, 0xc2, 0x3e, 0x48, 0x3e, 0x4b, 0x1f, 0xb0, 0xc5, 0xc2
	.byte 0x09, 0x71, 0xc0, 0xc2, 0xfb, 0xbc, 0x4d, 0x38, 0x80, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xffffffffe00001
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x2024
	/* C6 */
	.octa 0xffffffffffff8f40
	/* C7 */
	.octa 0x80000000000100050000000000001f23
	/* C8 */
	.octa 0x400000000000000000000000
	/* C16 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xffffffffe00001
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C6 */
	.octa 0xffffffffffff8f40
	/* C7 */
	.octa 0x80000000000100050000000000001ffe
	/* C8 */
	.octa 0x400000000000000000000000
	/* C9 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C27 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x40000000514401390000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100600070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd01000000007000700ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001020
	.dword initial_cap_values + 64
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x0b82135e // add_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:30 Rn:26 imm6:000100 Rm:2 0:0 shift:10 01011:01011 S:0 op:0 sf:0
	.inst 0x82427fe1 // ASTR-R.RI-64 Rt:1 Rn:31 op:11 imm9:000100111 L:0 1000001001:1000001001
	.inst 0xb81a4050 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:16 Rn:2 00:00 imm9:110100100 0:0 opc:00 111000:111000 size:10
	.inst 0xc26038c2 // LDR-C.RIB-C Ct:2 Rn:6 imm12:100000001110 L:1 110000100:110000100
	.inst 0x1b00781f // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:31 Rn:0 Ra:30 o0:0 Rm:0 0011011000:0011011000 sf:0
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0x4b3e483e // sub_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:30 Rn:1 imm3:010 option:010 Rm:30 01011001:01011001 S:0 op:1 sf:0
	.inst 0xc2c5b01f // CVTP-C.R-C Cd:31 Rn:0 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xc2c07109 // GCOFF-R.C-C Rd:9 Cn:8 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0x384dbcfb // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:27 Rn:7 11:11 imm9:011011011 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c21080
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x17, cptr_el3
	orr x17, x17, #0x200
	msr cptr_el3, x17
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
	ldr x17, =initial_cap_values
	.inst 0xc2400220 // ldr c0, [x17, #0]
	.inst 0xc2400621 // ldr c1, [x17, #1]
	.inst 0xc2400a22 // ldr c2, [x17, #2]
	.inst 0xc2400e26 // ldr c6, [x17, #3]
	.inst 0xc2401227 // ldr c7, [x17, #4]
	.inst 0xc2401628 // ldr c8, [x17, #5]
	.inst 0xc2401a30 // ldr c16, [x17, #6]
	/* Set up flags and system registers */
	mov x17, #0x00000000
	msr nzcv, x17
	ldr x17, =initial_SP_EL3_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2c1d23f // cpy c31, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30850038
	msr SCTLR_EL3, x17
	ldr x17, =0x0
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82603091 // ldr c17, [c4, #3]
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	.inst 0x82601091 // ldr c17, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c21220 // br c17
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400224 // ldr c4, [x17, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc2400624 // ldr c4, [x17, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400a24 // ldr c4, [x17, #2]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc2400e24 // ldr c4, [x17, #3]
	.inst 0xc2c4a4c1 // chkeq c6, c4
	b.ne comparison_fail
	.inst 0xc2401224 // ldr c4, [x17, #4]
	.inst 0xc2c4a4e1 // chkeq c7, c4
	b.ne comparison_fail
	.inst 0xc2401624 // ldr c4, [x17, #5]
	.inst 0xc2c4a501 // chkeq c8, c4
	b.ne comparison_fail
	.inst 0xc2401a24 // ldr c4, [x17, #6]
	.inst 0xc2c4a521 // chkeq c9, c4
	b.ne comparison_fail
	.inst 0xc2401e24 // ldr c4, [x17, #7]
	.inst 0xc2c4a601 // chkeq c16, c4
	b.ne comparison_fail
	.inst 0xc2402224 // ldr c4, [x17, #8]
	.inst 0xc2c4a761 // chkeq c27, c4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001020
	ldr x1, =check_data0
	ldr x2, =0x00001030
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001138
	ldr x1, =check_data1
	ldr x2, =0x00001140
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fc8
	ldr x1, =check_data2
	ldr x2, =0x00001fcc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
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
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
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

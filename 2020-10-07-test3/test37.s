.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x5b, 0xfc, 0x9f, 0x88, 0x20, 0xbc, 0xc1, 0x79, 0x51, 0x02, 0xc0, 0x5a, 0x23, 0x30, 0xc2, 0xc2
	.byte 0xfe, 0x33, 0xc5, 0xc2, 0x20, 0x88, 0xdb, 0xc2, 0xec, 0x2b, 0xd9, 0xc2, 0xc5, 0x1b, 0x18, 0x6b
	.byte 0x3f, 0xbf, 0xc2, 0x02, 0x9e, 0x01, 0x5a, 0x3c, 0x60, 0x12, 0xc2, 0xc2
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x20008000800000400000000000400010
	/* C2 */
	.octa 0x10e0
	/* C25 */
	.octa 0x400020008000000000000000
	/* C27 */
	.octa 0x20008000000100000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x20008000800000400000000000400010
	/* C1 */
	.octa 0x20008000800000400000000000400010
	/* C2 */
	.octa 0x10e0
	/* C12 */
	.octa 0x80000000000000000050005e
	/* C25 */
	.octa 0x400020008000000000000000
	/* C27 */
	.octa 0x20008000000100000000000000000000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x80000000000000000050005e
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000600470000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x889ffc5b // stlr:aarch64/instrs/memory/ordered Rt:27 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0x79c1bc20 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:1 imm12:000001101111 opc:11 111001:111001 size:01
	.inst 0x5ac00251 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:17 Rn:18 101101011000000000000:101101011000000000000 sf:0
	.inst 0xc2c23023 // BLRR-C-C 00011:00011 Cn:1 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xc2c533fe // CVTP-R.C-C Rd:30 Cn:31 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0xc2db8820 // CHKSSU-C.CC-C Cd:0 Cn:1 0010:0010 opc:10 Cm:27 11000010110:11000010110
	.inst 0xc2d92bec // BICFLGS-C.CR-C Cd:12 Cn:31 1010:1010 opc:00 Rm:25 11000010110:11000010110
	.inst 0x6b181bc5 // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:5 Rn:30 imm6:000110 Rm:24 0:0 shift:00 01011:01011 S:1 op:1 sf:0
	.inst 0x02c2bf3f // SUB-C.CIS-C Cd:31 Cn:25 imm12:000010101111 sh:1 A:1 00000010:00000010
	.inst 0x3c5a019e // ldur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:30 Rn:12 00:00 imm9:110100000 0:0 opc:01 111100:111100 size:00
	.inst 0xc2c21260
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x8, cptr_el3
	orr x8, x8, #0x200
	msr cptr_el3, x8
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
	ldr x8, =initial_cap_values
	.inst 0xc2400101 // ldr c1, [x8, #0]
	.inst 0xc2400502 // ldr c2, [x8, #1]
	.inst 0xc2400919 // ldr c25, [x8, #2]
	.inst 0xc2400d1b // ldr c27, [x8, #3]
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =initial_SP_EL3_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2c1d11f // cpy c31, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	ldr x8, =0x80
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x82603268 // ldr c8, [c19, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x82601268 // ldr c8, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400113 // ldr c19, [x8, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc2400513 // ldr c19, [x8, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400913 // ldr c19, [x8, #2]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400d13 // ldr c19, [x8, #3]
	.inst 0xc2d3a581 // chkeq c12, c19
	b.ne comparison_fail
	.inst 0xc2401113 // ldr c19, [x8, #4]
	.inst 0xc2d3a721 // chkeq c25, c19
	b.ne comparison_fail
	.inst 0xc2401513 // ldr c19, [x8, #5]
	.inst 0xc2d3a761 // chkeq c27, c19
	b.ne comparison_fail
	.inst 0xc2401913 // ldr c19, [x8, #6]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check vector registers */
	ldr x8, =0x0
	mov x19, v30.d[0]
	cmp x8, x19
	b.ne comparison_fail
	ldr x8, =0x0
	mov x19, v30.d[1]
	cmp x8, x19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010e0
	ldr x1, =check_data0
	ldr x2, =0x000010e4
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
	ldr x0, =0x004000ee
	ldr x1, =check_data2
	ldr x2, =0x004000f0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004ffffe
	ldr x1, =check_data3
	ldr x2, =0x004fffff
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
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
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

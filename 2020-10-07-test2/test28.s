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
	.byte 0x80, 0x00, 0x3f, 0xd6, 0xe0, 0xd7, 0x9c, 0x78, 0x22, 0xa0, 0xd8, 0xc2, 0x6e, 0x03, 0xc7, 0x38
	.byte 0x7b, 0xfc, 0x7f, 0x42, 0xde, 0xbe, 0x0e, 0x6c, 0x5f, 0xb5, 0x7e, 0x51, 0xc3, 0x88, 0xd9, 0xc2
	.byte 0xdf, 0x73, 0xc6, 0xc2, 0x21, 0x70, 0x7a, 0x93, 0x00, 0x12, 0xc2, 0xc2
.data
check_data3:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x3fff800000000000000000000000
	/* C3 */
	.octa 0x1000
	/* C4 */
	.octa 0x400004
	/* C6 */
	.octa 0x400200010000000000000001
	/* C22 */
	.octa 0x4000000060000e010000000000000f18
	/* C25 */
	.octa 0x96814005001fffffffff0001
	/* C27 */
	.octa 0x80000000000700060000000000001000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x3fff800000000000000000000000
	/* C3 */
	.octa 0x400200010000000000000001
	/* C4 */
	.octa 0x400004
	/* C6 */
	.octa 0x400200010000000000000001
	/* C14 */
	.octa 0x0
	/* C22 */
	.octa 0x4000000060000e010000000000000f18
	/* C25 */
	.octa 0x96814005001fffffffff0001
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000010100060000000000400005
initial_SP_EL3_value:
	.octa 0x800000000407840b00000000004001f0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000010100060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000005812000000ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd63f0080 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:4 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.inst 0x789cd7e0 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:31 01:01 imm9:111001101 0:0 opc:10 111000:111000 size:01
	.inst 0xc2d8a022 // CLRPERM-C.CR-C Cd:2 Cn:1 000:000 1:1 10:10 Rm:24 11000010110:11000010110
	.inst 0x38c7036e // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:14 Rn:27 00:00 imm9:001110000 0:0 opc:11 111000:111000 size:00
	.inst 0x427ffc7b // ALDAR-R.R-32 Rt:27 Rn:3 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x6c0ebede // stnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:30 Rn:22 Rt2:01111 imm7:0011101 L:0 1011000:1011000 opc:01
	.inst 0x517eb55f // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:10 imm12:111110101101 sh:1 0:0 10001:10001 S:0 op:1 sf:0
	.inst 0xc2d988c3 // CHKSSU-C.CC-C Cd:3 Cn:6 0010:0010 opc:10 Cm:25 11000010110:11000010110
	.inst 0xc2c673df // CLRPERM-C.CI-C Cd:31 Cn:30 100:100 perm:011 1100001011000110:1100001011000110
	.inst 0x937a7021 // sbfm:aarch64/instrs/integer/bitfield Rd:1 Rn:1 imms:011100 immr:111010 N:1 100110:100110 opc:00 sf:1
	.inst 0xc2c21200
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x19, cptr_el3
	orr x19, x19, #0x200
	msr cptr_el3, x19
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
	ldr x19, =initial_cap_values
	.inst 0xc2400261 // ldr c1, [x19, #0]
	.inst 0xc2400663 // ldr c3, [x19, #1]
	.inst 0xc2400a64 // ldr c4, [x19, #2]
	.inst 0xc2400e66 // ldr c6, [x19, #3]
	.inst 0xc2401276 // ldr c22, [x19, #4]
	.inst 0xc2401679 // ldr c25, [x19, #5]
	.inst 0xc2401a7b // ldr c27, [x19, #6]
	/* Vector registers */
	mrs x19, cptr_el3
	bfc x19, #10, #1
	msr cptr_el3, x19
	isb
	ldr q15, =0x0
	ldr q30, =0x0
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =initial_SP_EL3_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2c1d27f // cpy c31, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	ldr x19, =0xc
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82603213 // ldr c19, [c16, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x82601213 // ldr c19, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x16, #0xf
	and x19, x19, x16
	cmp x19, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400270 // ldr c16, [x19, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc2400670 // ldr c16, [x19, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400a70 // ldr c16, [x19, #2]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400e70 // ldr c16, [x19, #3]
	.inst 0xc2d0a461 // chkeq c3, c16
	b.ne comparison_fail
	.inst 0xc2401270 // ldr c16, [x19, #4]
	.inst 0xc2d0a481 // chkeq c4, c16
	b.ne comparison_fail
	.inst 0xc2401670 // ldr c16, [x19, #5]
	.inst 0xc2d0a4c1 // chkeq c6, c16
	b.ne comparison_fail
	.inst 0xc2401a70 // ldr c16, [x19, #6]
	.inst 0xc2d0a5c1 // chkeq c14, c16
	b.ne comparison_fail
	.inst 0xc2401e70 // ldr c16, [x19, #7]
	.inst 0xc2d0a6c1 // chkeq c22, c16
	b.ne comparison_fail
	.inst 0xc2402270 // ldr c16, [x19, #8]
	.inst 0xc2d0a721 // chkeq c25, c16
	b.ne comparison_fail
	.inst 0xc2402670 // ldr c16, [x19, #9]
	.inst 0xc2d0a761 // chkeq c27, c16
	b.ne comparison_fail
	.inst 0xc2402a70 // ldr c16, [x19, #10]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0x0
	mov x16, v15.d[0]
	cmp x19, x16
	b.ne comparison_fail
	ldr x19, =0x0
	mov x16, v15.d[1]
	cmp x19, x16
	b.ne comparison_fail
	ldr x19, =0x0
	mov x16, v30.d[0]
	cmp x19, x16
	b.ne comparison_fail
	ldr x19, =0x0
	mov x16, v30.d[1]
	cmp x19, x16
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
	ldr x0, =0x00001070
	ldr x1, =check_data1
	ldr x2, =0x00001071
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004001f0
	ldr x1, =check_data3
	ldr x2, =0x004001f2
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
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
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

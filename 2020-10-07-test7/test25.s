.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0xeb, 0xc3, 0xc0, 0xc2, 0x01, 0x40, 0x32, 0x52, 0x01, 0x13, 0xc2, 0xc2, 0x21, 0x04, 0xdf, 0xc2
	.byte 0x04, 0xb0, 0xc5, 0xc2, 0xe8, 0x03, 0x02, 0x3a, 0xba, 0x55, 0x94, 0x3d, 0xff, 0xab, 0x1f, 0xe2
	.byte 0x4d, 0x30, 0xfc, 0x28, 0x5e, 0x3c, 0x55, 0xa2, 0x60, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400010
	/* C2 */
	.octa 0x1af0
	/* C13 */
	.octa 0xffffffffffffc430
	/* C24 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x400010
	/* C1 */
	.octa 0x7fbfc010
	/* C2 */
	.octa 0x1000
	/* C4 */
	.octa 0x20008000000100070000000000400010
	/* C8 */
	.octa 0x1af0
	/* C11 */
	.octa 0x1011
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x80000000000180060000000000001011
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005b0400010000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c0c3eb // CVT-R.CC-C Rd:11 Cn:31 110000:110000 Cm:0 11000010110:11000010110
	.inst 0x52324001 // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:1 Rn:0 imms:010000 immr:110010 N:0 100100:100100 opc:10 sf:0
	.inst 0xc2c21301 // CHKSLD-C-C 00001:00001 Cn:24 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xc2df0421 // BUILD-C.C-C Cd:1 Cn:1 001:001 opc:00 0:0 Cm:31 11000010110:11000010110
	.inst 0xc2c5b004 // CVTP-C.R-C Cd:4 Rn:0 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0x3a0203e8 // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:8 Rn:31 000000:000000 Rm:2 11010000:11010000 S:1 op:0 sf:0
	.inst 0x3d9455ba // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:26 Rn:13 imm12:010100010101 opc:10 111101:111101 size:00
	.inst 0xe21fabff // ALDURSB-R.RI-64 Rt:31 Rn:31 op2:10 imm9:111111010 V:0 op1:00 11100010:11100010
	.inst 0x28fc304d // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:13 Rn:2 Rt2:01100 imm7:1111000 L:1 1010001:1010001 opc:00
	.inst 0xa2553c5e // LDR-C.RIBW-C Ct:30 Rn:2 11:11 imm9:101010011 0:0 opc:01 10100010:10100010
	.inst 0xc2c21360
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x16, cptr_el3
	orr x16, x16, #0x200
	msr cptr_el3, x16
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400602 // ldr c2, [x16, #1]
	.inst 0xc2400a0d // ldr c13, [x16, #2]
	.inst 0xc2400e18 // ldr c24, [x16, #3]
	/* Vector registers */
	mrs x16, cptr_el3
	bfc x16, #10, #1
	msr cptr_el3, x16
	isb
	ldr q26, =0x0
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =initial_SP_EL3_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2c1d21f // cpy c31, c16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30850032
	msr SCTLR_EL3, x16
	ldr x16, =0x8
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82603370 // ldr c16, [c27, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x82601370 // ldr c16, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	/* Check processor flags */
	mrs x16, nzcv
	ubfx x16, x16, #28, #4
	mov x27, #0xf
	and x16, x16, x27
	cmp x16, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc240021b // ldr c27, [x16, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240061b // ldr c27, [x16, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc2400a1b // ldr c27, [x16, #2]
	.inst 0xc2dba441 // chkeq c2, c27
	b.ne comparison_fail
	.inst 0xc2400e1b // ldr c27, [x16, #3]
	.inst 0xc2dba481 // chkeq c4, c27
	b.ne comparison_fail
	.inst 0xc240121b // ldr c27, [x16, #4]
	.inst 0xc2dba501 // chkeq c8, c27
	b.ne comparison_fail
	.inst 0xc240161b // ldr c27, [x16, #5]
	.inst 0xc2dba561 // chkeq c11, c27
	b.ne comparison_fail
	.inst 0xc2401a1b // ldr c27, [x16, #6]
	.inst 0xc2dba581 // chkeq c12, c27
	b.ne comparison_fail
	.inst 0xc2401e1b // ldr c27, [x16, #7]
	.inst 0xc2dba5a1 // chkeq c13, c27
	b.ne comparison_fail
	.inst 0xc240221b // ldr c27, [x16, #8]
	.inst 0xc2dba701 // chkeq c24, c27
	b.ne comparison_fail
	.inst 0xc240261b // ldr c27, [x16, #9]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x0
	mov x27, v26.d[0]
	cmp x16, x27
	b.ne comparison_fail
	ldr x16, =0x0
	mov x27, v26.d[1]
	cmp x16, x27
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
	ldr x0, =0x00001580
	ldr x1, =check_data1
	ldr x2, =0x00001590
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001af0
	ldr x1, =check_data2
	ldr x2, =0x00001af8
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
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
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

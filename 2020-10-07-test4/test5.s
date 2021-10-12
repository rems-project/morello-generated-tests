.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 32
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x2b, 0xd8, 0xcd, 0x38, 0x5e, 0x34, 0x83, 0x5a, 0x3f, 0x24, 0x7d, 0x79, 0x07, 0xa9, 0x20, 0x4b
	.byte 0x05, 0x13, 0xc0, 0xc2, 0xe2, 0x9b, 0x32, 0x31, 0x00, 0x43, 0x20, 0xe2, 0x21, 0x10, 0xc2, 0xc2
	.byte 0x39, 0x18, 0xe6, 0xc2, 0x6a, 0x6c, 0x4b, 0x62, 0x80, 0x12, 0xc2, 0xc2
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1000400000000003fffca
	/* C3 */
	.octa 0x1250
	/* C24 */
	.octa 0x40000000000100050000000000001ffa
final_cap_values:
	/* C1 */
	.octa 0x1000400000000003fffca
	/* C3 */
	.octa 0x1250
	/* C5 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C24 */
	.octa 0x40000000000100050000000000001ffa
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0xffffedb0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200620070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80100000000000000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000013b0
	.dword 0x00000000000013c0
	.dword initial_cap_values + 32
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x38cdd82b // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:11 Rn:1 10:10 imm9:011011101 0:0 opc:11 111000:111000 size:00
	.inst 0x5a83345e // csneg:aarch64/instrs/integer/conditional/select Rd:30 Rn:2 o2:1 0:0 cond:0011 Rm:3 011010100:011010100 op:1 sf:0
	.inst 0x797d243f // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:1 imm12:111101001001 opc:01 111001:111001 size:01
	.inst 0x4b20a907 // sub_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:7 Rn:8 imm3:010 option:101 Rm:0 01011001:01011001 S:0 op:1 sf:0
	.inst 0xc2c01305 // GCBASE-R.C-C Rd:5 Cn:24 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0x31329be2 // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:2 Rn:31 imm12:110010100110 sh:0 0:0 10001:10001 S:1 op:0 sf:0
	.inst 0xe2204300 // ASTUR-V.RI-B Rt:0 Rn:24 op2:00 imm9:000000100 V:1 op1:00 11100010:11100010
	.inst 0xc2c21021 // CHKSLD-C-C 00001:00001 Cn:1 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xc2e61839 // CVT-C.CR-C Cd:25 Cn:1 0110:0110 0:0 0:0 Rm:6 11000010111:11000010111
	.inst 0x624b6c6a // LDNP-C.RIB-C Ct:10 Rn:3 Ct2:11011 imm7:0010110 L:1 011000100:011000100
	.inst 0xc2c21280
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x9, cptr_el3
	orr x9, x9, #0x200
	msr cptr_el3, x9
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
	ldr x9, =initial_cap_values
	.inst 0xc2400121 // ldr c1, [x9, #0]
	.inst 0xc2400523 // ldr c3, [x9, #1]
	.inst 0xc2400938 // ldr c24, [x9, #2]
	/* Vector registers */
	mrs x9, cptr_el3
	bfc x9, #10, #1
	msr cptr_el3, x9
	isb
	ldr q0, =0x0
	/* Set up flags and system registers */
	mov x9, #0x20000000
	msr nzcv, x9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	ldr x9, =0x0
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82603289 // ldr c9, [c20, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x82601289 // ldr c9, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x20, #0xf
	and x9, x9, x20
	cmp x9, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400134 // ldr c20, [x9, #0]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400534 // ldr c20, [x9, #1]
	.inst 0xc2d4a461 // chkeq c3, c20
	b.ne comparison_fail
	.inst 0xc2400934 // ldr c20, [x9, #2]
	.inst 0xc2d4a4a1 // chkeq c5, c20
	b.ne comparison_fail
	.inst 0xc2400d34 // ldr c20, [x9, #3]
	.inst 0xc2d4a541 // chkeq c10, c20
	b.ne comparison_fail
	.inst 0xc2401134 // ldr c20, [x9, #4]
	.inst 0xc2d4a561 // chkeq c11, c20
	b.ne comparison_fail
	.inst 0xc2401534 // ldr c20, [x9, #5]
	.inst 0xc2d4a701 // chkeq c24, c20
	b.ne comparison_fail
	.inst 0xc2401934 // ldr c20, [x9, #6]
	.inst 0xc2d4a761 // chkeq c27, c20
	b.ne comparison_fail
	.inst 0xc2401d34 // ldr c20, [x9, #7]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0x0
	mov x20, v0.d[0]
	cmp x9, x20
	b.ne comparison_fail
	ldr x9, =0x0
	mov x20, v0.d[1]
	cmp x9, x20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000013b0
	ldr x1, =check_data0
	ldr x2, =0x000013d0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffe
	ldr x1, =check_data1
	ldr x2, =0x00001fff
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
	ldr x0, =0x004000a7
	ldr x1, =check_data3
	ldr x2, =0x004000a8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00401e5c
	ldr x1, =check_data4
	ldr x2, =0x00401e5e
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
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
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

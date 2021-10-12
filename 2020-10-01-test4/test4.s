.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x41, 0xe0, 0x34, 0xd2, 0x02, 0x84, 0xdd, 0xe2, 0x01, 0x88, 0xa1, 0x9b, 0xdf, 0x64, 0xc2, 0xc2
	.byte 0x21, 0xc0, 0xc1, 0xc2, 0xbf, 0xea, 0x1f, 0x78, 0x4d, 0x3b, 0x40, 0x2b, 0xa2, 0x33, 0xc2, 0xc2
.data
check_data2:
	.byte 0x01, 0x60, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00
.data
check_data3:
	.byte 0xa0, 0x10, 0xc2, 0xc2
.data
check_data4:
	.byte 0xce, 0xd3, 0xc5, 0xc2, 0x00, 0xc4, 0xca, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20408002000100050000000000400430
	/* C6 */
	.octa 0xc00284a40000000000000001
	/* C10 */
	.octa 0x400002000000000000000000000000
	/* C21 */
	.octa 0x40000000000100070000000000001ede
	/* C29 */
	.octa 0x20008000800100050000000000480000
final_cap_values:
	/* C0 */
	.octa 0x20408002000100050000000000400430
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xffffffffff6001
	/* C6 */
	.octa 0xc00284a40000000000000001
	/* C10 */
	.octa 0x400002000000000000000000000000
	/* C14 */
	.octa 0x80000000200300060000000000400021
	/* C21 */
	.octa 0x40000000000100070000000000001ede
	/* C29 */
	.octa 0x400000000000000000000000000000
	/* C30 */
	.octa 0x20008000800100070000000000400021
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000002003000600ffc00000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd234e041 // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:1 Rn:2 imms:111000 immr:110100 N:0 100100:100100 opc:10 sf:1
	.inst 0xe2dd8402 // ALDUR-R.RI-64 Rt:2 Rn:0 op2:01 imm9:111011000 V:0 op1:11 11100010:11100010
	.inst 0x9ba18801 // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:1 Rn:0 Ra:2 o0:1 Rm:1 01:01 U:1 10011011:10011011
	.inst 0xc2c264df // CPYVALUE-C.C-C Cd:31 Cn:6 001:001 opc:11 0:0 Cm:2 11000010110:11000010110
	.inst 0xc2c1c021 // CVT-R.CC-C Rd:1 Cn:1 110000:110000 Cm:1 11000010110:11000010110
	.inst 0x781feabf // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:21 10:10 imm9:111111110 0:0 opc:00 111000:111000 size:01
	.inst 0x2b403b4d // adds_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:13 Rn:26 imm6:001110 Rm:0 0:0 shift:01 01011:01011 S:1 op:0 sf:0
	.inst 0xc2c233a2 // BLRS-C-C 00010:00010 Cn:29 100:100 opc:01 11000010110000100:11000010110000100
	.zero 1000
	.inst 0xffff6001
	.inst 0x00ffffff
	.zero 32
	.inst 0xc2c210a0
	.zero 523212
	.inst 0xc2c5d3ce // CVTDZ-C.R-C Cd:14 Rn:30 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0xc2cac400 // RETS-C.C-C 00000:00000 Cn:0 001:001 opc:10 1:1 Cm:10 11000010110:11000010110
	.zero 524280
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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400666 // ldr c6, [x19, #1]
	.inst 0xc2400a6a // ldr c10, [x19, #2]
	.inst 0xc2400e75 // ldr c21, [x19, #3]
	.inst 0xc240127d // ldr c29, [x19, #4]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	ldr x19, =0x80
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030b3 // ldr c19, [c5, #3]
	.inst 0xc28b4133 // msr ddc_el3, c19
	isb
	.inst 0x826010b3 // ldr c19, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr ddc_el3, c19
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400265 // ldr c5, [x19, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400665 // ldr c5, [x19, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400a65 // ldr c5, [x19, #2]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400e65 // ldr c5, [x19, #3]
	.inst 0xc2c5a4c1 // chkeq c6, c5
	b.ne comparison_fail
	.inst 0xc2401265 // ldr c5, [x19, #4]
	.inst 0xc2c5a541 // chkeq c10, c5
	b.ne comparison_fail
	.inst 0xc2401665 // ldr c5, [x19, #5]
	.inst 0xc2c5a5c1 // chkeq c14, c5
	b.ne comparison_fail
	.inst 0xc2401a65 // ldr c5, [x19, #6]
	.inst 0xc2c5a6a1 // chkeq c21, c5
	b.ne comparison_fail
	.inst 0xc2401e65 // ldr c5, [x19, #7]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	.inst 0xc2402265 // ldr c5, [x19, #8]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001edc
	ldr x1, =check_data0
	ldr x2, =0x00001ede
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x00400020
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400408
	ldr x1, =check_data2
	ldr x2, =0x00400410
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400430
	ldr x1, =check_data3
	ldr x2, =0x00400434
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00480000
	ldr x1, =check_data4
	ldr x2, =0x00480008
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
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr ddc_el3, c19
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

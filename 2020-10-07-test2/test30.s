.section data0, #alloc, #write
	.zero 128
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x81, 0x14, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3952
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x61, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x97, 0x6c, 0x8f, 0x00
.data
check_data2:
	.byte 0x81, 0x14, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xe0, 0x73, 0xc2, 0xc2, 0xa0, 0xcc, 0x50, 0xf8, 0x5f, 0x0a, 0x51, 0x78, 0x1e, 0x00, 0xc4, 0x39
	.byte 0xde, 0x03, 0x07, 0xda, 0x22, 0x18, 0x0f, 0x2c, 0x8b, 0x87, 0x97, 0x6c, 0xfe, 0xef, 0x5e, 0x3c
	.byte 0x40, 0xa0, 0xbf, 0x9b, 0x51, 0x03, 0xc0, 0xc2, 0x60, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1000
	/* C5 */
	.octa 0x117c
	/* C18 */
	.octa 0x147c
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x1000
final_cap_values:
	/* C1 */
	.octa 0x1000
	/* C5 */
	.octa 0x1088
	/* C18 */
	.octa 0x147c
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x1178
initial_SP_EL3_value:
	.octa 0x1090
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000400000000fffffffffff000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xf850cca0 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:5 11:11 imm9:100001100 0:0 opc:01 111000:111000 size:11
	.inst 0x78510a5f // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:18 10:10 imm9:100010000 0:0 opc:01 111000:111000 size:01
	.inst 0x39c4001e // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:0 imm12:000100000000 opc:11 111001:111001 size:00
	.inst 0xda0703de // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:30 Rn:30 000000:000000 Rm:7 11010000:11010000 S:0 op:1 sf:1
	.inst 0x2c0f1822 // stnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:2 Rn:1 Rt2:00110 imm7:0011110 L:0 1011000:1011000 opc:00
	.inst 0x6c97878b // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:11 Rn:28 Rt2:00001 imm7:0101111 L:0 1011001:1011001 opc:01
	.inst 0x3c5eeffe // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:30 Rn:31 11:11 imm9:111101110 0:0 opc:01 111100:111100 size:00
	.inst 0x9bbfa040 // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:0 Rn:2 Ra:8 o0:1 Rm:31 01:01 U:1 10011011:10011011
	.inst 0xc2c00351 // SCBNDS-C.CR-C Cd:17 Cn:26 000:000 opc:00 0:0 Rm:0 11000010110:11000010110
	.inst 0xc2c21160
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x20, cptr_el3
	orr x20, x20, #0x200
	msr cptr_el3, x20
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
	ldr x20, =initial_cap_values
	.inst 0xc2400281 // ldr c1, [x20, #0]
	.inst 0xc2400685 // ldr c5, [x20, #1]
	.inst 0xc2400a92 // ldr c18, [x20, #2]
	.inst 0xc2400e9a // ldr c26, [x20, #3]
	.inst 0xc240129c // ldr c28, [x20, #4]
	/* Vector registers */
	mrs x20, cptr_el3
	bfc x20, #10, #1
	msr cptr_el3, x20
	isb
	ldr q1, =0x61
	ldr q2, =0x0
	ldr q6, =0x8f6c97
	ldr q11, =0x0
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =initial_SP_EL3_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2c1d29f // cpy c31, c20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30850038
	msr SCTLR_EL3, x20
	ldr x20, =0x4
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82603174 // ldr c20, [c11, #3]
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	.inst 0x82601174 // ldr c20, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc240028b // ldr c11, [x20, #0]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc240068b // ldr c11, [x20, #1]
	.inst 0xc2cba4a1 // chkeq c5, c11
	b.ne comparison_fail
	.inst 0xc2400a8b // ldr c11, [x20, #2]
	.inst 0xc2cba641 // chkeq c18, c11
	b.ne comparison_fail
	.inst 0xc2400e8b // ldr c11, [x20, #3]
	.inst 0xc2cba741 // chkeq c26, c11
	b.ne comparison_fail
	.inst 0xc240128b // ldr c11, [x20, #4]
	.inst 0xc2cba781 // chkeq c28, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x20, =0x61
	mov x11, v1.d[0]
	cmp x20, x11
	b.ne comparison_fail
	ldr x20, =0x0
	mov x11, v1.d[1]
	cmp x20, x11
	b.ne comparison_fail
	ldr x20, =0x0
	mov x11, v2.d[0]
	cmp x20, x11
	b.ne comparison_fail
	ldr x20, =0x0
	mov x11, v2.d[1]
	cmp x20, x11
	b.ne comparison_fail
	ldr x20, =0x8f6c97
	mov x11, v6.d[0]
	cmp x20, x11
	b.ne comparison_fail
	ldr x20, =0x0
	mov x11, v6.d[1]
	cmp x20, x11
	b.ne comparison_fail
	ldr x20, =0x0
	mov x11, v11.d[0]
	cmp x20, x11
	b.ne comparison_fail
	ldr x20, =0x0
	mov x11, v11.d[1]
	cmp x20, x11
	b.ne comparison_fail
	ldr x20, =0x8f
	mov x11, v30.d[0]
	cmp x20, x11
	b.ne comparison_fail
	ldr x20, =0x0
	mov x11, v30.d[1]
	cmp x20, x11
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
	ldr x0, =0x00001078
	ldr x1, =check_data1
	ldr x2, =0x00001080
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001088
	ldr x1, =check_data2
	ldr x2, =0x00001090
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000138c
	ldr x1, =check_data3
	ldr x2, =0x0000138e
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001581
	ldr x1, =check_data4
	ldr x2, =0x00001582
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
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

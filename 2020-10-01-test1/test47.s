.section data0, #alloc, #write
	.zero 864
	.byte 0x00, 0x00, 0x00, 0x00, 0xfe, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3216
.data
check_data0:
	.byte 0x8e, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xf8, 0x0a, 0x02, 0x58, 0x00, 0x40, 0x00, 0x80
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfa, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x9a
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0xfe, 0x0f
.data
check_data4:
	.byte 0x8e, 0x10
.data
check_data5:
	.zero 16
.data
check_data6:
	.byte 0xe1, 0xc2, 0xc2, 0xc2, 0x02, 0xac, 0xc5, 0x79, 0x3e, 0x33, 0x21, 0x9b, 0x95, 0x4e, 0xd5, 0xe2
	.byte 0xdf, 0x17, 0xc0, 0xda, 0xc0, 0x0e, 0x32, 0x79, 0x1f, 0xfe, 0x23, 0x7d, 0x1d, 0x7c, 0x1f, 0x42
	.byte 0xee, 0x7b, 0x58, 0xba, 0x40, 0x7c, 0x1f, 0x42, 0x00, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8000400058020af8000000000000108e
	/* C2 */
	.octa 0x400100000000000000000000
	/* C16 */
	.octa 0x40000000600000020000000000000000
	/* C20 */
	.octa 0x201a
	/* C22 */
	.octa 0x4000000000000000000000000000011a
	/* C23 */
	.octa 0x0
	/* C29 */
	.octa 0x9a00000000000000fa00000000000000
final_cap_values:
	/* C0 */
	.octa 0x8000400058020af8000000000000108e
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xffe
	/* C16 */
	.octa 0x40000000600000020000000000000000
	/* C20 */
	.octa 0x201a
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x4000000000000000000000000000011a
	/* C23 */
	.octa 0x0
	/* C29 */
	.octa 0x9a00000000000000fa00000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000a0000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc8000000400100020000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c2c2e1 // CVT-R.CC-C Rd:1 Cn:23 110000:110000 Cm:2 11000010110:11000010110
	.inst 0x79c5ac02 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:0 imm12:000101101011 opc:11 111001:111001 size:01
	.inst 0x9b21333e // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:30 Rn:25 Ra:12 o0:0 Rm:1 01:01 U:0 10011011:10011011
	.inst 0xe2d54e95 // ALDUR-C.RI-C Ct:21 Rn:20 op2:11 imm9:101010100 V:0 op1:11 11100010:11100010
	.inst 0xdac017df // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:31 Rn:30 op:1 10110101100000000010:10110101100000000010 sf:1
	.inst 0x79320ec0 // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:22 imm12:110010000011 opc:00 111001:111001 size:01
	.inst 0x7d23fe1f // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:31 Rn:16 imm12:100011111111 opc:00 111101:111101 size:01
	.inst 0x421f7c1d // ASTLR-C.R-C Ct:29 Rn:0 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xba587bee // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1110 0:0 Rn:31 10:10 cond:0111 imm5:11000 111010010:111010010 op:0 sf:1
	.inst 0x421f7c40 // ASTLR-C.R-C Ct:0 Rn:2 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xc2c21300
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x6, cptr_el3
	orr x6, x6, #0x200
	msr cptr_el3, x6
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c2 // ldr c2, [x6, #1]
	.inst 0xc24008d0 // ldr c16, [x6, #2]
	.inst 0xc2400cd4 // ldr c20, [x6, #3]
	.inst 0xc24010d6 // ldr c22, [x6, #4]
	.inst 0xc24014d7 // ldr c23, [x6, #5]
	.inst 0xc24018dd // ldr c29, [x6, #6]
	/* Vector registers */
	mrs x6, cptr_el3
	bfc x6, #10, #1
	msr cptr_el3, x6
	isb
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30850032
	msr SCTLR_EL3, x6
	ldr x6, =0x4
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82603306 // ldr c6, [c24, #3]
	.inst 0xc28b4126 // msr ddc_el3, c6
	isb
	.inst 0x82601306 // ldr c6, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr ddc_el3, c6
	isb
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x24, #0xf
	and x6, x6, x24
	cmp x6, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000d8 // ldr c24, [x6, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc24004d8 // ldr c24, [x6, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc24008d8 // ldr c24, [x6, #2]
	.inst 0xc2d8a441 // chkeq c2, c24
	b.ne comparison_fail
	.inst 0xc2400cd8 // ldr c24, [x6, #3]
	.inst 0xc2d8a601 // chkeq c16, c24
	b.ne comparison_fail
	.inst 0xc24010d8 // ldr c24, [x6, #4]
	.inst 0xc2d8a681 // chkeq c20, c24
	b.ne comparison_fail
	.inst 0xc24014d8 // ldr c24, [x6, #5]
	.inst 0xc2d8a6a1 // chkeq c21, c24
	b.ne comparison_fail
	.inst 0xc24018d8 // ldr c24, [x6, #6]
	.inst 0xc2d8a6c1 // chkeq c22, c24
	b.ne comparison_fail
	.inst 0xc2401cd8 // ldr c24, [x6, #7]
	.inst 0xc2d8a6e1 // chkeq c23, c24
	b.ne comparison_fail
	.inst 0xc24020d8 // ldr c24, [x6, #8]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x24, v31.d[0]
	cmp x6, x24
	b.ne comparison_fail
	ldr x6, =0x0
	mov x24, v31.d[1]
	cmp x6, x24
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
	ldr x0, =0x00001090
	ldr x1, =check_data1
	ldr x2, =0x000010a0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011fe
	ldr x1, =check_data2
	ldr x2, =0x00001200
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001364
	ldr x1, =check_data3
	ldr x2, =0x00001366
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001a20
	ldr x1, =check_data4
	ldr x2, =0x00001a22
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001f70
	ldr x1, =check_data5
	ldr x2, =0x00001f80
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr ddc_el3, c6
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

.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x62, 0x43, 0xd1, 0xc2, 0xcf, 0xf1, 0x4b, 0xd3, 0xa8, 0xd2, 0x8b, 0x5a, 0x00, 0x4c, 0xa0, 0x9b
	.byte 0x45, 0x58, 0x56, 0x7a, 0xc1, 0xc5, 0x8b, 0x79, 0x40, 0x07, 0x47, 0x38, 0xdc, 0x6b, 0x1f, 0x6c
	.byte 0x6f, 0x57, 0x73, 0x69, 0x51, 0xbc, 0xce, 0xad, 0xa0, 0x10, 0xc2, 0xc2
.data
check_data4:
	.zero 8
.data
check_data5:
	.zero 32
.data
.balign 16
initial_cap_values:
	/* C14 */
	.octa 0x1000
	/* C17 */
	.octa 0x480e30
	/* C26 */
	.octa 0x1b7f
	/* C27 */
	.octa 0x400780010000000000467070
	/* C30 */
	.octa 0x1528
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x481000
	/* C14 */
	.octa 0x1000
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x480e30
	/* C21 */
	.octa 0x0
	/* C26 */
	.octa 0x1bef
	/* C27 */
	.octa 0x400780010000000000467070
	/* C30 */
	.octa 0x1528
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000100000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000006001700ffffffffe00001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d14362 // SCVALUE-C.CR-C Cd:2 Cn:27 000:000 opc:10 0:0 Rm:17 11000010110:11000010110
	.inst 0xd34bf1cf // ubfm:aarch64/instrs/integer/bitfield Rd:15 Rn:14 imms:111100 immr:001011 N:1 100110:100110 opc:10 sf:1
	.inst 0x5a8bd2a8 // csinv:aarch64/instrs/integer/conditional/select Rd:8 Rn:21 o2:0 0:0 cond:1101 Rm:11 011010100:011010100 op:1 sf:0
	.inst 0x9ba04c00 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:0 Rn:0 Ra:19 o0:0 Rm:0 01:01 U:1 10011011:10011011
	.inst 0x7a565845 // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0101 0:0 Rn:2 10:10 cond:0101 imm5:10110 111010010:111010010 op:1 sf:0
	.inst 0x798bc5c1 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:14 imm12:001011110001 opc:10 111001:111001 size:01
	.inst 0x38470740 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:26 01:01 imm9:001110000 0:0 opc:01 111000:111000 size:00
	.inst 0x6c1f6bdc // stnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:28 Rn:30 Rt2:11010 imm7:0111110 L:0 1011000:1011000 opc:01
	.inst 0x6973576f // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:15 Rn:27 Rt2:10101 imm7:1100110 L:1 1010010:1010010 opc:01
	.inst 0xadcebc51 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:17 Rn:2 Rt2:01111 imm7:0011101 L:1 1011011:1011011 opc:10
	.inst 0xc2c210a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x3, cptr_el3
	orr x3, x3, #0x200
	msr cptr_el3, x3
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
	ldr x3, =initial_cap_values
	.inst 0xc240006e // ldr c14, [x3, #0]
	.inst 0xc2400471 // ldr c17, [x3, #1]
	.inst 0xc240087a // ldr c26, [x3, #2]
	.inst 0xc2400c7b // ldr c27, [x3, #3]
	.inst 0xc240107e // ldr c30, [x3, #4]
	/* Vector registers */
	mrs x3, cptr_el3
	bfc x3, #10, #1
	msr cptr_el3, x3
	isb
	ldr q26, =0x0
	ldr q28, =0x0
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	ldr x3, =0x0
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030a3 // ldr c3, [c5, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x826010a3 // ldr c3, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x5, #0xf
	and x3, x3, x5
	cmp x3, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400065 // ldr c5, [x3, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400465 // ldr c5, [x3, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400865 // ldr c5, [x3, #2]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400c65 // ldr c5, [x3, #3]
	.inst 0xc2c5a5c1 // chkeq c14, c5
	b.ne comparison_fail
	.inst 0xc2401065 // ldr c5, [x3, #4]
	.inst 0xc2c5a5e1 // chkeq c15, c5
	b.ne comparison_fail
	.inst 0xc2401465 // ldr c5, [x3, #5]
	.inst 0xc2c5a621 // chkeq c17, c5
	b.ne comparison_fail
	.inst 0xc2401865 // ldr c5, [x3, #6]
	.inst 0xc2c5a6a1 // chkeq c21, c5
	b.ne comparison_fail
	.inst 0xc2401c65 // ldr c5, [x3, #7]
	.inst 0xc2c5a741 // chkeq c26, c5
	b.ne comparison_fail
	.inst 0xc2402065 // ldr c5, [x3, #8]
	.inst 0xc2c5a761 // chkeq c27, c5
	b.ne comparison_fail
	.inst 0xc2402465 // ldr c5, [x3, #9]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0x0
	mov x5, v15.d[0]
	cmp x3, x5
	b.ne comparison_fail
	ldr x3, =0x0
	mov x5, v15.d[1]
	cmp x3, x5
	b.ne comparison_fail
	ldr x3, =0x0
	mov x5, v17.d[0]
	cmp x3, x5
	b.ne comparison_fail
	ldr x3, =0x0
	mov x5, v17.d[1]
	cmp x3, x5
	b.ne comparison_fail
	ldr x3, =0x0
	mov x5, v26.d[0]
	cmp x3, x5
	b.ne comparison_fail
	ldr x3, =0x0
	mov x5, v26.d[1]
	cmp x3, x5
	b.ne comparison_fail
	ldr x3, =0x0
	mov x5, v28.d[0]
	cmp x3, x5
	b.ne comparison_fail
	ldr x3, =0x0
	mov x5, v28.d[1]
	cmp x3, x5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000015e2
	ldr x1, =check_data0
	ldr x2, =0x000015e4
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001718
	ldr x1, =check_data1
	ldr x2, =0x00001728
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001b7f
	ldr x1, =check_data2
	ldr x2, =0x00001b80
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
	ldr x0, =0x00467008
	ldr x1, =check_data4
	ldr x2, =0x00467010
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00481000
	ldr x1, =check_data5
	ldr x2, =0x00481020
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
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
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

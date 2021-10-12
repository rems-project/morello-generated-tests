.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x40, 0x03, 0x3f, 0xd6
.data
check_data3:
	.byte 0xa0, 0x2c, 0x3a, 0x6d, 0x32, 0x02, 0x11, 0x9a, 0xe0, 0x0b, 0xc1, 0x9a, 0x51, 0x5c, 0x9f, 0xe2
	.byte 0xe0, 0x63, 0x44, 0x4a, 0xe2, 0x27, 0x1e, 0xf2, 0x89, 0xb2, 0x22, 0x2b, 0xe0, 0x73, 0xc2, 0xc2
	.byte 0xc1, 0x67, 0x3e, 0xab, 0x60, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xfcb
	/* C5 */
	.octa 0x40000000000700070000000000002038
	/* C17 */
	.octa 0x0
	/* C26 */
	.octa 0x40002c
final_cap_values:
	/* C1 */
	.octa 0xc0000f
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x40000000000700070000000000002038
	/* C17 */
	.octa 0x0
	/* C26 */
	.octa 0x40002c
	/* C30 */
	.octa 0x20008000000300070000000000400005
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000000107004700ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd63f0340 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:26 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 40
	.inst 0x6d3a2ca0 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:0 Rn:5 Rt2:01011 imm7:1110100 L:0 1011010:1011010 opc:01
	.inst 0x9a110232 // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:18 Rn:17 000000:000000 Rm:17 11010000:11010000 S:0 op:0 sf:1
	.inst 0x9ac10be0 // udiv:aarch64/instrs/integer/arithmetic/div Rd:0 Rn:31 o1:0 00001:00001 Rm:1 0011010110:0011010110 sf:1
	.inst 0xe29f5c51 // ASTUR-C.RI-C Ct:17 Rn:2 op2:11 imm9:111110101 V:0 op1:10 11100010:11100010
	.inst 0x4a4463e0 // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:0 Rn:31 imm6:011000 Rm:4 N:0 shift:01 01010:01010 opc:10 sf:0
	.inst 0xf21e27e2 // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:2 Rn:31 imms:001001 immr:011110 N:0 100100:100100 opc:11 sf:1
	.inst 0x2b22b289 // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:9 Rn:20 imm3:100 option:101 Rm:2 01011001:01011001 S:1 op:0 sf:0
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xab3e67c1 // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:1 Rn:30 imm3:001 option:011 Rm:30 01011001:01011001 S:1 op:0 sf:1
	.inst 0xc2c21160
	.zero 1048492
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x12, cptr_el3
	orr x12, x12, #0x200
	msr cptr_el3, x12
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
	ldr x12, =initial_cap_values
	.inst 0xc2400181 // ldr c1, [x12, #0]
	.inst 0xc2400582 // ldr c2, [x12, #1]
	.inst 0xc2400985 // ldr c5, [x12, #2]
	.inst 0xc2400d91 // ldr c17, [x12, #3]
	.inst 0xc240119a // ldr c26, [x12, #4]
	/* Vector registers */
	mrs x12, cptr_el3
	bfc x12, #10, #1
	msr cptr_el3, x12
	isb
	ldr q0, =0x8000000000
	ldr q11, =0x0
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	ldr x12, =0x4
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x8260316c // ldr c12, [c11, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x8260116c // ldr c12, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	/* Check processor flags */
	mrs x12, nzcv
	ubfx x12, x12, #28, #4
	mov x11, #0xf
	and x12, x12, x11
	cmp x12, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc240018b // ldr c11, [x12, #0]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc240058b // ldr c11, [x12, #1]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc240098b // ldr c11, [x12, #2]
	.inst 0xc2cba4a1 // chkeq c5, c11
	b.ne comparison_fail
	.inst 0xc2400d8b // ldr c11, [x12, #3]
	.inst 0xc2cba621 // chkeq c17, c11
	b.ne comparison_fail
	.inst 0xc240118b // ldr c11, [x12, #4]
	.inst 0xc2cba741 // chkeq c26, c11
	b.ne comparison_fail
	.inst 0xc240158b // ldr c11, [x12, #5]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x12, =0x8000000000
	mov x11, v0.d[0]
	cmp x12, x11
	b.ne comparison_fail
	ldr x12, =0x0
	mov x11, v0.d[1]
	cmp x12, x11
	b.ne comparison_fail
	ldr x12, =0x0
	mov x11, v11.d[0]
	cmp x12, x11
	b.ne comparison_fail
	ldr x12, =0x0
	mov x11, v11.d[1]
	cmp x12, x11
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
	ldr x0, =0x00001fd8
	ldr x1, =check_data1
	ldr x2, =0x00001fe8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400004
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0040002c
	ldr x1, =check_data3
	ldr x2, =0x00400054
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
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
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

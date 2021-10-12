.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x4a, 0x00, 0x50, 0x3c, 0xe1, 0x53, 0xa7, 0xe2, 0xf5, 0x55, 0x57, 0x82, 0x82, 0x18, 0x40, 0x6c
	.byte 0xb5, 0xa9, 0x78, 0xb7, 0xed, 0x03, 0x00, 0xfa, 0x00, 0x08, 0xc0, 0xda, 0x14, 0xa8, 0xfd, 0xc2
	.byte 0xdf, 0xff, 0x7f, 0x42, 0xc2, 0x13, 0xc2, 0xc2
.data
check_data4:
	.byte 0x60, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x800000000003000700000000005000fe
	/* C4 */
	.octa 0x80000000000100050000000000001d28
	/* C15 */
	.octa 0x1c89
	/* C21 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000000100050000000000400040
final_cap_values:
	/* C2 */
	.octa 0x800000000003000700000000005000fe
	/* C4 */
	.octa 0x80000000000100050000000000001d28
	/* C15 */
	.octa 0x1c89
	/* C21 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000000100050000000000400040
initial_SP_EL3_value:
	.octa 0x13c7
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000026000e0000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3c50004a // ldur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:10 Rn:2 00:00 imm9:100000000 0:0 opc:01 111100:111100 size:00
	.inst 0xe2a753e1 // ASTUR-V.RI-S Rt:1 Rn:31 op2:00 imm9:001110101 V:1 op1:10 11100010:11100010
	.inst 0x825755f5 // ASTRB-R.RI-B Rt:21 Rn:15 op:01 imm9:101110101 L:0 1000001001:1000001001
	.inst 0x6c401882 // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:2 Rn:4 Rt2:00110 imm7:0000000 L:1 1011000:1011000 opc:01
	.inst 0xb778a9b5 // tbnz:aarch64/instrs/branch/conditional/test Rt:21 imm14:00010101001101 b40:01111 op:1 011011:011011 b5:1
	.inst 0xfa0003ed // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:13 Rn:31 000000:000000 Rm:0 11010000:11010000 S:1 op:1 sf:1
	.inst 0xdac00800 // rev:aarch64/instrs/integer/arithmetic/rev Rd:0 Rn:0 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2fda814 // ORRFLGS-C.CI-C Cd:20 Cn:0 0:0 01:01 imm8:11101101 11000010111:11000010111
	.inst 0x427fffdf // ALDAR-R.R-32 Rt:31 Rn:30 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xc2c213c2 // BRS-C-C 00010:00010 Cn:30 100:100 opc:00 11000010110000100:11000010110000100
	.zero 24
	.inst 0xc2c21260
	.zero 1048508
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
	.inst 0xc2400222 // ldr c2, [x17, #0]
	.inst 0xc2400624 // ldr c4, [x17, #1]
	.inst 0xc2400a2f // ldr c15, [x17, #2]
	.inst 0xc2400e35 // ldr c21, [x17, #3]
	.inst 0xc240123e // ldr c30, [x17, #4]
	/* Vector registers */
	mrs x17, cptr_el3
	bfc x17, #10, #1
	msr cptr_el3, x17
	isb
	ldr q1, =0x0
	/* Set up flags and system registers */
	mov x17, #0x00000000
	msr nzcv, x17
	ldr x17, =initial_SP_EL3_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2c1d23f // cpy c31, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
	ldr x17, =0x0
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x82603271 // ldr c17, [c19, #3]
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	.inst 0x82601271 // ldr c17, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
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
	.inst 0xc2400233 // ldr c19, [x17, #0]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400633 // ldr c19, [x17, #1]
	.inst 0xc2d3a481 // chkeq c4, c19
	b.ne comparison_fail
	.inst 0xc2400a33 // ldr c19, [x17, #2]
	.inst 0xc2d3a5e1 // chkeq c15, c19
	b.ne comparison_fail
	.inst 0xc2400e33 // ldr c19, [x17, #3]
	.inst 0xc2d3a6a1 // chkeq c21, c19
	b.ne comparison_fail
	.inst 0xc2401233 // ldr c19, [x17, #4]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check vector registers */
	ldr x17, =0x0
	mov x19, v1.d[0]
	cmp x17, x19
	b.ne comparison_fail
	ldr x17, =0x0
	mov x19, v1.d[1]
	cmp x17, x19
	b.ne comparison_fail
	ldr x17, =0x0
	mov x19, v2.d[0]
	cmp x17, x19
	b.ne comparison_fail
	ldr x17, =0x0
	mov x19, v2.d[1]
	cmp x17, x19
	b.ne comparison_fail
	ldr x17, =0x0
	mov x19, v6.d[0]
	cmp x17, x19
	b.ne comparison_fail
	ldr x17, =0x0
	mov x19, v6.d[1]
	cmp x17, x19
	b.ne comparison_fail
	ldr x17, =0x0
	mov x19, v10.d[0]
	cmp x17, x19
	b.ne comparison_fail
	ldr x17, =0x0
	mov x19, v10.d[1]
	cmp x17, x19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000143c
	ldr x1, =check_data0
	ldr x2, =0x00001440
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001d28
	ldr x1, =check_data1
	ldr x2, =0x00001d38
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001dfe
	ldr x1, =check_data2
	ldr x2, =0x00001dff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400028
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400040
	ldr x1, =check_data4
	ldr x2, =0x00400044
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffffe
	ldr x1, =check_data5
	ldr x2, =0x004fffff
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

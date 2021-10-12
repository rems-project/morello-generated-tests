.section data0, #alloc, #write
	.zero 2096
	.byte 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1888
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 80
.data
check_data0:
	.byte 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc1, 0xa7, 0xdd, 0xc2, 0xa2, 0xc0, 0x93, 0xf9, 0xe2, 0x03, 0xc8, 0x78, 0x21, 0x10, 0xc2, 0xc2
	.byte 0xe5, 0x52, 0xc0, 0xc2, 0xe0, 0x33, 0xc5, 0xc2, 0x6c, 0x0f, 0xd8, 0xe2, 0xbe, 0x46, 0xe5, 0x2d
	.byte 0xe2, 0x0a, 0xc0, 0xda, 0xe6, 0x1b, 0x5a, 0xfa, 0xc0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C21 */
	.octa 0x800000004000000200000000004000e0
	/* C27 */
	.octa 0x2020
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0xffffffffffffffffffffffffffffffff
final_cap_values:
	/* C0 */
	.octa 0x17b0
	/* C1 */
	.octa 0x0
	/* C12 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C21 */
	.octa 0x80000000400000020000000000400008
	/* C27 */
	.octa 0x2020
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0xffffffffffffffffffffffffffffffff
initial_SP_EL3_value:
	.octa 0x800000000001000500000000000017b0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80100000000080080000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2dda7c1 // CHKEQ-_.CC-C 00001:00001 Cn:30 001:001 opc:01 1:1 Cm:29 11000010110:11000010110
	.inst 0xf993c0a2 // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:5 imm12:010011110000 opc:10 111001:111001 size:11
	.inst 0x78c803e2 // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:31 00:00 imm9:010000000 0:0 opc:11 111000:111000 size:01
	.inst 0xc2c21021 // CHKSLD-C-C 00001:00001 Cn:1 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xc2c052e5 // GCVALUE-R.C-C Rd:5 Cn:23 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0xc2c533e0 // CVTP-R.C-C Rd:0 Cn:31 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0xe2d80f6c // ALDUR-C.RI-C Ct:12 Rn:27 op2:11 imm9:110000000 V:0 op1:11 11100010:11100010
	.inst 0x2de546be // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:30 Rn:21 Rt2:10001 imm7:1001010 L:1 1011011:1011011 opc:00
	.inst 0xdac00ae2 // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:2 Rn:23 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xfa5a1be6 // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0110 0:0 Rn:31 10:10 cond:0001 imm5:11010 111010010:111010010 op:1 sf:1
	.inst 0xc2c212c0
	.zero 1048532
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
	.inst 0xc2400221 // ldr c1, [x17, #0]
	.inst 0xc2400635 // ldr c21, [x17, #1]
	.inst 0xc2400a3b // ldr c27, [x17, #2]
	.inst 0xc2400e3d // ldr c29, [x17, #3]
	.inst 0xc240123e // ldr c30, [x17, #4]
	/* Set up flags and system registers */
	mov x17, #0x00000000
	msr nzcv, x17
	ldr x17, =initial_SP_EL3_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2c1d23f // cpy c31, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30850038
	msr SCTLR_EL3, x17
	ldr x17, =0xc
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032d1 // ldr c17, [c22, #3]
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	.inst 0x826012d1 // ldr c17, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c21220 // br c17
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	/* Check processor flags */
	mrs x17, nzcv
	ubfx x17, x17, #28, #4
	mov x22, #0xf
	and x17, x17, x22
	cmp x17, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400236 // ldr c22, [x17, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400636 // ldr c22, [x17, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400a36 // ldr c22, [x17, #2]
	.inst 0xc2d6a581 // chkeq c12, c22
	b.ne comparison_fail
	.inst 0xc2400e36 // ldr c22, [x17, #3]
	.inst 0xc2d6a6a1 // chkeq c21, c22
	b.ne comparison_fail
	.inst 0xc2401236 // ldr c22, [x17, #4]
	.inst 0xc2d6a761 // chkeq c27, c22
	b.ne comparison_fail
	.inst 0xc2401636 // ldr c22, [x17, #5]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc2401a36 // ldr c22, [x17, #6]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x17, =0xc2c21021
	mov x22, v17.d[0]
	cmp x17, x22
	b.ne comparison_fail
	ldr x17, =0x0
	mov x22, v17.d[1]
	cmp x17, x22
	b.ne comparison_fail
	ldr x17, =0x78c803e2
	mov x22, v30.d[0]
	cmp x17, x22
	b.ne comparison_fail
	ldr x17, =0x0
	mov x22, v30.d[1]
	cmp x17, x22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001830
	ldr x1, =check_data0
	ldr x2, =0x00001832
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001fa0
	ldr x1, =check_data1
	ldr x2, =0x00001fb0
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

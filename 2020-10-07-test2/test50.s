.section data0, #alloc, #write
	.zero 1120
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x10, 0x00, 0x00, 0x00
	.zero 2960
.data
check_data0:
	.byte 0x00, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x10, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 32
.data
check_data3:
	.byte 0x25, 0x40, 0xc0, 0xe2, 0xec, 0x2f, 0x37, 0xeb, 0xbe, 0xb8, 0x62, 0x62, 0xd6, 0x2f, 0xdf, 0x1a
	.byte 0x1c, 0x10, 0xc7, 0xc2, 0x80, 0xfd, 0x7f, 0x42, 0x40, 0x80, 0x26, 0x9b, 0x21, 0xb3, 0xc0, 0xc2
	.byte 0xe1, 0x33, 0x65, 0xad, 0x5f, 0x9f, 0xdd, 0xb0, 0xe0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xffc
	/* C5 */
	.octa 0x90000000000300050000000000001800
	/* C23 */
	.octa 0x102
	/* C25 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0x90000000000300050000000000001800
	/* C12 */
	.octa 0x1000
	/* C14 */
	.octa 0x10800000000000000000000000
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x102
	/* C25 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x800000000007000f0000000000001810
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000004001000800ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001460
	.dword initial_cap_values + 32
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2c04025 // ASTUR-R.RI-64 Rt:5 Rn:1 op2:00 imm9:000000100 V:0 op1:11 11100010:11100010
	.inst 0xeb372fec // subs_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:12 Rn:31 imm3:011 option:001 Rm:23 01011001:01011001 S:1 op:1 sf:1
	.inst 0x6262b8be // LDNP-C.RIB-C Ct:30 Rn:5 Ct2:01110 imm7:1000101 L:1 011000100:011000100
	.inst 0x1adf2fd6 // rorv:aarch64/instrs/integer/shift/variable Rd:22 Rn:30 op2:11 0010:0010 Rm:31 0011010110:0011010110 sf:0
	.inst 0xc2c7101c // RRLEN-R.R-C Rd:28 Rn:0 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x427ffd80 // ALDAR-R.R-32 Rt:0 Rn:12 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x9b268040 // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:0 Rn:2 Ra:0 o0:1 Rm:6 01:01 U:0 10011011:10011011
	.inst 0xc2c0b321 // GCSEAL-R.C-C Rd:1 Cn:25 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xad6533e1 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:1 Rn:31 Rt2:01100 imm7:1001010 L:1 1011010:1011010 opc:10
	.inst 0xb0dd9f5f // ADRP-C.IP-C Rd:31 immhi:101110110011111010 P:1 10000:10000 immlo:01 op:1
	.inst 0xc2c210e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x24, cptr_el3
	orr x24, x24, #0x200
	msr cptr_el3, x24
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
	ldr x24, =initial_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400701 // ldr c1, [x24, #1]
	.inst 0xc2400b05 // ldr c5, [x24, #2]
	.inst 0xc2400f17 // ldr c23, [x24, #3]
	.inst 0xc2401319 // ldr c25, [x24, #4]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =initial_SP_EL3_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2c1d31f // cpy c31, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30850038
	msr SCTLR_EL3, x24
	ldr x24, =0x0
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030f8 // ldr c24, [c7, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x826010f8 // ldr c24, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	/* Check processor flags */
	mrs x24, nzcv
	ubfx x24, x24, #28, #4
	mov x7, #0xf
	and x24, x24, x7
	cmp x24, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400307 // ldr c7, [x24, #0]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400707 // ldr c7, [x24, #1]
	.inst 0xc2c7a4a1 // chkeq c5, c7
	b.ne comparison_fail
	.inst 0xc2400b07 // ldr c7, [x24, #2]
	.inst 0xc2c7a581 // chkeq c12, c7
	b.ne comparison_fail
	.inst 0xc2400f07 // ldr c7, [x24, #3]
	.inst 0xc2c7a5c1 // chkeq c14, c7
	b.ne comparison_fail
	.inst 0xc2401307 // ldr c7, [x24, #4]
	.inst 0xc2c7a6c1 // chkeq c22, c7
	b.ne comparison_fail
	.inst 0xc2401707 // ldr c7, [x24, #5]
	.inst 0xc2c7a6e1 // chkeq c23, c7
	b.ne comparison_fail
	.inst 0xc2401b07 // ldr c7, [x24, #6]
	.inst 0xc2c7a721 // chkeq c25, c7
	b.ne comparison_fail
	.inst 0xc2401f07 // ldr c7, [x24, #7]
	.inst 0xc2c7a781 // chkeq c28, c7
	b.ne comparison_fail
	.inst 0xc2402307 // ldr c7, [x24, #8]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0x0
	mov x7, v1.d[0]
	cmp x24, x7
	b.ne comparison_fail
	ldr x24, =0x0
	mov x7, v1.d[1]
	cmp x24, x7
	b.ne comparison_fail
	ldr x24, =0x0
	mov x7, v12.d[0]
	cmp x24, x7
	b.ne comparison_fail
	ldr x24, =0x0
	mov x7, v12.d[1]
	cmp x24, x7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001450
	ldr x1, =check_data1
	ldr x2, =0x00001470
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000014b0
	ldr x1, =check_data2
	ldr x2, =0x000014d0
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
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
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

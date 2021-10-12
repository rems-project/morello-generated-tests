.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00
.data
check_data1:
	.zero 32
.data
check_data2:
	.byte 0x40, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 32
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0x93, 0x08, 0xdf, 0xc2, 0x58, 0x7c, 0xd2, 0x9b, 0xda, 0x02, 0xc0, 0x5a, 0xa2, 0x1a, 0x58, 0xac
	.byte 0x41, 0x50, 0xc1, 0xc2, 0xa4, 0xd9, 0x15, 0x29, 0xd8, 0xf3, 0x1a, 0xa9, 0xf5, 0xb0, 0x39, 0xf2
	.byte 0xfb, 0x0f, 0xf8, 0xac, 0xde, 0x4f, 0x57, 0x82, 0x40, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C13 */
	.octa 0x400000000081c0050000000000001f18
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x80000000600201120000000000001240
	/* C22 */
	.octa 0x0
	/* C28 */
	.octa 0x40000000000
	/* C30 */
	.octa 0x40000000400100f90000000000000f40
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C13 */
	.octa 0x400000000081c0050000000000001f18
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x40000000000
	/* C30 */
	.octa 0x40000000400100f90000000000000f40
initial_SP_EL3_value:
	.octa 0x80000000000100070000000000001f60
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004400c4010000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x4000000063e1000000ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 128
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 192
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2df0893 // SEAL-C.CC-C Cd:19 Cn:4 0010:0010 opc:00 Cm:31 11000010110:11000010110
	.inst 0x9bd27c58 // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:24 Rn:2 Ra:11111 0:0 Rm:18 10:10 U:1 10011011:10011011
	.inst 0x5ac002da // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:26 Rn:22 101101011000000000000:101101011000000000000 sf:0
	.inst 0xac581aa2 // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:2 Rn:21 Rt2:00110 imm7:0110000 L:1 1011000:1011000 opc:10
	.inst 0xc2c15041 // CFHI-R.C-C Rd:1 Cn:2 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0x2915d9a4 // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:4 Rn:13 Rt2:10110 imm7:0101011 L:0 1010010:1010010 opc:00
	.inst 0xa91af3d8 // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:24 Rn:30 Rt2:11100 imm7:0110101 L:0 1010010:1010010 opc:10
	.inst 0xf239b0f5 // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:21 Rn:7 imms:101100 immr:111001 N:0 100100:100100 opc:11 sf:1
	.inst 0xacf80ffb // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:27 Rn:31 Rt2:00011 imm7:1110000 L:1 1011001:1011001 opc:10
	.inst 0x82574fde // ASTR-R.RI-64 Rt:30 Rn:30 op:11 imm9:101110100 L:0 1000001001:1000001001
	.inst 0xc2c21140
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x27, cptr_el3
	orr x27, x27, #0x200
	msr cptr_el3, x27
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
	ldr x27, =initial_cap_values
	.inst 0xc2400362 // ldr c2, [x27, #0]
	.inst 0xc2400764 // ldr c4, [x27, #1]
	.inst 0xc2400b67 // ldr c7, [x27, #2]
	.inst 0xc2400f6d // ldr c13, [x27, #3]
	.inst 0xc2401372 // ldr c18, [x27, #4]
	.inst 0xc2401775 // ldr c21, [x27, #5]
	.inst 0xc2401b76 // ldr c22, [x27, #6]
	.inst 0xc2401f7c // ldr c28, [x27, #7]
	.inst 0xc240237e // ldr c30, [x27, #8]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =initial_SP_EL3_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2c1d37f // cpy c31, c27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
	ldr x27, =0x4
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x8260315b // ldr c27, [c10, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x8260115b // ldr c27, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	/* Check processor flags */
	mrs x27, nzcv
	ubfx x27, x27, #28, #4
	mov x10, #0xf
	and x27, x27, x10
	cmp x27, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc240036a // ldr c10, [x27, #0]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc240076a // ldr c10, [x27, #1]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400b6a // ldr c10, [x27, #2]
	.inst 0xc2caa481 // chkeq c4, c10
	b.ne comparison_fail
	.inst 0xc2400f6a // ldr c10, [x27, #3]
	.inst 0xc2caa4e1 // chkeq c7, c10
	b.ne comparison_fail
	.inst 0xc240136a // ldr c10, [x27, #4]
	.inst 0xc2caa5a1 // chkeq c13, c10
	b.ne comparison_fail
	.inst 0xc240176a // ldr c10, [x27, #5]
	.inst 0xc2caa641 // chkeq c18, c10
	b.ne comparison_fail
	.inst 0xc2401b6a // ldr c10, [x27, #6]
	.inst 0xc2caa661 // chkeq c19, c10
	b.ne comparison_fail
	.inst 0xc2401f6a // ldr c10, [x27, #7]
	.inst 0xc2caa6a1 // chkeq c21, c10
	b.ne comparison_fail
	.inst 0xc240236a // ldr c10, [x27, #8]
	.inst 0xc2caa6c1 // chkeq c22, c10
	b.ne comparison_fail
	.inst 0xc240276a // ldr c10, [x27, #9]
	.inst 0xc2caa701 // chkeq c24, c10
	b.ne comparison_fail
	.inst 0xc2402b6a // ldr c10, [x27, #10]
	.inst 0xc2caa741 // chkeq c26, c10
	b.ne comparison_fail
	.inst 0xc2402f6a // ldr c10, [x27, #11]
	.inst 0xc2caa781 // chkeq c28, c10
	b.ne comparison_fail
	.inst 0xc240336a // ldr c10, [x27, #12]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x27, =0x0
	mov x10, v2.d[0]
	cmp x27, x10
	b.ne comparison_fail
	ldr x27, =0x0
	mov x10, v2.d[1]
	cmp x27, x10
	b.ne comparison_fail
	ldr x27, =0x0
	mov x10, v3.d[0]
	cmp x27, x10
	b.ne comparison_fail
	ldr x27, =0x0
	mov x10, v3.d[1]
	cmp x27, x10
	b.ne comparison_fail
	ldr x27, =0x0
	mov x10, v6.d[0]
	cmp x27, x10
	b.ne comparison_fail
	ldr x27, =0x0
	mov x10, v6.d[1]
	cmp x27, x10
	b.ne comparison_fail
	ldr x27, =0x0
	mov x10, v27.d[0]
	cmp x27, x10
	b.ne comparison_fail
	ldr x27, =0x0
	mov x10, v27.d[1]
	cmp x27, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010e8
	ldr x1, =check_data0
	ldr x2, =0x000010f8
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001540
	ldr x1, =check_data1
	ldr x2, =0x00001560
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ae0
	ldr x1, =check_data2
	ldr x2, =0x00001ae8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f60
	ldr x1, =check_data3
	ldr x2, =0x00001f80
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fc4
	ldr x1, =check_data4
	ldr x2, =0x00001fcc
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
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
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

.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x22, 0xcf, 0xd4, 0x3c, 0x3f, 0x00, 0xdf, 0xc2, 0x4e, 0xfe, 0x9f, 0x48, 0xc1, 0xff, 0x7f, 0x42
	.byte 0x6c, 0x28, 0xd1, 0x9a, 0x3f, 0x24, 0xca, 0xc2, 0x71, 0x2c, 0xd7, 0x1a, 0x5f, 0x00, 0xc0, 0xda
	.byte 0x20, 0xb4, 0xd7, 0x79, 0x3e, 0x40, 0xc0, 0xc2, 0x80, 0x12, 0xc2, 0xc2
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0x00, 0x08, 0x00, 0x00
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc00000000000000000000000
	/* C10 */
	.octa 0x3fff800000000000000000000000
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0x1000
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x500004
	/* C30 */
	.octa 0x800000000001000500000000004ffff8
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x800
	/* C10 */
	.octa 0x3fff800000000000000000000000
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0x1000
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x4fff50
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004c0400000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000180060080000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3cd4cf22 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:2 Rn:25 11:11 imm9:101001100 0:0 opc:11 111100:111100 size:00
	.inst 0xc2df003f // SCBNDS-C.CR-C Cd:31 Cn:1 000:000 opc:00 0:0 Rm:31 11000010110:11000010110
	.inst 0x489ffe4e // stlrh:aarch64/instrs/memory/ordered Rt:14 Rn:18 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x427fffc1 // ALDAR-R.R-32 Rt:1 Rn:30 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x9ad1286c // asrv:aarch64/instrs/integer/shift/variable Rd:12 Rn:3 op2:10 0010:0010 Rm:17 0011010110:0011010110 sf:1
	.inst 0xc2ca243f // CPYTYPE-C.C-C Cd:31 Cn:1 001:001 opc:01 0:0 Cm:10 11000010110:11000010110
	.inst 0x1ad72c71 // rorv:aarch64/instrs/integer/shift/variable Rd:17 Rn:3 op2:11 0010:0010 Rm:23 0011010110:0011010110 sf:0
	.inst 0xdac0005f // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:31 Rn:2 101101011000000000000:101101011000000000000 sf:1
	.inst 0x79d7b420 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:1 imm12:010111101101 opc:11 111001:111001 size:01
	.inst 0xc2c0403e // SCVALUE-C.CR-C Cd:30 Cn:1 000:000 opc:10 0:0 Rm:0 11000010110:11000010110
	.inst 0xc2c21280
	.zero 1048524
	.inst 0x00000800
	.zero 4
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
	.inst 0xc24000c1 // ldr c1, [x6, #0]
	.inst 0xc24004ca // ldr c10, [x6, #1]
	.inst 0xc24008ce // ldr c14, [x6, #2]
	.inst 0xc2400cd2 // ldr c18, [x6, #3]
	.inst 0xc24010d7 // ldr c23, [x6, #4]
	.inst 0xc24014d9 // ldr c25, [x6, #5]
	.inst 0xc24018de // ldr c30, [x6, #6]
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
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82603286 // ldr c6, [c20, #3]
	.inst 0xc28b4126 // msr ddc_el3, c6
	isb
	.inst 0x82601286 // ldr c6, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr ddc_el3, c6
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000d4 // ldr c20, [x6, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc24004d4 // ldr c20, [x6, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc24008d4 // ldr c20, [x6, #2]
	.inst 0xc2d4a541 // chkeq c10, c20
	b.ne comparison_fail
	.inst 0xc2400cd4 // ldr c20, [x6, #3]
	.inst 0xc2d4a5c1 // chkeq c14, c20
	b.ne comparison_fail
	.inst 0xc24010d4 // ldr c20, [x6, #4]
	.inst 0xc2d4a641 // chkeq c18, c20
	b.ne comparison_fail
	.inst 0xc24014d4 // ldr c20, [x6, #5]
	.inst 0xc2d4a6e1 // chkeq c23, c20
	b.ne comparison_fail
	.inst 0xc24018d4 // ldr c20, [x6, #6]
	.inst 0xc2d4a721 // chkeq c25, c20
	b.ne comparison_fail
	.inst 0xc2401cd4 // ldr c20, [x6, #7]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x20, v2.d[0]
	cmp x6, x20
	b.ne comparison_fail
	ldr x6, =0x0
	mov x20, v2.d[1]
	cmp x6, x20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000013da
	ldr x1, =check_data1
	ldr x2, =0x000013dc
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
	ldr x0, =0x004fff50
	ldr x1, =check_data3
	ldr x2, =0x004fff60
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004ffff8
	ldr x1, =check_data4
	ldr x2, =0x004ffffc
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

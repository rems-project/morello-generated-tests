.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 32
.data
check_data1:
	.byte 0x80, 0x00
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0xeb, 0xd7, 0x81, 0xda, 0x29, 0xf8, 0x7d, 0xac, 0x93, 0x72, 0xc0, 0xc2, 0x21, 0xc0, 0x0d, 0x78
	.byte 0xc6, 0x07, 0x22, 0x9b, 0x5f, 0xfc, 0x9f, 0x88, 0x82, 0x0e, 0xc0, 0xda, 0x5f, 0x08, 0xc0, 0xda
	.byte 0x3e, 0x3a, 0xdc, 0xc2, 0x57, 0x64, 0x3f, 0x6a, 0x40, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x80
	/* C2 */
	.octa 0x400
	/* C17 */
	.octa 0x400000000000000000000000
	/* C20 */
	.octa 0x400000008008010800000000
final_cap_values:
	/* C1 */
	.octa 0x80
	/* C2 */
	.octa 0x8010880
	/* C11 */
	.octa 0x0
	/* C17 */
	.octa 0x400000000000000000000000
	/* C19 */
	.octa 0x8000000000000000
	/* C20 */
	.octa 0x400000008008010800000000
	/* C23 */
	.octa 0x8010880
	/* C30 */
	.octa 0x403800000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000004001100000ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xda81d7eb // csneg:aarch64/instrs/integer/conditional/select Rd:11 Rn:31 o2:1 0:0 cond:1101 Rm:1 011010100:011010100 op:1 sf:1
	.inst 0xac7df829 // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:9 Rn:1 Rt2:11110 imm7:1111011 L:1 1011000:1011000 opc:10
	.inst 0xc2c07293 // GCOFF-R.C-C Rd:19 Cn:20 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0x780dc021 // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:1 00:00 imm9:011011100 0:0 opc:00 111000:111000 size:01
	.inst 0x9b2207c6 // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:6 Rn:30 Ra:1 o0:0 Rm:2 01:01 U:0 10011011:10011011
	.inst 0x889ffc5f // stlr:aarch64/instrs/memory/ordered Rt:31 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0xdac00e82 // rev:aarch64/instrs/integer/arithmetic/rev Rd:2 Rn:20 opc:11 1011010110000000000:1011010110000000000 sf:1
	.inst 0xdac0085f // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:31 Rn:2 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2dc3a3e // SCBNDS-C.CI-C Cd:30 Cn:17 1110:1110 S:0 imm6:111000 11000010110:11000010110
	.inst 0x6a3f6457 // bics:aarch64/instrs/integer/logical/shiftedreg Rd:23 Rn:2 imm6:011001 Rm:31 N:1 shift:00 01010:01010 opc:11 sf:0
	.inst 0xc2c21340
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x14, cptr_el3
	orr x14, x14, #0x200
	msr cptr_el3, x14
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c1 // ldr c1, [x14, #0]
	.inst 0xc24005c2 // ldr c2, [x14, #1]
	.inst 0xc24009d1 // ldr c17, [x14, #2]
	.inst 0xc2400dd4 // ldr c20, [x14, #3]
	/* Set up flags and system registers */
	mov x14, #0x80000000
	msr nzcv, x14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30850032
	msr SCTLR_EL3, x14
	ldr x14, =0x4
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x8260334e // ldr c14, [c26, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x8260134e // ldr c14, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x26, #0xf
	and x14, x14, x26
	cmp x14, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001da // ldr c26, [x14, #0]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc24005da // ldr c26, [x14, #1]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc24009da // ldr c26, [x14, #2]
	.inst 0xc2daa561 // chkeq c11, c26
	b.ne comparison_fail
	.inst 0xc2400dda // ldr c26, [x14, #3]
	.inst 0xc2daa621 // chkeq c17, c26
	b.ne comparison_fail
	.inst 0xc24011da // ldr c26, [x14, #4]
	.inst 0xc2daa661 // chkeq c19, c26
	b.ne comparison_fail
	.inst 0xc24015da // ldr c26, [x14, #5]
	.inst 0xc2daa681 // chkeq c20, c26
	b.ne comparison_fail
	.inst 0xc24019da // ldr c26, [x14, #6]
	.inst 0xc2daa6e1 // chkeq c23, c26
	b.ne comparison_fail
	.inst 0xc2401dda // ldr c26, [x14, #7]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0x0
	mov x26, v9.d[0]
	cmp x14, x26
	b.ne comparison_fail
	ldr x14, =0x0
	mov x26, v9.d[1]
	cmp x14, x26
	b.ne comparison_fail
	ldr x14, =0x0
	mov x26, v30.d[0]
	cmp x14, x26
	b.ne comparison_fail
	ldr x14, =0x0
	mov x26, v30.d[1]
	cmp x14, x26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001030
	ldr x1, =check_data0
	ldr x2, =0x00001050
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000115c
	ldr x1, =check_data1
	ldr x2, =0x0000115e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001400
	ldr x1, =check_data2
	ldr x2, =0x00001404
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
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
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

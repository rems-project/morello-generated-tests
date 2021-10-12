.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x04, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0xa0, 0xff, 0x9f, 0x48, 0xf4, 0xff, 0x5f, 0x42, 0x21, 0x78, 0xde, 0xea, 0xa5, 0x7f, 0xdf, 0x9b
	.byte 0xa0, 0xd3, 0xc0, 0xc2, 0xc1, 0x51, 0x53, 0x82, 0xcb, 0xb0, 0x84, 0x3c, 0xdf, 0x13, 0x2d, 0x78
	.byte 0x5e, 0x91, 0xc5, 0xc2, 0xd6, 0x07, 0xc0, 0xc2, 0x20, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C6 */
	.octa 0x40000000400000400000000000000fd5
	/* C10 */
	.octa 0xf83fc003000001
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C29 */
	.octa 0x40000000000000000000000000001000
	/* C30 */
	.octa 0xc000000020820001000000000000102c
final_cap_values:
	/* C0 */
	.octa 0x10000
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x40000000400000400000000000000fd5
	/* C10 */
	.octa 0xf83fc003000001
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C20 */
	.octa 0x9bdf7fa5eade7821425ffff4489fffa0
	/* C22 */
	.octa 0x400000001827000700f83fc003000001
	/* C29 */
	.octa 0x40000000000000000000000000001000
	/* C30 */
	.octa 0x400000001827000700f83fc003000001
initial_SP_EL3_value:
	.octa 0x90100000000b00070000000000400000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000004700060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000182700070000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 48
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x489fffa0 // stlrh:aarch64/instrs/memory/ordered Rt:0 Rn:29 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x425ffff4 // LDAR-C.R-C Ct:20 Rn:31 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xeade7821 // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:1 imm6:011110 Rm:30 N:0 shift:11 01010:01010 opc:11 sf:1
	.inst 0x9bdf7fa5 // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:5 Rn:29 Ra:11111 0:0 Rm:31 10:10 U:1 10011011:10011011
	.inst 0xc2c0d3a0 // GCPERM-R.C-C Rd:0 Cn:29 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0x825351c1 // ASTR-C.RI-C Ct:1 Rn:14 op:00 imm9:100110101 L:0 1000001001:1000001001
	.inst 0x3c84b0cb // stur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:11 Rn:6 00:00 imm9:001001011 0:0 opc:10 111100:111100 size:00
	.inst 0x782d13df // stclrh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:001 o3:0 Rs:13 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c5915e // CVTD-C.R-C Cd:30 Rn:10 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0xc2c007d6 // BUILD-C.C-C Cd:22 Cn:30 001:001 opc:00 0:0 Cm:0 11000010110:11000010110
	.inst 0xc2c21320
	.zero 1048532
.text
.global preamble
preamble:
	/* Ensure Morello is on */
	mov x0, 0x200
	msr cptr_el3, x0
	isb
	/* Set exception handler */
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	mov x0, #0xff
	msr mair_el3, x0
	ldr x0, =0x0d001519
	msr tcr_el3, x0
	isb
	tlbi alle3
	dsb sy
	isb
	/* Write tags to memory */
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400601 // ldr c1, [x16, #1]
	.inst 0xc2400a06 // ldr c6, [x16, #2]
	.inst 0xc2400e0a // ldr c10, [x16, #3]
	.inst 0xc240120d // ldr c13, [x16, #4]
	.inst 0xc240160e // ldr c14, [x16, #5]
	.inst 0xc2401a1d // ldr c29, [x16, #6]
	.inst 0xc2401e1e // ldr c30, [x16, #7]
	/* Vector registers */
	mrs x16, cptr_el3
	bfc x16, #10, #1
	msr cptr_el3, x16
	isb
	ldr q11, =0x41000000000000000000000
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =initial_SP_EL3_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2c1d21f // cpy c31, c16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x3085103d
	msr SCTLR_EL3, x16
	ldr x16, =0x4
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82603330 // ldr c16, [c25, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x82601330 // ldr c16, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	isb
	/* Check processor flags */
	mrs x16, nzcv
	ubfx x16, x16, #28, #4
	mov x25, #0xf
	and x16, x16, x25
	cmp x16, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400219 // ldr c25, [x16, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc2400619 // ldr c25, [x16, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400a19 // ldr c25, [x16, #2]
	.inst 0xc2d9a4a1 // chkeq c5, c25
	b.ne comparison_fail
	.inst 0xc2400e19 // ldr c25, [x16, #3]
	.inst 0xc2d9a4c1 // chkeq c6, c25
	b.ne comparison_fail
	.inst 0xc2401219 // ldr c25, [x16, #4]
	.inst 0xc2d9a541 // chkeq c10, c25
	b.ne comparison_fail
	.inst 0xc2401619 // ldr c25, [x16, #5]
	.inst 0xc2d9a5a1 // chkeq c13, c25
	b.ne comparison_fail
	.inst 0xc2401a19 // ldr c25, [x16, #6]
	.inst 0xc2d9a5c1 // chkeq c14, c25
	b.ne comparison_fail
	.inst 0xc2401e19 // ldr c25, [x16, #7]
	.inst 0xc2d9a681 // chkeq c20, c25
	b.ne comparison_fail
	.inst 0xc2402219 // ldr c25, [x16, #8]
	.inst 0xc2d9a6c1 // chkeq c22, c25
	b.ne comparison_fail
	.inst 0xc2402619 // ldr c25, [x16, #9]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc2402a19 // ldr c25, [x16, #10]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x0
	mov x25, v11.d[0]
	cmp x16, x25
	b.ne comparison_fail
	ldr x16, =0x4100000
	mov x25, v11.d[1]
	cmp x16, x25
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001030
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001350
	ldr x1, =check_data2
	ldr x2, =0x00001360
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
	/* Done print message */
	/* turn off MMU */
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
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

.section vector_table, #alloc, #execinstr
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

	/* Translation table, single entry, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000701
	.fill 4088, 1, 0

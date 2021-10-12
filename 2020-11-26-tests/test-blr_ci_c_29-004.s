.section data0, #alloc, #write
	.zero 16
	.byte 0x18, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x12, 0xe0, 0x00, 0x50, 0x00, 0x80, 0x00, 0x20
	.zero 4064
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x18, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x12, 0xe0, 0x00, 0x50, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.byte 0x40, 0x21, 0x7a, 0xac, 0x3e, 0x9a, 0xff, 0xc2, 0xc0, 0x2f, 0x2b, 0x02, 0xca, 0x58, 0xe1, 0xc2
	.byte 0xcc, 0x76, 0x21, 0x9b, 0xa1, 0x33, 0xd0, 0xc2, 0x1e, 0x7c, 0x5f, 0x08, 0xa0, 0x1b, 0xa0, 0x9b
	.byte 0x2c, 0x48, 0xc1, 0xc2, 0xbf, 0x23, 0x61, 0xb8, 0x60, 0x11, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x4000800000000000000100000000
	/* C6 */
	.octa 0x40000000000000000
	/* C10 */
	.octa 0x800000005000000100000000004000d0
	/* C17 */
	.octa 0x403533
	/* C29 */
	.octa 0x90100001800100050000000000001000
final_cap_values:
	/* C0 */
	.octa 0x403ffe000
	/* C1 */
	.octa 0x4000800000000000000100000000
	/* C6 */
	.octa 0x40000000000000000
	/* C10 */
	.octa 0x40000000100000000
	/* C12 */
	.octa 0x4000000000000000000100000000
	/* C17 */
	.octa 0x403533
	/* C29 */
	.octa 0x90100000000100050000000000001000
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000080080000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 16
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xac7a2140 // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:0 Rn:10 Rt2:01000 imm7:1110100 L:1 1011000:1011000 opc:10
	.inst 0xc2ff9a3e // SUBS-R.CC-C Rd:30 Cn:17 100110:100110 Cm:31 11000010111:11000010111
	.inst 0x022b2fc0 // ADD-C.CIS-C Cd:0 Cn:30 imm12:101011001011 sh:0 A:0 00000010:00000010
	.inst 0xc2e158ca // CVTZ-C.CR-C Cd:10 Cn:6 0110:0110 1:1 0:0 Rm:1 11000010111:11000010111
	.inst 0x9b2176cc // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:12 Rn:22 Ra:29 o0:0 Rm:1 01:01 U:0 10011011:10011011
	.inst 0xc2d033a1 // 0xc2d033a1
	.inst 0x085f7c1e // ldxrb:aarch64/instrs/memory/exclusive/single Rt:30 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0x9ba01ba0 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:0 Rn:29 Ra:6 o0:0 Rm:0 01:01 U:1 10011011:10011011
	.inst 0xc2c1482c // UNSEAL-C.CC-C Cd:12 Cn:1 0010:0010 opc:01 Cm:1 11000010110:11000010110
	.inst 0xb86123bf // steor:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:010 o3:0 Rs:1 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0xc2c21160
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
	ldr x19, =initial_cap_values
	.inst 0xc2400261 // ldr c1, [x19, #0]
	.inst 0xc2400666 // ldr c6, [x19, #1]
	.inst 0xc2400a6a // ldr c10, [x19, #2]
	.inst 0xc2400e71 // ldr c17, [x19, #3]
	.inst 0xc240127d // ldr c29, [x19, #4]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30851037
	msr SCTLR_EL3, x19
	ldr x19, =0x80
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82603173 // ldr c19, [c11, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x82601173 // ldr c19, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x11, #0xf
	and x19, x19, x11
	cmp x19, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc240026b // ldr c11, [x19, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc240066b // ldr c11, [x19, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc2400a6b // ldr c11, [x19, #2]
	.inst 0xc2cba4c1 // chkeq c6, c11
	b.ne comparison_fail
	.inst 0xc2400e6b // ldr c11, [x19, #3]
	.inst 0xc2cba541 // chkeq c10, c11
	b.ne comparison_fail
	.inst 0xc240126b // ldr c11, [x19, #4]
	.inst 0xc2cba581 // chkeq c12, c11
	b.ne comparison_fail
	.inst 0xc240166b // ldr c11, [x19, #5]
	.inst 0xc2cba621 // chkeq c17, c11
	b.ne comparison_fail
	.inst 0xc2401a6b // ldr c11, [x19, #6]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	.inst 0xc2401e6b // ldr c11, [x19, #7]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0xc2d033a19b2176cc
	mov x11, v0.d[0]
	cmp x19, x11
	b.ne comparison_fail
	ldr x19, =0x9ba01ba0085f7c1e
	mov x11, v0.d[1]
	cmp x19, x11
	b.ne comparison_fail
	ldr x19, =0xb86123bfc2c1482c
	mov x11, v8.d[0]
	cmp x19, x11
	b.ne comparison_fail
	ldr x19, =0xc2c21160
	mov x11, v8.d[1]
	cmp x19, x11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001020
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400030
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00403ffe
	ldr x1, =check_data3
	ldr x2, =0x00403fff
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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

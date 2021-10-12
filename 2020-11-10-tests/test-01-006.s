.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x9e, 0x9a, 0xe4, 0xc2, 0x61, 0x2e, 0xdf, 0x9a, 0xa7, 0xe9, 0x21, 0x9b, 0xa1, 0xff, 0x3f, 0x42
	.byte 0xe2, 0xd2, 0xc1, 0xc2, 0x08, 0x28, 0x4f, 0x28, 0x80, 0xf1, 0xc5, 0xc2, 0x9f, 0x20, 0xc0, 0x9a
	.byte 0x9f, 0x72, 0x7e, 0xf8, 0xe1, 0x99, 0xf8, 0xc2, 0xc0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000001f04
	/* C4 */
	.octa 0x0
	/* C12 */
	.octa 0x80000000300000
	/* C15 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C20 */
	.octa 0xc0000000000100050000000000001ff0
	/* C24 */
	.octa 0x0
	/* C29 */
	.octa 0x1df0
final_cap_values:
	/* C0 */
	.octa 0x20008000200620070080000000500000
	/* C1 */
	.octa 0x1
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x80000000300000
	/* C15 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C20 */
	.octa 0xc0000000000100050000000000001ff0
	/* C24 */
	.octa 0x0
	/* C29 */
	.octa 0x1df0
	/* C30 */
	.octa 0x1
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200620070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2e49a9e // SUBS-R.CC-C Rd:30 Cn:20 100110:100110 Cm:4 11000010111:11000010111
	.inst 0x9adf2e61 // rorv:aarch64/instrs/integer/shift/variable Rd:1 Rn:19 op2:11 0010:0010 Rm:31 0011010110:0011010110 sf:1
	.inst 0x9b21e9a7 // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:7 Rn:13 Ra:26 o0:1 Rm:1 01:01 U:0 10011011:10011011
	.inst 0x423fffa1 // ASTLR-R.R-32 Rt:1 Rn:29 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xc2c1d2e2 // CPY-C.C-C Cd:2 Cn:23 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0x284f2808 // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:8 Rn:0 Rt2:01010 imm7:0011110 L:1 1010000:1010000 opc:00
	.inst 0xc2c5f180 // CVTPZ-C.R-C Cd:0 Rn:12 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0x9ac0209f // lslv:aarch64/instrs/integer/shift/variable Rd:31 Rn:4 op2:00 0010:0010 Rm:0 0011010110:0011010110 sf:1
	.inst 0xf87e729f // stumin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:20 00:00 opc:111 o3:0 Rs:30 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0xc2f899e1 // SUBS-R.CC-C Rd:1 Cn:15 100110:100110 Cm:24 11000010111:11000010111
	.inst 0xc2c212c0
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
	.inst 0xc2400604 // ldr c4, [x16, #1]
	.inst 0xc2400a0c // ldr c12, [x16, #2]
	.inst 0xc2400e0f // ldr c15, [x16, #3]
	.inst 0xc2401213 // ldr c19, [x16, #4]
	.inst 0xc2401614 // ldr c20, [x16, #5]
	.inst 0xc2401a18 // ldr c24, [x16, #6]
	.inst 0xc2401e1d // ldr c29, [x16, #7]
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30851037
	msr SCTLR_EL3, x16
	ldr x16, =0x8
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032d0 // ldr c16, [c22, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x826012d0 // ldr c16, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
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
	mov x22, #0xf
	and x16, x16, x22
	cmp x16, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400216 // ldr c22, [x16, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400616 // ldr c22, [x16, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400a16 // ldr c22, [x16, #2]
	.inst 0xc2d6a481 // chkeq c4, c22
	b.ne comparison_fail
	.inst 0xc2400e16 // ldr c22, [x16, #3]
	.inst 0xc2d6a501 // chkeq c8, c22
	b.ne comparison_fail
	.inst 0xc2401216 // ldr c22, [x16, #4]
	.inst 0xc2d6a541 // chkeq c10, c22
	b.ne comparison_fail
	.inst 0xc2401616 // ldr c22, [x16, #5]
	.inst 0xc2d6a581 // chkeq c12, c22
	b.ne comparison_fail
	.inst 0xc2401a16 // ldr c22, [x16, #6]
	.inst 0xc2d6a5e1 // chkeq c15, c22
	b.ne comparison_fail
	.inst 0xc2401e16 // ldr c22, [x16, #7]
	.inst 0xc2d6a661 // chkeq c19, c22
	b.ne comparison_fail
	.inst 0xc2402216 // ldr c22, [x16, #8]
	.inst 0xc2d6a681 // chkeq c20, c22
	b.ne comparison_fail
	.inst 0xc2402616 // ldr c22, [x16, #9]
	.inst 0xc2d6a701 // chkeq c24, c22
	b.ne comparison_fail
	.inst 0xc2402a16 // ldr c22, [x16, #10]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc2402e16 // ldr c22, [x16, #11]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001df0
	ldr x1, =check_data0
	ldr x2, =0x00001df4
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001f7c
	ldr x1, =check_data1
	ldr x2, =0x00001f84
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff0
	ldr x1, =check_data2
	ldr x2, =0x00001ff8
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

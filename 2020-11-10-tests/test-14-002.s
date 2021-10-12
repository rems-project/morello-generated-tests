.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x01, 0x8b, 0xc1, 0xc2, 0x79, 0x01, 0x98, 0x5a, 0x0e, 0x28, 0xc2, 0x9a, 0x9e, 0xe8, 0x5f, 0x8a
	.byte 0xa1, 0xaa, 0x30, 0x9b, 0xc0, 0x7b, 0x63, 0x82, 0x9f, 0xfc, 0x01, 0x48, 0x00, 0x10, 0xc1, 0xc2
	.byte 0xde, 0xc3, 0xaa, 0xe2, 0x97, 0x1c, 0x76, 0x2a, 0x60, 0x13, 0xc2, 0xc2
.data
check_data3:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x4000000100ffffffffffe000
	/* C4 */
	.octa 0x400000000001000500000000004ffffc
	/* C24 */
	.octa 0x440000010000000000000001
final_cap_values:
	/* C0 */
	.octa 0xffffffffffffffff
	/* C1 */
	.octa 0x1
	/* C4 */
	.octa 0x400000000001000500000000004ffffc
	/* C24 */
	.octa 0x440000010000000000000001
	/* C25 */
	.octa 0xfffffffe
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200620070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000060000f800000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c18b01 // CHKSSU-C.CC-C Cd:1 Cn:24 0010:0010 opc:10 Cm:1 11000010110:11000010110
	.inst 0x5a980179 // csinv:aarch64/instrs/integer/conditional/select Rd:25 Rn:11 o2:0 0:0 cond:0000 Rm:24 011010100:011010100 op:1 sf:0
	.inst 0x9ac2280e // asrv:aarch64/instrs/integer/shift/variable Rd:14 Rn:0 op2:10 0010:0010 Rm:2 0011010110:0011010110 sf:1
	.inst 0x8a5fe89e // and_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:4 imm6:111010 Rm:31 N:0 shift:01 01010:01010 opc:00 sf:1
	.inst 0x9b30aaa1 // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:1 Rn:21 Ra:10 o0:1 Rm:16 01:01 U:0 10011011:10011011
	.inst 0x82637bc0 // ALDR-R.RI-32 Rt:0 Rn:30 op:10 imm9:000110111 L:1 1000001001:1000001001
	.inst 0x4801fc9f // stlxrh:aarch64/instrs/memory/exclusive/single Rt:31 Rn:4 Rt2:11111 o0:1 Rs:1 0:0 L:0 0010000:0010000 size:01
	.inst 0xc2c11000 // GCLIM-R.C-C Rd:0 Cn:0 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0xe2aac3de // ASTUR-V.RI-S Rt:30 Rn:30 op2:00 imm9:010101100 V:1 op1:10 11100010:11100010
	.inst 0x2a761c97 // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:23 Rn:4 imm6:000111 Rm:22 N:1 shift:01 01010:01010 opc:01 sf:0
	.inst 0xc2c21360
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e1 // ldr c1, [x15, #0]
	.inst 0xc24005e4 // ldr c4, [x15, #1]
	.inst 0xc24009f8 // ldr c24, [x15, #2]
	/* Vector registers */
	mrs x15, cptr_el3
	bfc x15, #10, #1
	msr cptr_el3, x15
	isb
	ldr q30, =0x0
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30851037
	msr SCTLR_EL3, x15
	ldr x15, =0x4
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x8260336f // ldr c15, [c27, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260136f // ldr c15, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	isb
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x27, #0xf
	and x15, x15, x27
	cmp x15, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001fb // ldr c27, [x15, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc24005fb // ldr c27, [x15, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc24009fb // ldr c27, [x15, #2]
	.inst 0xc2dba481 // chkeq c4, c27
	b.ne comparison_fail
	.inst 0xc2400dfb // ldr c27, [x15, #3]
	.inst 0xc2dba701 // chkeq c24, c27
	b.ne comparison_fail
	.inst 0xc24011fb // ldr c27, [x15, #4]
	.inst 0xc2dba721 // chkeq c25, c27
	b.ne comparison_fail
	.inst 0xc24015fb // ldr c27, [x15, #5]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x15, =0x0
	mov x27, v30.d[0]
	cmp x15, x27
	b.ne comparison_fail
	ldr x15, =0x0
	mov x27, v30.d[1]
	cmp x15, x27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000102c
	ldr x1, =check_data0
	ldr x2, =0x00001030
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000105c
	ldr x1, =check_data1
	ldr x2, =0x00001060
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
	ldr x0, =0x004ffffc
	ldr x1, =check_data3
	ldr x2, =0x004ffffe
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
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

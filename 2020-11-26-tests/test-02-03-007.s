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
	.zero 8
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x01, 0x7e, 0x92, 0xeb, 0x1e, 0x48, 0x3d, 0xf8, 0xfd, 0x93, 0xf3, 0xc2, 0xa3, 0x9f, 0x83, 0xb8
	.byte 0xb6, 0x73, 0xe1, 0x82, 0xa1, 0x83, 0x21, 0x9b, 0xbd, 0xe7, 0x76, 0xe2, 0xe5, 0xff, 0x09, 0x1b
	.byte 0x01, 0x13, 0xc5, 0xc2, 0x80, 0x32, 0xc1, 0xc2, 0x40, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000700070000000000001900
	/* C16 */
	.octa 0x3fffffff1f2ffc0a
	/* C18 */
	.octa 0x8f98000900000000
	/* C24 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C16 */
	.octa 0x3fffffff1f2ffc0a
	/* C18 */
	.octa 0x8f98000900000000
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000000100070000000000001068
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x80000000000100079c0000000000102f
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x8000000048010fec0000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword final_cap_values + 112
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xeb927e01 // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:1 Rn:16 imm6:011111 Rm:18 0:0 shift:10 01011:01011 S:1 op:1 sf:1
	.inst 0xf83d481e // str_reg_gen:aarch64/instrs/memory/single/general/register Rt:30 Rn:0 10:10 S:0 option:010 Rm:29 1:1 opc:00 111000:111000 size:11
	.inst 0xc2f393fd // EORFLGS-C.CI-C Cd:29 Cn:31 0:0 10:10 imm8:10011100 11000010111:11000010111
	.inst 0xb8839fa3 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:3 Rn:29 11:11 imm9:000111001 0:0 opc:10 111000:111000 size:10
	.inst 0x82e173b6 // ALDR-R.RRB-32 Rt:22 Rn:29 opc:00 S:1 option:011 Rm:1 1:1 L:1 100000101:100000101
	.inst 0x9b2183a1 // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:1 Rn:29 Ra:0 o0:1 Rm:1 01:01 U:0 10011011:10011011
	.inst 0xe276e7bd // ALDUR-V.RI-H Rt:29 Rn:29 op2:01 imm9:101101110 V:1 op1:01 11100010:11100010
	.inst 0x1b09ffe5 // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:5 Rn:31 Ra:31 o0:1 Rm:9 0011011000:0011011000 sf:0
	.inst 0xc2c51301 // CVTD-R.C-C Rd:1 Cn:24 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0xc2c13280 // GCFLGS-R.C-C Rd:0 Cn:20 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xc2c21040
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a0 // ldr c0, [x21, #0]
	.inst 0xc24006b0 // ldr c16, [x21, #1]
	.inst 0xc2400ab2 // ldr c18, [x21, #2]
	.inst 0xc2400eb8 // ldr c24, [x21, #3]
	.inst 0xc24012bd // ldr c29, [x21, #4]
	.inst 0xc24016be // ldr c30, [x21, #5]
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =initial_SP_EL3_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2c1d2bf // cpy c31, c21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30851037
	msr SCTLR_EL3, x21
	ldr x21, =0x4
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x2, =pcc_return_ddc_capabilities
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0x82603055 // ldr c21, [c2, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x82601055 // ldr c21, [c2, #1]
	.inst 0x82602042 // ldr c2, [c2, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	isb
	/* Check processor flags */
	mrs x21, nzcv
	ubfx x21, x21, #28, #4
	mov x2, #0xf
	and x21, x21, x2
	cmp x21, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002a2 // ldr c2, [x21, #0]
	.inst 0xc2c2a421 // chkeq c1, c2
	b.ne comparison_fail
	.inst 0xc24006a2 // ldr c2, [x21, #1]
	.inst 0xc2c2a461 // chkeq c3, c2
	b.ne comparison_fail
	.inst 0xc2400aa2 // ldr c2, [x21, #2]
	.inst 0xc2c2a4a1 // chkeq c5, c2
	b.ne comparison_fail
	.inst 0xc2400ea2 // ldr c2, [x21, #3]
	.inst 0xc2c2a601 // chkeq c16, c2
	b.ne comparison_fail
	.inst 0xc24012a2 // ldr c2, [x21, #4]
	.inst 0xc2c2a641 // chkeq c18, c2
	b.ne comparison_fail
	.inst 0xc24016a2 // ldr c2, [x21, #5]
	.inst 0xc2c2a6c1 // chkeq c22, c2
	b.ne comparison_fail
	.inst 0xc2401aa2 // ldr c2, [x21, #6]
	.inst 0xc2c2a701 // chkeq c24, c2
	b.ne comparison_fail
	.inst 0xc2401ea2 // ldr c2, [x21, #7]
	.inst 0xc2c2a7a1 // chkeq c29, c2
	b.ne comparison_fail
	.inst 0xc24022a2 // ldr c2, [x21, #8]
	.inst 0xc2c2a7c1 // chkeq c30, c2
	b.ne comparison_fail
	/* Check vector registers */
	ldr x21, =0x0
	mov x2, v29.d[0]
	cmp x21, x2
	b.ne comparison_fail
	ldr x21, =0x0
	mov x2, v29.d[1]
	cmp x21, x2
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001034
	ldr x1, =check_data0
	ldr x2, =0x00001038
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001068
	ldr x1, =check_data1
	ldr x2, =0x0000106c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001900
	ldr x1, =check_data2
	ldr x2, =0x00001908
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fc2
	ldr x1, =check_data3
	ldr x2, =0x00001fc4
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
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

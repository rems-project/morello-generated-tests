.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0xa1, 0xc3, 0xc1, 0xc2, 0x5d, 0xce, 0xdf, 0xc2, 0xfd, 0x03, 0xd6, 0xc2, 0x07, 0xae, 0x51, 0xe2
	.byte 0xc1, 0x7f, 0x4a, 0x9b, 0x20, 0x00, 0xc2, 0xc2, 0xe0, 0x73, 0xc2, 0xc2, 0x7d, 0x41, 0x44, 0xb1
	.byte 0xdf, 0x33, 0x62, 0xe2, 0x00, 0x02, 0x5f, 0xd6
.data
check_data2:
	.byte 0xc0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C16 */
	.octa 0x4000e8
	/* C29 */
	.octa 0x2000000
	/* C30 */
	.octa 0x4000000040010004000000000000104d
final_cap_values:
	/* C7 */
	.octa 0xffffc2c1
	/* C16 */
	.octa 0x4000e8
	/* C30 */
	.octa 0x4000000040010004000000000000104d
initial_SP_EL3_value:
	.octa 0x800700060000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c1c3a1 // CVT-R.CC-C Rd:1 Cn:29 110000:110000 Cm:1 11000010110:11000010110
	.inst 0xc2dfce5d // CSEL-C.CI-C Cd:29 Cn:18 11:11 cond:1100 Cm:31 11000010110:11000010110
	.inst 0xc2d603fd // SCBNDS-C.CR-C Cd:29 Cn:31 000:000 opc:00 0:0 Rm:22 11000010110:11000010110
	.inst 0xe251ae07 // ALDURSH-R.RI-32 Rt:7 Rn:16 op2:11 imm9:100011010 V:0 op1:01 11100010:11100010
	.inst 0x9b4a7fc1 // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:1 Rn:30 Ra:11111 0:0 Rm:10 10:10 U:0 10011011:10011011
	.inst 0xc2c20020 // 0xc2c20020
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xb144417d // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:29 Rn:11 imm12:000100010000 sh:1 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0xe26233df // ASTUR-V.RI-H Rt:31 Rn:30 op2:00 imm9:000100011 V:1 op1:01 11100010:11100010
	.inst 0xd65f0200 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:16 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 192
	.inst 0xc2c211c0
	.zero 1048340
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
	.inst 0xc2400270 // ldr c16, [x19, #0]
	.inst 0xc240067d // ldr c29, [x19, #1]
	.inst 0xc2400a7e // ldr c30, [x19, #2]
	/* Vector registers */
	mrs x19, cptr_el3
	bfc x19, #10, #1
	msr cptr_el3, x19
	isb
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =initial_SP_EL3_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2c1d27f // cpy c31, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	ldr x19, =0x0
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031d3 // ldr c19, [c14, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x826011d3 // ldr c19, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc240026e // ldr c14, [x19, #0]
	.inst 0xc2cea4e1 // chkeq c7, c14
	b.ne comparison_fail
	.inst 0xc240066e // ldr c14, [x19, #1]
	.inst 0xc2cea601 // chkeq c16, c14
	b.ne comparison_fail
	.inst 0xc2400a6e // ldr c14, [x19, #2]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0x0
	mov x14, v31.d[0]
	cmp x19, x14
	b.ne comparison_fail
	ldr x19, =0x0
	mov x14, v31.d[1]
	cmp x19, x14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001070
	ldr x1, =check_data0
	ldr x2, =0x00001072
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x00400028
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x004000e8
	ldr x1, =check_data2
	ldr x2, =0x004000ec
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
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

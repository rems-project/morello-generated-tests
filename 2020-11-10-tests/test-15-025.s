.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x07, 0xa0, 0xde, 0xc2, 0xa1, 0xdf, 0x85, 0xe2, 0xef, 0xf3, 0xc5, 0xc2, 0x61, 0x0c, 0xc2, 0x9a
	.byte 0x8b, 0x02, 0x4c, 0x82, 0x0a, 0x2c, 0xdf, 0x1a, 0xe2, 0x2b, 0xc6, 0xc2, 0x00, 0x98, 0xe5, 0xc2
	.byte 0xfe, 0x11, 0xc1, 0xc2, 0x81, 0x6d, 0x94, 0x82, 0xc0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C20 */
	.octa 0x1000
	/* C29 */
	.octa 0x10a3
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x3fff800000000000000000000000
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C20 */
	.octa 0x1000
	/* C29 */
	.octa 0x10a3
	/* C30 */
	.octa 0xffffffffffffffff
initial_SP_EL3_value:
	.octa 0x3fff800000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x4c000000400100020000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2dea007 // CLRPERM-C.CR-C Cd:7 Cn:0 000:000 1:1 10:10 Rm:30 11000010110:11000010110
	.inst 0xe285dfa1 // ASTUR-C.RI-C Ct:1 Rn:29 op2:11 imm9:001011101 V:0 op1:10 11100010:11100010
	.inst 0xc2c5f3ef // CVTPZ-C.R-C Cd:15 Rn:31 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0x9ac20c61 // sdiv:aarch64/instrs/integer/arithmetic/div Rd:1 Rn:3 o1:1 00001:00001 Rm:2 0011010110:0011010110 sf:1
	.inst 0x824c028b // ASTR-C.RI-C Ct:11 Rn:20 op:00 imm9:011000000 L:0 1000001001:1000001001
	.inst 0x1adf2c0a // rorv:aarch64/instrs/integer/shift/variable Rd:10 Rn:0 op2:11 0010:0010 Rm:31 0011010110:0011010110 sf:0
	.inst 0xc2c62be2 // BICFLGS-C.CR-C Cd:2 Cn:31 1010:1010 opc:00 Rm:6 11000010110:11000010110
	.inst 0xc2e59800 // SUBS-R.CC-C Rd:0 Cn:0 100110:100110 Cm:5 11000010111:11000010111
	.inst 0xc2c111fe // GCLIM-R.C-C Rd:30 Cn:15 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0x82946d81 // ASTRH-R.RRB-32 Rt:1 Rn:12 opc:11 S:0 option:011 Rm:20 0:0 L:0 100000101:100000101
	.inst 0xc2c211c0
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c0 // ldr c0, [x22, #0]
	.inst 0xc24006c1 // ldr c1, [x22, #1]
	.inst 0xc2400ac2 // ldr c2, [x22, #2]
	.inst 0xc2400ec5 // ldr c5, [x22, #3]
	.inst 0xc24012cb // ldr c11, [x22, #4]
	.inst 0xc24016cc // ldr c12, [x22, #5]
	.inst 0xc2401ad4 // ldr c20, [x22, #6]
	.inst 0xc2401edd // ldr c29, [x22, #7]
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =initial_SP_EL3_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2c1d2df // cpy c31, c22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30851037
	msr SCTLR_EL3, x22
	ldr x22, =0x0
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031d6 // ldr c22, [c14, #3]
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	.inst 0x826011d6 // ldr c22, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30851035
	msr SCTLR_EL3, x22
	isb
	/* Check processor flags */
	mrs x22, nzcv
	ubfx x22, x22, #28, #4
	mov x14, #0xf
	and x22, x22, x14
	cmp x22, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002ce // ldr c14, [x22, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc24006ce // ldr c14, [x22, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc2400ace // ldr c14, [x22, #2]
	.inst 0xc2cea441 // chkeq c2, c14
	b.ne comparison_fail
	.inst 0xc2400ece // ldr c14, [x22, #3]
	.inst 0xc2cea4a1 // chkeq c5, c14
	b.ne comparison_fail
	.inst 0xc24012ce // ldr c14, [x22, #4]
	.inst 0xc2cea4e1 // chkeq c7, c14
	b.ne comparison_fail
	.inst 0xc24016ce // ldr c14, [x22, #5]
	.inst 0xc2cea541 // chkeq c10, c14
	b.ne comparison_fail
	.inst 0xc2401ace // ldr c14, [x22, #6]
	.inst 0xc2cea561 // chkeq c11, c14
	b.ne comparison_fail
	.inst 0xc2401ece // ldr c14, [x22, #7]
	.inst 0xc2cea581 // chkeq c12, c14
	b.ne comparison_fail
	.inst 0xc24022ce // ldr c14, [x22, #8]
	.inst 0xc2cea5e1 // chkeq c15, c14
	b.ne comparison_fail
	.inst 0xc24026ce // ldr c14, [x22, #9]
	.inst 0xc2cea681 // chkeq c20, c14
	b.ne comparison_fail
	.inst 0xc2402ace // ldr c14, [x22, #10]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	.inst 0xc2402ece // ldr c14, [x22, #11]
	.inst 0xc2cea7c1 // chkeq c30, c14
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
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001110
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001c00
	ldr x1, =check_data2
	ldr x2, =0x00001c10
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
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
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

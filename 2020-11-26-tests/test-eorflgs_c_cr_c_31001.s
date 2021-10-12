.section data0, #alloc, #write
	.zero 3920
	.byte 0x11, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x8f, 0x04, 0x06, 0x3f, 0x00, 0x80, 0x00, 0x20
	.zero 160
.data
check_data0:
	.byte 0x00, 0x88, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 48
.data
check_data1:
	.byte 0x11, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x40, 0x00, 0xc0, 0x00, 0x20
	.byte 0x11, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x8f, 0x04, 0x06, 0x3f, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.byte 0xc0, 0xfb, 0xc1, 0x82, 0xf2, 0x3d, 0x94, 0xe2, 0xe0, 0x73, 0xdc, 0xc2
.data
check_data3:
	.byte 0xc1, 0xa3, 0x5c, 0x7a, 0x5c, 0xb0, 0xc4, 0xc2, 0xf0, 0xab, 0xc1, 0xc2, 0x07, 0xc0, 0x09, 0x91
	.byte 0xbf, 0x0a, 0xce, 0x9a, 0x3e, 0xd4, 0xe0, 0xc2, 0x05, 0x64, 0xd6, 0xc2, 0x80, 0x12, 0xc2, 0xc2
.data
check_data4:
	.byte 0x00, 0x01
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x80000000520102020000000000001000
	/* C14 */
	.octa 0x0
	/* C15 */
	.octa 0x1ffd
	/* C18 */
	.octa 0x2000c000400000020000000000400011
	/* C30 */
	.octa 0x408800
final_cap_values:
	/* C0 */
	.octa 0x100
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x80000000520102020000000000001000
	/* C7 */
	.octa 0x370
	/* C14 */
	.octa 0x0
	/* C15 */
	.octa 0x1ffd
	/* C16 */
	.octa 0x9000000040810ff40000000000002120
	/* C18 */
	.octa 0x2000c000400000020000000000400011
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x408800
initial_SP_EL3_value:
	.octa 0x9000000040810ff40000000000002120
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200040000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc8000000000300070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001020
	.dword 0x0000000000001030
	.dword 0x0000000000001f50
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82c1fbc0 // ALDRSH-R.RRB-32 Rt:0 Rn:30 opc:10 S:1 option:111 Rm:1 0:0 L:1 100000101:100000101
	.inst 0xe2943df2 // ASTUR-C.RI-C Ct:18 Rn:15 op2:11 imm9:101000011 V:0 op1:10 11100010:11100010
	.inst 0xc2dc73e0 // BR-CI-C 0:0 0000:0000 Cn:31 100:100 imm7:1100011 110000101101:110000101101
	.zero 4
	.inst 0x7a5ca3c1 // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0001 0:0 Rn:30 00:00 cond:1010 Rm:28 111010010:111010010 op:1 sf:0
	.inst 0xc2c4b05c // LDCT-R.R-_ Rt:28 Rn:2 100:100 opc:01 11000010110001001:11000010110001001
	.inst 0xc2c1abf0 // 0xc2c1abf0
	.inst 0x9109c007 // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:7 Rn:0 imm12:001001110000 sh:0 0:0 10001:10001 S:0 op:0 sf:1
	.inst 0x9ace0abf // udiv:aarch64/instrs/integer/arithmetic/div Rd:31 Rn:21 o1:0 00001:00001 Rm:14 0011010110:0011010110 sf:1
	.inst 0xc2e0d43e // ASTR-C.RRB-C Ct:30 Rn:1 1:1 L:0 S:1 option:110 Rm:0 11000010111:11000010111
	.inst 0xc2d66405 // CPYVALUE-C.C-C Cd:5 Cn:0 001:001 opc:11 0:0 Cm:22 11000010110:11000010110
	.inst 0xc2c21280
	.zero 34768
	.inst 0x00000100
	.zero 1013756
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
	ldr x24, =initial_cap_values
	.inst 0xc2400301 // ldr c1, [x24, #0]
	.inst 0xc2400702 // ldr c2, [x24, #1]
	.inst 0xc2400b0e // ldr c14, [x24, #2]
	.inst 0xc2400f0f // ldr c15, [x24, #3]
	.inst 0xc2401312 // ldr c18, [x24, #4]
	.inst 0xc240171e // ldr c30, [x24, #5]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =initial_SP_EL3_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2c1d31f // cpy c31, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	ldr x24, =0x0
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82603298 // ldr c24, [c20, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x82601298 // ldr c24, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400314 // ldr c20, [x24, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400714 // ldr c20, [x24, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400b14 // ldr c20, [x24, #2]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400f14 // ldr c20, [x24, #3]
	.inst 0xc2d4a4e1 // chkeq c7, c20
	b.ne comparison_fail
	.inst 0xc2401314 // ldr c20, [x24, #4]
	.inst 0xc2d4a5c1 // chkeq c14, c20
	b.ne comparison_fail
	.inst 0xc2401714 // ldr c20, [x24, #5]
	.inst 0xc2d4a5e1 // chkeq c15, c20
	b.ne comparison_fail
	.inst 0xc2401b14 // ldr c20, [x24, #6]
	.inst 0xc2d4a601 // chkeq c16, c20
	b.ne comparison_fail
	.inst 0xc2401f14 // ldr c20, [x24, #7]
	.inst 0xc2d4a641 // chkeq c18, c20
	b.ne comparison_fail
	.inst 0xc2402314 // ldr c20, [x24, #8]
	.inst 0xc2d4a781 // chkeq c28, c20
	b.ne comparison_fail
	.inst 0xc2402714 // ldr c20, [x24, #9]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001040
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001f40
	ldr x1, =check_data1
	ldr x2, =0x00001f60
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040000c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400010
	ldr x1, =check_data3
	ldr x2, =0x00400030
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00408800
	ldr x1, =check_data4
	ldr x2, =0x00408802
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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

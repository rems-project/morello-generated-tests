.section data0, #alloc, #write
	.byte 0x60, 0xfa, 0x44, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x60, 0xfa, 0x44, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x21, 0x7c, 0xdf, 0x08, 0xdf, 0x00, 0x62, 0xf8, 0xc0, 0xe9, 0xbe, 0xf8, 0x02, 0x10, 0xf4, 0xf8
	.byte 0x46, 0x79, 0x4b, 0x3a, 0x01, 0x2c, 0x36, 0xeb, 0xde, 0xab, 0x57, 0xe2, 0x3e, 0x74, 0xe0, 0x82
	.byte 0x3e, 0xff, 0x5f, 0x08, 0x40, 0x00, 0x1f, 0xd6
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0x00, 0x12, 0xc2, 0xc2
.data
check_data6:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000600400000000000000001000
	/* C1 */
	.octa 0x80000000600000020000000000001000
	/* C2 */
	.octa 0x0
	/* C6 */
	.octa 0xc0000000000300070000000000001800
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0xff7
	/* C25 */
	.octa 0x800000000001000500000000004ffbfe
	/* C30 */
	.octa 0x1082
final_cap_values:
	/* C0 */
	.octa 0xc0000000600400000000000000001000
	/* C1 */
	.octa 0xffffffffffff9048
	/* C2 */
	.octa 0x44fa60
	/* C6 */
	.octa 0xc0000000000300070000000000001800
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0xff7
	/* C25 */
	.octa 0x800000000001000500000000004ffbfe
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000007000500000000003fc001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x08df7c21 // ldlarb:aarch64/instrs/memory/ordered Rt:1 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xf86200df // stadd:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:6 00:00 opc:000 o3:0 Rs:2 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0xf8bee9c0 // prfm_reg:aarch64/instrs/memory/single/general/register Rt:0 Rn:14 10:10 S:0 option:111 Rm:30 1:1 opc:10 111000:111000 size:11
	.inst 0xf8f41002 // ldclr:aarch64/instrs/memory/atomicops/ld Rt:2 Rn:0 00:00 opc:001 0:0 Rs:20 1:1 R:1 A:1 111000:111000 size:11
	.inst 0x3a4b7946 // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0110 0:0 Rn:10 10:10 cond:0111 imm5:01011 111010010:111010010 op:0 sf:0
	.inst 0xeb362c01 // subs_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:1 Rn:0 imm3:011 option:001 Rm:22 01011001:01011001 S:1 op:1 sf:1
	.inst 0xe257abde // ALDURSH-R.RI-64 Rt:30 Rn:30 op2:10 imm9:101111010 V:0 op1:01 11100010:11100010
	.inst 0x82e0743e // ALDR-R.RRB-64 Rt:30 Rn:1 opc:01 S:1 option:011 Rm:0 1:1 L:1 100000101:100000101
	.inst 0x085fff3e // ldaxrb:aarch64/instrs/memory/exclusive/single Rt:30 Rn:25 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0xd61f0040 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:2 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.zero 326200
	.inst 0xc2c21200
	.zero 722332
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
	ldr x4, =initial_cap_values
	.inst 0xc2400080 // ldr c0, [x4, #0]
	.inst 0xc2400481 // ldr c1, [x4, #1]
	.inst 0xc2400882 // ldr c2, [x4, #2]
	.inst 0xc2400c86 // ldr c6, [x4, #3]
	.inst 0xc2401094 // ldr c20, [x4, #4]
	.inst 0xc2401496 // ldr c22, [x4, #5]
	.inst 0xc2401899 // ldr c25, [x4, #6]
	.inst 0xc2401c9e // ldr c30, [x4, #7]
	/* Set up flags and system registers */
	mov x4, #0x10000000
	msr nzcv, x4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30851037
	msr SCTLR_EL3, x4
	ldr x4, =0x4
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82603204 // ldr c4, [c16, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x82601204 // ldr c4, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	isb
	/* Check processor flags */
	mrs x4, nzcv
	ubfx x4, x4, #28, #4
	mov x16, #0xf
	and x4, x4, x16
	cmp x4, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400090 // ldr c16, [x4, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc2400490 // ldr c16, [x4, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400890 // ldr c16, [x4, #2]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400c90 // ldr c16, [x4, #3]
	.inst 0xc2d0a4c1 // chkeq c6, c16
	b.ne comparison_fail
	.inst 0xc2401090 // ldr c16, [x4, #4]
	.inst 0xc2d0a681 // chkeq c20, c16
	b.ne comparison_fail
	.inst 0xc2401490 // ldr c16, [x4, #5]
	.inst 0xc2d0a6c1 // chkeq c22, c16
	b.ne comparison_fail
	.inst 0xc2401890 // ldr c16, [x4, #6]
	.inst 0xc2d0a721 // chkeq c25, c16
	b.ne comparison_fail
	.inst 0xc2401c90 // ldr c16, [x4, #7]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001800
	ldr x1, =check_data1
	ldr x2, =0x00001808
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400028
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400ffc
	ldr x1, =check_data3
	ldr x2, =0x00400ffe
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00401048
	ldr x1, =check_data4
	ldr x2, =0x00401050
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0044fa60
	ldr x1, =check_data5
	ldr x2, =0x0044fa64
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004ffbfe
	ldr x1, =check_data6
	ldr x2, =0x004ffbff
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
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

.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x5b, 0xfd, 0x00, 0xc8, 0x9f, 0x31, 0xc0, 0xc2, 0xe1, 0x63, 0xc0, 0xc2, 0xdd, 0xfe, 0x5f, 0x22
	.byte 0x7f, 0x20, 0x3d, 0x38, 0x22, 0x53, 0xc1, 0xc2, 0xe5, 0x6b, 0x44, 0xfa, 0x3e, 0xd0, 0xc1, 0xc2
	.byte 0x30, 0xfc, 0x5f, 0x42, 0xdd, 0x2f, 0xdf, 0x1a, 0xe0, 0x11, 0xc2, 0xc2
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C3 */
	.octa 0xc0000000000100050000000000001ffe
	/* C10 */
	.octa 0x40000000400000020000000000001070
	/* C12 */
	.octa 0x642830000000012000000
	/* C22 */
	.octa 0x801000000001000500000000004001e0
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x901000004000e11f000000000040e120
	/* C3 */
	.octa 0xc0000000000100050000000000001ffe
	/* C10 */
	.octa 0x40000000400000020000000000001070
	/* C12 */
	.octa 0x642830000000012000000
	/* C16 */
	.octa 0x0
	/* C22 */
	.octa 0x801000000001000500000000004001e0
	/* C29 */
	.octa 0x40e120
	/* C30 */
	.octa 0x901000004000e11f000000000040e120
initial_SP_EL3_value:
	.octa 0x901000004000e11f000000000040e120
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001ff400030000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc800fd5b // stlxr:aarch64/instrs/memory/exclusive/single Rt:27 Rn:10 Rt2:11111 o0:1 Rs:0 0:0 L:0 0010000:0010000 size:11
	.inst 0xc2c0319f // GCLEN-R.C-C Rd:31 Cn:12 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0xc2c063e1 // SCOFF-C.CR-C Cd:1 Cn:31 000:000 opc:11 0:0 Rm:0 11000010110:11000010110
	.inst 0x225ffedd // LDAXR-C.R-C Ct:29 Rn:22 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0x383d207f // steorb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:3 00:00 opc:010 o3:0 Rs:29 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2c15322 // CFHI-R.C-C Rd:2 Cn:25 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xfa446be5 // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0101 0:0 Rn:31 10:10 cond:0110 imm5:00100 111010010:111010010 op:1 sf:1
	.inst 0xc2c1d03e // CPY-C.C-C Cd:30 Cn:1 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0x425ffc30 // LDAR-C.R-C Ct:16 Rn:1 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0x1adf2fdd // rorv:aarch64/instrs/integer/shift/variable Rd:29 Rn:30 op2:11 0010:0010 Rm:31 0011010110:0011010110 sf:0
	.inst 0xc2c211e0
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c3 // ldr c3, [x14, #0]
	.inst 0xc24005ca // ldr c10, [x14, #1]
	.inst 0xc24009cc // ldr c12, [x14, #2]
	.inst 0xc2400dd6 // ldr c22, [x14, #3]
	/* Set up flags and system registers */
	mov x14, #0x10000000
	msr nzcv, x14
	ldr x14, =initial_SP_EL3_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2c1d1df // cpy c31, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826011ee // ldr c14, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x15, #0xf
	and x14, x14, x15
	cmp x14, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001cf // ldr c15, [x14, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc24005cf // ldr c15, [x14, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc24009cf // ldr c15, [x14, #2]
	.inst 0xc2cfa461 // chkeq c3, c15
	b.ne comparison_fail
	.inst 0xc2400dcf // ldr c15, [x14, #3]
	.inst 0xc2cfa541 // chkeq c10, c15
	b.ne comparison_fail
	.inst 0xc24011cf // ldr c15, [x14, #4]
	.inst 0xc2cfa581 // chkeq c12, c15
	b.ne comparison_fail
	.inst 0xc24015cf // ldr c15, [x14, #5]
	.inst 0xc2cfa601 // chkeq c16, c15
	b.ne comparison_fail
	.inst 0xc24019cf // ldr c15, [x14, #6]
	.inst 0xc2cfa6c1 // chkeq c22, c15
	b.ne comparison_fail
	.inst 0xc2401dcf // ldr c15, [x14, #7]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc24021cf // ldr c15, [x14, #8]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001070
	ldr x1, =check_data0
	ldr x2, =0x00001078
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffe
	ldr x1, =check_data1
	ldr x2, =0x00001fff
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
	ldr x0, =0x004001e0
	ldr x1, =check_data3
	ldr x2, =0x004001f0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0040e120
	ldr x1, =check_data4
	ldr x2, =0x0040e130
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
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

.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x3e, 0x57, 0x81, 0x82, 0xd8, 0x07, 0xc0, 0x5a, 0x80, 0x07, 0x18, 0x78, 0x3e, 0xfc, 0x9f, 0x48
	.byte 0x3c, 0x0c, 0xc5, 0x1a, 0x23, 0x5c, 0xdc, 0x82, 0x3e, 0x65, 0x55, 0x82, 0x41, 0x14, 0xc1, 0x39
	.byte 0x9e, 0xa3, 0x87, 0x5a, 0x18, 0x30, 0xc6, 0xc2, 0xe0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000000000000000000
	/* C1 */
	.octa 0x400000000007000e00000000000010fc
	/* C2 */
	.octa 0x80000000000100050000000000001fb9
	/* C5 */
	.octa 0x0
	/* C9 */
	.octa 0x10a8
	/* C25 */
	.octa 0xf02
	/* C28 */
	.octa 0x40000000200020000000000000001000
final_cap_values:
	/* C0 */
	.octa 0x800000000000000000000000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x80000000000100050000000000001fb9
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C9 */
	.octa 0x10a8
	/* C24 */
	.octa 0x800000000000000000000000
	/* C25 */
	.octa 0xf02
	/* C28 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000640070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000001c0700000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x8281573e // ALDRSB-R.RRB-64 Rt:30 Rn:25 opc:01 S:1 option:010 Rm:1 0:0 L:0 100000101:100000101
	.inst 0x5ac007d8 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:24 Rn:30 opc:01 1011010110000000000:1011010110000000000 sf:0
	.inst 0x78180780 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:28 01:01 imm9:110000000 0:0 opc:00 111000:111000 size:01
	.inst 0x489ffc3e // stlrh:aarch64/instrs/memory/ordered Rt:30 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x1ac50c3c // sdiv:aarch64/instrs/integer/arithmetic/div Rd:28 Rn:1 o1:1 00001:00001 Rm:5 0011010110:0011010110 sf:0
	.inst 0x82dc5c23 // ALDRH-R.RRB-32 Rt:3 Rn:1 opc:11 S:1 option:010 Rm:28 0:0 L:1 100000101:100000101
	.inst 0x8255653e // ASTRB-R.RI-B Rt:30 Rn:9 op:01 imm9:101010110 L:0 1000001001:1000001001
	.inst 0x39c11441 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:2 imm12:000001000101 opc:11 111001:111001 size:00
	.inst 0x5a87a39e // csinv:aarch64/instrs/integer/conditional/select Rd:30 Rn:28 o2:0 0:0 cond:1010 Rm:7 011010100:011010100 op:1 sf:0
	.inst 0xc2c63018 // CLRPERM-C.CI-C Cd:24 Cn:0 100:100 perm:001 1100001011000110:1100001011000110
	.inst 0xc2c212e0
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
	.inst 0xc24006a1 // ldr c1, [x21, #1]
	.inst 0xc2400aa2 // ldr c2, [x21, #2]
	.inst 0xc2400ea5 // ldr c5, [x21, #3]
	.inst 0xc24012a9 // ldr c9, [x21, #4]
	.inst 0xc24016b9 // ldr c25, [x21, #5]
	.inst 0xc2401abc // ldr c28, [x21, #6]
	/* Set up flags and system registers */
	mov x21, #0x80000000
	msr nzcv, x21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	ldr x21, =0x4
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032f5 // ldr c21, [c23, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x826012f5 // ldr c21, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
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
	mov x23, #0x9
	and x21, x21, x23
	cmp x21, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002b7 // ldr c23, [x21, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc24006b7 // ldr c23, [x21, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400ab7 // ldr c23, [x21, #2]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400eb7 // ldr c23, [x21, #3]
	.inst 0xc2d7a461 // chkeq c3, c23
	b.ne comparison_fail
	.inst 0xc24012b7 // ldr c23, [x21, #4]
	.inst 0xc2d7a4a1 // chkeq c5, c23
	b.ne comparison_fail
	.inst 0xc24016b7 // ldr c23, [x21, #5]
	.inst 0xc2d7a521 // chkeq c9, c23
	b.ne comparison_fail
	.inst 0xc2401ab7 // ldr c23, [x21, #6]
	.inst 0xc2d7a701 // chkeq c24, c23
	b.ne comparison_fail
	.inst 0xc2401eb7 // ldr c23, [x21, #7]
	.inst 0xc2d7a721 // chkeq c25, c23
	b.ne comparison_fail
	.inst 0xc24022b7 // ldr c23, [x21, #8]
	.inst 0xc2d7a781 // chkeq c28, c23
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
	ldr x0, =0x000010fc
	ldr x1, =check_data1
	ldr x2, =0x000010fe
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011fe
	ldr x1, =check_data2
	ldr x2, =0x000011ff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
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

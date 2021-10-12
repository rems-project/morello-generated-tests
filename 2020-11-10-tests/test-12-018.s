.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xf0, 0x4b, 0xa1, 0xf9, 0x3f, 0x23, 0x7c, 0x38, 0x3f, 0xa6, 0x3d, 0x0b, 0xee, 0x93, 0xc1, 0xc2
	.byte 0x7f, 0x47, 0x84, 0x9a, 0x4b, 0x10, 0xc5, 0xc2, 0xc0, 0x97, 0x06, 0xe2, 0x8f, 0x2c, 0x98, 0x78
	.byte 0x61, 0xf2, 0x60, 0x02, 0xc2, 0xa3, 0xdf, 0xc2, 0x60, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x80000000000300040000000000002078
	/* C19 */
	.octa 0x720000000000000000000
	/* C25 */
	.octa 0xc0000000000e00020000000000001000
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x800000000000000000001f95
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x72000000000000083c000
	/* C2 */
	.octa 0x800000000000000000001f95
	/* C4 */
	.octa 0x80000000000300040000000000001ffa
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C19 */
	.octa 0x720000000000000000000
	/* C25 */
	.octa 0xc0000000000e00020000000000001000
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x800000000000000000001f95
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000085604070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000003000700ffe00000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 48
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf9a14bf0 // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:16 Rn:31 imm12:100001010010 opc:10 111001:111001 size:11
	.inst 0x387c233f // steorb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:25 00:00 opc:010 o3:0 Rs:28 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0x0b3da63f // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:31 Rn:17 imm3:001 option:101 Rm:29 01011001:01011001 S:0 op:0 sf:0
	.inst 0xc2c193ee // CLRTAG-C.C-C Cd:14 Cn:31 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0x9a84477f // csinc:aarch64/instrs/integer/conditional/select Rd:31 Rn:27 o2:1 0:0 cond:0100 Rm:4 011010100:011010100 op:0 sf:1
	.inst 0xc2c5104b // CVTD-R.C-C Rd:11 Cn:2 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0xe20697c0 // ALDURB-R.RI-32 Rt:0 Rn:30 op2:01 imm9:001101001 V:0 op1:00 11100010:11100010
	.inst 0x78982c8f // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:15 Rn:4 11:11 imm9:110000010 0:0 opc:10 111000:111000 size:01
	.inst 0x0260f261 // ADD-C.CIS-C Cd:1 Cn:19 imm12:100000111100 sh:1 A:0 00000010:00000010
	.inst 0xc2dfa3c2 // CLRPERM-C.CR-C Cd:2 Cn:30 000:000 1:1 10:10 Rm:31 11000010110:11000010110
	.inst 0xc2c21060
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
	ldr x10, =initial_cap_values
	.inst 0xc2400142 // ldr c2, [x10, #0]
	.inst 0xc2400544 // ldr c4, [x10, #1]
	.inst 0xc2400953 // ldr c19, [x10, #2]
	.inst 0xc2400d59 // ldr c25, [x10, #3]
	.inst 0xc240115c // ldr c28, [x10, #4]
	.inst 0xc240155e // ldr c30, [x10, #5]
	/* Set up flags and system registers */
	mov x10, #0x80000000
	msr nzcv, x10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30851037
	msr SCTLR_EL3, x10
	ldr x10, =0x0
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x8260306a // ldr c10, [c3, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x8260106a // ldr c10, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x3, #0xf
	and x10, x10, x3
	cmp x10, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400143 // ldr c3, [x10, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc2400543 // ldr c3, [x10, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400943 // ldr c3, [x10, #2]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400d43 // ldr c3, [x10, #3]
	.inst 0xc2c3a481 // chkeq c4, c3
	b.ne comparison_fail
	.inst 0xc2401143 // ldr c3, [x10, #4]
	.inst 0xc2c3a561 // chkeq c11, c3
	b.ne comparison_fail
	.inst 0xc2401543 // ldr c3, [x10, #5]
	.inst 0xc2c3a5e1 // chkeq c15, c3
	b.ne comparison_fail
	.inst 0xc2401943 // ldr c3, [x10, #6]
	.inst 0xc2c3a661 // chkeq c19, c3
	b.ne comparison_fail
	.inst 0xc2401d43 // ldr c3, [x10, #7]
	.inst 0xc2c3a721 // chkeq c25, c3
	b.ne comparison_fail
	.inst 0xc2402143 // ldr c3, [x10, #8]
	.inst 0xc2c3a781 // chkeq c28, c3
	b.ne comparison_fail
	.inst 0xc2402543 // ldr c3, [x10, #9]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffa
	ldr x1, =check_data1
	ldr x2, =0x00001ffc
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
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
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
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

.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x05, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0xdd, 0x27, 0x57, 0x82, 0xe3, 0xa0, 0xa8, 0x35, 0x51, 0x99, 0xb6, 0xf9, 0xe0, 0xd0, 0xc0, 0xc2
	.byte 0xd8, 0x03, 0xdf, 0xc2, 0xdd, 0x13, 0xc5, 0xc2, 0xe1, 0xaf, 0xce, 0xe2, 0xfe, 0x8a, 0x8e, 0x22
	.byte 0x83, 0x31, 0xc2, 0xc2
.data
check_data4:
	.byte 0xff, 0x13, 0xe0, 0x78, 0xc0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C12 */
	.octa 0x200080002001c0050000000000400041
	/* C23 */
	.octa 0x40000000000180060000000000001000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x500070000000000000400
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C12 */
	.octa 0x200080002001c0050000000000400041
	/* C23 */
	.octa 0x400000000001800600000000000011d0
	/* C24 */
	.octa 0x440004000000000000000400
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000040000200000000000400025
initial_SP_EL3_value:
	.octa 0xc0000000580100020000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000040000200000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000040000c060000000000003c00
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001cf0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x825727dd // ASTRB-R.RI-B Rt:29 Rn:30 op:01 imm9:101110010 L:0 1000001001:1000001001
	.inst 0x35a8a0e3 // cbnz:aarch64/instrs/branch/conditional/compare Rt:3 imm19:1010100010100000111 op:1 011010:011010 sf:0
	.inst 0xf9b69951 // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:17 Rn:10 imm12:110110100110 opc:10 111001:111001 size:11
	.inst 0xc2c0d0e0 // GCPERM-R.C-C Rd:0 Cn:7 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0xc2df03d8 // SCBNDS-C.CR-C Cd:24 Cn:30 000:000 opc:00 0:0 Rm:31 11000010110:11000010110
	.inst 0xc2c513dd // CVTD-R.C-C Rd:29 Cn:30 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0xe2ceafe1 // ALDUR-C.RI-C Ct:1 Rn:31 op2:11 imm9:011101010 V:0 op1:11 11100010:11100010
	.inst 0x228e8afe // STP-CC.RIAW-C Ct:30 Rn:23 Ct2:00010 imm7:0011101 L:0 001000101:001000101
	.inst 0xc2c23183 // BLRR-C-C 00011:00011 Cn:12 100:100 opc:01 11000010110000100:11000010110000100
	.zero 28
	.inst 0x78e013ff // ldclrh:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:31 00:00 opc:001 0:0 Rs:0 1:1 R:1 A:1 111000:111000 size:01
	.inst 0xc2c212c0
	.zero 1048504
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
	.inst 0xc2400202 // ldr c2, [x16, #0]
	.inst 0xc2400603 // ldr c3, [x16, #1]
	.inst 0xc2400a07 // ldr c7, [x16, #2]
	.inst 0xc2400e0c // ldr c12, [x16, #3]
	.inst 0xc2401217 // ldr c23, [x16, #4]
	.inst 0xc240161d // ldr c29, [x16, #5]
	.inst 0xc2401a1e // ldr c30, [x16, #6]
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =initial_SP_EL3_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2c1d21f // cpy c31, c16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30851037
	msr SCTLR_EL3, x16
	ldr x16, =0x4
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
	cmp x16, #0x0
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
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400e16 // ldr c22, [x16, #3]
	.inst 0xc2d6a461 // chkeq c3, c22
	b.ne comparison_fail
	.inst 0xc2401216 // ldr c22, [x16, #4]
	.inst 0xc2d6a4e1 // chkeq c7, c22
	b.ne comparison_fail
	.inst 0xc2401616 // ldr c22, [x16, #5]
	.inst 0xc2d6a581 // chkeq c12, c22
	b.ne comparison_fail
	.inst 0xc2401a16 // ldr c22, [x16, #6]
	.inst 0xc2d6a6e1 // chkeq c23, c22
	b.ne comparison_fail
	.inst 0xc2401e16 // ldr c22, [x16, #7]
	.inst 0xc2d6a701 // chkeq c24, c22
	b.ne comparison_fail
	.inst 0xc2402216 // ldr c22, [x16, #8]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc2402616 // ldr c22, [x16, #9]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001178
	ldr x1, =check_data1
	ldr x2, =0x00001179
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001cf0
	ldr x1, =check_data2
	ldr x2, =0x00001d00
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400024
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400040
	ldr x1, =check_data4
	ldr x2, =0x00400048
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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

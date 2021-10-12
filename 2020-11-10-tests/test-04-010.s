.section data0, #alloc, #write
	.zero 1008
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
	.zero 128
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2928
.data
check_data0:
	.byte 0x00, 0x80, 0x4f, 0x00
.data
check_data1:
	.byte 0x01, 0x00
.data
check_data2:
	.byte 0x80
.data
check_data3:
	.byte 0x58, 0xc7, 0x7d, 0x02, 0x46, 0x91, 0xc1, 0xc2, 0xc1, 0x73, 0x86, 0xe2, 0x3f, 0x7c, 0x5f, 0x08
	.byte 0xff, 0x73, 0x79, 0x78, 0x47, 0x50, 0xe2, 0x38, 0x13, 0xbc, 0x95, 0xb9, 0x40, 0x7c, 0x51, 0xd1
	.byte 0x1f, 0xe0, 0xc0, 0xc2, 0x06, 0x30, 0xc0, 0xc2, 0x00, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000001000500000000004fea3c
	/* C1 */
	.octa 0x800000000000800800000000004f8000
	/* C2 */
	.octa 0xc0000000000100050000000000001480
	/* C25 */
	.octa 0xa000
	/* C26 */
	.octa 0x5200400000000a0400040
	/* C30 */
	.octa 0xfd9
final_cap_values:
	/* C0 */
	.octa 0xffffffffffba2480
	/* C1 */
	.octa 0x800000000000800800000000004f8000
	/* C2 */
	.octa 0xc0000000000100050000000000001480
	/* C6 */
	.octa 0xffffffffffffffff
	/* C7 */
	.octa 0xff
	/* C19 */
	.octa 0x0
	/* C24 */
	.octa 0x5200400000000a1371040
	/* C25 */
	.octa 0xa000
	/* C26 */
	.octa 0x5200400000000a0400040
	/* C30 */
	.octa 0xfd9
initial_SP_EL3_value:
	.octa 0xc00000000001000500000000000013fc
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080100000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000000100060000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x027dc758 // ADD-C.CIS-C Cd:24 Cn:26 imm12:111101110001 sh:1 A:0 00000010:00000010
	.inst 0xc2c19146 // CLRTAG-C.C-C Cd:6 Cn:10 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xe28673c1 // ASTUR-R.RI-32 Rt:1 Rn:30 op2:00 imm9:001100111 V:0 op1:10 11100010:11100010
	.inst 0x085f7c3f // ldxrb:aarch64/instrs/memory/exclusive/single Rt:31 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0x787973ff // stuminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:111 o3:0 Rs:25 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x38e25047 // ldsminb:aarch64/instrs/memory/atomicops/ld Rt:7 Rn:2 00:00 opc:101 0:0 Rs:2 1:1 R:1 A:1 111000:111000 size:00
	.inst 0xb995bc13 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:19 Rn:0 imm12:010101101111 opc:10 111001:111001 size:10
	.inst 0xd1517c40 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:0 Rn:2 imm12:010001011111 sh:1 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0xc2c0e01f // SCFLGS-C.CR-C Cd:31 Cn:0 111000:111000 Rm:0 11000010110:11000010110
	.inst 0xc2c03006 // GCLEN-R.C-C Rd:6 Cn:0 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0xc2c21200
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
	ldr x11, =initial_cap_values
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400561 // ldr c1, [x11, #1]
	.inst 0xc2400962 // ldr c2, [x11, #2]
	.inst 0xc2400d79 // ldr c25, [x11, #3]
	.inst 0xc240117a // ldr c26, [x11, #4]
	.inst 0xc240157e // ldr c30, [x11, #5]
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =initial_SP_EL3_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2c1d17f // cpy c31, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30851037
	msr SCTLR_EL3, x11
	ldr x11, =0x0
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x8260320b // ldr c11, [c16, #3]
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	.inst 0x8260120b // ldr c11, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30851035
	msr SCTLR_EL3, x11
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400170 // ldr c16, [x11, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc2400570 // ldr c16, [x11, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400970 // ldr c16, [x11, #2]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400d70 // ldr c16, [x11, #3]
	.inst 0xc2d0a4c1 // chkeq c6, c16
	b.ne comparison_fail
	.inst 0xc2401170 // ldr c16, [x11, #4]
	.inst 0xc2d0a4e1 // chkeq c7, c16
	b.ne comparison_fail
	.inst 0xc2401570 // ldr c16, [x11, #5]
	.inst 0xc2d0a661 // chkeq c19, c16
	b.ne comparison_fail
	.inst 0xc2401970 // ldr c16, [x11, #6]
	.inst 0xc2d0a701 // chkeq c24, c16
	b.ne comparison_fail
	.inst 0xc2401d70 // ldr c16, [x11, #7]
	.inst 0xc2d0a721 // chkeq c25, c16
	b.ne comparison_fail
	.inst 0xc2402170 // ldr c16, [x11, #8]
	.inst 0xc2d0a741 // chkeq c26, c16
	b.ne comparison_fail
	.inst 0xc2402570 // ldr c16, [x11, #9]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001040
	ldr x1, =check_data0
	ldr x2, =0x00001044
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000013fc
	ldr x1, =check_data1
	ldr x2, =0x000013fe
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001480
	ldr x1, =check_data2
	ldr x2, =0x00001481
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
	ldr x0, =0x004f8000
	ldr x1, =check_data4
	ldr x2, =0x004f8001
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffff8
	ldr x1, =check_data5
	ldr x2, =0x004ffffc
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
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

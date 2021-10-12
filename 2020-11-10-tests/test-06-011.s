.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x42, 0x64, 0xa1, 0xea, 0x41, 0xa8, 0xde, 0xc2, 0x20, 0x00, 0x67, 0xb9, 0xc2, 0x43, 0x4c, 0x51
	.byte 0x62, 0x12, 0xc2, 0xc2
.data
check_data1:
	.byte 0x7e, 0x1f, 0x73, 0x82, 0xdf, 0x92, 0xc1, 0xc2, 0x1f, 0x01, 0x17, 0xfa, 0x9f, 0xc3, 0xbf, 0x38
	.byte 0xdc, 0x27, 0xc2, 0x9a, 0x60, 0x10, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C19 */
	.octa 0x20008000000100050000000000400019
	/* C27 */
	.octa 0x8c
	/* C28 */
	.octa 0x800000000001000500000000004ffffe
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xc2c2c2c2
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xffcf0000
	/* C19 */
	.octa 0x20008000000100050000000000400019
	/* C27 */
	.octa 0x8c
	/* C28 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C30 */
	.octa 0xc2c2c2c2c2c2c2c2
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000402100000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000400000040000000000400001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xeaa16442 // bics:aarch64/instrs/integer/logical/shiftedreg Rd:2 Rn:2 imm6:011001 Rm:1 N:1 shift:10 01010:01010 opc:11 sf:1
	.inst 0xc2dea841 // EORFLGS-C.CR-C Cd:1 Cn:2 1010:1010 opc:10 Rm:30 11000010110:11000010110
	.inst 0xb9670020 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:1 imm12:100111000000 opc:01 111001:111001 size:10
	.inst 0x514c43c2 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:2 Rn:30 imm12:001100010000 sh:1 0:0 10001:10001 S:0 op:1 sf:0
	.inst 0xc2c21262 // BRS-C-C 00010:00010 Cn:19 100:100 opc:00 11000010110000100:11000010110000100
	.zero 4
	.inst 0x82731f7e // ALDR-R.RI-64 Rt:30 Rn:27 op:11 imm9:100110001 L:1 1000001001:1000001001
	.inst 0xc2c192df // CLRTAG-C.C-C Cd:31 Cn:22 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xfa17011f // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:31 Rn:8 000000:000000 Rm:23 11010000:11010000 S:1 op:1 sf:1
	.inst 0x38bfc39f // ldaprb:aarch64/instrs/memory/ordered-rcpc Rt:31 Rn:28 110000:110000 Rs:11111 111000101:111000101 size:00
	.inst 0x9ac227dc // lsrv:aarch64/instrs/integer/shift/variable Rd:28 Rn:30 op2:01 0010:0010 Rm:2 0011010110:0011010110 sf:1
	.inst 0xc2c21060
	.zero 2536
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 7396
	.inst 0xc2c2c2c2
	.zero 1038580
	.inst 0x00c20000
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
	ldr x26, =initial_cap_values
	.inst 0xc2400341 // ldr c1, [x26, #0]
	.inst 0xc2400742 // ldr c2, [x26, #1]
	.inst 0xc2400b53 // ldr c19, [x26, #2]
	.inst 0xc2400f5b // ldr c27, [x26, #3]
	.inst 0xc240135c // ldr c28, [x26, #4]
	.inst 0xc240175e // ldr c30, [x26, #5]
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30851037
	msr SCTLR_EL3, x26
	ldr x26, =0x4
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x8260307a // ldr c26, [c3, #3]
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	.inst 0x8260107a // ldr c26, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30851035
	msr SCTLR_EL3, x26
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400343 // ldr c3, [x26, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc2400743 // ldr c3, [x26, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400b43 // ldr c3, [x26, #2]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400f43 // ldr c3, [x26, #3]
	.inst 0xc2c3a661 // chkeq c19, c3
	b.ne comparison_fail
	.inst 0xc2401343 // ldr c3, [x26, #4]
	.inst 0xc2c3a761 // chkeq c27, c3
	b.ne comparison_fail
	.inst 0xc2401743 // ldr c3, [x26, #5]
	.inst 0xc2c3a781 // chkeq c28, c3
	b.ne comparison_fail
	.inst 0xc2401b43 // ldr c3, [x26, #6]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00400000
	ldr x1, =check_data0
	ldr x2, =0x00400014
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400018
	ldr x1, =check_data1
	ldr x2, =0x00400030
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400a18
	ldr x1, =check_data2
	ldr x2, =0x00400a20
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00402704
	ldr x1, =check_data3
	ldr x2, =0x00402708
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004ffffe
	ldr x1, =check_data4
	ldr x2, =0x004fffff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
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

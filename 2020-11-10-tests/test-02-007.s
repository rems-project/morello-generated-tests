.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00
	.zero 768
	.byte 0x00, 0x00, 0x00, 0x00, 0x6b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3296
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x60, 0x00, 0x17
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x60, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x6b
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x09, 0x60, 0x20, 0x38, 0x39, 0xad, 0x62, 0xaa, 0xff, 0x63, 0x3f, 0x38, 0x3f, 0x70, 0x7a, 0x78
	.byte 0xce, 0x6b, 0xc2, 0xc2, 0x19, 0x30, 0xc1, 0xc2, 0x05, 0x50, 0x0d, 0x38, 0x0c, 0x22, 0xde, 0x9a
	.byte 0x58, 0x40, 0x12, 0x62, 0x41, 0x30, 0xc2, 0xc2, 0x60, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1306
	/* C1 */
	.octa 0x1000
	/* C2 */
	.octa 0xdd2
	/* C5 */
	.octa 0x0
	/* C16 */
	.octa 0x60000000000000000000000000
	/* C24 */
	.octa 0x17006000000000000000000000000000
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x3fff800000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x1306
	/* C1 */
	.octa 0x1000
	/* C2 */
	.octa 0xdd2
	/* C5 */
	.octa 0x0
	/* C9 */
	.octa 0x6b
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x3fff800000000000000000000000
	/* C16 */
	.octa 0x60000000000000000000000000
	/* C24 */
	.octa 0x17006000000000000000000000000000
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x3fff800000000000000000000000
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100600170000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000006003000e000000000000c003
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x38206009 // ldumaxb:aarch64/instrs/memory/atomicops/ld Rt:9 Rn:0 00:00 opc:110 0:0 Rs:0 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xaa62ad39 // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:25 Rn:9 imm6:101011 Rm:2 N:1 shift:01 01010:01010 opc:01 sf:1
	.inst 0x383f63ff // stumaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:110 o3:0 Rs:31 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x787a703f // stuminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:111 o3:0 Rs:26 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c26bce // ORRFLGS-C.CR-C Cd:14 Cn:30 1010:1010 opc:01 Rm:2 11000010110:11000010110
	.inst 0xc2c13019 // GCFLGS-R.C-C Rd:25 Cn:0 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0x380d5005 // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:5 Rn:0 00:00 imm9:011010101 0:0 opc:00 111000:111000 size:00
	.inst 0x9ade220c // lslv:aarch64/instrs/integer/shift/variable Rd:12 Rn:16 op2:00 0010:0010 Rm:30 0011010110:0011010110 sf:1
	.inst 0x62124058 // STNP-C.RIB-C Ct:24 Rn:2 Ct2:10000 imm7:0100100 L:0 011000100:011000100
	.inst 0xc2c23041 // CHKTGD-C-C 00001:00001 Cn:2 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xc2c21360
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
	.inst 0xc24012d0 // ldr c16, [x22, #4]
	.inst 0xc24016d8 // ldr c24, [x22, #5]
	.inst 0xc2401ada // ldr c26, [x22, #6]
	.inst 0xc2401ede // ldr c30, [x22, #7]
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =initial_SP_EL3_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2c1d2df // cpy c31, c22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x3085103f
	msr SCTLR_EL3, x22
	ldr x22, =0x4
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82603376 // ldr c22, [c27, #3]
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	.inst 0x82601376 // ldr c22, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
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
	mov x27, #0xf
	and x22, x22, x27
	cmp x22, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002db // ldr c27, [x22, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc24006db // ldr c27, [x22, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc2400adb // ldr c27, [x22, #2]
	.inst 0xc2dba441 // chkeq c2, c27
	b.ne comparison_fail
	.inst 0xc2400edb // ldr c27, [x22, #3]
	.inst 0xc2dba4a1 // chkeq c5, c27
	b.ne comparison_fail
	.inst 0xc24012db // ldr c27, [x22, #4]
	.inst 0xc2dba521 // chkeq c9, c27
	b.ne comparison_fail
	.inst 0xc24016db // ldr c27, [x22, #5]
	.inst 0xc2dba581 // chkeq c12, c27
	b.ne comparison_fail
	.inst 0xc2401adb // ldr c27, [x22, #6]
	.inst 0xc2dba5c1 // chkeq c14, c27
	b.ne comparison_fail
	.inst 0xc2401edb // ldr c27, [x22, #7]
	.inst 0xc2dba601 // chkeq c16, c27
	b.ne comparison_fail
	.inst 0xc24022db // ldr c27, [x22, #8]
	.inst 0xc2dba701 // chkeq c24, c27
	b.ne comparison_fail
	.inst 0xc24026db // ldr c27, [x22, #9]
	.inst 0xc2dba721 // chkeq c25, c27
	b.ne comparison_fail
	.inst 0xc2402adb // ldr c27, [x22, #10]
	.inst 0xc2dba741 // chkeq c26, c27
	b.ne comparison_fail
	.inst 0xc2402edb // ldr c27, [x22, #11]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000100e
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001040
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001314
	ldr x1, =check_data2
	ldr x2, =0x00001315
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000013e9
	ldr x1, =check_data3
	ldr x2, =0x000013ea
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

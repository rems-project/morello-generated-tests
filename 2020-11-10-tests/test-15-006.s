.section data0, #alloc, #write
	.zero 512
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3568
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0xdf, 0x72, 0x6b, 0x38, 0xe0, 0xf4, 0x4a, 0xa2, 0x40, 0x30, 0xc1, 0xc2, 0x22, 0x30, 0x8e, 0x9a
	.byte 0x01, 0xf4, 0x07, 0xc2, 0xf2, 0x5d, 0x11, 0x78, 0x99, 0x64, 0xb6, 0x82, 0xe3, 0xe3, 0x06, 0xb2
	.byte 0xcd, 0x30, 0xc3, 0xc2, 0x02, 0x4a, 0xa2, 0x38, 0x80, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x40000000602400340000000000000000
	/* C6 */
	.octa 0x800000000000000000000000
	/* C7 */
	.octa 0x1f20
	/* C11 */
	.octa 0x20
	/* C14 */
	.octa 0xc
	/* C15 */
	.octa 0x15c3
	/* C16 */
	.octa 0x1200
	/* C18 */
	.octa 0x0
	/* C22 */
	.octa 0x1200
	/* C25 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x4444444444444444
	/* C4 */
	.octa 0x40000000602400340000000000000000
	/* C6 */
	.octa 0x800000000000000000000000
	/* C7 */
	.octa 0x2a10
	/* C11 */
	.octa 0x20
	/* C13 */
	.octa 0x800000000000000000000000
	/* C14 */
	.octa 0xc
	/* C15 */
	.octa 0x14d8
	/* C16 */
	.octa 0x1200
	/* C18 */
	.octa 0x0
	/* C22 */
	.octa 0x1200
	/* C25 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000010100050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xdc10000000020003000000000000e7fa
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x386b72df // stuminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:22 00:00 opc:111 o3:0 Rs:11 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xa24af4e0 // LDR-C.RIAW-C Ct:0 Rn:7 01:01 imm9:010101111 0:0 opc:01 10100010:10100010
	.inst 0xc2c13040 // GCFLGS-R.C-C Rd:0 Cn:2 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0x9a8e3022 // csel:aarch64/instrs/integer/conditional/select Rd:2 Rn:1 o2:0 0:0 cond:0011 Rm:14 011010100:011010100 op:0 sf:1
	.inst 0xc207f401 // STR-C.RIB-C Ct:1 Rn:0 imm12:000111111101 L:0 110000100:110000100
	.inst 0x78115df2 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:18 Rn:15 11:11 imm9:100010101 0:0 opc:00 111000:111000 size:01
	.inst 0x82b66499 // ASTR-R.RRB-64 Rt:25 Rn:4 opc:01 S:0 option:011 Rm:22 1:1 L:0 100000101:100000101
	.inst 0xb206e3e3 // orr_log_imm:aarch64/instrs/integer/logical/immediate Rd:3 Rn:31 imms:111000 immr:000110 N:0 100100:100100 opc:01 sf:1
	.inst 0xc2c330cd // SEAL-C.CI-C Cd:13 Cn:6 100:100 form:01 11000010110000110:11000010110000110
	.inst 0x38a24a02 // ldrsb_reg:aarch64/instrs/memory/single/general/register Rt:2 Rn:16 10:10 S:0 option:010 Rm:2 1:1 opc:10 111000:111000 size:00
	.inst 0xc2c21180
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
	ldr x28, =initial_cap_values
	.inst 0xc2400381 // ldr c1, [x28, #0]
	.inst 0xc2400782 // ldr c2, [x28, #1]
	.inst 0xc2400b84 // ldr c4, [x28, #2]
	.inst 0xc2400f86 // ldr c6, [x28, #3]
	.inst 0xc2401387 // ldr c7, [x28, #4]
	.inst 0xc240178b // ldr c11, [x28, #5]
	.inst 0xc2401b8e // ldr c14, [x28, #6]
	.inst 0xc2401f8f // ldr c15, [x28, #7]
	.inst 0xc2402390 // ldr c16, [x28, #8]
	.inst 0xc2402792 // ldr c18, [x28, #9]
	.inst 0xc2402b96 // ldr c22, [x28, #10]
	.inst 0xc2402f99 // ldr c25, [x28, #11]
	/* Set up flags and system registers */
	mov x28, #0x20000000
	msr nzcv, x28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	ldr x28, =0x4
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x8260319c // ldr c28, [c12, #3]
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	.inst 0x8260119c // ldr c28, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	isb
	/* Check processor flags */
	mrs x28, nzcv
	ubfx x28, x28, #28, #4
	mov x12, #0x2
	and x28, x28, x12
	cmp x28, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc240038c // ldr c12, [x28, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc240078c // ldr c12, [x28, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc2400b8c // ldr c12, [x28, #2]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc2400f8c // ldr c12, [x28, #3]
	.inst 0xc2cca461 // chkeq c3, c12
	b.ne comparison_fail
	.inst 0xc240138c // ldr c12, [x28, #4]
	.inst 0xc2cca481 // chkeq c4, c12
	b.ne comparison_fail
	.inst 0xc240178c // ldr c12, [x28, #5]
	.inst 0xc2cca4c1 // chkeq c6, c12
	b.ne comparison_fail
	.inst 0xc2401b8c // ldr c12, [x28, #6]
	.inst 0xc2cca4e1 // chkeq c7, c12
	b.ne comparison_fail
	.inst 0xc2401f8c // ldr c12, [x28, #7]
	.inst 0xc2cca561 // chkeq c11, c12
	b.ne comparison_fail
	.inst 0xc240238c // ldr c12, [x28, #8]
	.inst 0xc2cca5a1 // chkeq c13, c12
	b.ne comparison_fail
	.inst 0xc240278c // ldr c12, [x28, #9]
	.inst 0xc2cca5c1 // chkeq c14, c12
	b.ne comparison_fail
	.inst 0xc2402b8c // ldr c12, [x28, #10]
	.inst 0xc2cca5e1 // chkeq c15, c12
	b.ne comparison_fail
	.inst 0xc2402f8c // ldr c12, [x28, #11]
	.inst 0xc2cca601 // chkeq c16, c12
	b.ne comparison_fail
	.inst 0xc240338c // ldr c12, [x28, #12]
	.inst 0xc2cca641 // chkeq c18, c12
	b.ne comparison_fail
	.inst 0xc240378c // ldr c12, [x28, #13]
	.inst 0xc2cca6c1 // chkeq c22, c12
	b.ne comparison_fail
	.inst 0xc2403b8c // ldr c12, [x28, #14]
	.inst 0xc2cca721 // chkeq c25, c12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001200
	ldr x1, =check_data0
	ldr x2, =0x00001208
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000120c
	ldr x1, =check_data1
	ldr x2, =0x0000120d
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000014d8
	ldr x1, =check_data2
	ldr x2, =0x000014da
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f20
	ldr x1, =check_data3
	ldr x2, =0x00001f30
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fd0
	ldr x1, =check_data4
	ldr x2, =0x00001fe0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
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

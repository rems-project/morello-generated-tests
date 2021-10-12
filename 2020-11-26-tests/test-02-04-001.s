.section data0, #alloc, #write
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x10
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x02
.data
check_data2:
	.byte 0x65, 0x10, 0x00, 0x00
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0xbf, 0x40, 0x7f, 0x78, 0x01, 0xb0, 0xc0, 0xc2, 0x14, 0xe8, 0xc0, 0xc2, 0xec, 0xee, 0x0e, 0xa2
	.byte 0x6f, 0xef, 0x19, 0xe2, 0xc0, 0xbb, 0x3a, 0xe2, 0xbf, 0x5f, 0xa0, 0x4a, 0x00, 0x9b, 0xe9, 0xc2
	.byte 0xfe, 0x47, 0x18, 0xb8, 0xe0, 0x73, 0xc2, 0xc2, 0x80, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C5 */
	.octa 0xc0000000510100040000000000001000
	/* C9 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C23 */
	.octa 0x40000000000100050000000000001000
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x1204
	/* C30 */
	.octa 0x1065
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0xc0000000510100040000000000001000
	/* C9 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C23 */
	.octa 0x40000000000100050000000000001ee0
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x1204
	/* C30 */
	.octa 0x1065
initial_SP_EL3_value:
	.octa 0x40000000000100060000000000001040
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000a0080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000000030007000000000000f677
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x787f40bf // stsmaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:5 00:00 opc:100 o3:0 Rs:31 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c0b001 // GCSEAL-R.C-C Rd:1 Cn:0 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xc2c0e814 // CTHI-C.CR-C Cd:20 Cn:0 1010:1010 opc:11 Rm:0 11000010110:11000010110
	.inst 0xa20eeeec // STR-C.RIBW-C Ct:12 Rn:23 11:11 imm9:011101110 0:0 opc:00 10100010:10100010
	.inst 0xe219ef6f // ALDURSB-R.RI-32 Rt:15 Rn:27 op2:11 imm9:110011110 V:0 op1:00 11100010:11100010
	.inst 0xe23abbc0 // ASTUR-V.RI-Q Rt:0 Rn:30 op2:10 imm9:110101011 V:1 op1:00 11100010:11100010
	.inst 0x4aa05fbf // eon:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:29 imm6:010111 Rm:0 N:1 shift:10 01010:01010 opc:10 sf:0
	.inst 0xc2e99b00 // SUBS-R.CC-C Rd:0 Cn:24 100110:100110 Cm:9 11000010111:11000010111
	.inst 0xb81847fe // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:31 01:01 imm9:110000100 0:0 opc:00 111000:111000 size:10
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xc2c21380
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
	.inst 0xc24006a5 // ldr c5, [x21, #1]
	.inst 0xc2400aa9 // ldr c9, [x21, #2]
	.inst 0xc2400eac // ldr c12, [x21, #3]
	.inst 0xc24012b7 // ldr c23, [x21, #4]
	.inst 0xc24016b8 // ldr c24, [x21, #5]
	.inst 0xc2401abb // ldr c27, [x21, #6]
	.inst 0xc2401ebe // ldr c30, [x21, #7]
	/* Vector registers */
	mrs x21, cptr_el3
	bfc x21, #10, #1
	msr cptr_el3, x21
	isb
	ldr q0, =0x2000010000000000800000000000000
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =initial_SP_EL3_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2c1d2bf // cpy c31, c21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	ldr x21, =0x4
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82603395 // ldr c21, [c28, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x82601395 // ldr c21, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
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
	mov x28, #0xf
	and x21, x21, x28
	cmp x21, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002bc // ldr c28, [x21, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc24006bc // ldr c28, [x21, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc2400abc // ldr c28, [x21, #2]
	.inst 0xc2dca4a1 // chkeq c5, c28
	b.ne comparison_fail
	.inst 0xc2400ebc // ldr c28, [x21, #3]
	.inst 0xc2dca521 // chkeq c9, c28
	b.ne comparison_fail
	.inst 0xc24012bc // ldr c28, [x21, #4]
	.inst 0xc2dca581 // chkeq c12, c28
	b.ne comparison_fail
	.inst 0xc24016bc // ldr c28, [x21, #5]
	.inst 0xc2dca5e1 // chkeq c15, c28
	b.ne comparison_fail
	.inst 0xc2401abc // ldr c28, [x21, #6]
	.inst 0xc2dca681 // chkeq c20, c28
	b.ne comparison_fail
	.inst 0xc2401ebc // ldr c28, [x21, #7]
	.inst 0xc2dca6e1 // chkeq c23, c28
	b.ne comparison_fail
	.inst 0xc24022bc // ldr c28, [x21, #8]
	.inst 0xc2dca701 // chkeq c24, c28
	b.ne comparison_fail
	.inst 0xc24026bc // ldr c28, [x21, #9]
	.inst 0xc2dca761 // chkeq c27, c28
	b.ne comparison_fail
	.inst 0xc2402abc // ldr c28, [x21, #10]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check vector registers */
	ldr x21, =0x800000000000000
	mov x28, v0.d[0]
	cmp x21, x28
	b.ne comparison_fail
	ldr x21, =0x200001000000000
	mov x28, v0.d[1]
	cmp x21, x28
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
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001020
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001040
	ldr x1, =check_data2
	ldr x2, =0x00001044
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000011a2
	ldr x1, =check_data3
	ldr x2, =0x000011a3
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ee0
	ldr x1, =check_data4
	ldr x2, =0x00001ef0
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

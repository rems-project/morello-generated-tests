.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 32
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x84, 0xc3, 0xfd, 0x62, 0x61, 0xe5, 0xfd, 0xc2, 0xe1, 0xeb, 0x92, 0x39, 0x07, 0xe0, 0x1a, 0xb9
	.byte 0xa5, 0x3d, 0x3a, 0x0a, 0xbd, 0x60, 0xde, 0xc2, 0xff, 0x3b, 0xca, 0xc2, 0xd5, 0xb5, 0xad, 0xe2
	.byte 0x0a, 0x10, 0xc5, 0xc2, 0x2e, 0x30, 0x3d, 0x0b, 0x40, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4000000060010fe80000000000000500
	/* C1 */
	.octa 0x4000000000000000000000000000
	/* C7 */
	.octa 0x0
	/* C11 */
	.octa 0x784100000030c000
	/* C14 */
	.octa 0x1029
	/* C28 */
	.octa 0x90100000000100070000000000002000
	/* C29 */
	.octa 0x87beffffffcf5000
final_cap_values:
	/* C0 */
	.octa 0x4000000060010fe80000000000000500
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x784100000030c000
	/* C16 */
	.octa 0x0
	/* C28 */
	.octa 0x90100000000100070000000000001fb0
initial_SP_EL3_value:
	.octa 0x80000000000700070000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080003d6b00070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc80000005d0605000000000000000021
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fb0
	.dword 0x0000000000001fc0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x62fdc384 // LDP-C.RIBW-C Ct:4 Rn:28 Ct2:10000 imm7:1111011 L:1 011000101:011000101
	.inst 0xc2fde561 // ASTR-C.RRB-C Ct:1 Rn:11 1:1 L:0 S:0 option:111 Rm:29 11000010111:11000010111
	.inst 0x3992ebe1 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:31 imm12:010010111010 opc:10 111001:111001 size:00
	.inst 0xb91ae007 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:7 Rn:0 imm12:011010111000 opc:00 111001:111001 size:10
	.inst 0x0a3a3da5 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:5 Rn:13 imm6:001111 Rm:26 N:1 shift:00 01010:01010 opc:00 sf:0
	.inst 0xc2de60bd // SCOFF-C.CR-C Cd:29 Cn:5 000:000 opc:11 0:0 Rm:30 11000010110:11000010110
	.inst 0xc2ca3bff // SCBNDS-C.CI-C Cd:31 Cn:31 1110:1110 S:0 imm6:010100 11000010110:11000010110
	.inst 0xe2adb5d5 // ALDUR-V.RI-S Rt:21 Rn:14 op2:01 imm9:011011011 V:1 op1:10 11100010:11100010
	.inst 0xc2c5100a // CVTD-R.C-C Rd:10 Cn:0 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0x0b3d302e // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:14 Rn:1 imm3:100 option:001 Rm:29 01011001:01011001 S:0 op:0 sf:0
	.inst 0xc2c21040
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c1 // ldr c1, [x6, #1]
	.inst 0xc24008c7 // ldr c7, [x6, #2]
	.inst 0xc2400ccb // ldr c11, [x6, #3]
	.inst 0xc24010ce // ldr c14, [x6, #4]
	.inst 0xc24014dc // ldr c28, [x6, #5]
	.inst 0xc24018dd // ldr c29, [x6, #6]
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =initial_SP_EL3_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2c1d0df // cpy c31, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	ldr x6, =0x4
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x2, =pcc_return_ddc_capabilities
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0x82603046 // ldr c6, [c2, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x82601046 // ldr c6, [c2, #1]
	.inst 0x82602042 // ldr c2, [c2, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	isb
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x2, #0xf
	and x6, x6, x2
	cmp x6, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000c2 // ldr c2, [x6, #0]
	.inst 0xc2c2a401 // chkeq c0, c2
	b.ne comparison_fail
	.inst 0xc24004c2 // ldr c2, [x6, #1]
	.inst 0xc2c2a421 // chkeq c1, c2
	b.ne comparison_fail
	.inst 0xc24008c2 // ldr c2, [x6, #2]
	.inst 0xc2c2a481 // chkeq c4, c2
	b.ne comparison_fail
	.inst 0xc2400cc2 // ldr c2, [x6, #3]
	.inst 0xc2c2a4e1 // chkeq c7, c2
	b.ne comparison_fail
	.inst 0xc24010c2 // ldr c2, [x6, #4]
	.inst 0xc2c2a541 // chkeq c10, c2
	b.ne comparison_fail
	.inst 0xc24014c2 // ldr c2, [x6, #5]
	.inst 0xc2c2a561 // chkeq c11, c2
	b.ne comparison_fail
	.inst 0xc24018c2 // ldr c2, [x6, #6]
	.inst 0xc2c2a601 // chkeq c16, c2
	b.ne comparison_fail
	.inst 0xc2401cc2 // ldr c2, [x6, #7]
	.inst 0xc2c2a781 // chkeq c28, c2
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x2, v21.d[0]
	cmp x6, x2
	b.ne comparison_fail
	ldr x6, =0x0
	mov x2, v21.d[1]
	cmp x6, x2
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000014ba
	ldr x1, =check_data0
	ldr x2, =0x000014bb
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001500
	ldr x1, =check_data1
	ldr x2, =0x00001510
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001604
	ldr x1, =check_data2
	ldr x2, =0x00001608
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fb0
	ldr x1, =check_data3
	ldr x2, =0x00001fd0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fe0
	ldr x1, =check_data4
	ldr x2, =0x00001fe4
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
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
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

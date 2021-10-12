.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x51, 0xfc, 0xdf, 0xc8, 0xe1, 0x40, 0x14, 0xb8, 0x07, 0xf0, 0xc0, 0xc2, 0x42, 0x51, 0x57, 0x78
	.byte 0x06, 0x2a, 0xa8, 0xf9, 0xdb, 0x73, 0x1d, 0xe2, 0xbe, 0x27, 0xca, 0x9a, 0x3e, 0x00, 0x15, 0xda
	.byte 0xdf, 0x7b, 0x28, 0xf8, 0x35, 0x0f, 0xdb, 0x1a, 0xa0, 0x10, 0xc2, 0xc2
.data
check_data4:
	.zero 8
.data
check_data5:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x8000000000000000
	/* C2 */
	.octa 0x441100
	/* C7 */
	.octa 0x203c
	/* C8 */
	.octa 0x200
	/* C10 */
	.octa 0x480083
	/* C21 */
	.octa 0x7fffffffffffffff
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x40000000000700170000000000002000
final_cap_values:
	/* C1 */
	.octa 0x8000000000000000
	/* C2 */
	.octa 0x0
	/* C8 */
	.octa 0x200
	/* C10 */
	.octa 0x480083
	/* C17 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500100000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000180050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc8dffc51 // ldar:aarch64/instrs/memory/ordered Rt:17 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0xb81440e1 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:7 00:00 imm9:101000100 0:0 opc:00 111000:111000 size:10
	.inst 0xc2c0f007 // GCTYPE-R.C-C Rd:7 Cn:0 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0x78575142 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:10 00:00 imm9:101110101 0:0 opc:01 111000:111000 size:01
	.inst 0xf9a82a06 // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:6 Rn:16 imm12:101000001010 opc:10 111001:111001 size:11
	.inst 0xe21d73db // ASTURB-R.RI-32 Rt:27 Rn:30 op2:00 imm9:111010111 V:0 op1:00 11100010:11100010
	.inst 0x9aca27be // lsrv:aarch64/instrs/integer/shift/variable Rd:30 Rn:29 op2:01 0010:0010 Rm:10 0011010110:0011010110 sf:1
	.inst 0xda15003e // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:30 Rn:1 000000:000000 Rm:21 11010000:11010000 S:0 op:1 sf:1
	.inst 0xf8287bdf // str_reg_gen:aarch64/instrs/memory/single/general/register Rt:31 Rn:30 10:10 S:1 option:011 Rm:8 1:1 opc:00 111000:111000 size:11
	.inst 0x1adb0f35 // sdiv:aarch64/instrs/integer/arithmetic/div Rd:21 Rn:25 o1:1 00001:00001 Rm:27 0011010110:0011010110 sf:0
	.inst 0xc2c210a0
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
	ldr x20, =initial_cap_values
	.inst 0xc2400281 // ldr c1, [x20, #0]
	.inst 0xc2400682 // ldr c2, [x20, #1]
	.inst 0xc2400a87 // ldr c7, [x20, #2]
	.inst 0xc2400e88 // ldr c8, [x20, #3]
	.inst 0xc240128a // ldr c10, [x20, #4]
	.inst 0xc2401695 // ldr c21, [x20, #5]
	.inst 0xc2401a9b // ldr c27, [x20, #6]
	.inst 0xc2401e9e // ldr c30, [x20, #7]
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30851037
	msr SCTLR_EL3, x20
	ldr x20, =0x4
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030b4 // ldr c20, [c5, #3]
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	.inst 0x826010b4 // ldr c20, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	isb
	/* Check processor flags */
	mrs x20, nzcv
	ubfx x20, x20, #28, #4
	mov x5, #0x2
	and x20, x20, x5
	cmp x20, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc2400285 // ldr c5, [x20, #0]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400685 // ldr c5, [x20, #1]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400a85 // ldr c5, [x20, #2]
	.inst 0xc2c5a501 // chkeq c8, c5
	b.ne comparison_fail
	.inst 0xc2400e85 // ldr c5, [x20, #3]
	.inst 0xc2c5a541 // chkeq c10, c5
	b.ne comparison_fail
	.inst 0xc2401285 // ldr c5, [x20, #4]
	.inst 0xc2c5a621 // chkeq c17, c5
	b.ne comparison_fail
	.inst 0xc2401685 // ldr c5, [x20, #5]
	.inst 0xc2c5a6a1 // chkeq c21, c5
	b.ne comparison_fail
	.inst 0xc2401a85 // ldr c5, [x20, #6]
	.inst 0xc2c5a761 // chkeq c27, c5
	b.ne comparison_fail
	.inst 0xc2401e85 // ldr c5, [x20, #7]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001f80
	ldr x1, =check_data1
	ldr x2, =0x00001f84
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fd7
	ldr x1, =check_data2
	ldr x2, =0x00001fd8
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
	ldr x0, =0x00441100
	ldr x1, =check_data4
	ldr x2, =0x00441108
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0047fff8
	ldr x1, =check_data5
	ldr x2, =0x0047fffa
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
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

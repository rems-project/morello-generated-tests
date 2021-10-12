.section data0, #alloc, #write
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 208
	.byte 0x20, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x01, 0xa2, 0x01, 0x81, 0x40, 0x20
	.zero 3856
.data
check_data0:
	.byte 0x01, 0x00
.data
check_data1:
	.zero 16
	.byte 0x20, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x01, 0xa2, 0x01, 0x81, 0x40, 0x20
.data
check_data2:
	.byte 0x02, 0x70, 0xbe, 0x78, 0x20, 0x30, 0x9f, 0x1a, 0xff, 0x9b, 0xe2, 0xc2, 0xc1, 0x0b, 0xd2, 0xc2
	.byte 0x19, 0xa5, 0x07, 0x98, 0xec, 0xeb, 0x0d, 0xf0, 0xe1, 0xab, 0xee, 0x42, 0x40, 0xc5, 0xd5, 0xc2
	.byte 0xde, 0x11, 0xc5, 0xc2, 0xe6, 0xb2, 0xc5, 0xc2, 0xa0, 0x11, 0xc2, 0xc2
.data
check_data3:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0x2000000000100040000000000000000
	/* C21 */
	.octa 0x400101800000000000000000000000
	/* C23 */
	.octa 0x1
	/* C30 */
	.octa 0x8000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1
	/* C6 */
	.octa 0x20408000220100070000000000000001
	/* C10 */
	.octa 0x20408101a20100070000000000400020
	/* C12 */
	.octa 0x1c17f000
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0x2000000000100040000000000000000
	/* C21 */
	.octa 0x400101800000000000000000000000
	/* C23 */
	.octa 0x1
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x400000000000000000000000000000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1300
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0008000000100050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0100000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000010e0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x78be7002 // lduminh:aarch64/instrs/memory/atomicops/ld Rt:2 Rn:0 00:00 opc:111 0:0 Rs:30 1:1 R:0 A:1 111000:111000 size:01
	.inst 0x1a9f3020 // csel:aarch64/instrs/integer/conditional/select Rd:0 Rn:1 o2:0 0:0 cond:0011 Rm:31 011010100:011010100 op:0 sf:0
	.inst 0xc2e29bff // SUBS-R.CC-C Rd:31 Cn:31 100110:100110 Cm:2 11000010111:11000010111
	.inst 0xc2d20bc1 // SEAL-C.CC-C Cd:1 Cn:30 0010:0010 opc:00 Cm:18 11000010110:11000010110
	.inst 0x9807a519 // ldrsw_lit:aarch64/instrs/memory/literal/general Rt:25 imm19:0000011110100101000 011000:011000 opc:10
	.inst 0xf00debec // ADRDP-C.ID-C Rd:12 immhi:000110111101011111 P:0 10000:10000 immlo:11 op:1
	.inst 0x42eeabe1 // LDP-C.RIB-C Ct:1 Rn:31 Ct2:01010 imm7:1011101 L:1 010000101:010000101
	.inst 0xc2d5c540 // RETS-C.C-C 00000:00000 Cn:10 001:001 opc:10 1:1 Cm:21 11000010110:11000010110
	.inst 0xc2c511de // CVTD-R.C-C Rd:30 Cn:14 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0xc2c5b2e6 // CVTP-C.R-C Cd:6 Rn:23 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xc2c211a0
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
	ldr x17, =initial_cap_values
	.inst 0xc2400220 // ldr c0, [x17, #0]
	.inst 0xc240062e // ldr c14, [x17, #1]
	.inst 0xc2400a32 // ldr c18, [x17, #2]
	.inst 0xc2400e35 // ldr c21, [x17, #3]
	.inst 0xc2401237 // ldr c23, [x17, #4]
	.inst 0xc240163e // ldr c30, [x17, #5]
	/* Set up flags and system registers */
	mov x17, #0x20000000
	msr nzcv, x17
	ldr x17, =initial_SP_EL3_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2c1d23f // cpy c31, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30851035
	msr SCTLR_EL3, x17
	ldr x17, =0x0
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031b1 // ldr c17, [c13, #3]
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	.inst 0x826011b1 // ldr c17, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c21220 // br c17
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30851035
	msr SCTLR_EL3, x17
	isb
	/* Check processor flags */
	mrs x17, nzcv
	ubfx x17, x17, #28, #4
	mov x13, #0xf
	and x17, x17, x13
	cmp x17, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc240022d // ldr c13, [x17, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240062d // ldr c13, [x17, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc2400a2d // ldr c13, [x17, #2]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc2400e2d // ldr c13, [x17, #3]
	.inst 0xc2cda4c1 // chkeq c6, c13
	b.ne comparison_fail
	.inst 0xc240122d // ldr c13, [x17, #4]
	.inst 0xc2cda541 // chkeq c10, c13
	b.ne comparison_fail
	.inst 0xc240162d // ldr c13, [x17, #5]
	.inst 0xc2cda581 // chkeq c12, c13
	b.ne comparison_fail
	.inst 0xc2401a2d // ldr c13, [x17, #6]
	.inst 0xc2cda5c1 // chkeq c14, c13
	b.ne comparison_fail
	.inst 0xc2401e2d // ldr c13, [x17, #7]
	.inst 0xc2cda641 // chkeq c18, c13
	b.ne comparison_fail
	.inst 0xc240222d // ldr c13, [x17, #8]
	.inst 0xc2cda6a1 // chkeq c21, c13
	b.ne comparison_fail
	.inst 0xc240262d // ldr c13, [x17, #9]
	.inst 0xc2cda6e1 // chkeq c23, c13
	b.ne comparison_fail
	.inst 0xc2402a2d // ldr c13, [x17, #10]
	.inst 0xc2cda721 // chkeq c25, c13
	b.ne comparison_fail
	.inst 0xc2402e2d // ldr c13, [x17, #11]
	.inst 0xc2cda7a1 // chkeq c29, c13
	b.ne comparison_fail
	.inst 0xc240322d // ldr c13, [x17, #12]
	.inst 0xc2cda7c1 // chkeq c30, c13
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
	ldr x0, =0x000010d0
	ldr x1, =check_data1
	ldr x2, =0x000010f0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0040f4b0
	ldr x1, =check_data3
	ldr x2, =0x0040f4b4
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
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

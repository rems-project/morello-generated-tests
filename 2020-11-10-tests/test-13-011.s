.section data0, #alloc, #write
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2496
	.byte 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1520
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 32
.data
check_data0:
	.byte 0x01
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x01, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x40, 0x10, 0xc2, 0xc2
.data
check_data5:
	.byte 0x9e, 0x11, 0x1b, 0x31, 0x2e, 0x4a, 0xd6, 0xc2, 0xdd, 0x57, 0x36, 0xe2, 0xff, 0x63, 0x60, 0xb8
	.byte 0x00, 0x00, 0x13, 0xfa, 0xa0, 0x13, 0xc2, 0xc2
.data
check_data6:
	.byte 0xc1, 0x81, 0xdc, 0x36, 0xde, 0x73, 0xe9, 0x38, 0x9e, 0x71, 0xe5, 0xb8, 0x42, 0x32, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x8000000
	/* C2 */
	.octa 0x200080008007c006000000000047fff0
	/* C5 */
	.octa 0x0
	/* C9 */
	.octa 0x40
	/* C12 */
	.octa 0x19d4
	/* C17 */
	.octa 0x800000000000000000000000
	/* C18 */
	.octa 0x20008000800100050000000000400021
	/* C22 */
	.octa 0x1000000000710010000000000000001
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C1 */
	.octa 0x8000000
	/* C2 */
	.octa 0x200080008007c006000000000047fff0
	/* C5 */
	.octa 0x0
	/* C9 */
	.octa 0x40
	/* C12 */
	.octa 0x19d4
	/* C14 */
	.octa 0x0
	/* C17 */
	.octa 0x800000000000000000000000
	/* C18 */
	.octa 0x20008000800100050000000000400021
	/* C22 */
	.octa 0x1000000000710010000000000000001
	/* C30 */
	.octa 0x2098
initial_SP_EL3_value:
	.octa 0xc0000000000100050000000000001fd0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000000080000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword initial_cap_values + 128
	.dword final_cap_values + 16
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c21040 // BR-C-C 00000:00000 Cn:2 100:100 opc:00 11000010110000100:11000010110000100
	.zero 28
	.inst 0x311b119e // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:30 Rn:12 imm12:011011000100 sh:0 0:0 10001:10001 S:1 op:0 sf:0
	.inst 0xc2d64a2e // UNSEAL-C.CC-C Cd:14 Cn:17 0010:0010 opc:01 Cm:22 11000010110:11000010110
	.inst 0xe23657dd // ALDUR-V.RI-B Rt:29 Rn:30 op2:01 imm9:101100101 V:1 op1:00 11100010:11100010
	.inst 0xb86063ff // stumax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:110 o3:0 Rs:0 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0xfa130000 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:0 Rn:0 000000:000000 Rm:19 11010000:11010000 S:1 op:1 sf:1
	.inst 0xc2c213a0
	.zero 524216
	.inst 0x36dc81c1 // tbz:aarch64/instrs/branch/conditional/test Rt:1 imm14:10010000001110 b40:11011 op:0 011011:011011 b5:0
	.inst 0x38e973de // lduminb:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:30 00:00 opc:111 0:0 Rs:9 1:1 R:1 A:1 111000:111000 size:00
	.inst 0xb8e5719e // ldumin:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:12 00:00 opc:111 0:0 Rs:5 1:1 R:1 A:1 111000:111000 size:10
	.inst 0xc2c23242 // BLRS-C-C 00010:00010 Cn:18 100:100 opc:01 11000010110000100:11000010110000100
	.zero 524288
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
	.inst 0xc2400340 // ldr c0, [x26, #0]
	.inst 0xc2400741 // ldr c1, [x26, #1]
	.inst 0xc2400b42 // ldr c2, [x26, #2]
	.inst 0xc2400f45 // ldr c5, [x26, #3]
	.inst 0xc2401349 // ldr c9, [x26, #4]
	.inst 0xc240174c // ldr c12, [x26, #5]
	.inst 0xc2401b51 // ldr c17, [x26, #6]
	.inst 0xc2401f52 // ldr c18, [x26, #7]
	.inst 0xc2402356 // ldr c22, [x26, #8]
	.inst 0xc240275e // ldr c30, [x26, #9]
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =initial_SP_EL3_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2c1d35f // cpy c31, c26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x3085103f
	msr SCTLR_EL3, x26
	ldr x26, =0x84
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x29, =pcc_return_ddc_capabilities
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0x826033ba // ldr c26, [c29, #3]
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	.inst 0x826013ba // ldr c26, [c29, #1]
	.inst 0x826023bd // ldr c29, [c29, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30851035
	msr SCTLR_EL3, x26
	isb
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x29, #0x3
	and x26, x26, x29
	cmp x26, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc240035d // ldr c29, [x26, #0]
	.inst 0xc2dda421 // chkeq c1, c29
	b.ne comparison_fail
	.inst 0xc240075d // ldr c29, [x26, #1]
	.inst 0xc2dda441 // chkeq c2, c29
	b.ne comparison_fail
	.inst 0xc2400b5d // ldr c29, [x26, #2]
	.inst 0xc2dda4a1 // chkeq c5, c29
	b.ne comparison_fail
	.inst 0xc2400f5d // ldr c29, [x26, #3]
	.inst 0xc2dda521 // chkeq c9, c29
	b.ne comparison_fail
	.inst 0xc240135d // ldr c29, [x26, #4]
	.inst 0xc2dda581 // chkeq c12, c29
	b.ne comparison_fail
	.inst 0xc240175d // ldr c29, [x26, #5]
	.inst 0xc2dda5c1 // chkeq c14, c29
	b.ne comparison_fail
	.inst 0xc2401b5d // ldr c29, [x26, #6]
	.inst 0xc2dda621 // chkeq c17, c29
	b.ne comparison_fail
	.inst 0xc2401f5d // ldr c29, [x26, #7]
	.inst 0xc2dda641 // chkeq c18, c29
	b.ne comparison_fail
	.inst 0xc240235d // ldr c29, [x26, #8]
	.inst 0xc2dda6c1 // chkeq c22, c29
	b.ne comparison_fail
	.inst 0xc240275d // ldr c29, [x26, #9]
	.inst 0xc2dda7c1 // chkeq c30, c29
	b.ne comparison_fail
	/* Check vector registers */
	ldr x26, =0x0
	mov x29, v29.d[0]
	cmp x26, x29
	b.ne comparison_fail
	ldr x26, =0x0
	mov x29, v29.d[1]
	cmp x26, x29
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
	ldr x0, =0x000019d4
	ldr x1, =check_data1
	ldr x2, =0x000019d8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fd0
	ldr x1, =check_data2
	ldr x2, =0x00001fd4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffd
	ldr x1, =check_data3
	ldr x2, =0x00001ffe
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400004
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400020
	ldr x1, =check_data5
	ldr x2, =0x00400038
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0047fff0
	ldr x1, =check_data6
	ldr x2, =0x00480000
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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

.section data0, #alloc, #write
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xff
.data
check_data1:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0xe1, 0x53, 0x5f, 0xb3, 0xff, 0xcb, 0x93, 0xb8, 0x3e, 0x7f, 0xdf, 0x9b, 0x3d, 0x7e, 0x9f, 0xc8
	.byte 0xbf, 0x13, 0x6f, 0x38, 0x00, 0x87, 0xc6, 0xc2
.data
check_data4:
	.zero 16
.data
check_data5:
	.zero 4
.data
check_data6:
	.zero 2
.data
check_data7:
	.byte 0x60, 0x00, 0x19, 0xda, 0xdf, 0x03, 0x28, 0x78, 0xf6, 0xcf, 0x5e, 0x78, 0xe1, 0xec, 0x43, 0xa8
	.byte 0xa0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C6 */
	.octa 0x400002000000000000000000000000
	/* C7 */
	.octa 0x400000
	/* C8 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x4000000040040c040000000000001400
	/* C24 */
	.octa 0x20408002000d000c0000000000440000
	/* C29 */
	.octa 0xc0000000000700070000000000001000
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C6 */
	.octa 0x400002000000000000000000000000
	/* C7 */
	.octa 0x400000
	/* C8 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x4000000040040c040000000000001400
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0x20408002000d000c0000000000440000
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x400000000000000000000000000000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x80000000000080080000000000407020
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100100050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000001006001f00ffffffffe00001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb35f53e1 // bfm:aarch64/instrs/integer/bitfield Rd:1 Rn:31 imms:010100 immr:011111 N:1 100110:100110 opc:01 sf:1
	.inst 0xb893cbff // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:31 10:10 imm9:100111100 0:0 opc:10 111000:111000 size:10
	.inst 0x9bdf7f3e // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:30 Rn:25 Ra:11111 0:0 Rm:31 10:10 U:1 10011011:10011011
	.inst 0xc89f7e3d // stllr:aarch64/instrs/memory/ordered Rt:29 Rn:17 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0x386f13bf // stclrb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:001 o3:0 Rs:15 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2c68700 // BRS-C.C-C 00000:00000 Cn:24 001:001 opc:00 1:1 Cm:6 11000010110:11000010110
	.zero 262120
	.inst 0xda190060 // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:0 Rn:3 000000:000000 Rm:25 11010000:11010000 S:0 op:1 sf:1
	.inst 0x782803df // staddh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:000 o3:0 Rs:8 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x785ecff6 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:22 Rn:31 11:11 imm9:111101100 0:0 opc:01 111000:111000 size:01
	.inst 0xa843ece1 // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:1 Rn:7 Rt2:11011 imm7:0000111 L:1 1010000:1010000 opc:10
	.inst 0xc2c210a0
	.zero 786412
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
	ldr x2, =initial_cap_values
	.inst 0xc2400046 // ldr c6, [x2, #0]
	.inst 0xc2400447 // ldr c7, [x2, #1]
	.inst 0xc2400848 // ldr c8, [x2, #2]
	.inst 0xc2400c4f // ldr c15, [x2, #3]
	.inst 0xc2401051 // ldr c17, [x2, #4]
	.inst 0xc2401458 // ldr c24, [x2, #5]
	.inst 0xc240185d // ldr c29, [x2, #6]
	/* Set up flags and system registers */
	mov x2, #0x00000000
	msr nzcv, x2
	ldr x2, =initial_SP_EL3_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2c1d05f // cpy c31, c2
	ldr x2, =0x200
	msr CPTR_EL3, x2
	ldr x2, =0x3085103f
	msr SCTLR_EL3, x2
	ldr x2, =0x4
	msr S3_6_C1_C2_2, x2 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030a2 // ldr c2, [c5, #3]
	.inst 0xc28b4122 // msr DDC_EL3, c2
	isb
	.inst 0x826010a2 // ldr c2, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c21040 // br c2
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30851035
	msr SCTLR_EL3, x2
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x2, =final_cap_values
	.inst 0xc2400045 // ldr c5, [x2, #0]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400445 // ldr c5, [x2, #1]
	.inst 0xc2c5a4c1 // chkeq c6, c5
	b.ne comparison_fail
	.inst 0xc2400845 // ldr c5, [x2, #2]
	.inst 0xc2c5a4e1 // chkeq c7, c5
	b.ne comparison_fail
	.inst 0xc2400c45 // ldr c5, [x2, #3]
	.inst 0xc2c5a501 // chkeq c8, c5
	b.ne comparison_fail
	.inst 0xc2401045 // ldr c5, [x2, #4]
	.inst 0xc2c5a5e1 // chkeq c15, c5
	b.ne comparison_fail
	.inst 0xc2401445 // ldr c5, [x2, #5]
	.inst 0xc2c5a621 // chkeq c17, c5
	b.ne comparison_fail
	.inst 0xc2401845 // ldr c5, [x2, #6]
	.inst 0xc2c5a6c1 // chkeq c22, c5
	b.ne comparison_fail
	.inst 0xc2401c45 // ldr c5, [x2, #7]
	.inst 0xc2c5a701 // chkeq c24, c5
	b.ne comparison_fail
	.inst 0xc2402045 // ldr c5, [x2, #8]
	.inst 0xc2c5a761 // chkeq c27, c5
	b.ne comparison_fail
	.inst 0xc2402445 // ldr c5, [x2, #9]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	.inst 0xc2402845 // ldr c5, [x2, #10]
	.inst 0xc2c5a7c1 // chkeq c30, c5
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
	ldr x0, =0x00001400
	ldr x1, =check_data1
	ldr x2, =0x00001408
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001802
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400018
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00401838
	ldr x1, =check_data4
	ldr x2, =0x00401848
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00406f5c
	ldr x1, =check_data5
	ldr x2, =0x00406f60
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0040880c
	ldr x1, =check_data6
	ldr x2, =0x0040880e
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00440000
	ldr x1, =check_data7
	ldr x2, =0x00440014
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
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

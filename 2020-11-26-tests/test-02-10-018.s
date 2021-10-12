.section data0, #alloc, #write
	.byte 0x22, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x22, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x20, 0x01
.data
check_data4:
	.byte 0x80, 0x20, 0x1c, 0x78, 0xbe, 0x79, 0x49, 0x91, 0xba, 0x03, 0x40, 0x78, 0x5f, 0x42, 0x7e, 0x78
	.byte 0xe4, 0x25, 0x32, 0x0b, 0x20, 0xa8, 0x03, 0x78, 0xdf, 0x0f, 0x7f, 0xc8, 0xd9, 0x99, 0x0d, 0xf8
	.byte 0x00, 0x00, 0x1d, 0x5a, 0x0b, 0x78, 0xa8, 0x9b, 0xc0, 0x10, 0xc2, 0xc2
.data
check_data5:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xfca
	/* C4 */
	.octa 0x1100
	/* C13 */
	.octa 0x222010
	/* C14 */
	.octa 0x1007
	/* C18 */
	.octa 0x1000
	/* C25 */
	.octa 0x120004000000000
	/* C29 */
	.octa 0x1000
final_cap_values:
	/* C1 */
	.octa 0xfca
	/* C3 */
	.octa 0x0
	/* C13 */
	.octa 0x222010
	/* C14 */
	.octa 0x1007
	/* C18 */
	.octa 0x1000
	/* C25 */
	.octa 0x120004000000000
	/* C26 */
	.octa 0x22
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x480010
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000000000000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x781c2080 // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:4 00:00 imm9:111000010 0:0 opc:00 111000:111000 size:01
	.inst 0x914979be // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:30 Rn:13 imm12:001001011110 sh:1 0:0 10001:10001 S:0 op:0 sf:1
	.inst 0x784003ba // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:26 Rn:29 00:00 imm9:000000000 0:0 opc:01 111000:111000 size:01
	.inst 0x787e425f // stsmaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:18 00:00 opc:100 o3:0 Rs:30 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x0b3225e4 // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:4 Rn:15 imm3:001 option:001 Rm:18 01011001:01011001 S:0 op:0 sf:0
	.inst 0x7803a820 // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:1 10:10 imm9:000111010 0:0 opc:00 111000:111000 size:01
	.inst 0xc87f0fdf // ldxp:aarch64/instrs/memory/exclusive/pair Rt:31 Rn:30 Rt2:00011 o0:0 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.inst 0xf80d99d9 // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:25 Rn:14 10:10 imm9:011011001 0:0 opc:00 111000:111000 size:11
	.inst 0x5a1d0000 // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:0 Rn:0 000000:000000 Rm:29 11010000:11010000 S:0 op:1 sf:0
	.inst 0x9ba8780b // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:11 Rn:0 Ra:30 o0:0 Rm:8 01:01 U:1 10011011:10011011
	.inst 0xc2c210c0
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
	ldr x24, =initial_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400701 // ldr c1, [x24, #1]
	.inst 0xc2400b04 // ldr c4, [x24, #2]
	.inst 0xc2400f0d // ldr c13, [x24, #3]
	.inst 0xc240130e // ldr c14, [x24, #4]
	.inst 0xc2401712 // ldr c18, [x24, #5]
	.inst 0xc2401b19 // ldr c25, [x24, #6]
	.inst 0xc2401f1d // ldr c29, [x24, #7]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =0x30851037
	msr SCTLR_EL3, x24
	ldr x24, =0x4
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030d8 // ldr c24, [c6, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x826010d8 // ldr c24, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400306 // ldr c6, [x24, #0]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400706 // ldr c6, [x24, #1]
	.inst 0xc2c6a461 // chkeq c3, c6
	b.ne comparison_fail
	.inst 0xc2400b06 // ldr c6, [x24, #2]
	.inst 0xc2c6a5a1 // chkeq c13, c6
	b.ne comparison_fail
	.inst 0xc2400f06 // ldr c6, [x24, #3]
	.inst 0xc2c6a5c1 // chkeq c14, c6
	b.ne comparison_fail
	.inst 0xc2401306 // ldr c6, [x24, #4]
	.inst 0xc2c6a641 // chkeq c18, c6
	b.ne comparison_fail
	.inst 0xc2401706 // ldr c6, [x24, #5]
	.inst 0xc2c6a721 // chkeq c25, c6
	b.ne comparison_fail
	.inst 0xc2401b06 // ldr c6, [x24, #6]
	.inst 0xc2c6a741 // chkeq c26, c6
	b.ne comparison_fail
	.inst 0xc2401f06 // ldr c6, [x24, #7]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	.inst 0xc2402306 // ldr c6, [x24, #8]
	.inst 0xc2c6a7c1 // chkeq c30, c6
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
	ldr x0, =0x00001004
	ldr x1, =check_data1
	ldr x2, =0x00001006
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010c2
	ldr x1, =check_data2
	ldr x2, =0x000010c4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000010e0
	ldr x1, =check_data3
	ldr x2, =0x000010e8
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
	ldr x0, =0x00480010
	ldr x1, =check_data5
	ldr x2, =0x00480020
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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

.section data0, #alloc, #write
	.zero 16
	.byte 0x44, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x05, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 1024
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3024
.data
check_data0:
	.zero 16
	.byte 0x44, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x05, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.byte 0x01, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0xfb
.data
check_data3:
	.byte 0xda, 0x57, 0x81, 0x9a, 0xf0, 0xdf, 0x95, 0xb8, 0x21, 0x58, 0x1c, 0x38, 0x30, 0xe5, 0xe5, 0x69
	.byte 0x40, 0x54, 0x9f, 0x02, 0x20, 0x7c, 0x54, 0x9b, 0xde, 0x5b, 0xe8, 0xc2, 0xac, 0x13, 0xc4, 0xc2
.data
check_data4:
	.byte 0xc2, 0x12, 0xac, 0xf2, 0xff, 0x63, 0x6e, 0x78, 0x80, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1ffb
	/* C2 */
	.octa 0xc000a0000000000000000a22
	/* C8 */
	.octa 0xc000
	/* C9 */
	.octa 0x10dc
	/* C14 */
	.octa 0x0
	/* C29 */
	.octa 0x90000000000100050000000000001000
	/* C30 */
	.octa 0xc001200100a8000000010001
final_cap_values:
	/* C1 */
	.octa 0x1ffb
	/* C2 */
	.octa 0x60960a22
	/* C8 */
	.octa 0xc000
	/* C9 */
	.octa 0x1008
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x1ffc
	/* C29 */
	.octa 0x90000000000100050000000000001000
	/* C30 */
	.octa 0xc0012001000000000000c000
initial_SP_EL3_value:
	.octa 0x14c3
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000a0000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000300070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword initial_cap_values + 80
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9a8157da // csinc:aarch64/instrs/integer/conditional/select Rd:26 Rn:30 o2:1 0:0 cond:0101 Rm:1 011010100:011010100 op:0 sf:1
	.inst 0xb895dff0 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:16 Rn:31 11:11 imm9:101011101 0:0 opc:10 111000:111000 size:10
	.inst 0x381c5821 // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:1 10:10 imm9:111000101 0:0 opc:00 111000:111000 size:00
	.inst 0x69e5e530 // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:16 Rn:9 Rt2:11001 imm7:1001011 L:1 1010011:1010011 opc:01
	.inst 0x029f5440 // SUB-C.CIS-C Cd:0 Cn:2 imm12:011111010101 sh:0 A:1 00000010:00000010
	.inst 0x9b547c20 // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:0 Rn:1 Ra:11111 0:0 Rm:20 10:10 U:0 10011011:10011011
	.inst 0xc2e85bde // CVTZ-C.CR-C Cd:30 Cn:30 0110:0110 1:1 0:0 Rm:8 11000010111:11000010111
	.inst 0xc2c413ac // LDPBR-C.C-C Ct:12 Cn:29 100:100 opc:00 11000010110001000:11000010110001000
	.zero 36
	.inst 0xf2ac12c2 // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:2 imm16:0110000010010110 hw:01 100101:100101 opc:11 sf:1
	.inst 0x786e63ff // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:110 o3:0 Rs:14 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c21380
	.zero 1048496
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
	.inst 0xc24002a1 // ldr c1, [x21, #0]
	.inst 0xc24006a2 // ldr c2, [x21, #1]
	.inst 0xc2400aa8 // ldr c8, [x21, #2]
	.inst 0xc2400ea9 // ldr c9, [x21, #3]
	.inst 0xc24012ae // ldr c14, [x21, #4]
	.inst 0xc24016bd // ldr c29, [x21, #5]
	.inst 0xc2401abe // ldr c30, [x21, #6]
	/* Set up flags and system registers */
	mov x21, #0x80000000
	msr nzcv, x21
	ldr x21, =initial_SP_EL3_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2c1d2bf // cpy c31, c21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	ldr x21, =0x0
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
	mov x28, #0x8
	and x21, x21, x28
	cmp x21, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002bc // ldr c28, [x21, #0]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc24006bc // ldr c28, [x21, #1]
	.inst 0xc2dca441 // chkeq c2, c28
	b.ne comparison_fail
	.inst 0xc2400abc // ldr c28, [x21, #2]
	.inst 0xc2dca501 // chkeq c8, c28
	b.ne comparison_fail
	.inst 0xc2400ebc // ldr c28, [x21, #3]
	.inst 0xc2dca521 // chkeq c9, c28
	b.ne comparison_fail
	.inst 0xc24012bc // ldr c28, [x21, #4]
	.inst 0xc2dca581 // chkeq c12, c28
	b.ne comparison_fail
	.inst 0xc24016bc // ldr c28, [x21, #5]
	.inst 0xc2dca5c1 // chkeq c14, c28
	b.ne comparison_fail
	.inst 0xc2401abc // ldr c28, [x21, #6]
	.inst 0xc2dca601 // chkeq c16, c28
	b.ne comparison_fail
	.inst 0xc2401ebc // ldr c28, [x21, #7]
	.inst 0xc2dca721 // chkeq c25, c28
	b.ne comparison_fail
	.inst 0xc24022bc // ldr c28, [x21, #8]
	.inst 0xc2dca741 // chkeq c26, c28
	b.ne comparison_fail
	.inst 0xc24026bc // ldr c28, [x21, #9]
	.inst 0xc2dca7a1 // chkeq c29, c28
	b.ne comparison_fail
	.inst 0xc2402abc // ldr c28, [x21, #10]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001420
	ldr x1, =check_data1
	ldr x2, =0x00001424
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fc0
	ldr x1, =check_data2
	ldr x2, =0x00001fc1
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400020
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400044
	ldr x1, =check_data4
	ldr x2, =0x00400050
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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

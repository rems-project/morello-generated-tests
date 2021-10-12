.section data0, #alloc, #write
	.zero 768
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x10, 0x00, 0x00, 0x00
	.zero 3280
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x10, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x31, 0x02, 0x05, 0x7a, 0xde, 0x9f, 0x5c, 0x51, 0x7f, 0x75, 0x14, 0x2c, 0xd2, 0x43, 0xbf, 0x82
	.byte 0x4b, 0xd8, 0xae, 0x38, 0x1e, 0x3a, 0x47, 0x79, 0x02, 0xdd, 0xb8, 0xb9, 0xd2, 0x21, 0x56, 0xa2
	.byte 0x22, 0x88, 0xdf, 0xc2, 0x8a, 0x65, 0x6b, 0xc2, 0x80, 0x13, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x200f200f0031208000002001
	/* C2 */
	.octa 0x80000000400080040000000000408c62
	/* C8 */
	.octa 0x800000007c111c2a0000000000480328
	/* C11 */
	.octa 0x40000000200700270000000000000f60
	/* C12 */
	.octa 0x9000000000010005ffffffffffff7250
	/* C14 */
	.octa 0x9000000000010005000000000000139e
	/* C16 */
	.octa 0x800000000007000300000000003ffc70
	/* C18 */
	.octa 0x0
	/* C30 */
	.octa 0x728000
final_cap_values:
	/* C1 */
	.octa 0x200f200f0031208000002001
	/* C2 */
	.octa 0x200f200f0031208000002001
	/* C8 */
	.octa 0x800000007c111c2a0000000000480328
	/* C10 */
	.octa 0x800000000000000000000000
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x9000000000010005ffffffffffff7250
	/* C14 */
	.octa 0x9000000000010005000000000000139e
	/* C16 */
	.octa 0x800000000007000300000000003ffc70
	/* C18 */
	.octa 0x10800000000000000000000000
	/* C30 */
	.octa 0x43d2
initial_csp_value:
	.octa 0x2000000000000026000001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080400000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000508400000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001300
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x7a050231 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:17 Rn:17 000000:000000 Rm:5 11010000:11010000 S:1 op:1 sf:0
	.inst 0x515c9fde // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:30 Rn:30 imm12:011100100111 sh:1 0:0 10001:10001 S:0 op:1 sf:0
	.inst 0x2c14757f // stnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:31 Rn:11 Rt2:11101 imm7:0101000 L:0 1011000:1011000 opc:00
	.inst 0x82bf43d2 // ASTR-R.RRB-32 Rt:18 Rn:30 opc:00 S:0 option:010 Rm:31 1:1 L:0 100000101:100000101
	.inst 0x38aed84b // ldrsb_reg:aarch64/instrs/memory/single/general/register Rt:11 Rn:2 10:10 S:1 option:110 Rm:14 1:1 opc:10 111000:111000 size:00
	.inst 0x79473a1e // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:16 imm12:000111001110 opc:01 111001:111001 size:01
	.inst 0xb9b8dd02 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:8 imm12:111000110111 opc:10 111001:111001 size:10
	.inst 0xa25621d2 // LDUR-C.RI-C Ct:18 Rn:14 00:00 imm9:101100010 0:0 opc:01 10100010:10100010
	.inst 0xc2df8822 // CHKSSU-C.CC-C Cd:2 Cn:1 0010:0010 opc:10 Cm:31 11000010110:11000010110
	.inst 0xc26b658a // LDR-C.RIB-C Ct:10 Rn:12 imm12:101011011001 L:1 110000100:110000100
	.inst 0xc2c21380
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x0, cptr_el3
	orr x0, x0, #0x200
	msr cptr_el3, x0
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr cvbar_el3, c1
	isb
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
	ldr x0, =initial_cap_values
	.inst 0xc2400001 // ldr c1, [x0, #0]
	.inst 0xc2400402 // ldr c2, [x0, #1]
	.inst 0xc2400808 // ldr c8, [x0, #2]
	.inst 0xc2400c0b // ldr c11, [x0, #3]
	.inst 0xc240100c // ldr c12, [x0, #4]
	.inst 0xc240140e // ldr c14, [x0, #5]
	.inst 0xc2401810 // ldr c16, [x0, #6]
	.inst 0xc2401c12 // ldr c18, [x0, #7]
	.inst 0xc240201e // ldr c30, [x0, #8]
	/* Vector registers */
	mrs x0, cptr_el3
	bfc x0, #10, #1
	msr cptr_el3, x0
	isb
	ldr q29, =0x0
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x0, #0x00000000
	msr nzcv, x0
	ldr x0, =initial_csp_value
	.inst 0xc2400000 // ldr c0, [x0, #0]
	.inst 0xc2c1d01f // cpy c31, c0
	ldr x0, =0x200
	msr CPTR_EL3, x0
	ldr x0, =0x30850030
	msr SCTLR_EL3, x0
	ldr x0, =0x4
	msr S3_6_C1_C2_2, x0 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82603380 // ldr c0, [c28, #3]
	.inst 0xc28b4120 // msr ddc_el3, c0
	isb
	.inst 0x82601380 // ldr c0, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c21000 // br c0
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b000 // cvtp c0, x0
	.inst 0xc2df4000 // scvalue c0, c0, x31
	.inst 0xc28b4120 // msr ddc_el3, c0
	isb
	/* Check processor flags */
	mrs x0, nzcv
	ubfx x0, x0, #28, #4
	mov x28, #0xf
	and x0, x0, x28
	cmp x0, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x0, =final_cap_values
	.inst 0xc240001c // ldr c28, [x0, #0]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc240041c // ldr c28, [x0, #1]
	.inst 0xc2dca441 // chkeq c2, c28
	b.ne comparison_fail
	.inst 0xc240081c // ldr c28, [x0, #2]
	.inst 0xc2dca501 // chkeq c8, c28
	b.ne comparison_fail
	.inst 0xc2400c1c // ldr c28, [x0, #3]
	.inst 0xc2dca541 // chkeq c10, c28
	b.ne comparison_fail
	.inst 0xc240101c // ldr c28, [x0, #4]
	.inst 0xc2dca561 // chkeq c11, c28
	b.ne comparison_fail
	.inst 0xc240141c // ldr c28, [x0, #5]
	.inst 0xc2dca581 // chkeq c12, c28
	b.ne comparison_fail
	.inst 0xc240181c // ldr c28, [x0, #6]
	.inst 0xc2dca5c1 // chkeq c14, c28
	b.ne comparison_fail
	.inst 0xc2401c1c // ldr c28, [x0, #7]
	.inst 0xc2dca601 // chkeq c16, c28
	b.ne comparison_fail
	.inst 0xc240201c // ldr c28, [x0, #8]
	.inst 0xc2dca641 // chkeq c18, c28
	b.ne comparison_fail
	.inst 0xc240241c // ldr c28, [x0, #9]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check vector registers */
	ldr x0, =0x0
	mov x28, v29.d[0]
	cmp x0, x28
	b.ne comparison_fail
	ldr x0, =0x0
	mov x28, v29.d[1]
	cmp x0, x28
	b.ne comparison_fail
	ldr x0, =0x0
	mov x28, v31.d[0]
	cmp x0, x28
	b.ne comparison_fail
	ldr x0, =0x0
	mov x28, v31.d[1]
	cmp x0, x28
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
	ldr x0, =0x00001300
	ldr x1, =check_data1
	ldr x2, =0x00001310
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fe0
	ldr x1, =check_data2
	ldr x2, =0x00001ff0
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
	ldr x0, =0x0040a000
	ldr x1, =check_data4
	ldr x2, =0x0040a001
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00483c04
	ldr x1, =check_data5
	ldr x2, =0x00483c08
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b000 // cvtp c0, x0
	.inst 0xc2df4000 // scvalue c0, c0, x31
	.inst 0xc28b4120 // msr ddc_el3, c0
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

	.balign 128
vector_table:
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

.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 32
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x3f, 0x68, 0x36, 0x38, 0xfe, 0x0f, 0x5c, 0x38, 0x9e, 0xdc, 0xc4, 0x42, 0x3f, 0xe0, 0xc2, 0xc2
	.byte 0x7e, 0x17, 0xec, 0x68, 0x97, 0x92, 0xc0, 0xc2, 0x2c, 0x28, 0xc0, 0xc2, 0x1e, 0x8d, 0x56, 0xca
	.byte 0x03, 0xec, 0x12, 0xb8, 0x09, 0x90, 0x2f, 0x32, 0x80, 0x13, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2002
	/* C1 */
	.octa 0xa
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x1020
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0x19e2
	/* C27 */
	.octa 0x40fffc
final_cap_values:
	/* C0 */
	.octa 0x1f30
	/* C1 */
	.octa 0xa
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x1020
	/* C5 */
	.octa 0x0
	/* C9 */
	.octa 0x3e1f3e
	/* C12 */
	.octa 0xa
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0x19e2
	/* C23 */
	.octa 0x1
	/* C27 */
	.octa 0x40ff5c
initial_SP_EL3_value:
	.octa 0x400220
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080100000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0100000000180060080000000070000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3836683f // strb_reg:aarch64/instrs/memory/single/general/register Rt:31 Rn:1 10:10 S:0 option:011 Rm:22 1:1 opc:00 111000:111000 size:00
	.inst 0x385c0ffe // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:31 11:11 imm9:111000000 0:0 opc:01 111000:111000 size:00
	.inst 0x42c4dc9e // LDP-C.RIB-C Ct:30 Rn:4 Ct2:10111 imm7:0001001 L:1 010000101:010000101
	.inst 0xc2c2e03f // SCFLGS-C.CR-C Cd:31 Cn:1 111000:111000 Rm:2 11000010110:11000010110
	.inst 0x68ec177e // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:30 Rn:27 Rt2:00101 imm7:1011000 L:1 1010001:1010001 opc:01
	.inst 0xc2c09297 // GCTAG-R.C-C Rd:23 Cn:20 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0xc2c0282c // BICFLGS-C.CR-C Cd:12 Cn:1 1010:1010 opc:00 Rm:0 11000010110:11000010110
	.inst 0xca568d1e // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:8 imm6:100011 Rm:22 N:0 shift:01 01010:01010 opc:10 sf:1
	.inst 0xb812ec03 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:3 Rn:0 11:11 imm9:100101110 0:0 opc:00 111000:111000 size:10
	.inst 0x322f9009 // orr_log_imm:aarch64/instrs/integer/logical/immediate Rd:9 Rn:0 imms:100100 immr:101111 N:0 100100:100100 opc:01 sf:0
	.inst 0xc2c21380
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x18, cptr_el3
	orr x18, x18, #0x200
	msr cptr_el3, x18
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
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
	ldr x18, =initial_cap_values
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc2400641 // ldr c1, [x18, #1]
	.inst 0xc2400a43 // ldr c3, [x18, #2]
	.inst 0xc2400e44 // ldr c4, [x18, #3]
	.inst 0xc2401254 // ldr c20, [x18, #4]
	.inst 0xc2401656 // ldr c22, [x18, #5]
	.inst 0xc2401a5b // ldr c27, [x18, #6]
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =initial_SP_EL3_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2c1d25f // cpy c31, c18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30850038
	msr SCTLR_EL3, x18
	ldr x18, =0x0
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82603392 // ldr c18, [c28, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x82601392 // ldr c18, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc240025c // ldr c28, [x18, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc240065c // ldr c28, [x18, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc2400a5c // ldr c28, [x18, #2]
	.inst 0xc2dca461 // chkeq c3, c28
	b.ne comparison_fail
	.inst 0xc2400e5c // ldr c28, [x18, #3]
	.inst 0xc2dca481 // chkeq c4, c28
	b.ne comparison_fail
	.inst 0xc240125c // ldr c28, [x18, #4]
	.inst 0xc2dca4a1 // chkeq c5, c28
	b.ne comparison_fail
	.inst 0xc240165c // ldr c28, [x18, #5]
	.inst 0xc2dca521 // chkeq c9, c28
	b.ne comparison_fail
	.inst 0xc2401a5c // ldr c28, [x18, #6]
	.inst 0xc2dca581 // chkeq c12, c28
	b.ne comparison_fail
	.inst 0xc2401e5c // ldr c28, [x18, #7]
	.inst 0xc2dca681 // chkeq c20, c28
	b.ne comparison_fail
	.inst 0xc240225c // ldr c28, [x18, #8]
	.inst 0xc2dca6c1 // chkeq c22, c28
	b.ne comparison_fail
	.inst 0xc240265c // ldr c28, [x18, #9]
	.inst 0xc2dca6e1 // chkeq c23, c28
	b.ne comparison_fail
	.inst 0xc2402a5c // ldr c28, [x18, #10]
	.inst 0xc2dca761 // chkeq c27, c28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010b0
	ldr x1, =check_data0
	ldr x2, =0x000010d0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000019ec
	ldr x1, =check_data1
	ldr x2, =0x000019ed
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f30
	ldr x1, =check_data2
	ldr x2, =0x00001f34
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
	ldr x0, =0x004001e0
	ldr x1, =check_data4
	ldr x2, =0x004001e1
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0040fffc
	ldr x1, =check_data5
	ldr x2, =0x00410004
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
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
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

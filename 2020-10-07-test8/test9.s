.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 32
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 32
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0x63, 0xdf, 0x75, 0xf0, 0xe1, 0xf7, 0x05, 0xf9, 0xc1, 0x3f, 0x01, 0x11, 0xfe, 0xff, 0xd4, 0x42
	.byte 0xee, 0xaf, 0x48, 0xa2, 0x57, 0x31, 0x4e, 0x38, 0x21, 0xd0, 0xc6, 0xc2, 0xff, 0x68, 0xed, 0x78
	.byte 0xea, 0x07, 0x4d, 0x38, 0xe1, 0xf7, 0xc1, 0x22, 0x40, 0x13, 0xc2, 0xc2
.data
check_data6:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0x80000000400100090000000000000400
	/* C10 */
	.octa 0x80000000400ce007000000000047ff22
	/* C13 */
	.octa 0xc00
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x8001200400508004ebbef000
	/* C7 */
	.octa 0x80000000400100090000000000000400
	/* C10 */
	.octa 0x0
	/* C13 */
	.octa 0xc00
	/* C14 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0xc0000000000100070000000000001260
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080005004d8060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800120040050800400000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000014f0
	.dword 0x0000000000001500
	.dword 0x0000000000001b00
	.dword 0x0000000000001be0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 32
	.dword initial_SP_EL3_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf075df63 // ADRDP-C.ID-C Rd:3 immhi:111010111011111011 P:0 10000:10000 immlo:11 op:1
	.inst 0xf905f7e1 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:31 imm12:000101111101 opc:00 111001:111001 size:11
	.inst 0x11013fc1 // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:1 Rn:30 imm12:000001001111 sh:0 0:0 10001:10001 S:0 op:0 sf:0
	.inst 0x42d4fffe // LDP-C.RIB-C Ct:30 Rn:31 Ct2:11111 imm7:0101001 L:1 010000101:010000101
	.inst 0xa248afee // LDR-C.RIBW-C Ct:14 Rn:31 11:11 imm9:010001010 0:0 opc:01 10100010:10100010
	.inst 0x384e3157 // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:23 Rn:10 00:00 imm9:011100011 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c6d021 // CLRPERM-C.CI-C Cd:1 Cn:1 100:100 perm:110 1100001011000110:1100001011000110
	.inst 0x78ed68ff // ldrsh_reg:aarch64/instrs/memory/single/general/register Rt:31 Rn:7 10:10 S:0 option:011 Rm:13 1:1 opc:11 111000:111000 size:01
	.inst 0x384d07ea // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:10 Rn:31 01:01 imm9:011010000 0:0 opc:01 111000:111000 size:00
	.inst 0x22c1f7e1 // LDP-CC.RIAW-C Ct:1 Rn:31 Ct2:11101 imm7:0000011 L:1 001000101:001000101
	.inst 0xc2c21340
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x24, cptr_el3
	orr x24, x24, #0x200
	msr cptr_el3, x24
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
	ldr x24, =initial_cap_values
	.inst 0xc2400301 // ldr c1, [x24, #0]
	.inst 0xc2400707 // ldr c7, [x24, #1]
	.inst 0xc2400b0a // ldr c10, [x24, #2]
	.inst 0xc2400f0d // ldr c13, [x24, #3]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =initial_SP_EL3_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2c1d31f // cpy c31, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30850032
	msr SCTLR_EL3, x24
	ldr x24, =0x0
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82603358 // ldr c24, [c26, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x82601358 // ldr c24, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc240031a // ldr c26, [x24, #0]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc240071a // ldr c26, [x24, #1]
	.inst 0xc2daa461 // chkeq c3, c26
	b.ne comparison_fail
	.inst 0xc2400b1a // ldr c26, [x24, #2]
	.inst 0xc2daa4e1 // chkeq c7, c26
	b.ne comparison_fail
	.inst 0xc2400f1a // ldr c26, [x24, #3]
	.inst 0xc2daa541 // chkeq c10, c26
	b.ne comparison_fail
	.inst 0xc240131a // ldr c26, [x24, #4]
	.inst 0xc2daa5a1 // chkeq c13, c26
	b.ne comparison_fail
	.inst 0xc240171a // ldr c26, [x24, #5]
	.inst 0xc2daa5c1 // chkeq c14, c26
	b.ne comparison_fail
	.inst 0xc2401b1a // ldr c26, [x24, #6]
	.inst 0xc2daa6e1 // chkeq c23, c26
	b.ne comparison_fail
	.inst 0xc2401f1a // ldr c26, [x24, #7]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc240231a // ldr c26, [x24, #8]
	.inst 0xc2daa7c1 // chkeq c30, c26
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
	ldr x0, =0x000014f0
	ldr x1, =check_data1
	ldr x2, =0x00001510
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001b00
	ldr x1, =check_data2
	ldr x2, =0x00001b10
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001bd0
	ldr x1, =check_data3
	ldr x2, =0x00001bf0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001e48
	ldr x1, =check_data4
	ldr x2, =0x00001e50
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
	ldr x0, =0x00480005
	ldr x1, =check_data6
	ldr x2, =0x00480006
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
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

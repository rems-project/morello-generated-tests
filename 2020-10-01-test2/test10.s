.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x80, 0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x11, 0x80
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0xc0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data5:
	.byte 0xc2, 0x3d, 0x95, 0xe2, 0x18, 0x0c, 0x52, 0xa2, 0x10, 0xf2, 0xc0, 0xc2, 0x1e, 0x78, 0x1e, 0x9b
	.byte 0x31, 0x90, 0x5f, 0xeb, 0xe1, 0x5a, 0x21, 0xa2, 0x0c, 0xf0, 0x9c, 0xf8, 0x01, 0xd4, 0x57, 0xe2
	.byte 0x7e, 0x7f, 0x57, 0x9b, 0xc0, 0x7c, 0x1f, 0x42, 0x80, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80110000000000000000000000002080
	/* C1 */
	.octa 0x40000000000000000000000000c0
	/* C2 */
	.octa 0x200000000000000000000
	/* C6 */
	.octa 0x883
	/* C14 */
	.octa 0x1880
	/* C23 */
	.octa 0x48000000000000000000000000000800
final_cap_values:
	/* C0 */
	.octa 0x80110000000000000000000000001280
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x200000000000000000000
	/* C6 */
	.octa 0x883
	/* C14 */
	.octa 0x1880
	/* C17 */
	.octa 0xc0
	/* C23 */
	.octa 0x48000000000000000000000000000800
	/* C24 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100100060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc000000600107cd00ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001280
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2953dc2 // ASTUR-C.RI-C Ct:2 Rn:14 op2:11 imm9:101010011 V:0 op1:10 11100010:11100010
	.inst 0xa2520c18 // LDR-C.RIBW-C Ct:24 Rn:0 11:11 imm9:100100000 0:0 opc:01 10100010:10100010
	.inst 0xc2c0f210 // GCTYPE-R.C-C Rd:16 Cn:16 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0x9b1e781e // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:30 Rn:0 Ra:30 o0:0 Rm:30 0011011000:0011011000 sf:1
	.inst 0xeb5f9031 // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:17 Rn:1 imm6:100100 Rm:31 0:0 shift:01 01011:01011 S:1 op:1 sf:1
	.inst 0xa2215ae1 // STR-C.RRB-C Ct:1 Rn:23 10:10 S:1 option:010 Rm:1 1:1 opc:00 10100010:10100010
	.inst 0xf89cf00c // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:12 Rn:0 00:00 imm9:111001111 0:0 opc:10 111000:111000 size:11
	.inst 0xe257d401 // ALDURH-R.RI-32 Rt:1 Rn:0 op2:01 imm9:101111101 V:0 op1:01 11100010:11100010
	.inst 0x9b577f7e // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:30 Rn:27 Ra:11111 0:0 Rm:23 10:10 U:0 10011011:10011011
	.inst 0x421f7cc0 // ASTLR-C.R-C Ct:0 Rn:6 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xc2c21380
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x9, cptr_el3
	orr x9, x9, #0x200
	msr cptr_el3, x9
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
	ldr x9, =initial_cap_values
	.inst 0xc2400120 // ldr c0, [x9, #0]
	.inst 0xc2400521 // ldr c1, [x9, #1]
	.inst 0xc2400922 // ldr c2, [x9, #2]
	.inst 0xc2400d26 // ldr c6, [x9, #3]
	.inst 0xc240112e // ldr c14, [x9, #4]
	.inst 0xc2401537 // ldr c23, [x9, #5]
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	ldr x9, =0x4
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82603389 // ldr c9, [c28, #3]
	.inst 0xc28b4129 // msr ddc_el3, c9
	isb
	.inst 0x82601389 // ldr c9, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr ddc_el3, c9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x28, #0xf
	and x9, x9, x28
	cmp x9, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc240013c // ldr c28, [x9, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc240053c // ldr c28, [x9, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc240093c // ldr c28, [x9, #2]
	.inst 0xc2dca441 // chkeq c2, c28
	b.ne comparison_fail
	.inst 0xc2400d3c // ldr c28, [x9, #3]
	.inst 0xc2dca4c1 // chkeq c6, c28
	b.ne comparison_fail
	.inst 0xc240113c // ldr c28, [x9, #4]
	.inst 0xc2dca5c1 // chkeq c14, c28
	b.ne comparison_fail
	.inst 0xc240153c // ldr c28, [x9, #5]
	.inst 0xc2dca621 // chkeq c17, c28
	b.ne comparison_fail
	.inst 0xc240193c // ldr c28, [x9, #6]
	.inst 0xc2dca6e1 // chkeq c23, c28
	b.ne comparison_fail
	.inst 0xc2401d3c // ldr c28, [x9, #7]
	.inst 0xc2dca701 // chkeq c24, c28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001050
	ldr x1, =check_data0
	ldr x2, =0x00001060
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001280
	ldr x1, =check_data1
	ldr x2, =0x00001290
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001400
	ldr x1, =check_data2
	ldr x2, =0x00001410
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000019ca
	ldr x1, =check_data3
	ldr x2, =0x000019cc
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fa0
	ldr x1, =check_data4
	ldr x2, =0x00001fb0
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr ddc_el3, c9
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

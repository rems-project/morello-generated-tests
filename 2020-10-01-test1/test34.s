.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x97, 0x1a
.data
check_data1:
	.byte 0x01, 0x02, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0xde, 0x83, 0x00, 0x9b, 0x07, 0xff, 0xdf, 0x08, 0x34, 0x84, 0xef, 0xd8, 0x22, 0xa4, 0xda, 0x38
	.byte 0x4d, 0x32, 0x3f, 0x36, 0x60, 0xb9, 0x1b, 0xb9, 0xc3, 0xe3, 0x37, 0x52, 0xff, 0xff, 0xdf, 0x48
	.byte 0x5e, 0x7d, 0x9f, 0x82, 0xe7, 0xbf, 0xff, 0x68, 0xa0, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x201
	/* C1 */
	.octa 0x800000001007100800000000004598fe
	/* C10 */
	.octa 0x1000
	/* C11 */
	.octa 0x40000000600003ba0000000000000000
	/* C13 */
	.octa 0x80
	/* C24 */
	.octa 0x80000000400000010000000000001bfe
	/* C30 */
	.octa 0x136a
final_cap_values:
	/* C0 */
	.octa 0x201
	/* C1 */
	.octa 0x800000001007100800000000004598a8
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0xddfb38b5
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0x1000
	/* C11 */
	.octa 0x40000000600003ba0000000000000000
	/* C13 */
	.octa 0x80
	/* C15 */
	.octa 0x0
	/* C24 */
	.octa 0x80000000400000010000000000001bfe
	/* C30 */
	.octa 0xffffffffffd91a97
initial_csp_value:
	.octa 0x80000000000100050000000000001ff4
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200620070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000200140050080000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 96
	.dword final_cap_values + 144
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9b0083de // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:30 Rn:30 Ra:0 o0:1 Rm:0 0011011000:0011011000 sf:1
	.inst 0x08dfff07 // ldarb:aarch64/instrs/memory/ordered Rt:7 Rn:24 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xd8ef8434 // prfm_lit:aarch64/instrs/memory/literal/general Rt:20 imm19:1110111110000100001 011000:011000 opc:11
	.inst 0x38daa422 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:2 Rn:1 01:01 imm9:110101010 0:0 opc:11 111000:111000 size:00
	.inst 0x363f324d // tbz:aarch64/instrs/branch/conditional/test Rt:13 imm14:11100110010010 b40:00111 op:0 011011:011011 b5:0
	.inst 0xb91bb960 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:11 imm12:011011101110 opc:00 111001:111001 size:10
	.inst 0x5237e3c3 // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:3 Rn:30 imms:111000 immr:110111 N:0 100100:100100 opc:10 sf:0
	.inst 0x48dfffff // ldarh:aarch64/instrs/memory/ordered Rt:31 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0x829f7d5e // ASTRH-R.RRB-32 Rt:30 Rn:10 opc:11 S:1 option:011 Rm:31 0:0 L:0 100000101:100000101
	.inst 0x68ffbfe7 // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:7 Rn:31 Rt2:01111 imm7:1111111 L:1 1010001:1010001 opc:01
	.inst 0xc2c212a0
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
	.inst 0xc240092a // ldr c10, [x9, #2]
	.inst 0xc2400d2b // ldr c11, [x9, #3]
	.inst 0xc240112d // ldr c13, [x9, #4]
	.inst 0xc2401538 // ldr c24, [x9, #5]
	.inst 0xc240193e // ldr c30, [x9, #6]
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =initial_csp_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2c1d13f // cpy c31, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30850032
	msr SCTLR_EL3, x9
	ldr x9, =0x4
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032a9 // ldr c9, [c21, #3]
	.inst 0xc28b4129 // msr ddc_el3, c9
	isb
	.inst 0x826012a9 // ldr c9, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr ddc_el3, c9
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400135 // ldr c21, [x9, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400535 // ldr c21, [x9, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400935 // ldr c21, [x9, #2]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400d35 // ldr c21, [x9, #3]
	.inst 0xc2d5a461 // chkeq c3, c21
	b.ne comparison_fail
	.inst 0xc2401135 // ldr c21, [x9, #4]
	.inst 0xc2d5a4e1 // chkeq c7, c21
	b.ne comparison_fail
	.inst 0xc2401535 // ldr c21, [x9, #5]
	.inst 0xc2d5a541 // chkeq c10, c21
	b.ne comparison_fail
	.inst 0xc2401935 // ldr c21, [x9, #6]
	.inst 0xc2d5a561 // chkeq c11, c21
	b.ne comparison_fail
	.inst 0xc2401d35 // ldr c21, [x9, #7]
	.inst 0xc2d5a5a1 // chkeq c13, c21
	b.ne comparison_fail
	.inst 0xc2402135 // ldr c21, [x9, #8]
	.inst 0xc2d5a5e1 // chkeq c15, c21
	b.ne comparison_fail
	.inst 0xc2402535 // ldr c21, [x9, #9]
	.inst 0xc2d5a701 // chkeq c24, c21
	b.ne comparison_fail
	.inst 0xc2402935 // ldr c21, [x9, #10]
	.inst 0xc2d5a7c1 // chkeq c30, c21
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
	ldr x0, =0x00001bb8
	ldr x1, =check_data1
	ldr x2, =0x00001bbc
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001bfe
	ldr x1, =check_data2
	ldr x2, =0x00001bff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff4
	ldr x1, =check_data3
	ldr x2, =0x00001ffc
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
	ldr x0, =0x004598fe
	ldr x1, =check_data5
	ldr x2, =0x004598ff
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

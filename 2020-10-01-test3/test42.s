.section data0, #alloc, #write
	.zero 4080
	.byte 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.byte 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f
.data
check_data1:
	.byte 0x10, 0xfc, 0x1f, 0x1b, 0xc0, 0x02, 0x3f, 0xd6
.data
check_data2:
	.byte 0x1f, 0x1f
.data
check_data3:
	.byte 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f
.data
check_data4:
	.byte 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f
.data
check_data5:
	.byte 0x1f, 0x87, 0x74, 0x7d, 0x41, 0x4f, 0x3e, 0x0a, 0x45, 0x04, 0x4b, 0x91, 0x63, 0xe3, 0x4a, 0xf8
	.byte 0x7f, 0xcd, 0x5f, 0xf8, 0xea, 0x19, 0x52, 0x38, 0x5e, 0xfb, 0x9e, 0xcb, 0xfe, 0xc6, 0xc6, 0x58
	.byte 0x20, 0x11, 0xc2, 0xc2
.data
check_data6:
	.byte 0x1f
.data
.balign 16
initial_cap_values:
	/* C11 */
	.octa 0x80000000000600010000000000402084
	/* C15 */
	.octa 0x800000000001000500000000005000dd
	/* C22 */
	.octa 0x47ffe0
	/* C24 */
	.octa 0x80000000000100050000000000400260
	/* C27 */
	.octa 0x80000000000100050000000000001f42
final_cap_values:
	/* C3 */
	.octa 0x1f1f1f1f1f1f1f1f
	/* C10 */
	.octa 0x1f
	/* C11 */
	.octa 0x80000000000600010000000000402080
	/* C15 */
	.octa 0x800000000001000500000000005000dd
	/* C16 */
	.octa 0x0
	/* C22 */
	.octa 0x47ffe0
	/* C24 */
	.octa 0x80000000000100050000000000400260
	/* C27 */
	.octa 0x80000000000100050000000000001f42
	/* C30 */
	.octa 0x1f1f1f1f1f1f1f1f
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0008000000300070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x1b1ffc10 // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:16 Rn:0 Ra:31 o0:1 Rm:31 0011011000:0011011000 sf:0
	.inst 0xd63f02c0 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:22 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 7320
	.inst 0x1f1f0000
	.zero 988
	.inst 0x1f1f1f1f
	.inst 0x1f1f1f1f
	.zero 47184
	.inst 0x1f1f1f1f
	.inst 0x1f1f1f1f
	.zero 468736
	.inst 0x7d74871f // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:31 Rn:24 imm12:110100100001 opc:01 111101:111101 size:01
	.inst 0x0a3e4f41 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:26 imm6:010011 Rm:30 N:1 shift:00 01010:01010 opc:00 sf:0
	.inst 0x914b0445 // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:5 Rn:2 imm12:001011000001 sh:1 0:0 10001:10001 S:0 op:0 sf:1
	.inst 0xf84ae363 // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:3 Rn:27 00:00 imm9:010101110 0:0 opc:01 111000:111000 size:11
	.inst 0xf85fcd7f // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:11 11:11 imm9:111111100 0:0 opc:01 111000:111000 size:11
	.inst 0x385219ea // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:10 Rn:15 10:10 imm9:100100001 0:0 opc:01 111000:111000 size:00
	.inst 0xcb9efb5e // sub_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:30 Rn:26 imm6:111110 Rm:30 0:0 shift:10 01011:01011 S:0 op:1 sf:1
	.inst 0x58c6c6fe // ldr_lit_gen:aarch64/instrs/memory/literal/general Rt:30 imm19:1100011011000110111 011000:011000 opc:01
	.inst 0xc2c21120
	.zero 524280
	.inst 0x001f0000
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x17, cptr_el3
	orr x17, x17, #0x200
	msr cptr_el3, x17
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
	ldr x17, =initial_cap_values
	.inst 0xc240022b // ldr c11, [x17, #0]
	.inst 0xc240062f // ldr c15, [x17, #1]
	.inst 0xc2400a36 // ldr c22, [x17, #2]
	.inst 0xc2400e38 // ldr c24, [x17, #3]
	.inst 0xc240123b // ldr c27, [x17, #4]
	/* Set up flags and system registers */
	mov x17, #0x00000000
	msr nzcv, x17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30850032
	msr SCTLR_EL3, x17
	ldr x17, =0x8
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82601131 // ldr c17, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c21220 // br c17
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr ddc_el3, c17
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400229 // ldr c9, [x17, #0]
	.inst 0xc2c9a461 // chkeq c3, c9
	b.ne comparison_fail
	.inst 0xc2400629 // ldr c9, [x17, #1]
	.inst 0xc2c9a541 // chkeq c10, c9
	b.ne comparison_fail
	.inst 0xc2400a29 // ldr c9, [x17, #2]
	.inst 0xc2c9a561 // chkeq c11, c9
	b.ne comparison_fail
	.inst 0xc2400e29 // ldr c9, [x17, #3]
	.inst 0xc2c9a5e1 // chkeq c15, c9
	b.ne comparison_fail
	.inst 0xc2401229 // ldr c9, [x17, #4]
	.inst 0xc2c9a601 // chkeq c16, c9
	b.ne comparison_fail
	.inst 0xc2401629 // ldr c9, [x17, #5]
	.inst 0xc2c9a6c1 // chkeq c22, c9
	b.ne comparison_fail
	.inst 0xc2401a29 // ldr c9, [x17, #6]
	.inst 0xc2c9a701 // chkeq c24, c9
	b.ne comparison_fail
	.inst 0xc2401e29 // ldr c9, [x17, #7]
	.inst 0xc2c9a761 // chkeq c27, c9
	b.ne comparison_fail
	.inst 0xc2402229 // ldr c9, [x17, #8]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check vector registers */
	ldr x17, =0x1f1f
	mov x9, v31.d[0]
	cmp x17, x9
	b.ne comparison_fail
	ldr x17, =0x0
	mov x9, v31.d[1]
	cmp x17, x9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001ff0
	ldr x1, =check_data0
	ldr x2, =0x00001ff8
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x00400008
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00401ca2
	ldr x1, =check_data2
	ldr x2, =0x00401ca4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00402080
	ldr x1, =check_data3
	ldr x2, =0x00402088
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0040d8d8
	ldr x1, =check_data4
	ldr x2, =0x0040d8e0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0047ffe0
	ldr x1, =check_data5
	ldr x2, =0x00480004
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004ffffe
	ldr x1, =check_data6
	ldr x2, =0x004fffff
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
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr ddc_el3, c17
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

.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0xdf, 0x85, 0x43, 0xe2, 0x2c, 0x2b, 0x55, 0xcb, 0x3e, 0x3e, 0x20, 0x6d, 0x01, 0x30, 0xc5, 0xc2
	.byte 0xde, 0x2b, 0xce, 0x1a, 0xc1, 0x6b, 0x1c, 0x72, 0x9f, 0x22, 0xea, 0xd8, 0x5b, 0x5b, 0x21, 0x38
	.byte 0xd6, 0x1e, 0xde, 0xc2, 0x18, 0x14, 0xc0, 0xda, 0x80, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C14 */
	.octa 0x3fffe4
	/* C17 */
	.octa 0x40000000600000020000000000002180
	/* C26 */
	.octa 0x4000000000070047fffffffffffff000
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x20000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x2000
	/* C14 */
	.octa 0x3fffe4
	/* C17 */
	.octa 0x40000000600000020000000000002180
	/* C24 */
	.octa 0x3f
	/* C26 */
	.octa 0x4000000000070047fffffffffffff000
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x2000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080002007a1070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000008b000700ffe00000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe24385df // ALDURH-R.RI-32 Rt:31 Rn:14 op2:01 imm9:000111000 V:0 op1:01 11100010:11100010
	.inst 0xcb552b2c // sub_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:12 Rn:25 imm6:001010 Rm:21 0:0 shift:01 01011:01011 S:0 op:1 sf:1
	.inst 0x6d203e3e // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:30 Rn:17 Rt2:01111 imm7:1000000 L:0 1011010:1011010 opc:01
	.inst 0xc2c53001 // CVTP-R.C-C Rd:1 Cn:0 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0x1ace2bde // asrv:aarch64/instrs/integer/shift/variable Rd:30 Rn:30 op2:10 0010:0010 Rm:14 0011010110:0011010110 sf:0
	.inst 0x721c6bc1 // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:1 Rn:30 imms:011010 immr:011100 N:0 100100:100100 opc:11 sf:0
	.inst 0xd8ea229f // prfm_lit:aarch64/instrs/memory/literal/general Rt:31 imm19:1110101000100010100 011000:011000 opc:11
	.inst 0x38215b5b // strb_reg:aarch64/instrs/memory/single/general/register Rt:27 Rn:26 10:10 S:1 option:010 Rm:1 1:1 opc:00 111000:111000 size:00
	.inst 0xc2de1ed6 // CSEL-C.CI-C Cd:22 Cn:22 11:11 cond:0001 Cm:30 11000010110:11000010110
	.inst 0xdac01418 // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:24 Rn:0 op:1 10110101100000000010:10110101100000000010 sf:1
	.inst 0xc2c21380
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x4, cptr_el3
	orr x4, x4, #0x200
	msr cptr_el3, x4
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
	ldr x4, =initial_cap_values
	.inst 0xc2400080 // ldr c0, [x4, #0]
	.inst 0xc240048e // ldr c14, [x4, #1]
	.inst 0xc2400891 // ldr c17, [x4, #2]
	.inst 0xc2400c9a // ldr c26, [x4, #3]
	.inst 0xc240109b // ldr c27, [x4, #4]
	.inst 0xc240149e // ldr c30, [x4, #5]
	/* Vector registers */
	mrs x4, cptr_el3
	bfc x4, #10, #1
	msr cptr_el3, x4
	isb
	ldr q15, =0x0
	ldr q30, =0x0
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	ldr x4, =0x0
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82603384 // ldr c4, [c28, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x82601384 // ldr c4, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	/* Check processor flags */
	mrs x4, nzcv
	ubfx x4, x4, #28, #4
	mov x28, #0xf
	and x4, x4, x28
	cmp x4, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc240009c // ldr c28, [x4, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc240049c // ldr c28, [x4, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc240089c // ldr c28, [x4, #2]
	.inst 0xc2dca5c1 // chkeq c14, c28
	b.ne comparison_fail
	.inst 0xc2400c9c // ldr c28, [x4, #3]
	.inst 0xc2dca621 // chkeq c17, c28
	b.ne comparison_fail
	.inst 0xc240109c // ldr c28, [x4, #4]
	.inst 0xc2dca701 // chkeq c24, c28
	b.ne comparison_fail
	.inst 0xc240149c // ldr c28, [x4, #5]
	.inst 0xc2dca741 // chkeq c26, c28
	b.ne comparison_fail
	.inst 0xc240189c // ldr c28, [x4, #6]
	.inst 0xc2dca761 // chkeq c27, c28
	b.ne comparison_fail
	.inst 0xc2401c9c // ldr c28, [x4, #7]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check vector registers */
	ldr x4, =0x0
	mov x28, v15.d[0]
	cmp x4, x28
	b.ne comparison_fail
	ldr x4, =0x0
	mov x28, v15.d[1]
	cmp x4, x28
	b.ne comparison_fail
	ldr x4, =0x0
	mov x28, v30.d[0]
	cmp x4, x28
	b.ne comparison_fail
	ldr x4, =0x0
	mov x28, v30.d[1]
	cmp x4, x28
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
	ldr x0, =0x00001f80
	ldr x1, =check_data1
	ldr x2, =0x00001f90
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
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

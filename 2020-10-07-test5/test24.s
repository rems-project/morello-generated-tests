.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.byte 0xcc, 0x83, 0xab, 0x22, 0x3b, 0x13, 0xa4, 0xf9, 0xe2, 0x87, 0x9f, 0x9a, 0x5f, 0x88, 0xd9, 0xc2
	.byte 0x4d, 0x00, 0x00, 0x9a, 0x22, 0x44, 0xcf, 0x38, 0xc1, 0x8b, 0x99, 0xca, 0x1f, 0x02, 0x0a, 0xda
	.byte 0x40, 0x10, 0x83, 0x6b, 0xe4, 0x93, 0xc5, 0xc2, 0x60, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4000000000000000000000000000
	/* C1 */
	.octa 0x1000
	/* C12 */
	.octa 0x0
	/* C25 */
	.octa 0x400100010000000000000001
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C1 */
	.octa 0xd70
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0xc80000004009000a0000000000000000
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x1
	/* C25 */
	.octa 0x400100010000000000000001
	/* C30 */
	.octa 0xd70
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc80000004009000a0000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x22ab83cc // STP-CC.RIAW-C Ct:12 Rn:30 Ct2:00000 imm7:1010111 L:0 001000101:001000101
	.inst 0xf9a4133b // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:27 Rn:25 imm12:100100000100 opc:10 111001:111001 size:11
	.inst 0x9a9f87e2 // csinc:aarch64/instrs/integer/conditional/select Rd:2 Rn:31 o2:1 0:0 cond:1000 Rm:31 011010100:011010100 op:0 sf:1
	.inst 0xc2d9885f // CHKSSU-C.CC-C Cd:31 Cn:2 0010:0010 opc:10 Cm:25 11000010110:11000010110
	.inst 0x9a00004d // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:13 Rn:2 000000:000000 Rm:0 11010000:11010000 S:0 op:0 sf:1
	.inst 0x38cf4422 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:2 Rn:1 01:01 imm9:011110100 0:0 opc:11 111000:111000 size:00
	.inst 0xca998bc1 // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:30 imm6:100010 Rm:25 N:0 shift:10 01010:01010 opc:10 sf:1
	.inst 0xda0a021f // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:31 Rn:16 000000:000000 Rm:10 11010000:11010000 S:0 op:1 sf:1
	.inst 0x6b831040 // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:0 Rn:2 imm6:000100 Rm:3 0:0 shift:10 01011:01011 S:1 op:1 sf:0
	.inst 0xc2c593e4 // CVTD-C.R-C Cd:4 Rn:31 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0xc2c21360
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x8, cptr_el3
	orr x8, x8, #0x200
	msr cptr_el3, x8
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
	ldr x8, =initial_cap_values
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400501 // ldr c1, [x8, #1]
	.inst 0xc240090c // ldr c12, [x8, #2]
	.inst 0xc2400d19 // ldr c25, [x8, #3]
	.inst 0xc240111e // ldr c30, [x8, #4]
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30850032
	msr SCTLR_EL3, x8
	ldr x8, =0x0
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82603368 // ldr c8, [c27, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x82601368 // ldr c8, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc240011b // ldr c27, [x8, #0]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc240051b // ldr c27, [x8, #1]
	.inst 0xc2dba441 // chkeq c2, c27
	b.ne comparison_fail
	.inst 0xc240091b // ldr c27, [x8, #2]
	.inst 0xc2dba481 // chkeq c4, c27
	b.ne comparison_fail
	.inst 0xc2400d1b // ldr c27, [x8, #3]
	.inst 0xc2dba581 // chkeq c12, c27
	b.ne comparison_fail
	.inst 0xc240111b // ldr c27, [x8, #4]
	.inst 0xc2dba5a1 // chkeq c13, c27
	b.ne comparison_fail
	.inst 0xc240151b // ldr c27, [x8, #5]
	.inst 0xc2dba721 // chkeq c25, c27
	b.ne comparison_fail
	.inst 0xc240191b // ldr c27, [x8, #6]
	.inst 0xc2dba7c1 // chkeq c30, c27
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
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
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

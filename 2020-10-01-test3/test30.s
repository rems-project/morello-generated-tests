.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x5a, 0x52, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x01, 0xe3, 0x12, 0xf8, 0xb5, 0x25, 0x82, 0x5a, 0xc4, 0xdb, 0x6f, 0x82, 0x61, 0xdd, 0x6e, 0xfd
	.byte 0x5d, 0x18, 0xcc, 0xc2, 0x3f, 0x10, 0xc0, 0x5a, 0x5f, 0x26, 0x4c, 0x82, 0xbe, 0xad, 0xa3, 0x9b
	.byte 0xec, 0x53, 0xc0, 0xc2, 0x5f, 0x33, 0x03, 0xd5, 0x00, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x525a000000
	/* C2 */
	.octa 0x1000000030000000000000000
	/* C11 */
	.octa 0xffffffffffffb250
	/* C18 */
	.octa 0x40000000580210040000000000001000
	/* C24 */
	.octa 0x10e2
	/* C30 */
	.octa 0x80000000000700170000000000001000
final_cap_values:
	/* C1 */
	.octa 0x525a000000
	/* C2 */
	.octa 0x1000000030000000000000000
	/* C4 */
	.octa 0x0
	/* C11 */
	.octa 0xffffffffffffb250
	/* C18 */
	.octa 0x40000000580210040000000000001000
	/* C24 */
	.octa 0x10e2
	/* C29 */
	.octa 0x1000000030000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000001ff90005000080000001e000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf812e301 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:24 00:00 imm9:100101110 0:0 opc:00 111000:111000 size:11
	.inst 0x5a8225b5 // csneg:aarch64/instrs/integer/conditional/select Rd:21 Rn:13 o2:1 0:0 cond:0010 Rm:2 011010100:011010100 op:1 sf:0
	.inst 0x826fdbc4 // ALDR-R.RI-32 Rt:4 Rn:30 op:10 imm9:011111101 L:1 1000001001:1000001001
	.inst 0xfd6edd61 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:1 Rn:11 imm12:101110110111 opc:01 111101:111101 size:11
	.inst 0xc2cc185d // ALIGND-C.CI-C Cd:29 Cn:2 0110:0110 U:0 imm6:011000 11000010110:11000010110
	.inst 0x5ac0103f // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:31 Rn:1 op:0 10110101100000000010:10110101100000000010 sf:0
	.inst 0x824c265f // ASTRB-R.RI-B Rt:31 Rn:18 op:01 imm9:011000010 L:0 1000001001:1000001001
	.inst 0x9ba3adbe // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:30 Rn:13 Ra:11 o0:1 Rm:3 01:01 U:1 10011011:10011011
	.inst 0xc2c053ec // GCVALUE-R.C-C Rd:12 Cn:31 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0xd503335f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:0011 11010101000000110011:11010101000000110011
	.inst 0xc2c21100
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
	.inst 0xc240080b // ldr c11, [x0, #2]
	.inst 0xc2400c12 // ldr c18, [x0, #3]
	.inst 0xc2401018 // ldr c24, [x0, #4]
	.inst 0xc240141e // ldr c30, [x0, #5]
	/* Set up flags and system registers */
	mov x0, #0x20000000
	msr nzcv, x0
	ldr x0, =0x200
	msr CPTR_EL3, x0
	ldr x0, =0x30850032
	msr SCTLR_EL3, x0
	ldr x0, =0x4
	msr S3_6_C1_C2_2, x0 // CCTLR_EL3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x82603100 // ldr c0, [c8, #3]
	.inst 0xc28b4120 // msr ddc_el3, c0
	isb
	.inst 0x82601100 // ldr c0, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
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
	mov x8, #0x2
	and x0, x0, x8
	cmp x0, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x0, =final_cap_values
	.inst 0xc2400008 // ldr c8, [x0, #0]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc2400408 // ldr c8, [x0, #1]
	.inst 0xc2c8a441 // chkeq c2, c8
	b.ne comparison_fail
	.inst 0xc2400808 // ldr c8, [x0, #2]
	.inst 0xc2c8a481 // chkeq c4, c8
	b.ne comparison_fail
	.inst 0xc2400c08 // ldr c8, [x0, #3]
	.inst 0xc2c8a561 // chkeq c11, c8
	b.ne comparison_fail
	.inst 0xc2401008 // ldr c8, [x0, #4]
	.inst 0xc2c8a641 // chkeq c18, c8
	b.ne comparison_fail
	.inst 0xc2401408 // ldr c8, [x0, #5]
	.inst 0xc2c8a701 // chkeq c24, c8
	b.ne comparison_fail
	.inst 0xc2401808 // ldr c8, [x0, #6]
	.inst 0xc2c8a7a1 // chkeq c29, c8
	b.ne comparison_fail
	/* Check vector registers */
	ldr x0, =0x0
	mov x8, v1.d[0]
	cmp x0, x8
	b.ne comparison_fail
	ldr x0, =0x0
	mov x8, v1.d[1]
	cmp x0, x8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001008
	ldr x1, =check_data0
	ldr x2, =0x00001018
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010c2
	ldr x1, =check_data1
	ldr x2, =0x000010c3
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000013f4
	ldr x1, =check_data2
	ldr x2, =0x000013f8
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

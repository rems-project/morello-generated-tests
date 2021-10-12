.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x01, 0x03, 0x1e, 0xda, 0xf5, 0x53, 0x87, 0xb8, 0x5f, 0x3d, 0x03, 0xd5, 0x1e, 0xf8, 0xff, 0x82
	.byte 0x00, 0xc5, 0xe1, 0x82, 0x47, 0x45, 0xb1, 0x70, 0x5f, 0x59, 0xfe, 0xc2, 0x20, 0x00, 0x5f, 0xd6
.data
check_data3:
	.byte 0xe1, 0x07, 0x1c, 0x38, 0x23, 0x10, 0x3a, 0x4b, 0xa0, 0x10, 0xc2, 0xc2
.data
check_data4:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000000000000000000001000
	/* C8 */
	.octa 0x80000000000300070000000000000440
	/* C10 */
	.octa 0x4001080100fffffffffff000
	/* C24 */
	.octa 0x1c00000000500000
	/* C30 */
	.octa 0x1c000000000007c0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x4ff840
	/* C7 */
	.octa 0x3628bf
	/* C8 */
	.octa 0x80000000000300070000000000000440
	/* C10 */
	.octa 0x4001080100fffffffffff000
	/* C21 */
	.octa 0x0
	/* C24 */
	.octa 0x1c00000000500000
	/* C30 */
	.octa 0x1c000000000007c0
initial_SP_EL3_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000088000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005084100300ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xda1e0301 // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:24 000000:000000 Rm:30 11010000:11010000 S:0 op:1 sf:1
	.inst 0xb88753f5 // ldursw:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:21 Rn:31 00:00 imm9:001110101 0:0 opc:10 111000:111000 size:10
	.inst 0xd5033d5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1101 11010101000000110011:11010101000000110011
	.inst 0x82fff81e // ALDR-V.RRB-D Rt:30 Rn:0 opc:10 S:1 option:111 Rm:31 1:1 L:1 100000101:100000101
	.inst 0x82e1c500 // ALDR-R.RRB-64 Rt:0 Rn:8 opc:01 S:0 option:110 Rm:1 1:1 L:1 100000101:100000101
	.inst 0x70b14547 // ADR-C.I-C Rd:7 immhi:011000101000101010 P:1 10000:10000 immlo:11 op:0
	.inst 0xc2fe595f // CVTZ-C.CR-C Cd:31 Cn:10 0110:0110 1:1 0:0 Rm:30 11000010111:11000010111
	.inst 0xd65f0020 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:1 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 1046560
	.inst 0x381c07e1 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:31 01:01 imm9:111000000 0:0 opc:00 111000:111000 size:00
	.inst 0x4b3a1023 // sub_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:3 Rn:1 imm3:100 option:000 Rm:26 01011001:01011001 S:0 op:1 sf:0
	.inst 0xc2c210a0
	.zero 1972
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
	ldr x9, =initial_cap_values
	.inst 0xc2400120 // ldr c0, [x9, #0]
	.inst 0xc2400528 // ldr c8, [x9, #1]
	.inst 0xc240092a // ldr c10, [x9, #2]
	.inst 0xc2400d38 // ldr c24, [x9, #3]
	.inst 0xc240113e // ldr c30, [x9, #4]
	/* Set up flags and system registers */
	mov x9, #0x20000000
	msr nzcv, x9
	ldr x9, =initial_SP_EL3_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2c1d13f // cpy c31, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30850038
	msr SCTLR_EL3, x9
	ldr x9, =0x4
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030a9 // ldr c9, [c5, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x826010a9 // ldr c9, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x5, #0x2
	and x9, x9, x5
	cmp x9, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400125 // ldr c5, [x9, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400525 // ldr c5, [x9, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400925 // ldr c5, [x9, #2]
	.inst 0xc2c5a4e1 // chkeq c7, c5
	b.ne comparison_fail
	.inst 0xc2400d25 // ldr c5, [x9, #3]
	.inst 0xc2c5a501 // chkeq c8, c5
	b.ne comparison_fail
	.inst 0xc2401125 // ldr c5, [x9, #4]
	.inst 0xc2c5a541 // chkeq c10, c5
	b.ne comparison_fail
	.inst 0xc2401525 // ldr c5, [x9, #5]
	.inst 0xc2c5a6a1 // chkeq c21, c5
	b.ne comparison_fail
	.inst 0xc2401925 // ldr c5, [x9, #6]
	.inst 0xc2c5a701 // chkeq c24, c5
	b.ne comparison_fail
	.inst 0xc2401d25 // ldr c5, [x9, #7]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0x0
	mov x5, v30.d[0]
	cmp x9, x5
	b.ne comparison_fail
	ldr x9, =0x0
	mov x5, v30.d[1]
	cmp x9, x5
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
	ldr x0, =0x00001078
	ldr x1, =check_data1
	ldr x2, =0x0000107c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400020
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004ff840
	ldr x1, =check_data3
	ldr x2, =0x004ff84c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004ffc80
	ldr x1, =check_data4
	ldr x2, =0x004ffc88
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
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

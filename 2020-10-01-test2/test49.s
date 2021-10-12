.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x02, 0x50, 0xc2, 0xc2, 0x00, 0x08, 0xd8, 0xc2, 0x01, 0x2e, 0x43, 0x90, 0xa0, 0x10, 0xc2, 0xc2
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x02, 0xd8, 0x26, 0xbc, 0x02, 0x04, 0x9e, 0x98, 0xe8, 0x13, 0xc0, 0xc2, 0xde, 0xff, 0x72, 0xc2
	.byte 0x1b, 0x72, 0xf1, 0xc2, 0xe4, 0xdf, 0x49, 0x69, 0x00, 0x03, 0x1f, 0xd6
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xa00080008000000000000000004d1000
	/* C6 */
	.octa 0xffecc000
	/* C16 */
	.octa 0x3fff800000000000000000000000
	/* C24 */
	.octa 0x400004
	/* C30 */
	.octa 0x400100
final_cap_values:
	/* C0 */
	.octa 0xa00080020000000000000000004d1000
	/* C1 */
	.octa 0x869c0000
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C6 */
	.octa 0xffecc000
	/* C8 */
	.octa 0x0
	/* C16 */
	.octa 0x3fff800000000000000000000000
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0x400004
	/* C27 */
	.octa 0x3fff800000008b00000000000000
	/* C30 */
	.octa 0x0
initial_csp_value:
	.octa 0x100060000000000400000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd00000000003000700ffff0302800001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c25002 // RETS-C-C 00010:00010 Cn:0 100:100 opc:10 11000010110000100:11000010110000100
	.inst 0xc2d80800 // SEAL-C.CC-C Cd:0 Cn:0 0010:0010 opc:00 Cm:24 11000010110:11000010110
	.inst 0x90432e01 // ADRP-C.I-C Rd:1 immhi:100001100101110000 P:0 10000:10000 immlo:00 op:1
	.inst 0xc2c210a0
	.zero 856048
	.inst 0xbc26d802 // str_reg_fpsimd:aarch64/instrs/memory/single/simdfp/register Rt:2 Rn:0 10:10 S:1 option:110 Rm:6 1:1 opc:00 111100:111100 size:10
	.inst 0x989e0402 // ldrsw_lit:aarch64/instrs/memory/literal/general Rt:2 imm19:1001111000000100000 011000:011000 opc:10
	.inst 0xc2c013e8 // GCBASE-R.C-C Rd:8 Cn:31 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0xc272ffde // LDR-C.RIB-C Ct:30 Rn:30 imm12:110010111111 L:1 110000100:110000100
	.inst 0xc2f1721b // EORFLGS-C.CI-C Cd:27 Cn:16 0:0 10:10 imm8:10001011 11000010111:11000010111
	.inst 0x6949dfe4 // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:4 Rn:31 Rt2:10111 imm7:0010011 L:1 1010010:1010010 opc:01
	.inst 0xd61f0300 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:24 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.zero 192484
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
	.inst 0xc2400526 // ldr c6, [x9, #1]
	.inst 0xc2400930 // ldr c16, [x9, #2]
	.inst 0xc2400d38 // ldr c24, [x9, #3]
	.inst 0xc240113e // ldr c30, [x9, #4]
	/* Vector registers */
	mrs x9, cptr_el3
	bfc x9, #10, #1
	msr cptr_el3, x9
	isb
	ldr q2, =0x0
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
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030a9 // ldr c9, [c5, #3]
	.inst 0xc28b4129 // msr ddc_el3, c9
	isb
	.inst 0x826010a9 // ldr c9, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
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
	.inst 0xc2400125 // ldr c5, [x9, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400525 // ldr c5, [x9, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400925 // ldr c5, [x9, #2]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400d25 // ldr c5, [x9, #3]
	.inst 0xc2c5a481 // chkeq c4, c5
	b.ne comparison_fail
	.inst 0xc2401125 // ldr c5, [x9, #4]
	.inst 0xc2c5a4c1 // chkeq c6, c5
	b.ne comparison_fail
	.inst 0xc2401525 // ldr c5, [x9, #5]
	.inst 0xc2c5a501 // chkeq c8, c5
	b.ne comparison_fail
	.inst 0xc2401925 // ldr c5, [x9, #6]
	.inst 0xc2c5a601 // chkeq c16, c5
	b.ne comparison_fail
	.inst 0xc2401d25 // ldr c5, [x9, #7]
	.inst 0xc2c5a6e1 // chkeq c23, c5
	b.ne comparison_fail
	.inst 0xc2402125 // ldr c5, [x9, #8]
	.inst 0xc2c5a701 // chkeq c24, c5
	b.ne comparison_fail
	.inst 0xc2402525 // ldr c5, [x9, #9]
	.inst 0xc2c5a761 // chkeq c27, c5
	b.ne comparison_fail
	.inst 0xc2402925 // ldr c5, [x9, #10]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0x0
	mov x5, v2.d[0]
	cmp x9, x5
	b.ne comparison_fail
	ldr x9, =0x0
	mov x5, v2.d[1]
	cmp x9, x5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x00400010
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0040004c
	ldr x1, =check_data2
	ldr x2, =0x00400054
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0040ccf0
	ldr x1, =check_data3
	ldr x2, =0x0040cd00
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0040d084
	ldr x1, =check_data4
	ldr x2, =0x0040d088
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004d1000
	ldr x1, =check_data5
	ldr x2, =0x004d101c
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

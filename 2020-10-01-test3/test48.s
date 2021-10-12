.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x82, 0x53, 0xc2, 0xc2
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x24, 0x33, 0xc1, 0xc2, 0x49, 0xcf, 0x6c, 0xd8, 0x84, 0xbb, 0xd8, 0x78, 0x01, 0x30, 0xc2, 0xc2
	.byte 0x01, 0x3c, 0x25, 0x79, 0xa8, 0x22, 0xf4, 0xc2, 0xd4, 0x27, 0xc1, 0x9a, 0x01, 0xa0, 0xcf, 0xc2
	.byte 0xb2, 0x96, 0x96, 0xe2, 0x40, 0x13, 0xc2, 0xc2
.data
check_data4:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000100050000000000000d5e
	/* C1 */
	.octa 0x0
	/* C21 */
	.octa 0x20000000000000000000050008f
	/* C28 */
	.octa 0xa00080001037503f0000000000409001
final_cap_values:
	/* C0 */
	.octa 0x40000000000100050000000000000d5e
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x20000000000000000000050008f
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x20000000000000000000050008f
	/* C28 */
	.octa 0xa00080001037503f0000000000409001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000407c00f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000090000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c25382 // RETS-C-C 00010:00010 Cn:28 100:100 opc:10 11000010110000100:11000010110000100
	.zero 36860
	.inst 0xc2c13324 // GCFLGS-R.C-C Rd:4 Cn:25 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xd86ccf49 // prfm_lit:aarch64/instrs/memory/literal/general Rt:9 imm19:0110110011001111010 011000:011000 opc:11
	.inst 0x78d8bb84 // ldtrsh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:4 Rn:28 10:10 imm9:110001011 0:0 opc:11 111000:111000 size:01
	.inst 0xc2c23001 // CHKTGD-C-C 00001:00001 Cn:0 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x79253c01 // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:0 imm12:100101001111 opc:00 111001:111001 size:01
	.inst 0xc2f422a8 // BICFLGS-C.CI-C Cd:8 Cn:21 0:0 00:00 imm8:10100001 11000010111:11000010111
	.inst 0x9ac127d4 // lsrv:aarch64/instrs/integer/shift/variable Rd:20 Rn:30 op2:01 0010:0010 Rm:1 0011010110:0011010110 sf:1
	.inst 0xc2cfa001 // CLRPERM-C.CR-C Cd:1 Cn:0 000:000 1:1 10:10 Rm:15 11000010110:11000010110
	.inst 0xe29696b2 // ALDUR-R.RI-32 Rt:18 Rn:21 op2:01 imm9:101101001 V:0 op1:10 11100010:11100010
	.inst 0xc2c21340
	.zero 1011672
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x6, cptr_el3
	orr x6, x6, #0x200
	msr cptr_el3, x6
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c1 // ldr c1, [x6, #1]
	.inst 0xc24008d5 // ldr c21, [x6, #2]
	.inst 0xc2400cdc // ldr c28, [x6, #3]
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30850032
	msr SCTLR_EL3, x6
	ldr x6, =0x0
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82603346 // ldr c6, [c26, #3]
	.inst 0xc28b4126 // msr ddc_el3, c6
	isb
	.inst 0x82601346 // ldr c6, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr ddc_el3, c6
	isb
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x26, #0xf
	and x6, x6, x26
	cmp x6, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000da // ldr c26, [x6, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc24004da // ldr c26, [x6, #1]
	.inst 0xc2daa481 // chkeq c4, c26
	b.ne comparison_fail
	.inst 0xc24008da // ldr c26, [x6, #2]
	.inst 0xc2daa501 // chkeq c8, c26
	b.ne comparison_fail
	.inst 0xc2400cda // ldr c26, [x6, #3]
	.inst 0xc2daa641 // chkeq c18, c26
	b.ne comparison_fail
	.inst 0xc24010da // ldr c26, [x6, #4]
	.inst 0xc2daa6a1 // chkeq c21, c26
	b.ne comparison_fail
	.inst 0xc24014da // ldr c26, [x6, #5]
	.inst 0xc2daa781 // chkeq c28, c26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001ffc
	ldr x1, =check_data0
	ldr x2, =0x00001ffe
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x00400004
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00408f8c
	ldr x1, =check_data2
	ldr x2, =0x00408f8e
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00409000
	ldr x1, =check_data3
	ldr x2, =0x00409028
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004ffff8
	ldr x1, =check_data4
	ldr x2, =0x004ffffc
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
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr ddc_el3, c6
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

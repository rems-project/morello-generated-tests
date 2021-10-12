.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xf7, 0xeb, 0xc5, 0xc2, 0x5d, 0x08, 0xc1, 0x9a, 0x1f, 0xb8, 0x44, 0xb8, 0x5f, 0x86, 0x19, 0x92
	.byte 0xe1, 0x23, 0x13, 0xaa, 0x52, 0xb4, 0x51, 0x78, 0x5a, 0x48, 0xba, 0xf8, 0x04, 0x70, 0xc0, 0xc2
	.byte 0xef, 0xe8, 0x1f, 0x9b, 0xfe, 0x1b, 0xf5, 0xc2, 0x40, 0x11, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x300070000000000430fd5
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x4cffe4
final_cap_values:
	/* C0 */
	.octa 0x300070000000000430fd5
	/* C2 */
	.octa 0x4cfeff
	/* C4 */
	.octa 0x430fd5
	/* C18 */
	.octa 0xc2c2
	/* C29 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000600870000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000003f060086000000000000e001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c5ebf7 // CTHI-C.CR-C Cd:23 Cn:31 1010:1010 opc:11 Rm:5 11000010110:11000010110
	.inst 0x9ac1085d // udiv:aarch64/instrs/integer/arithmetic/div Rd:29 Rn:2 o1:0 00001:00001 Rm:1 0011010110:0011010110 sf:1
	.inst 0xb844b81f // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:0 10:10 imm9:001001011 0:0 opc:01 111000:111000 size:10
	.inst 0x9219865f // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:31 Rn:18 imms:100001 immr:011001 N:0 100100:100100 opc:00 sf:1
	.inst 0xaa1323e1 // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:31 imm6:001000 Rm:19 N:0 shift:00 01010:01010 opc:01 sf:1
	.inst 0x7851b452 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:18 Rn:2 01:01 imm9:100011011 0:0 opc:01 111000:111000 size:01
	.inst 0xf8ba485a // prfm_reg:aarch64/instrs/memory/single/general/register Rt:26 Rn:2 10:10 S:0 option:010 Rm:26 1:1 opc:10 111000:111000 size:11
	.inst 0xc2c07004 // GCOFF-R.C-C Rd:4 Cn:0 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0x9b1fe8ef // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:15 Rn:7 Ra:26 o0:1 Rm:31 0011011000:0011011000 sf:1
	.inst 0xc2f51bfe // CVT-C.CR-C Cd:30 Cn:31 0110:0110 0:0 0:0 Rm:21 11000010111:11000010111
	.inst 0xc2c21140
	.zero 266228
	.inst 0xc2c2c2c2
	.zero 651200
	.inst 0x0000c2c2
	.zero 131096
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x20, cptr_el3
	orr x20, x20, #0x200
	msr cptr_el3, x20
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
	ldr x20, =initial_cap_values
	.inst 0xc2400280 // ldr c0, [x20, #0]
	.inst 0xc2400681 // ldr c1, [x20, #1]
	.inst 0xc2400a82 // ldr c2, [x20, #2]
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
	ldr x20, =0x4
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603154 // ldr c20, [c10, #3]
	.inst 0xc28b4134 // msr ddc_el3, c20
	isb
	.inst 0x82601154 // ldr c20, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr ddc_el3, c20
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc240028a // ldr c10, [x20, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240068a // ldr c10, [x20, #1]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400a8a // ldr c10, [x20, #2]
	.inst 0xc2caa481 // chkeq c4, c10
	b.ne comparison_fail
	.inst 0xc2400e8a // ldr c10, [x20, #3]
	.inst 0xc2caa641 // chkeq c18, c10
	b.ne comparison_fail
	.inst 0xc240128a // ldr c10, [x20, #4]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00400000
	ldr x1, =check_data0
	ldr x2, =0x0040002c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00441020
	ldr x1, =check_data1
	ldr x2, =0x00441024
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x004dffe4
	ldr x1, =check_data2
	ldr x2, =0x004dffe6
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
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr ddc_el3, c20
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

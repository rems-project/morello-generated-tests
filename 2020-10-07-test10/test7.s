.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x5f, 0x3e, 0x03, 0xd5, 0x12, 0x8d, 0xc0, 0xf0, 0x21, 0x9b, 0x80, 0xe2, 0x9e, 0xd0, 0xc0, 0xc2
	.byte 0xff, 0xcf, 0x59, 0x78, 0xc5, 0xff, 0x3f, 0x42, 0x7d, 0x52, 0xc0, 0xc2, 0x1a, 0x02, 0xc0, 0x5a
	.byte 0xb3, 0x32, 0xc1, 0xc2, 0x82, 0x9a, 0xd6, 0xc2, 0x80, 0x11, 0xc2, 0xc2
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C4 */
	.octa 0x7fe0000000000000000000000000000
	/* C5 */
	.octa 0x0
	/* C20 */
	.octa 0x803b803e00c4000000000001
	/* C25 */
	.octa 0x478203
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x803b803e00c4000000000000
	/* C4 */
	.octa 0x7fe0000000000000000000000000000
	/* C5 */
	.octa 0x0
	/* C18 */
	.octa 0x200080003dc62007ffffffff815a3000
	/* C20 */
	.octa 0x803b803e00c4000000000001
	/* C25 */
	.octa 0x478203
	/* C30 */
	.octa 0x1ff8
initial_SP_EL3_value:
	.octa 0x800000000007800f0000000000408800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080003dc620070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000500030000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd5033e5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1110 11010101000000110011:11010101000000110011
	.inst 0xf0c08d12 // ADRP-C.I-C Rd:18 immhi:100000010001101000 P:1 10000:10000 immlo:11 op:1
	.inst 0xe2809b21 // ALDURSW-R.RI-64 Rt:1 Rn:25 op2:10 imm9:000001001 V:0 op1:10 11100010:11100010
	.inst 0xc2c0d09e // GCPERM-R.C-C Rd:30 Cn:4 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0x7859cfff // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:31 11:11 imm9:110011100 0:0 opc:01 111000:111000 size:01
	.inst 0x423fffc5 // ASTLR-R.R-32 Rt:5 Rn:30 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xc2c0527d // GCVALUE-R.C-C Rd:29 Cn:19 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0x5ac0021a // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:26 Rn:16 101101011000000000000:101101011000000000000 sf:0
	.inst 0xc2c132b3 // GCFLGS-R.C-C Rd:19 Cn:21 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xc2d69a82 // ALIGND-C.CI-C Cd:2 Cn:20 0110:0110 U:0 imm6:101101 11000010110:11000010110
	.inst 0xc2c21180
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x15, cptr_el3
	orr x15, x15, #0x200
	msr cptr_el3, x15
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e4 // ldr c4, [x15, #0]
	.inst 0xc24005e5 // ldr c5, [x15, #1]
	.inst 0xc24009f4 // ldr c20, [x15, #2]
	.inst 0xc2400df9 // ldr c25, [x15, #3]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =initial_SP_EL3_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2c1d1ff // cpy c31, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30850032
	msr SCTLR_EL3, x15
	ldr x15, =0x0
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x8260318f // ldr c15, [c12, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260118f // ldr c15, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001ec // ldr c12, [x15, #0]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc24005ec // ldr c12, [x15, #1]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc24009ec // ldr c12, [x15, #2]
	.inst 0xc2cca481 // chkeq c4, c12
	b.ne comparison_fail
	.inst 0xc2400dec // ldr c12, [x15, #3]
	.inst 0xc2cca4a1 // chkeq c5, c12
	b.ne comparison_fail
	.inst 0xc24011ec // ldr c12, [x15, #4]
	.inst 0xc2cca641 // chkeq c18, c12
	b.ne comparison_fail
	.inst 0xc24015ec // ldr c12, [x15, #5]
	.inst 0xc2cca681 // chkeq c20, c12
	b.ne comparison_fail
	.inst 0xc24019ec // ldr c12, [x15, #6]
	.inst 0xc2cca721 // chkeq c25, c12
	b.ne comparison_fail
	.inst 0xc2401dec // ldr c12, [x15, #7]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001ff8
	ldr x1, =check_data0
	ldr x2, =0x00001ffc
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
	ldr x0, =0x0040879c
	ldr x1, =check_data2
	ldr x2, =0x0040879e
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0047820c
	ldr x1, =check_data3
	ldr x2, =0x00478210
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
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
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

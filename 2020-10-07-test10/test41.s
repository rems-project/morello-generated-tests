.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xe8, 0x66, 0x50, 0xbc, 0x96, 0x12, 0xc0, 0xc2, 0x02, 0xd2, 0xc5, 0xc2, 0xc1, 0xa3, 0x0a, 0xb8
	.byte 0xc1, 0xfd, 0x9f, 0x08, 0x5d, 0xe9, 0xf9, 0xc2, 0x1a, 0x30, 0xc1, 0xc2, 0xa1, 0xeb, 0xae, 0xb6
	.byte 0x1a, 0x50, 0xc1, 0xc2, 0x1a, 0xf0, 0xc5, 0xc2, 0xa0, 0x10, 0xc2, 0xc2
.data
check_data3:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000000000
	/* C1 */
	.octa 0x20000000000000
	/* C10 */
	.octa 0x3fff800000000000000000000000
	/* C14 */
	.octa 0x1c20
	/* C16 */
	.octa 0x80000000000000
	/* C20 */
	.octa 0x700060000000000000000
	/* C23 */
	.octa 0x420240
	/* C30 */
	.octa 0x1006
final_cap_values:
	/* C0 */
	.octa 0x400000000000
	/* C1 */
	.octa 0x20000000000000
	/* C2 */
	.octa 0xc0000000000500070080000000000000
	/* C10 */
	.octa 0x3fff800000000000000000000000
	/* C14 */
	.octa 0x1c20
	/* C16 */
	.octa 0x80000000000000
	/* C20 */
	.octa 0x700060000000000000000
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x420146
	/* C26 */
	.octa 0x20008000000000000000400000000000
	/* C29 */
	.octa 0x3fff80000000cf00000000000000
	/* C30 */
	.octa 0x1006
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000500070000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xbc5066e8 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:8 Rn:23 01:01 imm9:100000110 0:0 opc:01 111100:111100 size:10
	.inst 0xc2c01296 // GCBASE-R.C-C Rd:22 Cn:20 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0xc2c5d202 // CVTDZ-C.R-C Cd:2 Rn:16 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0xb80aa3c1 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:30 00:00 imm9:010101010 0:0 opc:00 111000:111000 size:10
	.inst 0x089ffdc1 // stlrb:aarch64/instrs/memory/ordered Rt:1 Rn:14 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2f9e95d // ORRFLGS-C.CI-C Cd:29 Cn:10 0:0 01:01 imm8:11001111 11000010111:11000010111
	.inst 0xc2c1301a // GCFLGS-R.C-C Rd:26 Cn:0 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xb6aeeba1 // tbz:aarch64/instrs/branch/conditional/test Rt:1 imm14:11011101011101 b40:10101 op:0 011011:011011 b5:1
	.inst 0xc2c1501a // CFHI-R.C-C Rd:26 Cn:0 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xc2c5f01a // CVTPZ-C.R-C Cd:26 Rn:0 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0xc2c210a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x13, cptr_el3
	orr x13, x13, #0x200
	msr cptr_el3, x13
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a1 // ldr c1, [x13, #1]
	.inst 0xc24009aa // ldr c10, [x13, #2]
	.inst 0xc2400dae // ldr c14, [x13, #3]
	.inst 0xc24011b0 // ldr c16, [x13, #4]
	.inst 0xc24015b4 // ldr c20, [x13, #5]
	.inst 0xc24019b7 // ldr c23, [x13, #6]
	.inst 0xc2401dbe // ldr c30, [x13, #7]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	ldr x13, =0x8
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030ad // ldr c13, [c5, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x826010ad // ldr c13, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001a5 // ldr c5, [x13, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc24005a5 // ldr c5, [x13, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc24009a5 // ldr c5, [x13, #2]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400da5 // ldr c5, [x13, #3]
	.inst 0xc2c5a541 // chkeq c10, c5
	b.ne comparison_fail
	.inst 0xc24011a5 // ldr c5, [x13, #4]
	.inst 0xc2c5a5c1 // chkeq c14, c5
	b.ne comparison_fail
	.inst 0xc24015a5 // ldr c5, [x13, #5]
	.inst 0xc2c5a601 // chkeq c16, c5
	b.ne comparison_fail
	.inst 0xc24019a5 // ldr c5, [x13, #6]
	.inst 0xc2c5a681 // chkeq c20, c5
	b.ne comparison_fail
	.inst 0xc2401da5 // ldr c5, [x13, #7]
	.inst 0xc2c5a6c1 // chkeq c22, c5
	b.ne comparison_fail
	.inst 0xc24021a5 // ldr c5, [x13, #8]
	.inst 0xc2c5a6e1 // chkeq c23, c5
	b.ne comparison_fail
	.inst 0xc24025a5 // ldr c5, [x13, #9]
	.inst 0xc2c5a741 // chkeq c26, c5
	b.ne comparison_fail
	.inst 0xc24029a5 // ldr c5, [x13, #10]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	.inst 0xc2402da5 // ldr c5, [x13, #11]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0x0
	mov x5, v8.d[0]
	cmp x13, x5
	b.ne comparison_fail
	ldr x13, =0x0
	mov x5, v8.d[1]
	cmp x13, x5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010b0
	ldr x1, =check_data0
	ldr x2, =0x000010b4
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001c20
	ldr x1, =check_data1
	ldr x2, =0x00001c21
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
	ldr x0, =0x00420240
	ldr x1, =check_data3
	ldr x2, =0x00420244
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
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
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

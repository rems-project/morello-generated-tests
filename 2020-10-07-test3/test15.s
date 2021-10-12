.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x00, 0x03, 0x3f, 0xd6, 0x41, 0x80, 0x5e, 0xd1, 0xa2, 0x7a, 0x9e, 0x82, 0xfe, 0x67, 0x74, 0xe2
	.byte 0xa0, 0x03, 0x3f, 0xd6
.data
check_data4:
	.byte 0xff, 0x63, 0x9f, 0x82, 0x41, 0xac, 0xc4, 0xe2, 0x40, 0x4d, 0xd7, 0xf0, 0xe4, 0x07, 0xc0, 0xda
	.byte 0xca, 0x11, 0x8a, 0x78, 0x60, 0x13, 0xc2, 0xc2
.data
check_data5:
	.byte 0x96, 0x1f
.data
.balign 16
initial_cap_values:
	/* C14 */
	.octa 0x80000000000100050000000000001f5b
	/* C21 */
	.octa 0xffffffffffc03ff2
	/* C24 */
	.octa 0x400004
	/* C29 */
	.octa 0x400018
final_cap_values:
	/* C0 */
	.octa 0x2000800000010007ffffffffaedab000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1f96
	/* C4 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C14 */
	.octa 0x80000000000100050000000000001f5b
	/* C21 */
	.octa 0xffffffffffc03ff2
	/* C24 */
	.octa 0x400004
	/* C29 */
	.octa 0x400018
	/* C30 */
	.octa 0x20008000800100070000000000400015
initial_SP_EL3_value:
	.octa 0x1ffc
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0100000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 0
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd63f0300 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:24 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.inst 0xd15e8041 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:1 Rn:2 imm12:011110100000 sh:1 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0x829e7aa2 // ALDRSH-R.RRB-64 Rt:2 Rn:21 opc:10 S:1 option:011 Rm:30 0:0 L:0 100000101:100000101
	.inst 0xe27467fe // ALDUR-V.RI-H Rt:30 Rn:31 op2:01 imm9:101000110 V:1 op1:01 11100010:11100010
	.inst 0xd63f03a0 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:29 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 4
	.inst 0x829f63ff // ASTRB-R.RRB-B Rt:31 Rn:31 opc:00 S:0 option:011 Rm:31 0:0 L:0 100000101:100000101
	.inst 0xe2c4ac41 // ALDUR-C.RI-C Ct:1 Rn:2 op2:11 imm9:001001010 V:0 op1:11 11100010:11100010
	.inst 0xf0d74d40 // ADRP-C.IP-C Rd:0 immhi:101011101001101010 P:1 10000:10000 immlo:11 op:1
	.inst 0xdac007e4 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:4 Rn:31 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0x788a11ca // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:10 Rn:14 00:00 imm9:010100001 0:0 opc:10 111000:111000 size:01
	.inst 0xc2c21360
	.zero 16332
	.inst 0x00001f96
	.zero 1032192
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x12, cptr_el3
	orr x12, x12, #0x200
	msr cptr_el3, x12
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
	ldr x12, =initial_cap_values
	.inst 0xc240018e // ldr c14, [x12, #0]
	.inst 0xc2400595 // ldr c21, [x12, #1]
	.inst 0xc2400998 // ldr c24, [x12, #2]
	.inst 0xc2400d9d // ldr c29, [x12, #3]
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =initial_SP_EL3_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2c1d19f // cpy c31, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30850032
	msr SCTLR_EL3, x12
	ldr x12, =0x80
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x8260336c // ldr c12, [c27, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x8260136c // ldr c12, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc240019b // ldr c27, [x12, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240059b // ldr c27, [x12, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc240099b // ldr c27, [x12, #2]
	.inst 0xc2dba441 // chkeq c2, c27
	b.ne comparison_fail
	.inst 0xc2400d9b // ldr c27, [x12, #3]
	.inst 0xc2dba481 // chkeq c4, c27
	b.ne comparison_fail
	.inst 0xc240119b // ldr c27, [x12, #4]
	.inst 0xc2dba541 // chkeq c10, c27
	b.ne comparison_fail
	.inst 0xc240159b // ldr c27, [x12, #5]
	.inst 0xc2dba5c1 // chkeq c14, c27
	b.ne comparison_fail
	.inst 0xc240199b // ldr c27, [x12, #6]
	.inst 0xc2dba6a1 // chkeq c21, c27
	b.ne comparison_fail
	.inst 0xc2401d9b // ldr c27, [x12, #7]
	.inst 0xc2dba701 // chkeq c24, c27
	b.ne comparison_fail
	.inst 0xc240219b // ldr c27, [x12, #8]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	.inst 0xc240259b // ldr c27, [x12, #9]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x12, =0x0
	mov x27, v30.d[0]
	cmp x12, x27
	b.ne comparison_fail
	ldr x12, =0x0
	mov x27, v30.d[1]
	cmp x12, x27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001f42
	ldr x1, =check_data0
	ldr x2, =0x00001f44
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001fe0
	ldr x1, =check_data1
	ldr x2, =0x00001ff0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffc
	ldr x1, =check_data2
	ldr x2, =0x00001ffe
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400018
	ldr x1, =check_data4
	ldr x2, =0x00400030
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00403ffc
	ldr x1, =check_data5
	ldr x2, =0x00403ffe
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
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
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

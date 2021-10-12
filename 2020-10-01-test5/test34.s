.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0xc2, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x7e, 0x7d, 0xdf, 0x08, 0xff, 0x33, 0xc3, 0xc2, 0x6a, 0xaf, 0xd0, 0x38, 0x02, 0x80, 0x0e, 0xb1
	.byte 0x0c, 0x68, 0x06, 0x29, 0x22, 0xd8, 0xda, 0xc2, 0x22, 0x50, 0xc2, 0xc2
.data
check_data4:
	.byte 0x40
.data
check_data5:
	.byte 0xd9, 0xcf, 0x5f, 0x82, 0x41, 0x53, 0xc0, 0xc2, 0xe6, 0x6b, 0x4e, 0xe2, 0x80, 0x12, 0xc2, 0xc2
.data
check_data6:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xfe0
	/* C1 */
	.octa 0x200080001ffa00070000000000420009
	/* C11 */
	.octa 0x4004ff
	/* C12 */
	.octa 0x0
	/* C25 */
	.octa 0xc2000000
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x480008
final_cap_values:
	/* C0 */
	.octa 0xfe0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x200080001ffa00070020000000000000
	/* C6 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x4004ff
	/* C12 */
	.octa 0x0
	/* C25 */
	.octa 0xc2000000
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x47ff12
	/* C30 */
	.octa 0x40
initial_csp_value:
	.octa 0x1bf0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000680000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000a21c0050000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x08df7d7e // ldlarb:aarch64/instrs/memory/ordered Rt:30 Rn:11 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xc2c333ff // SEAL-C.CI-C Cd:31 Cn:31 100:100 form:01 11000010110000110:11000010110000110
	.inst 0x38d0af6a // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:10 Rn:27 11:11 imm9:100001010 0:0 opc:11 111000:111000 size:00
	.inst 0xb10e8002 // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:2 Rn:0 imm12:001110100000 sh:0 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0x2906680c // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:12 Rn:0 Rt2:11010 imm7:0001100 L:0 1010010:1010010 opc:00
	.inst 0xc2dad822 // ALIGNU-C.CI-C Cd:2 Cn:1 0110:0110 U:1 imm6:110101 11000010110:11000010110
	.inst 0xc2c25022 // RETS-C-C 00010:00010 Cn:1 100:100 opc:10 11000010110000100:11000010110000100
	.zero 1248
	.inst 0x40000000
	.zero 129800
	.inst 0x825fcfd9 // ASTR-R.RI-64 Rt:25 Rn:30 op:11 imm9:111111100 L:0 1000001001:1000001001
	.inst 0xc2c05341 // GCVALUE-R.C-C Rd:1 Cn:26 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0xe24e6be6 // ALDURSH-R.RI-64 Rt:6 Rn:31 op2:10 imm9:011100110 V:0 op1:01 11100010:11100010
	.inst 0xc2c21280
	.zero 917480
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x14, cptr_el3
	orr x14, x14, #0x200
	msr cptr_el3, x14
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c1 // ldr c1, [x14, #1]
	.inst 0xc24009cb // ldr c11, [x14, #2]
	.inst 0xc2400dcc // ldr c12, [x14, #3]
	.inst 0xc24011d9 // ldr c25, [x14, #4]
	.inst 0xc24015da // ldr c26, [x14, #5]
	.inst 0xc24019db // ldr c27, [x14, #6]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =initial_csp_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2c1d1df // cpy c31, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x3085003a
	msr SCTLR_EL3, x14
	ldr x14, =0x4
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x8260328e // ldr c14, [c20, #3]
	.inst 0xc28b412e // msr ddc_el3, c14
	isb
	.inst 0x8260128e // ldr c14, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr ddc_el3, c14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x20, #0xf
	and x14, x14, x20
	cmp x14, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001d4 // ldr c20, [x14, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc24005d4 // ldr c20, [x14, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc24009d4 // ldr c20, [x14, #2]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400dd4 // ldr c20, [x14, #3]
	.inst 0xc2d4a4c1 // chkeq c6, c20
	b.ne comparison_fail
	.inst 0xc24011d4 // ldr c20, [x14, #4]
	.inst 0xc2d4a541 // chkeq c10, c20
	b.ne comparison_fail
	.inst 0xc24015d4 // ldr c20, [x14, #5]
	.inst 0xc2d4a561 // chkeq c11, c20
	b.ne comparison_fail
	.inst 0xc24019d4 // ldr c20, [x14, #6]
	.inst 0xc2d4a581 // chkeq c12, c20
	b.ne comparison_fail
	.inst 0xc2401dd4 // ldr c20, [x14, #7]
	.inst 0xc2d4a721 // chkeq c25, c20
	b.ne comparison_fail
	.inst 0xc24021d4 // ldr c20, [x14, #8]
	.inst 0xc2d4a741 // chkeq c26, c20
	b.ne comparison_fail
	.inst 0xc24025d4 // ldr c20, [x14, #9]
	.inst 0xc2d4a761 // chkeq c27, c20
	b.ne comparison_fail
	.inst 0xc24029d4 // ldr c20, [x14, #10]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001018
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001028
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001cd6
	ldr x1, =check_data2
	ldr x2, =0x00001cd8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040001c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004004ff
	ldr x1, =check_data4
	ldr x2, =0x00400500
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00420008
	ldr x1, =check_data5
	ldr x2, =0x00420018
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0047ff12
	ldr x1, =check_data6
	ldr x2, =0x0047ff13
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr ddc_el3, c14
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

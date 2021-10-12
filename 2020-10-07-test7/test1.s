.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x00, 0x8c, 0xb7, 0x9b, 0x36, 0x0c, 0x1a, 0xe2, 0x60, 0xd4, 0xac, 0xa9, 0x1e, 0x80, 0xc0, 0xc2
	.byte 0x5e, 0xc0, 0x03, 0x38, 0x62, 0xcf, 0xb0, 0xf0, 0x6e, 0xeb, 0xc5, 0xc2, 0x31, 0x50, 0xff, 0xc2
	.byte 0xc1, 0x58, 0xbb, 0x72, 0xbf, 0x25, 0x0d, 0x62, 0x20, 0x13, 0xc2, 0xc2
.data
check_data3:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4
	/* C1 */
	.octa 0x2000000000000000000000000808
	/* C2 */
	.octa 0x400000000401400500000000000011c4
	/* C3 */
	.octa 0x40000000400e074c0000000000002080
	/* C9 */
	.octa 0x4000000000000000000000000000
	/* C13 */
	.octa 0x48000000000100050000000000001060
	/* C21 */
	.octa 0x0
	/* C23 */
	.octa 0x820
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xdac60808
	/* C2 */
	.octa 0x20008000000500070000000061def000
	/* C3 */
	.octa 0x40000000400e074c0000000000001f48
	/* C9 */
	.octa 0x4000000000000000000000000000
	/* C13 */
	.octa 0x48000000000100050000000000001060
	/* C17 */
	.octa 0x200000000000fa00000000000808
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x820
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000500070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000007800f00000000004f8001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9bb78c00 // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:0 Rn:0 Ra:3 o0:1 Rm:23 01:01 U:1 10011011:10011011
	.inst 0xe21a0c36 // ALDURSB-R.RI-32 Rt:22 Rn:1 op2:11 imm9:110100000 V:0 op1:00 11100010:11100010
	.inst 0xa9acd460 // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:0 Rn:3 Rt2:10101 imm7:1011001 L:0 1010011:1010011 opc:10
	.inst 0xc2c0801e // SCTAG-C.CR-C Cd:30 Cn:0 000:000 0:0 10:10 Rm:0 11000010110:11000010110
	.inst 0x3803c05e // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:2 00:00 imm9:000111100 0:0 opc:00 111000:111000 size:00
	.inst 0xf0b0cf62 // ADRP-C.IP-C Rd:2 immhi:011000011001111011 P:1 10000:10000 immlo:11 op:1
	.inst 0xc2c5eb6e // CTHI-C.CR-C Cd:14 Cn:27 1010:1010 opc:11 Rm:5 11000010110:11000010110
	.inst 0xc2ff5031 // EORFLGS-C.CI-C Cd:17 Cn:1 0:0 10:10 imm8:11111010 11000010111:11000010111
	.inst 0x72bb58c1 // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:1 imm16:1101101011000110 hw:01 100101:100101 opc:11 sf:0
	.inst 0x620d25bf // STNP-C.RIB-C Ct:31 Rn:13 Ct2:01001 imm7:0011010 L:0 011000100:011000100
	.inst 0xc2c21320
	.zero 1048532
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c1 // ldr c1, [x6, #1]
	.inst 0xc24008c2 // ldr c2, [x6, #2]
	.inst 0xc2400cc3 // ldr c3, [x6, #3]
	.inst 0xc24010c9 // ldr c9, [x6, #4]
	.inst 0xc24014cd // ldr c13, [x6, #5]
	.inst 0xc24018d5 // ldr c21, [x6, #6]
	.inst 0xc2401cd7 // ldr c23, [x6, #7]
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30850032
	msr SCTLR_EL3, x6
	ldr x6, =0x4
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82603326 // ldr c6, [c25, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x82601326 // ldr c6, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000d9 // ldr c25, [x6, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc24004d9 // ldr c25, [x6, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc24008d9 // ldr c25, [x6, #2]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400cd9 // ldr c25, [x6, #3]
	.inst 0xc2d9a461 // chkeq c3, c25
	b.ne comparison_fail
	.inst 0xc24010d9 // ldr c25, [x6, #4]
	.inst 0xc2d9a521 // chkeq c9, c25
	b.ne comparison_fail
	.inst 0xc24014d9 // ldr c25, [x6, #5]
	.inst 0xc2d9a5a1 // chkeq c13, c25
	b.ne comparison_fail
	.inst 0xc24018d9 // ldr c25, [x6, #6]
	.inst 0xc2d9a621 // chkeq c17, c25
	b.ne comparison_fail
	.inst 0xc2401cd9 // ldr c25, [x6, #7]
	.inst 0xc2d9a6a1 // chkeq c21, c25
	b.ne comparison_fail
	.inst 0xc24020d9 // ldr c25, [x6, #8]
	.inst 0xc2d9a6c1 // chkeq c22, c25
	b.ne comparison_fail
	.inst 0xc24024d9 // ldr c25, [x6, #9]
	.inst 0xc2d9a6e1 // chkeq c23, c25
	b.ne comparison_fail
	.inst 0xc24028d9 // ldr c25, [x6, #10]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001200
	ldr x1, =check_data0
	ldr x2, =0x00001220
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001f48
	ldr x1, =check_data1
	ldr x2, =0x00001f58
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
	ldr x0, =0x004f87b0
	ldr x1, =check_data3
	ldr x2, =0x004f87b1
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
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
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

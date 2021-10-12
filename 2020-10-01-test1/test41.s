.section data0, #alloc, #write
	.zero 4080
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x00
.data
check_data0:
	.byte 0xc2
.data
check_data1:
	.byte 0x36, 0xf0, 0xc0, 0xc2, 0xb0, 0x92, 0xc5, 0xc2, 0x7e, 0x53, 0xc3, 0xc2, 0xdf, 0x61, 0x91, 0xda
	.byte 0x83, 0x72, 0x84, 0x02, 0x40, 0x78, 0xd0, 0x78, 0x1e, 0xa7, 0x21, 0xab, 0xa2, 0x84, 0x10, 0xe2
	.byte 0x72, 0xd1, 0xc5, 0xc2, 0xcc, 0x7e, 0xc1, 0x9b, 0x20, 0x11, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x800000000007800f0000000000408175
	/* C5 */
	.octa 0x20f6
	/* C11 */
	.octa 0x100000000000000
	/* C20 */
	.octa 0x620070c80000000000100
	/* C21 */
	.octa 0x80000000000001
	/* C27 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xffffc2c2
	/* C2 */
	.octa 0xc2
	/* C3 */
	.octa 0x620070c7fffffffffffe4
	/* C5 */
	.octa 0x20f6
	/* C11 */
	.octa 0x100000000000000
	/* C16 */
	.octa 0x80000000000100070080000000000001
	/* C18 */
	.octa 0x80000000000100070100000000000000
	/* C20 */
	.octa 0x620070c80000000000100
	/* C21 */
	.octa 0x80000000000001
	/* C27 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000601ff0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c0f036 // GCTYPE-R.C-C Rd:22 Cn:1 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xc2c592b0 // CVTD-C.R-C Cd:16 Rn:21 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0xc2c3537e // SEAL-C.CI-C Cd:30 Cn:27 100:100 form:10 11000010110000110:11000010110000110
	.inst 0xda9161df // csinv:aarch64/instrs/integer/conditional/select Rd:31 Rn:14 o2:0 0:0 cond:0110 Rm:17 011010100:011010100 op:1 sf:1
	.inst 0x02847283 // SUB-C.CIS-C Cd:3 Cn:20 imm12:000100011100 sh:0 A:1 00000010:00000010
	.inst 0x78d07840 // ldtrsh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:2 10:10 imm9:100000111 0:0 opc:11 111000:111000 size:01
	.inst 0xab21a71e // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:30 Rn:24 imm3:001 option:101 Rm:1 01011001:01011001 S:1 op:0 sf:1
	.inst 0xe21084a2 // ALDURB-R.RI-32 Rt:2 Rn:5 op2:01 imm9:100001000 V:0 op1:00 11100010:11100010
	.inst 0xc2c5d172 // CVTDZ-C.R-C Cd:18 Rn:11 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0x9bc17ecc // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:12 Rn:22 Ra:11111 0:0 Rm:1 10:10 U:1 10011011:10011011
	.inst 0xc2c21120
	.zero 32848
	.inst 0x0000c2c2
	.zero 1015680
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
	.inst 0xc24000c2 // ldr c2, [x6, #0]
	.inst 0xc24004c5 // ldr c5, [x6, #1]
	.inst 0xc24008cb // ldr c11, [x6, #2]
	.inst 0xc2400cd4 // ldr c20, [x6, #3]
	.inst 0xc24010d5 // ldr c21, [x6, #4]
	.inst 0xc24014db // ldr c27, [x6, #5]
	/* Set up flags and system registers */
	mov x6, #0x10000000
	msr nzcv, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30850032
	msr SCTLR_EL3, x6
	ldr x6, =0x0
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603126 // ldr c6, [c9, #3]
	.inst 0xc28b4126 // msr ddc_el3, c6
	isb
	.inst 0x82601126 // ldr c6, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr ddc_el3, c6
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000c9 // ldr c9, [x6, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc24004c9 // ldr c9, [x6, #1]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc24008c9 // ldr c9, [x6, #2]
	.inst 0xc2c9a461 // chkeq c3, c9
	b.ne comparison_fail
	.inst 0xc2400cc9 // ldr c9, [x6, #3]
	.inst 0xc2c9a4a1 // chkeq c5, c9
	b.ne comparison_fail
	.inst 0xc24010c9 // ldr c9, [x6, #4]
	.inst 0xc2c9a561 // chkeq c11, c9
	b.ne comparison_fail
	.inst 0xc24014c9 // ldr c9, [x6, #5]
	.inst 0xc2c9a601 // chkeq c16, c9
	b.ne comparison_fail
	.inst 0xc24018c9 // ldr c9, [x6, #6]
	.inst 0xc2c9a641 // chkeq c18, c9
	b.ne comparison_fail
	.inst 0xc2401cc9 // ldr c9, [x6, #7]
	.inst 0xc2c9a681 // chkeq c20, c9
	b.ne comparison_fail
	.inst 0xc24020c9 // ldr c9, [x6, #8]
	.inst 0xc2c9a6a1 // chkeq c21, c9
	b.ne comparison_fail
	.inst 0xc24024c9 // ldr c9, [x6, #9]
	.inst 0xc2c9a761 // chkeq c27, c9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001ffe
	ldr x1, =check_data0
	ldr x2, =0x00001fff
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
	ldr x0, =0x0040807c
	ldr x1, =check_data2
	ldr x2, =0x0040807e
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

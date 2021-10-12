.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x19, 0x0c, 0xc2, 0x9a, 0x9a, 0x3a, 0x0c, 0x6b, 0xe1, 0x03, 0x17, 0xfa, 0x3f, 0xf4, 0xf4, 0xc2
	.byte 0xbe, 0xd2, 0xc1, 0xc2, 0x00, 0xb0, 0xc5, 0xc2, 0x33, 0x68, 0xfd, 0xc2, 0x01, 0xd0, 0x90, 0xf8
	.byte 0xc0, 0x83, 0x21, 0x6c, 0x5f, 0x27, 0xd6, 0xd2, 0xe0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xffe00000000001
	/* C2 */
	.octa 0x0
	/* C12 */
	.octa 0x20000
	/* C20 */
	.octa 0x100000000001e
	/* C21 */
	.octa 0x400000000001800600000000000021c0
	/* C23 */
	.octa 0xfffffffffe303
final_cap_values:
	/* C0 */
	.octa 0x200080000003000700ffe00000000001
	/* C1 */
	.octa 0xfff0000000001cfc
	/* C2 */
	.octa 0x0
	/* C12 */
	.octa 0x20000
	/* C19 */
	.octa 0xfff0000000001cfc
	/* C20 */
	.octa 0x100000000001e
	/* C21 */
	.octa 0x400000000001800600000000000021c0
	/* C23 */
	.octa 0xfffffffffe303
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x8000001e
	/* C30 */
	.octa 0x400000000001800600000000000021c0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000005f0900040000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9ac20c19 // sdiv:aarch64/instrs/integer/arithmetic/div Rd:25 Rn:0 o1:1 00001:00001 Rm:2 0011010110:0011010110 sf:1
	.inst 0x6b0c3a9a // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:26 Rn:20 imm6:001110 Rm:12 0:0 shift:00 01011:01011 S:1 op:1 sf:0
	.inst 0xfa1703e1 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:31 000000:000000 Rm:23 11010000:11010000 S:1 op:1 sf:1
	.inst 0xc2f4f43f // ASTR-C.RRB-C Ct:31 Rn:1 1:1 L:0 S:1 option:111 Rm:20 11000010111:11000010111
	.inst 0xc2c1d2be // CPY-C.C-C Cd:30 Cn:21 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0xc2c5b000 // CVTP-C.R-C Cd:0 Rn:0 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xc2fd6833 // ORRFLGS-C.CI-C Cd:19 Cn:1 0:0 01:01 imm8:11101011 11000010111:11000010111
	.inst 0xf890d001 // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:0 00:00 imm9:100001101 0:0 opc:10 111000:111000 size:11
	.inst 0x6c2183c0 // stnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:0 Rn:30 Rt2:00000 imm7:1000011 L:0 1011000:1011000 opc:01
	.inst 0xd2d6275f // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:31 imm16:1011000100111010 hw:10 100101:100101 opc:10 sf:1
	.inst 0xc2c211e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x29, cptr_el3
	orr x29, x29, #0x200
	msr cptr_el3, x29
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
	ldr x29, =initial_cap_values
	.inst 0xc24003a0 // ldr c0, [x29, #0]
	.inst 0xc24007a2 // ldr c2, [x29, #1]
	.inst 0xc2400bac // ldr c12, [x29, #2]
	.inst 0xc2400fb4 // ldr c20, [x29, #3]
	.inst 0xc24013b5 // ldr c21, [x29, #4]
	.inst 0xc24017b7 // ldr c23, [x29, #5]
	/* Vector registers */
	mrs x29, cptr_el3
	bfc x29, #10, #1
	msr cptr_el3, x29
	isb
	ldr q0, =0x0
	/* Set up flags and system registers */
	mov x29, #0x00000000
	msr nzcv, x29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x30850032
	msr SCTLR_EL3, x29
	ldr x29, =0x4
	msr S3_6_C1_C2_2, x29 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031fd // ldr c29, [c15, #3]
	.inst 0xc28b413d // msr ddc_el3, c29
	isb
	.inst 0x826011fd // ldr c29, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c213a0 // br c29
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr ddc_el3, c29
	isb
	/* Check processor flags */
	mrs x29, nzcv
	ubfx x29, x29, #28, #4
	mov x15, #0xf
	and x29, x29, x15
	cmp x29, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003af // ldr c15, [x29, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc24007af // ldr c15, [x29, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc2400baf // ldr c15, [x29, #2]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc2400faf // ldr c15, [x29, #3]
	.inst 0xc2cfa581 // chkeq c12, c15
	b.ne comparison_fail
	.inst 0xc24013af // ldr c15, [x29, #4]
	.inst 0xc2cfa661 // chkeq c19, c15
	b.ne comparison_fail
	.inst 0xc24017af // ldr c15, [x29, #5]
	.inst 0xc2cfa681 // chkeq c20, c15
	b.ne comparison_fail
	.inst 0xc2401baf // ldr c15, [x29, #6]
	.inst 0xc2cfa6a1 // chkeq c21, c15
	b.ne comparison_fail
	.inst 0xc2401faf // ldr c15, [x29, #7]
	.inst 0xc2cfa6e1 // chkeq c23, c15
	b.ne comparison_fail
	.inst 0xc24023af // ldr c15, [x29, #8]
	.inst 0xc2cfa721 // chkeq c25, c15
	b.ne comparison_fail
	.inst 0xc24027af // ldr c15, [x29, #9]
	.inst 0xc2cfa741 // chkeq c26, c15
	b.ne comparison_fail
	.inst 0xc2402baf // ldr c15, [x29, #10]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check vector registers */
	ldr x29, =0x0
	mov x15, v0.d[0]
	cmp x29, x15
	b.ne comparison_fail
	ldr x29, =0x0
	mov x15, v0.d[1]
	cmp x29, x15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001ee0
	ldr x1, =check_data0
	ldr x2, =0x00001ef0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001fd8
	ldr x1, =check_data1
	ldr x2, =0x00001fe8
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr ddc_el3, c29
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

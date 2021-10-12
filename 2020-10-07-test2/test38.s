.section data0, #alloc, #write
	.zero 128
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 352
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 3568
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0x40, 0x30, 0xc2, 0xc2
.data
check_data3:
	.byte 0x5f, 0x81, 0xc1, 0xc2, 0xff, 0x0f, 0xac, 0xb9, 0x02, 0x30, 0xc0, 0xc2, 0x1d, 0x6b, 0xe6, 0x70
	.byte 0xc1, 0x2b, 0xc0, 0x9a, 0x52, 0x58, 0xcd, 0xc2, 0x80, 0xaf, 0xdc, 0x62, 0x5b, 0x44, 0xdf, 0xc2
	.byte 0x61, 0x2e, 0x56, 0x50, 0xc0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8000270000000000000001
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x20008000900740070000000000404004
	/* C10 */
	.octa 0xffffffffffffd580
	/* C28 */
	.octa 0xfffffffffffffc70
final_cap_values:
	/* C0 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C1 */
	.octa 0x4b05f2
	/* C2 */
	.octa 0xffffffffffffffff
	/* C10 */
	.octa 0xffffffffffffd580
	/* C11 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C18 */
	.octa 0x0
	/* C27 */
	.octa 0xffffffffffffffff
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x3d0d73
	/* C30 */
	.octa 0x20008000800100070000000000400005
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x801000004001108000ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001080
	.dword initial_cap_values + 32
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c23040 // BLR-C-C 00000:00000 Cn:2 100:100 opc:01 11000010110000100:11000010110000100
	.zero 16384
	.inst 0xc2c1815f // SCTAG-C.CR-C Cd:31 Cn:10 000:000 0:0 10:10 Rm:1 11000010110:11000010110
	.inst 0xb9ac0fff // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:31 imm12:101100000011 opc:10 111001:111001 size:10
	.inst 0xc2c03002 // GCLEN-R.C-C Rd:2 Cn:0 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0x70e66b1d // ADR-C.I-C Rd:29 immhi:110011001101011000 P:1 10000:10000 immlo:11 op:0
	.inst 0x9ac02bc1 // asrv:aarch64/instrs/integer/shift/variable Rd:1 Rn:30 op2:10 0010:0010 Rm:0 0011010110:0011010110 sf:1
	.inst 0xc2cd5852 // ALIGNU-C.CI-C Cd:18 Cn:2 0110:0110 U:1 imm6:011010 11000010110:11000010110
	.inst 0x62dcaf80 // LDP-C.RIBW-C Ct:0 Rn:28 Ct2:01011 imm7:0111001 L:1 011000101:011000101
	.inst 0xc2df445b // CSEAL-C.C-C Cd:27 Cn:2 001:001 opc:10 0:0 Cm:31 11000010110:11000010110
	.inst 0x50562e61 // ADR-C.I-C Rd:1 immhi:101011000101110011 P:0 10000:10000 immlo:10 op:0
	.inst 0xc2c211c0
	.zero 1032148
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
	ldr x20, =initial_cap_values
	.inst 0xc2400280 // ldr c0, [x20, #0]
	.inst 0xc2400681 // ldr c1, [x20, #1]
	.inst 0xc2400a82 // ldr c2, [x20, #2]
	.inst 0xc2400e8a // ldr c10, [x20, #3]
	.inst 0xc240129c // ldr c28, [x20, #4]
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30850038
	msr SCTLR_EL3, x20
	ldr x20, =0x84
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031d4 // ldr c20, [c14, #3]
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	.inst 0x826011d4 // ldr c20, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	/* Check processor flags */
	mrs x20, nzcv
	ubfx x20, x20, #28, #4
	mov x14, #0xf
	and x20, x20, x14
	cmp x20, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc240028e // ldr c14, [x20, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc240068e // ldr c14, [x20, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc2400a8e // ldr c14, [x20, #2]
	.inst 0xc2cea441 // chkeq c2, c14
	b.ne comparison_fail
	.inst 0xc2400e8e // ldr c14, [x20, #3]
	.inst 0xc2cea541 // chkeq c10, c14
	b.ne comparison_fail
	.inst 0xc240128e // ldr c14, [x20, #4]
	.inst 0xc2cea561 // chkeq c11, c14
	b.ne comparison_fail
	.inst 0xc240168e // ldr c14, [x20, #5]
	.inst 0xc2cea641 // chkeq c18, c14
	b.ne comparison_fail
	.inst 0xc2401a8e // ldr c14, [x20, #6]
	.inst 0xc2cea761 // chkeq c27, c14
	b.ne comparison_fail
	.inst 0xc2401e8e // ldr c14, [x20, #7]
	.inst 0xc2cea781 // chkeq c28, c14
	b.ne comparison_fail
	.inst 0xc240228e // ldr c14, [x20, #8]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	.inst 0xc240268e // ldr c14, [x20, #9]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001080
	ldr x1, =check_data0
	ldr x2, =0x000010a0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000120c
	ldr x1, =check_data1
	ldr x2, =0x00001210
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400004
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00404004
	ldr x1, =check_data3
	ldr x2, =0x0040402c
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
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
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

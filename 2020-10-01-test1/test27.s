.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xfc, 0x13, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x18, 0x7e, 0x1f, 0x42, 0x1f, 0x53, 0xdf, 0x68, 0x81, 0x9a, 0xff, 0xc2, 0x21, 0x33, 0xc6, 0xc2
	.byte 0x31, 0xf8, 0x98, 0xb8, 0x1c, 0x28, 0x04, 0x38, 0xe2, 0x19, 0xe2, 0xc2, 0x21, 0x84, 0xc1, 0xc2
	.byte 0xea, 0xc0, 0x03, 0x2d, 0x5f, 0x3e, 0x03, 0xd5, 0x60, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1100
	/* C2 */
	.octa 0x4000000001c000
	/* C7 */
	.octa 0x1000
	/* C15 */
	.octa 0x801007000e004000000001c000
	/* C16 */
	.octa 0x4c000000504004000000000000001000
	/* C24 */
	.octa 0x13fc
	/* C25 */
	.octa 0x80000000070000000000002001
	/* C28 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x1100
	/* C1 */
	.octa 0x80000000070000000000002001
	/* C2 */
	.octa 0x801007000e004000000001c000
	/* C7 */
	.octa 0x1000
	/* C15 */
	.octa 0x801007000e004000000001c000
	/* C16 */
	.octa 0x4c000000504004000000000000001000
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C24 */
	.octa 0x14f4
	/* C25 */
	.octa 0x80000000070000000000002001
	/* C28 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000081000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000007000700ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x421f7e18 // ASTLR-C.R-C Ct:24 Rn:16 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0x68df531f // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:31 Rn:24 Rt2:10100 imm7:0111110 L:1 1010001:1010001 opc:01
	.inst 0xc2ff9a81 // SUBS-R.CC-C Rd:1 Cn:20 100110:100110 Cm:31 11000010111:11000010111
	.inst 0xc2c63321 // CLRPERM-C.CI-C Cd:1 Cn:25 100:100 perm:001 1100001011000110:1100001011000110
	.inst 0xb898f831 // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:17 Rn:1 10:10 imm9:110001111 0:0 opc:10 111000:111000 size:10
	.inst 0x3804281c // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:28 Rn:0 10:10 imm9:001000010 0:0 opc:00 111000:111000 size:00
	.inst 0xc2e219e2 // CVT-C.CR-C Cd:2 Cn:15 0110:0110 0:0 0:0 Rm:2 11000010111:11000010111
	.inst 0xc2c18421 // CHKSS-_.CC-C 00001:00001 Cn:1 001:001 opc:00 1:1 Cm:1 11000010110:11000010110
	.inst 0x2d03c0ea // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:10 Rn:7 Rt2:10000 imm7:0000111 L:0 1011010:1011010 opc:00
	.inst 0xd5033e5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1110 11010101000000110011:11010101000000110011
	.inst 0xc2c21060
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
	.inst 0xc2400ba7 // ldr c7, [x29, #2]
	.inst 0xc2400faf // ldr c15, [x29, #3]
	.inst 0xc24013b0 // ldr c16, [x29, #4]
	.inst 0xc24017b8 // ldr c24, [x29, #5]
	.inst 0xc2401bb9 // ldr c25, [x29, #6]
	.inst 0xc2401fbc // ldr c28, [x29, #7]
	/* Vector registers */
	mrs x29, cptr_el3
	bfc x29, #10, #1
	msr cptr_el3, x29
	isb
	ldr q10, =0x0
	ldr q16, =0x0
	/* Set up flags and system registers */
	mov x29, #0x00000000
	msr nzcv, x29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x30850030
	msr SCTLR_EL3, x29
	ldr x29, =0x0
	msr S3_6_C1_C2_2, x29 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x8260307d // ldr c29, [c3, #3]
	.inst 0xc28b413d // msr ddc_el3, c29
	isb
	.inst 0x8260107d // ldr c29, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
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
	mov x3, #0xf
	and x29, x29, x3
	cmp x29, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003a3 // ldr c3, [x29, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc24007a3 // ldr c3, [x29, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400ba3 // ldr c3, [x29, #2]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400fa3 // ldr c3, [x29, #3]
	.inst 0xc2c3a4e1 // chkeq c7, c3
	b.ne comparison_fail
	.inst 0xc24013a3 // ldr c3, [x29, #4]
	.inst 0xc2c3a5e1 // chkeq c15, c3
	b.ne comparison_fail
	.inst 0xc24017a3 // ldr c3, [x29, #5]
	.inst 0xc2c3a601 // chkeq c16, c3
	b.ne comparison_fail
	.inst 0xc2401ba3 // ldr c3, [x29, #6]
	.inst 0xc2c3a621 // chkeq c17, c3
	b.ne comparison_fail
	.inst 0xc2401fa3 // ldr c3, [x29, #7]
	.inst 0xc2c3a681 // chkeq c20, c3
	b.ne comparison_fail
	.inst 0xc24023a3 // ldr c3, [x29, #8]
	.inst 0xc2c3a701 // chkeq c24, c3
	b.ne comparison_fail
	.inst 0xc24027a3 // ldr c3, [x29, #9]
	.inst 0xc2c3a721 // chkeq c25, c3
	b.ne comparison_fail
	.inst 0xc2402ba3 // ldr c3, [x29, #10]
	.inst 0xc2c3a781 // chkeq c28, c3
	b.ne comparison_fail
	/* Check vector registers */
	ldr x29, =0x0
	mov x3, v10.d[0]
	cmp x29, x3
	b.ne comparison_fail
	ldr x29, =0x0
	mov x3, v10.d[1]
	cmp x29, x3
	b.ne comparison_fail
	ldr x29, =0x0
	mov x3, v16.d[0]
	cmp x29, x3
	b.ne comparison_fail
	ldr x29, =0x0
	mov x3, v16.d[1]
	cmp x29, x3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000101c
	ldr x1, =check_data1
	ldr x2, =0x00001024
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001142
	ldr x1, =check_data2
	ldr x2, =0x00001143
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000013fc
	ldr x1, =check_data3
	ldr x2, =0x00001404
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f90
	ldr x1, =check_data4
	ldr x2, =0x00001f94
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
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

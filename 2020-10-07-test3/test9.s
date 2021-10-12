.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x01, 0x00, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x02, 0x40, 0x00, 0x00, 0x00, 0x80
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xc2, 0x77, 0x15, 0x78, 0x01, 0x41, 0x8a, 0x78, 0xc2, 0x03, 0x01, 0x7a, 0x12, 0x24, 0x8a, 0xe2
	.byte 0xdf, 0x0b, 0xc2, 0xc2, 0x0f, 0x94, 0x0a, 0xe2, 0xff, 0x30, 0x98, 0xb8, 0xde, 0x05, 0x36, 0x3d
	.byte 0x07, 0xd3, 0x4e, 0x82, 0xf7, 0x2b, 0xc6, 0x1a, 0x80, 0x12, 0xc2, 0xc2
.data
check_data6:
	.zero 2
.data
check_data7:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C2 */
	.octa 0x0
	/* C7 */
	.octa 0x800000004002c2000000000000480001
	/* C8 */
	.octa 0x80000000020300070000000000404000
	/* C14 */
	.octa 0x40000000600100040000000000001020
	/* C24 */
	.octa 0x13e
	/* C30 */
	.octa 0x40000000000100060000000000001000
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0x800000004002c2000000000000480001
	/* C8 */
	.octa 0x80000000020300070000000000404000
	/* C14 */
	.octa 0x40000000600100040000000000001020
	/* C15 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C24 */
	.octa 0x13e
	/* C30 */
	.octa 0x40000000000100060000000000000f57
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000100000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc000000580400020000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x781577c2 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:2 Rn:30 01:01 imm9:101010111 0:0 opc:00 111000:111000 size:01
	.inst 0x788a4101 // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:8 00:00 imm9:010100100 0:0 opc:10 111000:111000 size:01
	.inst 0x7a0103c2 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:2 Rn:30 000000:000000 Rm:1 11010000:11010000 S:1 op:1 sf:0
	.inst 0xe28a2412 // ALDUR-R.RI-32 Rt:18 Rn:0 op2:01 imm9:010100010 V:0 op1:10 11100010:11100010
	.inst 0xc2c20bdf // SEAL-C.CC-C Cd:31 Cn:30 0010:0010 opc:00 Cm:2 11000010110:11000010110
	.inst 0xe20a940f // ALDURB-R.RI-32 Rt:15 Rn:0 op2:01 imm9:010101001 V:0 op1:00 11100010:11100010
	.inst 0xb89830ff // ldursw:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:7 00:00 imm9:110000011 0:0 opc:10 111000:111000 size:10
	.inst 0x3d3605de // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:30 Rn:14 imm12:110110000001 opc:00 111101:111101 size:00
	.inst 0x824ed307 // ASTR-C.RI-C Ct:7 Rn:24 op:00 imm9:011101101 L:0 1000001001:1000001001
	.inst 0x1ac62bf7 // asrv:aarch64/instrs/integer/shift/variable Rd:23 Rn:31 op2:10 0010:0010 Rm:6 0011010110:0011010110 sf:0
	.inst 0xc2c21280
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x3, cptr_el3
	orr x3, x3, #0x200
	msr cptr_el3, x3
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
	ldr x3, =initial_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400462 // ldr c2, [x3, #1]
	.inst 0xc2400867 // ldr c7, [x3, #2]
	.inst 0xc2400c68 // ldr c8, [x3, #3]
	.inst 0xc240106e // ldr c14, [x3, #4]
	.inst 0xc2401478 // ldr c24, [x3, #5]
	.inst 0xc240187e // ldr c30, [x3, #6]
	/* Vector registers */
	mrs x3, cptr_el3
	bfc x3, #10, #1
	msr cptr_el3, x3
	isb
	ldr q30, =0x0
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30850032
	msr SCTLR_EL3, x3
	ldr x3, =0x4
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82603283 // ldr c3, [c20, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x82601283 // ldr c3, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x20, #0xf
	and x3, x3, x20
	cmp x3, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400074 // ldr c20, [x3, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400474 // ldr c20, [x3, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400874 // ldr c20, [x3, #2]
	.inst 0xc2d4a4e1 // chkeq c7, c20
	b.ne comparison_fail
	.inst 0xc2400c74 // ldr c20, [x3, #3]
	.inst 0xc2d4a501 // chkeq c8, c20
	b.ne comparison_fail
	.inst 0xc2401074 // ldr c20, [x3, #4]
	.inst 0xc2d4a5c1 // chkeq c14, c20
	b.ne comparison_fail
	.inst 0xc2401474 // ldr c20, [x3, #5]
	.inst 0xc2d4a5e1 // chkeq c15, c20
	b.ne comparison_fail
	.inst 0xc2401874 // ldr c20, [x3, #6]
	.inst 0xc2d4a641 // chkeq c18, c20
	b.ne comparison_fail
	.inst 0xc2401c74 // ldr c20, [x3, #7]
	.inst 0xc2d4a701 // chkeq c24, c20
	b.ne comparison_fail
	.inst 0xc2402074 // ldr c20, [x3, #8]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0x0
	mov x20, v30.d[0]
	cmp x3, x20
	b.ne comparison_fail
	ldr x3, =0x0
	mov x20, v30.d[1]
	cmp x3, x20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001020
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010a4
	ldr x1, =check_data2
	ldr x2, =0x000010a8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000010ab
	ldr x1, =check_data3
	ldr x2, =0x000010ac
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001da1
	ldr x1, =check_data4
	ldr x2, =0x00001da2
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
	ldr x0, =0x004040a4
	ldr x1, =check_data6
	ldr x2, =0x004040a6
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x0047ff84
	ldr x1, =check_data7
	ldr x2, =0x0047ff88
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
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

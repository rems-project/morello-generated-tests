.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0xe2, 0x53, 0x87, 0x5a, 0xff, 0xd9, 0x2c, 0x78, 0xe2, 0x7f, 0x3f, 0x42, 0xc4, 0x11, 0xc5, 0xc2
	.byte 0xdf, 0xb3, 0xc5, 0xc2, 0x8f, 0xaf, 0x48, 0xfc, 0x40, 0xa4, 0x9e, 0x1a, 0x40, 0x88, 0x50, 0x02
	.byte 0x41, 0x96, 0x98, 0x78, 0xab, 0x7e, 0x57, 0xa2, 0x80, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 16
.data
check_data5:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C7 */
	.octa 0xff
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x1
	/* C15 */
	.octa 0x1fd4
	/* C18 */
	.octa 0x4ffffc
	/* C21 */
	.octa 0x402000
	/* C28 */
	.octa 0x1f66
	/* C30 */
	.octa 0x40400000
final_cap_values:
	/* C0 */
	.octa 0x100421f00
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xffffff00
	/* C4 */
	.octa 0x1
	/* C7 */
	.octa 0xff
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x1
	/* C15 */
	.octa 0x1fd4
	/* C18 */
	.octa 0x4fff85
	/* C21 */
	.octa 0x401770
	/* C28 */
	.octa 0x1ff0
	/* C30 */
	.octa 0x40400000
initial_SP_EL3_value:
	.octa 0x40000000000100050000000000001810
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 112
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x5a8753e2 // csinv:aarch64/instrs/integer/conditional/select Rd:2 Rn:31 o2:0 0:0 cond:0101 Rm:7 011010100:011010100 op:1 sf:0
	.inst 0x782cd9ff // strh_reg:aarch64/instrs/memory/single/general/register Rt:31 Rn:15 10:10 S:1 option:110 Rm:12 1:1 opc:00 111000:111000 size:01
	.inst 0x423f7fe2 // ASTLRB-R.R-B Rt:2 Rn:31 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xc2c511c4 // CVTD-R.C-C Rd:4 Cn:14 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0xc2c5b3df // CVTP-C.R-C Cd:31 Rn:30 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xfc48af8f // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:15 Rn:28 11:11 imm9:010001010 0:0 opc:01 111100:111100 size:11
	.inst 0x1a9ea440 // csinc:aarch64/instrs/integer/conditional/select Rd:0 Rn:2 o2:1 0:0 cond:1010 Rm:30 011010100:011010100 op:0 sf:0
	.inst 0x02508840 // ADD-C.CIS-C Cd:0 Cn:2 imm12:010000100010 sh:1 A:0 00000010:00000010
	.inst 0x78989641 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:18 01:01 imm9:110001001 0:0 opc:10 111000:111000 size:01
	.inst 0xa2577eab // LDR-C.RIBW-C Ct:11 Rn:21 11:11 imm9:101110111 0:0 opc:01 10100010:10100010
	.inst 0xc2c21280
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x26, cptr_el3
	orr x26, x26, #0x200
	msr cptr_el3, x26
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
	ldr x26, =initial_cap_values
	.inst 0xc2400347 // ldr c7, [x26, #0]
	.inst 0xc240074c // ldr c12, [x26, #1]
	.inst 0xc2400b4e // ldr c14, [x26, #2]
	.inst 0xc2400f4f // ldr c15, [x26, #3]
	.inst 0xc2401352 // ldr c18, [x26, #4]
	.inst 0xc2401755 // ldr c21, [x26, #5]
	.inst 0xc2401b5c // ldr c28, [x26, #6]
	.inst 0xc2401f5e // ldr c30, [x26, #7]
	/* Set up flags and system registers */
	mov x26, #0x80000000
	msr nzcv, x26
	ldr x26, =initial_SP_EL3_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2c1d35f // cpy c31, c26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x3085003a
	msr SCTLR_EL3, x26
	ldr x26, =0x8
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x8260329a // ldr c26, [c20, #3]
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	.inst 0x8260129a // ldr c26, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x20, #0xf
	and x26, x26, x20
	cmp x26, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400354 // ldr c20, [x26, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400754 // ldr c20, [x26, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400b54 // ldr c20, [x26, #2]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400f54 // ldr c20, [x26, #3]
	.inst 0xc2d4a481 // chkeq c4, c20
	b.ne comparison_fail
	.inst 0xc2401354 // ldr c20, [x26, #4]
	.inst 0xc2d4a4e1 // chkeq c7, c20
	b.ne comparison_fail
	.inst 0xc2401754 // ldr c20, [x26, #5]
	.inst 0xc2d4a561 // chkeq c11, c20
	b.ne comparison_fail
	.inst 0xc2401b54 // ldr c20, [x26, #6]
	.inst 0xc2d4a581 // chkeq c12, c20
	b.ne comparison_fail
	.inst 0xc2401f54 // ldr c20, [x26, #7]
	.inst 0xc2d4a5c1 // chkeq c14, c20
	b.ne comparison_fail
	.inst 0xc2402354 // ldr c20, [x26, #8]
	.inst 0xc2d4a5e1 // chkeq c15, c20
	b.ne comparison_fail
	.inst 0xc2402754 // ldr c20, [x26, #9]
	.inst 0xc2d4a641 // chkeq c18, c20
	b.ne comparison_fail
	.inst 0xc2402b54 // ldr c20, [x26, #10]
	.inst 0xc2d4a6a1 // chkeq c21, c20
	b.ne comparison_fail
	.inst 0xc2402f54 // ldr c20, [x26, #11]
	.inst 0xc2d4a781 // chkeq c28, c20
	b.ne comparison_fail
	.inst 0xc2403354 // ldr c20, [x26, #12]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check vector registers */
	ldr x26, =0x0
	mov x20, v15.d[0]
	cmp x26, x20
	b.ne comparison_fail
	ldr x26, =0x0
	mov x20, v15.d[1]
	cmp x26, x20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001810
	ldr x1, =check_data0
	ldr x2, =0x00001811
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001fd4
	ldr x1, =check_data1
	ldr x2, =0x00001fd6
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff0
	ldr x1, =check_data2
	ldr x2, =0x00001ff8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00401770
	ldr x1, =check_data4
	ldr x2, =0x00401780
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffffc
	ldr x1, =check_data5
	ldr x2, =0x004ffffe
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
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
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

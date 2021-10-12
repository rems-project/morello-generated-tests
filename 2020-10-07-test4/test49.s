.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x02, 0x15, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x9c, 0xf7, 0x9e, 0xe2, 0x5b, 0x24, 0x82, 0x78, 0x30, 0x1c, 0x0f, 0x78, 0x5f, 0x79, 0x3b, 0x91
	.byte 0x7e, 0x01, 0x4d, 0x78, 0x1e, 0x70, 0x95, 0xf8, 0x22, 0xe6, 0x84, 0x22, 0xb8, 0x43, 0xc3, 0xc2
	.byte 0xfe, 0x57, 0x9d, 0x6d, 0x60, 0x90, 0x82, 0x9a, 0x40, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 2
.data
check_data6:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1d8f
	/* C2 */
	.octa 0x14e0
	/* C3 */
	.octa 0xc001
	/* C10 */
	.octa 0x2
	/* C11 */
	.octa 0x40002c
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x1000
	/* C25 */
	.octa 0x4000000000000000000000000000
	/* C28 */
	.octa 0x800000007ff6dffa0000000000480001
	/* C29 */
	.octa 0x400120010081000000010001
final_cap_values:
	/* C0 */
	.octa 0xc001
	/* C1 */
	.octa 0x1e80
	/* C2 */
	.octa 0x1502
	/* C3 */
	.octa 0xc001
	/* C10 */
	.octa 0x2
	/* C11 */
	.octa 0x40002c
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x1090
	/* C24 */
	.octa 0x40012001000000000000c001
	/* C25 */
	.octa 0x4000000000000000000000000000
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x400120010081000000010001
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc8000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 112
	.dword initial_cap_values + 128
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe29ef79c // ALDUR-R.RI-32 Rt:28 Rn:28 op2:01 imm9:111101111 V:0 op1:10 11100010:11100010
	.inst 0x7882245b // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:27 Rn:2 01:01 imm9:000100010 0:0 opc:10 111000:111000 size:01
	.inst 0x780f1c30 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:16 Rn:1 11:11 imm9:011110001 0:0 opc:00 111000:111000 size:01
	.inst 0x913b795f // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:10 imm12:111011011110 sh:0 0:0 10001:10001 S:0 op:0 sf:1
	.inst 0x784d017e // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:11 00:00 imm9:011010000 0:0 opc:01 111000:111000 size:01
	.inst 0xf895701e // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:0 00:00 imm9:101010111 0:0 opc:10 111000:111000 size:11
	.inst 0x2284e622 // STP-CC.RIAW-C Ct:2 Rn:17 Ct2:11001 imm7:0001001 L:0 001000101:001000101
	.inst 0xc2c343b8 // SCVALUE-C.CR-C Cd:24 Cn:29 000:000 opc:10 0:0 Rm:3 11000010110:11000010110
	.inst 0x6d9d57fe // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:30 Rn:31 Rt2:10101 imm7:0111010 L:0 1011011:1011011 opc:01
	.inst 0x9a829060 // csel:aarch64/instrs/integer/conditional/select Rd:0 Rn:3 o2:0 0:0 cond:1001 Rm:2 011010100:011010100 op:0 sf:1
	.inst 0xc2c21240
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x9, cptr_el3
	orr x9, x9, #0x200
	msr cptr_el3, x9
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
	ldr x9, =initial_cap_values
	.inst 0xc2400121 // ldr c1, [x9, #0]
	.inst 0xc2400522 // ldr c2, [x9, #1]
	.inst 0xc2400923 // ldr c3, [x9, #2]
	.inst 0xc2400d2a // ldr c10, [x9, #3]
	.inst 0xc240112b // ldr c11, [x9, #4]
	.inst 0xc2401530 // ldr c16, [x9, #5]
	.inst 0xc2401931 // ldr c17, [x9, #6]
	.inst 0xc2401d39 // ldr c25, [x9, #7]
	.inst 0xc240213c // ldr c28, [x9, #8]
	.inst 0xc240253d // ldr c29, [x9, #9]
	/* Vector registers */
	mrs x9, cptr_el3
	bfc x9, #10, #1
	msr cptr_el3, x9
	isb
	ldr q21, =0x0
	ldr q30, =0x0
	/* Set up flags and system registers */
	mov x9, #0x60000000
	msr nzcv, x9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x3085003a
	msr SCTLR_EL3, x9
	ldr x9, =0x0
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82603249 // ldr c9, [c18, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x82601249 // ldr c9, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x18, #0x6
	and x9, x9, x18
	cmp x9, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400132 // ldr c18, [x9, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400532 // ldr c18, [x9, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400932 // ldr c18, [x9, #2]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400d32 // ldr c18, [x9, #3]
	.inst 0xc2d2a461 // chkeq c3, c18
	b.ne comparison_fail
	.inst 0xc2401132 // ldr c18, [x9, #4]
	.inst 0xc2d2a541 // chkeq c10, c18
	b.ne comparison_fail
	.inst 0xc2401532 // ldr c18, [x9, #5]
	.inst 0xc2d2a561 // chkeq c11, c18
	b.ne comparison_fail
	.inst 0xc2401932 // ldr c18, [x9, #6]
	.inst 0xc2d2a601 // chkeq c16, c18
	b.ne comparison_fail
	.inst 0xc2401d32 // ldr c18, [x9, #7]
	.inst 0xc2d2a621 // chkeq c17, c18
	b.ne comparison_fail
	.inst 0xc2402132 // ldr c18, [x9, #8]
	.inst 0xc2d2a701 // chkeq c24, c18
	b.ne comparison_fail
	.inst 0xc2402532 // ldr c18, [x9, #9]
	.inst 0xc2d2a721 // chkeq c25, c18
	b.ne comparison_fail
	.inst 0xc2402932 // ldr c18, [x9, #10]
	.inst 0xc2d2a761 // chkeq c27, c18
	b.ne comparison_fail
	.inst 0xc2402d32 // ldr c18, [x9, #11]
	.inst 0xc2d2a781 // chkeq c28, c18
	b.ne comparison_fail
	.inst 0xc2403132 // ldr c18, [x9, #12]
	.inst 0xc2d2a7a1 // chkeq c29, c18
	b.ne comparison_fail
	.inst 0xc2403532 // ldr c18, [x9, #13]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0x0
	mov x18, v21.d[0]
	cmp x9, x18
	b.ne comparison_fail
	ldr x9, =0x0
	mov x18, v21.d[1]
	cmp x9, x18
	b.ne comparison_fail
	ldr x9, =0x0
	mov x18, v30.d[0]
	cmp x9, x18
	b.ne comparison_fail
	ldr x9, =0x0
	mov x18, v30.d[1]
	cmp x9, x18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010b0
	ldr x1, =check_data1
	ldr x2, =0x000010c0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000014e0
	ldr x1, =check_data2
	ldr x2, =0x000014e2
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001e80
	ldr x1, =check_data3
	ldr x2, =0x00001e82
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004000fc
	ldr x1, =check_data5
	ldr x2, =0x004000fe
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0047fff0
	ldr x1, =check_data6
	ldr x2, =0x0047fff4
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
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
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

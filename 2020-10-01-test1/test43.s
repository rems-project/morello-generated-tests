.section data0, #alloc, #write
	.zero 400
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 3680
.data
check_data0:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x36, 0x70, 0x24, 0xe2, 0x90, 0x73, 0xa2, 0xaa, 0x1f, 0x10, 0xc0, 0x5a, 0xc2, 0x3b, 0x98, 0x38
	.byte 0xbe, 0x51, 0xc1, 0xc2, 0xa2, 0x03, 0xc0, 0x62, 0x7a, 0x4f, 0xd9, 0x2c, 0x74, 0x59, 0xe1, 0xc2
	.byte 0x3f, 0x5a, 0xc7, 0xc2, 0x3e, 0x04, 0x63, 0xe2, 0xe0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x17cc
	/* C11 */
	.octa 0x600220010000000000000001
	/* C17 */
	.octa 0x780060000200000000000
	/* C27 */
	.octa 0x80000000400200030000000000001fb4
	/* C29 */
	.octa 0x90000000000080080000000000001180
	/* C30 */
	.octa 0x8000000000010005000000000000207b
final_cap_values:
	/* C0 */
	.octa 0x101800000000000000000000000
	/* C1 */
	.octa 0x17cc
	/* C2 */
	.octa 0x0
	/* C11 */
	.octa 0x600220010000000000000001
	/* C17 */
	.octa 0x780060000200000000000
	/* C20 */
	.octa 0x6002200100000000000017cc
	/* C27 */
	.octa 0x8000000040020003000000000000207c
	/* C29 */
	.octa 0x90000000000080080000000000001180
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001190
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2247036 // ASTUR-V.RI-B Rt:22 Rn:1 op2:00 imm9:001000111 V:1 op1:00 11100010:11100010
	.inst 0xaaa27390 // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:16 Rn:28 imm6:011100 Rm:2 N:1 shift:10 01010:01010 opc:01 sf:1
	.inst 0x5ac0101f // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:31 Rn:0 op:0 10110101100000000010:10110101100000000010 sf:0
	.inst 0x38983bc2 // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:30 10:10 imm9:110000011 0:0 opc:10 111000:111000 size:00
	.inst 0xc2c151be // CFHI-R.C-C Rd:30 Cn:13 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0x62c003a2 // LDP-C.RIBW-C Ct:2 Rn:29 Ct2:00000 imm7:0000000 L:1 011000101:011000101
	.inst 0x2cd94f7a // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:26 Rn:27 Rt2:10011 imm7:0110010 L:1 1011001:1011001 opc:00
	.inst 0xc2e15974 // CVTZ-C.CR-C Cd:20 Cn:11 0110:0110 1:1 0:0 Rm:1 11000010111:11000010111
	.inst 0xc2c75a3f // ALIGNU-C.CI-C Cd:31 Cn:17 0110:0110 U:1 imm6:001110 11000010110:11000010110
	.inst 0xe263043e // ALDUR-V.RI-H Rt:30 Rn:1 op2:01 imm9:000110000 V:1 op1:01 11100010:11100010
	.inst 0xc2c212e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x18, cptr_el3
	orr x18, x18, #0x200
	msr cptr_el3, x18
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
	ldr x18, =initial_cap_values
	.inst 0xc2400241 // ldr c1, [x18, #0]
	.inst 0xc240064b // ldr c11, [x18, #1]
	.inst 0xc2400a51 // ldr c17, [x18, #2]
	.inst 0xc2400e5b // ldr c27, [x18, #3]
	.inst 0xc240125d // ldr c29, [x18, #4]
	.inst 0xc240165e // ldr c30, [x18, #5]
	/* Vector registers */
	mrs x18, cptr_el3
	bfc x18, #10, #1
	msr cptr_el3, x18
	isb
	ldr q22, =0x0
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	ldr x18, =0x0
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032f2 // ldr c18, [c23, #3]
	.inst 0xc28b4132 // msr ddc_el3, c18
	isb
	.inst 0x826012f2 // ldr c18, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr ddc_el3, c18
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc2400257 // ldr c23, [x18, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc2400657 // ldr c23, [x18, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400a57 // ldr c23, [x18, #2]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400e57 // ldr c23, [x18, #3]
	.inst 0xc2d7a561 // chkeq c11, c23
	b.ne comparison_fail
	.inst 0xc2401257 // ldr c23, [x18, #4]
	.inst 0xc2d7a621 // chkeq c17, c23
	b.ne comparison_fail
	.inst 0xc2401657 // ldr c23, [x18, #5]
	.inst 0xc2d7a681 // chkeq c20, c23
	b.ne comparison_fail
	.inst 0xc2401a57 // ldr c23, [x18, #6]
	.inst 0xc2d7a761 // chkeq c27, c23
	b.ne comparison_fail
	.inst 0xc2401e57 // ldr c23, [x18, #7]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x18, =0x0
	mov x23, v19.d[0]
	cmp x18, x23
	b.ne comparison_fail
	ldr x18, =0x0
	mov x23, v19.d[1]
	cmp x18, x23
	b.ne comparison_fail
	ldr x18, =0x0
	mov x23, v22.d[0]
	cmp x18, x23
	b.ne comparison_fail
	ldr x18, =0x0
	mov x23, v22.d[1]
	cmp x18, x23
	b.ne comparison_fail
	ldr x18, =0x0
	mov x23, v26.d[0]
	cmp x18, x23
	b.ne comparison_fail
	ldr x18, =0x0
	mov x23, v26.d[1]
	cmp x18, x23
	b.ne comparison_fail
	ldr x18, =0x0
	mov x23, v30.d[0]
	cmp x18, x23
	b.ne comparison_fail
	ldr x18, =0x0
	mov x23, v30.d[1]
	cmp x18, x23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001180
	ldr x1, =check_data0
	ldr x2, =0x000011a0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000017fc
	ldr x1, =check_data1
	ldr x2, =0x000017fe
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001813
	ldr x1, =check_data2
	ldr x2, =0x00001814
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fb4
	ldr x1, =check_data3
	ldr x2, =0x00001fbc
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ffe
	ldr x1, =check_data4
	ldr x2, =0x00001fff
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
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr ddc_el3, c18
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

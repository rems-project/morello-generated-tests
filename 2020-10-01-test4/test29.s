.section data0, #alloc, #write
	.byte 0x00, 0x00, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xc2
.data
check_data1:
	.byte 0xe0, 0x01, 0x1e, 0xda, 0xff, 0x53, 0xc0, 0xc2, 0x92, 0xe1, 0x9e, 0x5a, 0x95, 0xd4, 0xa4, 0x72
	.byte 0x57, 0x30, 0xc0, 0xc2, 0xc0, 0x93, 0xe0, 0x28, 0x3e, 0x78, 0xd1, 0xc2, 0x61, 0x54, 0x82, 0xda
	.byte 0x59, 0x48, 0xd2, 0x39, 0x9f, 0xaa, 0x17, 0x52, 0x00, 0x13, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x80000300070000000000000000
	/* C2 */
	.octa 0x80000000000000100000000000000b70
	/* C30 */
	.octa 0x80000000700020010000000000402200
final_cap_values:
	/* C0 */
	.octa 0xc2c2c2c2
	/* C2 */
	.octa 0x80000000000000100000000000000b70
	/* C4 */
	.octa 0xc2c2c2c2
	/* C23 */
	.octa 0xffffffffffffffff
	/* C25 */
	.octa 0xffffffc2
	/* C30 */
	.octa 0x80422000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x2000800008b100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 16
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xda1e01e0 // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:0 Rn:15 000000:000000 Rm:30 11010000:11010000 S:0 op:1 sf:1
	.inst 0xc2c053ff // GCVALUE-R.C-C Rd:31 Cn:31 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0x5a9ee192 // csinv:aarch64/instrs/integer/conditional/select Rd:18 Rn:12 o2:0 0:0 cond:1110 Rm:30 011010100:011010100 op:1 sf:0
	.inst 0x72a4d495 // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:21 imm16:0010011010100100 hw:01 100101:100101 opc:11 sf:0
	.inst 0xc2c03057 // GCLEN-R.C-C Rd:23 Cn:2 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0x28e093c0 // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:0 Rn:30 Rt2:00100 imm7:1000001 L:1 1010001:1010001 opc:00
	.inst 0xc2d1783e // SCBNDS-C.CI-S Cd:30 Cn:1 1110:1110 S:1 imm6:100010 11000010110:11000010110
	.inst 0xda825461 // csneg:aarch64/instrs/integer/conditional/select Rd:1 Rn:3 o2:1 0:0 cond:0101 Rm:2 011010100:011010100 op:1 sf:1
	.inst 0x39d24859 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:25 Rn:2 imm12:010010010010 opc:11 111001:111001 size:00
	.inst 0x5217aa9f // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:31 Rn:20 imms:101010 immr:010111 N:0 100100:100100 opc:10 sf:0
	.inst 0xc2c21300
	.zero 8660
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 1039864
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
	.inst 0xc24000c1 // ldr c1, [x6, #0]
	.inst 0xc24004c2 // ldr c2, [x6, #1]
	.inst 0xc24008de // ldr c30, [x6, #2]
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30850032
	msr SCTLR_EL3, x6
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82601306 // ldr c6, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr ddc_el3, c6
	isb
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x24, #0x8
	and x6, x6, x24
	cmp x6, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000d8 // ldr c24, [x6, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc24004d8 // ldr c24, [x6, #1]
	.inst 0xc2d8a441 // chkeq c2, c24
	b.ne comparison_fail
	.inst 0xc24008d8 // ldr c24, [x6, #2]
	.inst 0xc2d8a481 // chkeq c4, c24
	b.ne comparison_fail
	.inst 0xc2400cd8 // ldr c24, [x6, #3]
	.inst 0xc2d8a6e1 // chkeq c23, c24
	b.ne comparison_fail
	.inst 0xc24010d8 // ldr c24, [x6, #4]
	.inst 0xc2d8a721 // chkeq c25, c24
	b.ne comparison_fail
	.inst 0xc24014d8 // ldr c24, [x6, #5]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001002
	ldr x1, =check_data0
	ldr x2, =0x00001003
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
	ldr x0, =0x00402200
	ldr x1, =check_data2
	ldr x2, =0x00402208
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

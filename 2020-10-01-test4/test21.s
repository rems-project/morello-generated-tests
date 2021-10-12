.section data0, #alloc, #write
	.zero 528
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00
	.zero 3552
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00
	.zero 16
.data
check_data5:
	.byte 0xae, 0x23, 0xc2, 0xc2, 0x56, 0x00, 0x02, 0x7a, 0xd0, 0x03, 0x0e, 0x1a, 0xff, 0x7f, 0xdf, 0x88
	.byte 0x5f, 0x5c, 0x85, 0x6c, 0xdc, 0xf7, 0x50, 0x62, 0x5e, 0xfc, 0x9f, 0x08, 0x45, 0x7f, 0xdf, 0x08
	.byte 0x45, 0xb0, 0x56, 0x7a, 0xfe, 0x2f, 0x12, 0x38, 0x80, 0x11, 0xc2, 0xc2
.data
check_data6:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x40000000000100070000000000001018
	/* C26 */
	.octa 0x800000000007800f0000000000419884
	/* C29 */
	.octa 0x2000700030000000000000000
	/* C30 */
	.octa 0x90000000000700070000000000001000
final_cap_values:
	/* C2 */
	.octa 0x40000000000100070000000000001068
	/* C5 */
	.octa 0x0
	/* C14 */
	.octa 0x2501800000000000000000000
	/* C16 */
	.octa 0x1001
	/* C22 */
	.octa 0x0
	/* C26 */
	.octa 0x800000000007800f0000000000419884
	/* C28 */
	.octa 0x400000000000000000000000000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x90000000000700070000000000001000
initial_csp_value:
	.octa 0xc00000000001000700000000000010e0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000402cc0400000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001210
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword initial_csp_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c223ae // SCBNDSE-C.CR-C Cd:14 Cn:29 000:000 opc:01 0:0 Rm:2 11000010110:11000010110
	.inst 0x7a020056 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:22 Rn:2 000000:000000 Rm:2 11010000:11010000 S:1 op:1 sf:0
	.inst 0x1a0e03d0 // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:16 Rn:30 000000:000000 Rm:14 11010000:11010000 S:0 op:0 sf:0
	.inst 0x88df7fff // ldlar:aarch64/instrs/memory/ordered Rt:31 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0x6c855c5f // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:31 Rn:2 Rt2:10111 imm7:0001010 L:0 1011001:1011001 opc:01
	.inst 0x6250f7dc // LDNP-C.RIB-C Ct:28 Rn:30 Ct2:11101 imm7:0100001 L:1 011000100:011000100
	.inst 0x089ffc5e // stlrb:aarch64/instrs/memory/ordered Rt:30 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x08df7f45 // ldlarb:aarch64/instrs/memory/ordered Rt:5 Rn:26 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x7a56b045 // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0101 0:0 Rn:2 00:00 cond:1011 Rm:22 111010010:111010010 op:1 sf:0
	.inst 0x38122ffe // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:31 11:11 imm9:100100010 0:0 opc:00 111000:111000 size:00
	.inst 0xc2c21180
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x4, cptr_el3
	orr x4, x4, #0x200
	msr cptr_el3, x4
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
	ldr x4, =initial_cap_values
	.inst 0xc2400082 // ldr c2, [x4, #0]
	.inst 0xc240049a // ldr c26, [x4, #1]
	.inst 0xc240089d // ldr c29, [x4, #2]
	.inst 0xc2400c9e // ldr c30, [x4, #3]
	/* Vector registers */
	mrs x4, cptr_el3
	bfc x4, #10, #1
	msr cptr_el3, x4
	isb
	ldr q23, =0x0
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x4, #0x20000000
	msr nzcv, x4
	ldr x4, =initial_csp_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2c1d09f // cpy c31, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82601184 // ldr c4, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr ddc_el3, c4
	isb
	/* Check processor flags */
	mrs x4, nzcv
	ubfx x4, x4, #28, #4
	mov x12, #0xf
	and x4, x4, x12
	cmp x4, #0x5
	b.ne comparison_fail
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc240008c // ldr c12, [x4, #0]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc240048c // ldr c12, [x4, #1]
	.inst 0xc2cca4a1 // chkeq c5, c12
	b.ne comparison_fail
	.inst 0xc240088c // ldr c12, [x4, #2]
	.inst 0xc2cca5c1 // chkeq c14, c12
	b.ne comparison_fail
	.inst 0xc2400c8c // ldr c12, [x4, #3]
	.inst 0xc2cca601 // chkeq c16, c12
	b.ne comparison_fail
	.inst 0xc240108c // ldr c12, [x4, #4]
	.inst 0xc2cca6c1 // chkeq c22, c12
	b.ne comparison_fail
	.inst 0xc240148c // ldr c12, [x4, #5]
	.inst 0xc2cca741 // chkeq c26, c12
	b.ne comparison_fail
	.inst 0xc240188c // ldr c12, [x4, #6]
	.inst 0xc2cca781 // chkeq c28, c12
	b.ne comparison_fail
	.inst 0xc2401c8c // ldr c12, [x4, #7]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	.inst 0xc240208c // ldr c12, [x4, #8]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check vector registers */
	ldr x4, =0x0
	mov x12, v23.d[0]
	cmp x4, x12
	b.ne comparison_fail
	ldr x4, =0x0
	mov x12, v23.d[1]
	cmp x4, x12
	b.ne comparison_fail
	ldr x4, =0x0
	mov x12, v31.d[0]
	cmp x4, x12
	b.ne comparison_fail
	ldr x4, =0x0
	mov x12, v31.d[1]
	cmp x4, x12
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
	ldr x0, =0x00001018
	ldr x1, =check_data1
	ldr x2, =0x00001028
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001068
	ldr x1, =check_data2
	ldr x2, =0x00001069
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000010e0
	ldr x1, =check_data3
	ldr x2, =0x000010e4
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001210
	ldr x1, =check_data4
	ldr x2, =0x00001230
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
	ldr x0, =0x00419884
	ldr x1, =check_data6
	ldr x2, =0x00419885
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
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr ddc_el3, c4
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

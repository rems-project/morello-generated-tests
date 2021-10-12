.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x1e, 0x6c, 0xee, 0x02, 0xe4, 0xf3, 0xc5, 0xc2, 0x01, 0x14, 0xf6, 0x69, 0xe2, 0x23, 0xdf, 0x9a
	.byte 0x8b, 0x41, 0xd5, 0xe2, 0x81, 0xd2, 0x59, 0xa9, 0x5c, 0x28, 0xc0, 0x9a, 0x2e, 0xde, 0xcf, 0x68
	.byte 0x3e, 0x48, 0xc5, 0xc2, 0xfa, 0x1b, 0xe0, 0xc2, 0x60, 0x10, 0xc2, 0xc2
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400003a0070000000000002000
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x4000000040000002000000000000172c
	/* C17 */
	.octa 0x401c00
	/* C20 */
	.octa 0x4ffe10
final_cap_values:
	/* C0 */
	.octa 0x1fb0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x4000000040000002000000000000172c
	/* C14 */
	.octa 0x0
	/* C17 */
	.octa 0x401c7c
	/* C20 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C26 */
	.octa 0x400100040000000000001fb4
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_csp_value:
	.octa 0x400100040000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000006000100fffffffc000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x02ee6c1e // SUB-C.CIS-C Cd:30 Cn:0 imm12:101110011011 sh:1 A:1 00000010:00000010
	.inst 0xc2c5f3e4 // CVTPZ-C.R-C Cd:4 Rn:31 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0x69f61401 // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:1 Rn:0 Rt2:00101 imm7:1101100 L:1 1010011:1010011 opc:01
	.inst 0x9adf23e2 // lslv:aarch64/instrs/integer/shift/variable Rd:2 Rn:31 op2:00 0010:0010 Rm:31 0011010110:0011010110 sf:1
	.inst 0xe2d5418b // ASTUR-R.RI-64 Rt:11 Rn:12 op2:00 imm9:101010100 V:0 op1:11 11100010:11100010
	.inst 0xa959d281 // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:1 Rn:20 Rt2:10100 imm7:0110011 L:1 1010010:1010010 opc:10
	.inst 0x9ac0285c // asrv:aarch64/instrs/integer/shift/variable Rd:28 Rn:2 op2:10 0010:0010 Rm:0 0011010110:0011010110 sf:1
	.inst 0x68cfde2e // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:14 Rn:17 Rt2:10111 imm7:0011111 L:1 1010001:1010001 opc:01
	.inst 0xc2c5483e // UNSEAL-C.CC-C Cd:30 Cn:1 0010:0010 opc:01 Cm:5 11000010110:11000010110
	.inst 0xc2e01bfa // CVT-C.CR-C Cd:26 Cn:31 0110:0110 0:0 0:0 Rm:0 11000010111:11000010111
	.inst 0xc2c21060
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
	ldr x9, =initial_cap_values
	.inst 0xc2400120 // ldr c0, [x9, #0]
	.inst 0xc240052b // ldr c11, [x9, #1]
	.inst 0xc240092c // ldr c12, [x9, #2]
	.inst 0xc2400d31 // ldr c17, [x9, #3]
	.inst 0xc2401134 // ldr c20, [x9, #4]
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =initial_csp_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2c1d13f // cpy c31, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30850032
	msr SCTLR_EL3, x9
	ldr x9, =0x4
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82603069 // ldr c9, [c3, #3]
	.inst 0xc28b4129 // msr ddc_el3, c9
	isb
	.inst 0x82601069 // ldr c9, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr ddc_el3, c9
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400123 // ldr c3, [x9, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc2400523 // ldr c3, [x9, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400923 // ldr c3, [x9, #2]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400d23 // ldr c3, [x9, #3]
	.inst 0xc2c3a481 // chkeq c4, c3
	b.ne comparison_fail
	.inst 0xc2401123 // ldr c3, [x9, #4]
	.inst 0xc2c3a4a1 // chkeq c5, c3
	b.ne comparison_fail
	.inst 0xc2401523 // ldr c3, [x9, #5]
	.inst 0xc2c3a561 // chkeq c11, c3
	b.ne comparison_fail
	.inst 0xc2401923 // ldr c3, [x9, #6]
	.inst 0xc2c3a581 // chkeq c12, c3
	b.ne comparison_fail
	.inst 0xc2401d23 // ldr c3, [x9, #7]
	.inst 0xc2c3a5c1 // chkeq c14, c3
	b.ne comparison_fail
	.inst 0xc2402123 // ldr c3, [x9, #8]
	.inst 0xc2c3a621 // chkeq c17, c3
	b.ne comparison_fail
	.inst 0xc2402523 // ldr c3, [x9, #9]
	.inst 0xc2c3a681 // chkeq c20, c3
	b.ne comparison_fail
	.inst 0xc2402923 // ldr c3, [x9, #10]
	.inst 0xc2c3a6e1 // chkeq c23, c3
	b.ne comparison_fail
	.inst 0xc2402d23 // ldr c3, [x9, #11]
	.inst 0xc2c3a741 // chkeq c26, c3
	b.ne comparison_fail
	.inst 0xc2403123 // ldr c3, [x9, #12]
	.inst 0xc2c3a781 // chkeq c28, c3
	b.ne comparison_fail
	.inst 0xc2403523 // ldr c3, [x9, #13]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001680
	ldr x1, =check_data0
	ldr x2, =0x00001688
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001fb0
	ldr x1, =check_data1
	ldr x2, =0x00001fb8
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
	ldr x0, =0x00401c00
	ldr x1, =check_data3
	ldr x2, =0x00401c08
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004fffa8
	ldr x1, =check_data4
	ldr x2, =0x004fffb8
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr ddc_el3, c9
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

.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x4c, 0x4b, 0x18, 0x47, 0xf1, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x32, 0x70, 0x32, 0x9b, 0x2f, 0xb0, 0xc0, 0xc2, 0x25, 0x71, 0x74, 0xaa, 0xe7, 0x7b, 0x75, 0x82
	.byte 0x41, 0x3c, 0x41, 0x8b, 0x15, 0x90, 0xc1, 0xc2, 0xff, 0x13, 0xc0, 0xc2, 0x85, 0x00, 0xbe, 0xa8
	.byte 0x7e, 0x4f, 0x40, 0xa2, 0x25, 0x98, 0xe4, 0xc2, 0xa0, 0x13, 0xc2, 0xc2
.data
check_data3:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x40000000000100070000000000001000
	/* C9 */
	.octa 0x0
	/* C20 */
	.octa 0xeb8e7b4b30000000
	/* C27 */
	.octa 0x901000000807000f0000000000400000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C4 */
	.octa 0x40000000000100070000000000000fe0
	/* C5 */
	.octa 0x3
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C20 */
	.octa 0xeb8e7b4b30000000
	/* C21 */
	.octa 0x0
	/* C27 */
	.octa 0x901000000807000f0000000000400040
	/* C30 */
	.octa 0x0
initial_csp_value:
	.octa 0x30003fffffffffffffec0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000408100000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000007060600ffffffffffc000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9b327032 // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:18 Rn:1 Ra:28 o0:0 Rm:18 01:01 U:0 10011011:10011011
	.inst 0xc2c0b02f // GCSEAL-R.C-C Rd:15 Cn:1 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xaa747125 // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:5 Rn:9 imm6:011100 Rm:20 N:1 shift:01 01010:01010 opc:01 sf:1
	.inst 0x82757be7 // ALDR-R.RI-32 Rt:7 Rn:31 op:10 imm9:101010111 L:1 1000001001:1000001001
	.inst 0x8b413c41 // add_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:1 Rn:2 imm6:001111 Rm:1 0:0 shift:01 01011:01011 S:0 op:0 sf:1
	.inst 0xc2c19015 // CLRTAG-C.C-C Cd:21 Cn:0 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xc2c013ff // GCBASE-R.C-C Rd:31 Cn:31 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0xa8be0085 // stp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:5 Rn:4 Rt2:00000 imm7:1111100 L:0 1010001:1010001 opc:10
	.inst 0xa2404f7e // LDR-C.RIBW-C Ct:30 Rn:27 11:11 imm9:000000100 0:0 opc:01 10100010:10100010
	.inst 0xc2e49825 // SUBS-R.CC-C Rd:5 Cn:1 100110:100110 Cm:4 11000010111:11000010111
	.inst 0xc2c213a0
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
	ldr x3, =initial_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400461 // ldr c1, [x3, #1]
	.inst 0xc2400864 // ldr c4, [x3, #2]
	.inst 0xc2400c69 // ldr c9, [x3, #3]
	.inst 0xc2401074 // ldr c20, [x3, #4]
	.inst 0xc240147b // ldr c27, [x3, #5]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =initial_csp_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2c1d07f // cpy c31, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x3085003a
	msr SCTLR_EL3, x3
	ldr x3, =0x4
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x29, =pcc_return_ddc_capabilities
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0x826033a3 // ldr c3, [c29, #3]
	.inst 0xc28b4123 // msr ddc_el3, c3
	isb
	.inst 0x826013a3 // ldr c3, [c29, #1]
	.inst 0x826023bd // ldr c29, [c29, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr ddc_el3, c3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x29, #0xf
	and x3, x3, x29
	cmp x3, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc240007d // ldr c29, [x3, #0]
	.inst 0xc2dda401 // chkeq c0, c29
	b.ne comparison_fail
	.inst 0xc240047d // ldr c29, [x3, #1]
	.inst 0xc2dda481 // chkeq c4, c29
	b.ne comparison_fail
	.inst 0xc240087d // ldr c29, [x3, #2]
	.inst 0xc2dda4a1 // chkeq c5, c29
	b.ne comparison_fail
	.inst 0xc2400c7d // ldr c29, [x3, #3]
	.inst 0xc2dda4e1 // chkeq c7, c29
	b.ne comparison_fail
	.inst 0xc240107d // ldr c29, [x3, #4]
	.inst 0xc2dda521 // chkeq c9, c29
	b.ne comparison_fail
	.inst 0xc240147d // ldr c29, [x3, #5]
	.inst 0xc2dda5e1 // chkeq c15, c29
	b.ne comparison_fail
	.inst 0xc240187d // ldr c29, [x3, #6]
	.inst 0xc2dda681 // chkeq c20, c29
	b.ne comparison_fail
	.inst 0xc2401c7d // ldr c29, [x3, #7]
	.inst 0xc2dda6a1 // chkeq c21, c29
	b.ne comparison_fail
	.inst 0xc240207d // ldr c29, [x3, #8]
	.inst 0xc2dda761 // chkeq c27, c29
	b.ne comparison_fail
	.inst 0xc240247d // ldr c29, [x3, #9]
	.inst 0xc2dda7c1 // chkeq c30, c29
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
	ldr x2, =0x00001020
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
	ldr x0, =0x00400040
	ldr x1, =check_data3
	ldr x2, =0x00400050
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
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr ddc_el3, c3
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

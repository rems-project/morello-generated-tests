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
	.byte 0x00, 0x64, 0xde, 0x82, 0xe1, 0x03, 0x9e, 0x1a, 0x71, 0x01, 0x9d, 0x78, 0xc1, 0x63, 0xdb, 0xe2
	.byte 0xc2, 0x51, 0xc2, 0xc2
.data
check_data3:
	.byte 0x81, 0x6a, 0xde, 0xc2, 0x45, 0x98, 0x17, 0xd8, 0xad, 0x0f, 0x72, 0x69, 0xe1, 0x10, 0xc5, 0xc2
	.byte 0x40, 0x47, 0xdf, 0xc2, 0xe0, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 2
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4fdfc4
	/* C7 */
	.octa 0x0
	/* C11 */
	.octa 0x80000000000100050000000000400a3c
	/* C14 */
	.octa 0x200080005001000d0000000000400018
	/* C20 */
	.octa 0x0
	/* C29 */
	.octa 0x1100
	/* C30 */
	.octa 0x203a
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C11 */
	.octa 0x80000000000100050000000000400a3c
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x200080005001000d0000000000400018
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C29 */
	.octa 0x1100
	/* C30 */
	.octa 0x203a
initial_csp_value:
	.octa 0xffffffffffffffff
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82de6400 // ALDRSB-R.RRB-32 Rt:0 Rn:0 opc:01 S:0 option:011 Rm:30 0:0 L:1 100000101:100000101
	.inst 0x1a9e03e1 // csel:aarch64/instrs/integer/conditional/select Rd:1 Rn:31 o2:0 0:0 cond:0000 Rm:30 011010100:011010100 op:0 sf:0
	.inst 0x789d0171 // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:17 Rn:11 00:00 imm9:111010000 0:0 opc:10 111000:111000 size:01
	.inst 0xe2db63c1 // ASTUR-R.RI-64 Rt:1 Rn:30 op2:00 imm9:110110110 V:0 op1:11 11100010:11100010
	.inst 0xc2c251c2 // RETS-C-C 00010:00010 Cn:14 100:100 opc:10 11000010110000100:11000010110000100
	.zero 4
	.inst 0xc2de6a81 // ORRFLGS-C.CR-C Cd:1 Cn:20 1010:1010 opc:01 Rm:30 11000010110:11000010110
	.inst 0xd8179845 // prfm_lit:aarch64/instrs/memory/literal/general Rt:5 imm19:0001011110011000010 011000:011000 opc:11
	.inst 0x69720fad // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:13 Rn:29 Rt2:00011 imm7:1100100 L:1 1010010:1010010 opc:01
	.inst 0xc2c510e1 // CVTD-R.C-C Rd:1 Cn:7 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0xc2df4740 // CSEAL-C.C-C Cd:0 Cn:26 001:001 opc:10 0:0 Cm:31 11000010110:11000010110
	.inst 0xc2c211e0
	.zero 1048528
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
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc2400647 // ldr c7, [x18, #1]
	.inst 0xc2400a4b // ldr c11, [x18, #2]
	.inst 0xc2400e4e // ldr c14, [x18, #3]
	.inst 0xc2401254 // ldr c20, [x18, #4]
	.inst 0xc240165d // ldr c29, [x18, #5]
	.inst 0xc2401a5e // ldr c30, [x18, #6]
	/* Set up flags and system registers */
	mov x18, #0x40000000
	msr nzcv, x18
	ldr x18, =initial_csp_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2c1d25f // cpy c31, c18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	ldr x18, =0x0
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031f2 // ldr c18, [c15, #3]
	.inst 0xc28b4132 // msr ddc_el3, c18
	isb
	.inst 0x826011f2 // ldr c18, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr ddc_el3, c18
	isb
	/* Check processor flags */
	mrs x18, nzcv
	ubfx x18, x18, #28, #4
	mov x15, #0xf
	and x18, x18, x15
	cmp x18, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc240024f // ldr c15, [x18, #0]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc240064f // ldr c15, [x18, #1]
	.inst 0xc2cfa461 // chkeq c3, c15
	b.ne comparison_fail
	.inst 0xc2400a4f // ldr c15, [x18, #2]
	.inst 0xc2cfa4e1 // chkeq c7, c15
	b.ne comparison_fail
	.inst 0xc2400e4f // ldr c15, [x18, #3]
	.inst 0xc2cfa561 // chkeq c11, c15
	b.ne comparison_fail
	.inst 0xc240124f // ldr c15, [x18, #4]
	.inst 0xc2cfa5a1 // chkeq c13, c15
	b.ne comparison_fail
	.inst 0xc240164f // ldr c15, [x18, #5]
	.inst 0xc2cfa5c1 // chkeq c14, c15
	b.ne comparison_fail
	.inst 0xc2401a4f // ldr c15, [x18, #6]
	.inst 0xc2cfa621 // chkeq c17, c15
	b.ne comparison_fail
	.inst 0xc2401e4f // ldr c15, [x18, #7]
	.inst 0xc2cfa681 // chkeq c20, c15
	b.ne comparison_fail
	.inst 0xc240224f // ldr c15, [x18, #8]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc240264f // ldr c15, [x18, #9]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001090
	ldr x1, =check_data0
	ldr x2, =0x00001098
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ff0
	ldr x1, =check_data1
	ldr x2, =0x00001ff8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400014
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400018
	ldr x1, =check_data3
	ldr x2, =0x00400030
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400a0c
	ldr x1, =check_data4
	ldr x2, =0x00400a0e
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffffe
	ldr x1, =check_data5
	ldr x2, =0x004fffff
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

.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 16
	.byte 0xf0, 0xff, 0x27, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x1c, 0xe4, 0xe0, 0x82, 0xc2, 0x0b, 0x7d, 0xc2, 0xd0, 0x1b, 0xff, 0xc2, 0x43, 0x1a, 0x4a, 0x3d
	.byte 0xe3, 0xeb, 0x49, 0x7a, 0xe2, 0xb3, 0xc0, 0xc2, 0xec, 0xf3, 0x3e, 0xeb, 0xe2, 0x7c, 0x4b, 0x9b
	.byte 0x3e, 0x7a, 0x2d, 0xe2, 0x20, 0xc3, 0x01, 0xf9, 0x60, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x27fff0
	/* C17 */
	.octa 0xf29
	/* C18 */
	.octa 0x80000000000100050000000000001d78
	/* C25 */
	.octa 0x40000000000100050000000000001c70
	/* C30 */
	.octa 0x8000000000030007ffffffffffff2bc0
final_cap_values:
	/* C0 */
	.octa 0x27fff0
	/* C12 */
	.octa 0xd4400
	/* C16 */
	.octa 0x80000000000300070000000000000000
	/* C17 */
	.octa 0xf29
	/* C18 */
	.octa 0x80000000000100050000000000001d78
	/* C25 */
	.octa 0x40000000000100050000000000001c70
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x8000000000030007ffffffffffff2bc0
initial_csp_value:
	.octa 0x3fff800000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000003000700ffe00000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82e0e41c // ALDR-R.RRB-64 Rt:28 Rn:0 opc:01 S:0 option:111 Rm:0 1:1 L:1 100000101:100000101
	.inst 0xc27d0bc2 // LDR-C.RIB-C Ct:2 Rn:30 imm12:111101000010 L:1 110000100:110000100
	.inst 0xc2ff1bd0 // CVT-C.CR-C Cd:16 Cn:30 0110:0110 0:0 0:0 Rm:31 11000010111:11000010111
	.inst 0x3d4a1a43 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:3 Rn:18 imm12:001010000110 opc:01 111101:111101 size:00
	.inst 0x7a49ebe3 // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0011 0:0 Rn:31 10:10 cond:1110 imm5:01001 111010010:111010010 op:1 sf:0
	.inst 0xc2c0b3e2 // GCSEAL-R.C-C Rd:2 Cn:31 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xeb3ef3ec // subs_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:12 Rn:31 imm3:100 option:111 Rm:30 01011001:01011001 S:1 op:1 sf:1
	.inst 0x9b4b7ce2 // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:2 Rn:7 Ra:11111 0:0 Rm:11 10:10 U:0 10011011:10011011
	.inst 0xe22d7a3e // ASTUR-V.RI-Q Rt:30 Rn:17 op2:10 imm9:011010111 V:1 op1:00 11100010:11100010
	.inst 0xf901c320 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:25 imm12:000001110000 opc:00 111001:111001 size:11
	.inst 0xc2c21260
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x13, cptr_el3
	orr x13, x13, #0x200
	msr cptr_el3, x13
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005b1 // ldr c17, [x13, #1]
	.inst 0xc24009b2 // ldr c18, [x13, #2]
	.inst 0xc2400db9 // ldr c25, [x13, #3]
	.inst 0xc24011be // ldr c30, [x13, #4]
	/* Vector registers */
	mrs x13, cptr_el3
	bfc x13, #10, #1
	msr cptr_el3, x13
	isb
	ldr q30, =0x0
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =initial_csp_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2c1d1bf // cpy c31, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	ldr x13, =0x0
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x8260326d // ldr c13, [c19, #3]
	.inst 0xc28b412d // msr ddc_el3, c13
	isb
	.inst 0x8260126d // ldr c13, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr ddc_el3, c13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x19, #0xf
	and x13, x13, x19
	cmp x13, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001b3 // ldr c19, [x13, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc24005b3 // ldr c19, [x13, #1]
	.inst 0xc2d3a581 // chkeq c12, c19
	b.ne comparison_fail
	.inst 0xc24009b3 // ldr c19, [x13, #2]
	.inst 0xc2d3a601 // chkeq c16, c19
	b.ne comparison_fail
	.inst 0xc2400db3 // ldr c19, [x13, #3]
	.inst 0xc2d3a621 // chkeq c17, c19
	b.ne comparison_fail
	.inst 0xc24011b3 // ldr c19, [x13, #4]
	.inst 0xc2d3a641 // chkeq c18, c19
	b.ne comparison_fail
	.inst 0xc24015b3 // ldr c19, [x13, #5]
	.inst 0xc2d3a721 // chkeq c25, c19
	b.ne comparison_fail
	.inst 0xc24019b3 // ldr c19, [x13, #6]
	.inst 0xc2d3a781 // chkeq c28, c19
	b.ne comparison_fail
	.inst 0xc2401db3 // ldr c19, [x13, #7]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0x0
	mov x19, v3.d[0]
	cmp x13, x19
	b.ne comparison_fail
	ldr x13, =0x0
	mov x19, v3.d[1]
	cmp x13, x19
	b.ne comparison_fail
	ldr x13, =0x0
	mov x19, v30.d[0]
	cmp x13, x19
	b.ne comparison_fail
	ldr x13, =0x0
	mov x19, v30.d[1]
	cmp x13, x19
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
	ldr x0, =0x00001fe0
	ldr x1, =check_data1
	ldr x2, =0x00001ff8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
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
	ldr x0, =0x004fffe0
	ldr x1, =check_data4
	ldr x2, =0x004fffe8
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
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr ddc_el3, c13
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

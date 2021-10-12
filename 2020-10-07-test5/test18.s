.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x81, 0x2e, 0x27, 0xd8, 0x00, 0x00, 0x1e, 0xda, 0x20, 0x28, 0x56, 0xe2, 0xd6, 0xb3, 0xc5, 0xc2
	.byte 0x1c, 0x64, 0xc2, 0xc2, 0x82, 0x8e, 0x89, 0xe2, 0xc3, 0x5b, 0xfe, 0xc2, 0x3f, 0x20, 0x00, 0x98
	.byte 0xe2, 0x77, 0x18, 0xc2, 0x52, 0x5e, 0x21, 0x9b, 0x00, 0x13, 0xc2, 0xc2
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x800000004000e004000000000048009c
	/* C2 */
	.octa 0x0
	/* C20 */
	.octa 0x40000000400200390000000000000f98
	/* C30 */
	.octa 0x70000000000000001
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x800000004000e004000000000048009c
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x70000000000000001
	/* C20 */
	.octa 0x40000000400200390000000000000f98
	/* C22 */
	.octa 0xa0008000442400000000000000000001
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x70000000000000001
initial_SP_EL3_value:
	.octa 0xffffffffffffb010
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0008000442400000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd8272e81 // prfm_lit:aarch64/instrs/memory/literal/general Rt:1 imm19:0010011100101110100 011000:011000 opc:11
	.inst 0xda1e0000 // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:0 Rn:0 000000:000000 Rm:30 11010000:11010000 S:0 op:1 sf:1
	.inst 0xe2562820 // ALDURSH-R.RI-64 Rt:0 Rn:1 op2:10 imm9:101100010 V:0 op1:01 11100010:11100010
	.inst 0xc2c5b3d6 // CVTP-C.R-C Cd:22 Rn:30 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xc2c2641c // CPYVALUE-C.C-C Cd:28 Cn:0 001:001 opc:11 0:0 Cm:2 11000010110:11000010110
	.inst 0xe2898e82 // ASTUR-C.RI-C Ct:2 Rn:20 op2:11 imm9:010011000 V:0 op1:10 11100010:11100010
	.inst 0xc2fe5bc3 // CVTZ-C.CR-C Cd:3 Cn:30 0110:0110 1:1 0:0 Rm:30 11000010111:11000010111
	.inst 0x9800203f // ldrsw_lit:aarch64/instrs/memory/literal/general Rt:31 imm19:0000000000100000001 011000:011000 opc:10
	.inst 0xc21877e2 // STR-C.RIB-C Ct:2 Rn:31 imm12:011000011101 L:0 110000100:110000100
	.inst 0x9b215e52 // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:18 Rn:18 Ra:23 o0:0 Rm:1 01:01 U:0 10011011:10011011
	.inst 0xc2c21300
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x29, cptr_el3
	orr x29, x29, #0x200
	msr cptr_el3, x29
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
	ldr x29, =initial_cap_values
	.inst 0xc24003a1 // ldr c1, [x29, #0]
	.inst 0xc24007a2 // ldr c2, [x29, #1]
	.inst 0xc2400bb4 // ldr c20, [x29, #2]
	.inst 0xc2400fbe // ldr c30, [x29, #3]
	/* Set up flags and system registers */
	mov x29, #0x00000000
	msr nzcv, x29
	ldr x29, =initial_SP_EL3_value
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0xc2c1d3bf // cpy c31, c29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x3085003a
	msr SCTLR_EL3, x29
	ldr x29, =0x0
	msr S3_6_C1_C2_2, x29 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x8260331d // ldr c29, [c24, #3]
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	.inst 0x8260131d // ldr c29, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c213a0 // br c29
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003b8 // ldr c24, [x29, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc24007b8 // ldr c24, [x29, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400bb8 // ldr c24, [x29, #2]
	.inst 0xc2d8a441 // chkeq c2, c24
	b.ne comparison_fail
	.inst 0xc2400fb8 // ldr c24, [x29, #3]
	.inst 0xc2d8a461 // chkeq c3, c24
	b.ne comparison_fail
	.inst 0xc24013b8 // ldr c24, [x29, #4]
	.inst 0xc2d8a681 // chkeq c20, c24
	b.ne comparison_fail
	.inst 0xc24017b8 // ldr c24, [x29, #5]
	.inst 0xc2d8a6c1 // chkeq c22, c24
	b.ne comparison_fail
	.inst 0xc2401bb8 // ldr c24, [x29, #6]
	.inst 0xc2d8a781 // chkeq c28, c24
	b.ne comparison_fail
	.inst 0xc2401fb8 // ldr c24, [x29, #7]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001030
	ldr x1, =check_data0
	ldr x2, =0x00001040
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000011e0
	ldr x1, =check_data1
	ldr x2, =0x000011f0
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
	ldr x0, =0x00400420
	ldr x1, =check_data3
	ldr x2, =0x00400424
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0047fffe
	ldr x1, =check_data4
	ldr x2, =0x00480000
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
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
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

.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 32
.data
check_data1:
	.byte 0x50, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x5f, 0xfc, 0x15, 0x39, 0x43, 0xfc, 0x81, 0xe2, 0x5c, 0x80, 0xc2, 0xc2, 0x68, 0x92, 0x41, 0xfa
	.byte 0xf5, 0xe3, 0xc6, 0xc2, 0x62, 0x27, 0xd2, 0x1a, 0x3f, 0x58, 0xea, 0xad, 0x89, 0x94, 0x9b, 0x3c
	.byte 0xff, 0xe4, 0x5f, 0x02, 0x41, 0xdc, 0x84, 0x62, 0xa0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1310
	/* C2 */
	.octa 0x480000005c8900640000000000001221
	/* C3 */
	.octa 0x4000000000000000000000000000
	/* C4 */
	.octa 0x1630
	/* C7 */
	.octa 0xc007c00000ffffffff840000
	/* C18 */
	.octa 0x12
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0x40000000
final_cap_values:
	/* C1 */
	.octa 0x1050
	/* C2 */
	.octa 0x1090
	/* C3 */
	.octa 0x4000000000000000000000000000
	/* C4 */
	.octa 0x15e9
	/* C7 */
	.octa 0xc007c00000ffffffff840000
	/* C18 */
	.octa 0x12
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0x40000000
	/* C28 */
	.octa 0x480000005c8900640000000000001221
initial_SP_EL3_value:
	.octa 0x3fff800000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20808000409100000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc0000005802000400ffffffffffe003
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3915fc5f // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:2 imm12:010101111111 opc:00 111001:111001 size:00
	.inst 0xe281fc43 // ASTUR-C.RI-C Ct:3 Rn:2 op2:11 imm9:000011111 V:0 op1:10 11100010:11100010
	.inst 0xc2c2805c // SCTAG-C.CR-C Cd:28 Cn:2 000:000 0:0 10:10 Rm:2 11000010110:11000010110
	.inst 0xfa419268 // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1000 0:0 Rn:19 00:00 cond:1001 Rm:1 111010010:111010010 op:1 sf:1
	.inst 0xc2c6e3f5 // SCFLGS-C.CR-C Cd:21 Cn:31 111000:111000 Rm:6 11000010110:11000010110
	.inst 0x1ad22762 // lsrv:aarch64/instrs/integer/shift/variable Rd:2 Rn:27 op2:01 0010:0010 Rm:18 0011010110:0011010110 sf:0
	.inst 0xadea583f // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:31 Rn:1 Rt2:10110 imm7:1010100 L:1 1011011:1011011 opc:10
	.inst 0x3c9b9489 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:9 Rn:4 01:01 imm9:110111001 0:0 opc:10 111100:111100 size:00
	.inst 0x025fe4ff // ADD-C.CIS-C Cd:31 Cn:7 imm12:011111111001 sh:1 A:0 00000010:00000010
	.inst 0x6284dc41 // STP-C.RIBW-C Ct:1 Rn:2 Ct2:10111 imm7:0001001 L:0 011000101:011000101
	.inst 0xc2c210a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x10, cptr_el3
	orr x10, x10, #0x200
	msr cptr_el3, x10
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
	ldr x10, =initial_cap_values
	.inst 0xc2400141 // ldr c1, [x10, #0]
	.inst 0xc2400542 // ldr c2, [x10, #1]
	.inst 0xc2400943 // ldr c3, [x10, #2]
	.inst 0xc2400d44 // ldr c4, [x10, #3]
	.inst 0xc2401147 // ldr c7, [x10, #4]
	.inst 0xc2401552 // ldr c18, [x10, #5]
	.inst 0xc2401957 // ldr c23, [x10, #6]
	.inst 0xc2401d5b // ldr c27, [x10, #7]
	/* Vector registers */
	mrs x10, cptr_el3
	bfc x10, #10, #1
	msr cptr_el3, x10
	isb
	ldr q9, =0x0
	/* Set up flags and system registers */
	mov x10, #0x20000000
	msr nzcv, x10
	ldr x10, =initial_SP_EL3_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2c1d15f // cpy c31, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30850032
	msr SCTLR_EL3, x10
	ldr x10, =0x0
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030aa // ldr c10, [c5, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x826010aa // ldr c10, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x5, #0xf
	and x10, x10, x5
	cmp x10, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400145 // ldr c5, [x10, #0]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400545 // ldr c5, [x10, #1]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400945 // ldr c5, [x10, #2]
	.inst 0xc2c5a461 // chkeq c3, c5
	b.ne comparison_fail
	.inst 0xc2400d45 // ldr c5, [x10, #3]
	.inst 0xc2c5a481 // chkeq c4, c5
	b.ne comparison_fail
	.inst 0xc2401145 // ldr c5, [x10, #4]
	.inst 0xc2c5a4e1 // chkeq c7, c5
	b.ne comparison_fail
	.inst 0xc2401545 // ldr c5, [x10, #5]
	.inst 0xc2c5a641 // chkeq c18, c5
	b.ne comparison_fail
	.inst 0xc2401945 // ldr c5, [x10, #6]
	.inst 0xc2c5a6e1 // chkeq c23, c5
	b.ne comparison_fail
	.inst 0xc2401d45 // ldr c5, [x10, #7]
	.inst 0xc2c5a761 // chkeq c27, c5
	b.ne comparison_fail
	.inst 0xc2402145 // ldr c5, [x10, #8]
	.inst 0xc2c5a781 // chkeq c28, c5
	b.ne comparison_fail
	/* Check vector registers */
	ldr x10, =0x0
	mov x5, v9.d[0]
	cmp x10, x5
	b.ne comparison_fail
	ldr x10, =0x0
	mov x5, v9.d[1]
	cmp x10, x5
	b.ne comparison_fail
	ldr x10, =0x0
	mov x5, v22.d[0]
	cmp x10, x5
	b.ne comparison_fail
	ldr x10, =0x0
	mov x5, v22.d[1]
	cmp x10, x5
	b.ne comparison_fail
	ldr x10, =0x0
	mov x5, v31.d[0]
	cmp x10, x5
	b.ne comparison_fail
	ldr x10, =0x0
	mov x5, v31.d[1]
	cmp x10, x5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001050
	ldr x1, =check_data0
	ldr x2, =0x00001070
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001090
	ldr x1, =check_data1
	ldr x2, =0x000010b0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001240
	ldr x1, =check_data2
	ldr x2, =0x00001250
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001630
	ldr x1, =check_data3
	ldr x2, =0x00001640
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000017a0
	ldr x1, =check_data4
	ldr x2, =0x000017a1
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
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
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

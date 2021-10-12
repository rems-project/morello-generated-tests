.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x30, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x02, 0xec, 0x40, 0x82, 0x61, 0xdc, 0x69, 0xb9, 0x41, 0x49, 0x3f, 0x8b, 0x48, 0xa1, 0xdf, 0xc2
	.byte 0x36, 0xd3, 0xb4, 0xe2, 0x1f, 0xe5, 0x95, 0xda, 0x24, 0x58, 0xc8, 0xc2, 0x5f, 0x44, 0x69, 0x82
	.byte 0x8d, 0x33, 0xc5, 0xc2, 0xde, 0xa7, 0x43, 0xab, 0xc0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000000007000d0000000000001000
	/* C2 */
	.octa 0x800000005002100a0000000000001030
	/* C3 */
	.octa 0xfffffffffffff000
	/* C10 */
	.octa 0x3fff800000000000000000000000
	/* C25 */
	.octa 0x4000000020050007000000000000180b
	/* C28 */
	.octa 0x1
final_cap_values:
	/* C0 */
	.octa 0x400000000007000d0000000000001000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x800000005002100a0000000000001030
	/* C3 */
	.octa 0xfffffffffffff000
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x3fff800000000000000000000000
	/* C10 */
	.octa 0x3fff800000000000000000000000
	/* C13 */
	.octa 0x1
	/* C25 */
	.octa 0x4000000020050007000000000000180b
	/* C28 */
	.octa 0x1
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000005c00180100ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x8240ec02 // ASTR-R.RI-64 Rt:2 Rn:0 op:11 imm9:000001110 L:0 1000001001:1000001001
	.inst 0xb969dc61 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:3 imm12:101001110111 opc:01 111001:111001 size:10
	.inst 0x8b3f4941 // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:1 Rn:10 imm3:010 option:010 Rm:31 01011001:01011001 S:0 op:0 sf:1
	.inst 0xc2dfa148 // CLRPERM-C.CR-C Cd:8 Cn:10 000:000 1:1 10:10 Rm:31 11000010110:11000010110
	.inst 0xe2b4d336 // ASTUR-V.RI-S Rt:22 Rn:25 op2:00 imm9:101001101 V:1 op1:10 11100010:11100010
	.inst 0xda95e51f // csneg:aarch64/instrs/integer/conditional/select Rd:31 Rn:8 o2:1 0:0 cond:1110 Rm:21 011010100:011010100 op:1 sf:1
	.inst 0xc2c85824 // ALIGNU-C.CI-C Cd:4 Cn:1 0110:0110 U:1 imm6:010000 11000010110:11000010110
	.inst 0x8269445f // ALDRB-R.RI-B Rt:31 Rn:2 op:01 imm9:010010100 L:1 1000001001:1000001001
	.inst 0xc2c5338d // CVTP-R.C-C Rd:13 Cn:28 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0xab43a7de // adds_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:30 Rn:30 imm6:101001 Rm:3 0:0 shift:01 01011:01011 S:1 op:0 sf:1
	.inst 0xc2c210c0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x11, cptr_el3
	orr x11, x11, #0x200
	msr cptr_el3, x11
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
	ldr x11, =initial_cap_values
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400562 // ldr c2, [x11, #1]
	.inst 0xc2400963 // ldr c3, [x11, #2]
	.inst 0xc2400d6a // ldr c10, [x11, #3]
	.inst 0xc2401179 // ldr c25, [x11, #4]
	.inst 0xc240157c // ldr c28, [x11, #5]
	/* Vector registers */
	mrs x11, cptr_el3
	bfc x11, #10, #1
	msr cptr_el3, x11
	isb
	ldr q22, =0x0
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	ldr x11, =0x0
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030cb // ldr c11, [c6, #3]
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	.inst 0x826010cb // ldr c11, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400166 // ldr c6, [x11, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400566 // ldr c6, [x11, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400966 // ldr c6, [x11, #2]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400d66 // ldr c6, [x11, #3]
	.inst 0xc2c6a461 // chkeq c3, c6
	b.ne comparison_fail
	.inst 0xc2401166 // ldr c6, [x11, #4]
	.inst 0xc2c6a481 // chkeq c4, c6
	b.ne comparison_fail
	.inst 0xc2401566 // ldr c6, [x11, #5]
	.inst 0xc2c6a501 // chkeq c8, c6
	b.ne comparison_fail
	.inst 0xc2401966 // ldr c6, [x11, #6]
	.inst 0xc2c6a541 // chkeq c10, c6
	b.ne comparison_fail
	.inst 0xc2401d66 // ldr c6, [x11, #7]
	.inst 0xc2c6a5a1 // chkeq c13, c6
	b.ne comparison_fail
	.inst 0xc2402166 // ldr c6, [x11, #8]
	.inst 0xc2c6a721 // chkeq c25, c6
	b.ne comparison_fail
	.inst 0xc2402566 // ldr c6, [x11, #9]
	.inst 0xc2c6a781 // chkeq c28, c6
	b.ne comparison_fail
	/* Check vector registers */
	ldr x11, =0x0
	mov x6, v22.d[0]
	cmp x11, x6
	b.ne comparison_fail
	ldr x11, =0x0
	mov x6, v22.d[1]
	cmp x11, x6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001070
	ldr x1, =check_data0
	ldr x2, =0x00001078
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010c4
	ldr x1, =check_data1
	ldr x2, =0x000010c5
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001758
	ldr x1, =check_data2
	ldr x2, =0x0000175c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000019dc
	ldr x1, =check_data3
	ldr x2, =0x000019e0
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
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

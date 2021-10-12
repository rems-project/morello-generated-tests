.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0xeb, 0x73, 0xc0, 0xc2, 0x39, 0xe0, 0xbc, 0x9b, 0x8b, 0xc1, 0x5f, 0x3a, 0x16, 0x44, 0xde, 0xc2
	.byte 0xf9, 0xa5, 0x52, 0xb8, 0xc0, 0xf3, 0x3f, 0x4b, 0x46, 0xb0, 0x54, 0xe2, 0x5e, 0x2c, 0xdf, 0x9a
	.byte 0x34, 0x10, 0xc5, 0xc2, 0x5f, 0xaa, 0x0a, 0x78, 0x00, 0x12, 0xc2, 0xc2
.data
check_data3:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000000000000000000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x400000000005000700000000000018b1
	/* C6 */
	.octa 0x0
	/* C15 */
	.octa 0x4abff8
	/* C18 */
	.octa 0x1f52
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x400000000005000700000000000018b1
	/* C6 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0x4abf22
	/* C18 */
	.octa 0x1f52
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0x800000000000000000000000
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0x18b1
initial_SP_EL3_value:
	.octa 0x300070000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c073eb // GCOFF-R.C-C Rd:11 Cn:31 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0x9bbce039 // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:25 Rn:1 Ra:24 o0:1 Rm:28 01:01 U:1 10011011:10011011
	.inst 0x3a5fc18b // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1011 0:0 Rn:12 00:00 cond:1100 Rm:31 111010010:111010010 op:0 sf:0
	.inst 0xc2de4416 // CSEAL-C.C-C Cd:22 Cn:0 001:001 opc:10 0:0 Cm:30 11000010110:11000010110
	.inst 0xb852a5f9 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:25 Rn:15 01:01 imm9:100101010 0:0 opc:01 111000:111000 size:10
	.inst 0x4b3ff3c0 // sub_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:0 Rn:30 imm3:100 option:111 Rm:31 01011001:01011001 S:0 op:1 sf:0
	.inst 0xe254b046 // ASTURH-R.RI-32 Rt:6 Rn:2 op2:00 imm9:101001011 V:0 op1:01 11100010:11100010
	.inst 0x9adf2c5e // rorv:aarch64/instrs/integer/shift/variable Rd:30 Rn:2 op2:11 0010:0010 Rm:31 0011010110:0011010110 sf:1
	.inst 0xc2c51034 // CVTD-R.C-C Rd:20 Cn:1 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0x780aaa5f // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:18 10:10 imm9:010101010 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c21200
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x5, cptr_el3
	orr x5, x5, #0x200
	msr cptr_el3, x5
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004a1 // ldr c1, [x5, #1]
	.inst 0xc24008a2 // ldr c2, [x5, #2]
	.inst 0xc2400ca6 // ldr c6, [x5, #3]
	.inst 0xc24010af // ldr c15, [x5, #4]
	.inst 0xc24014b2 // ldr c18, [x5, #5]
	.inst 0xc24018be // ldr c30, [x5, #6]
	/* Set up flags and system registers */
	mov x5, #0x80000000
	msr nzcv, x5
	ldr x5, =initial_SP_EL3_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2c1d0bf // cpy c31, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30850032
	msr SCTLR_EL3, x5
	ldr x5, =0x0
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82603205 // ldr c5, [c16, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x82601205 // ldr c5, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	/* Check processor flags */
	mrs x5, nzcv
	ubfx x5, x5, #28, #4
	mov x16, #0xf
	and x5, x5, x16
	cmp x5, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000b0 // ldr c16, [x5, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc24004b0 // ldr c16, [x5, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc24008b0 // ldr c16, [x5, #2]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400cb0 // ldr c16, [x5, #3]
	.inst 0xc2d0a4c1 // chkeq c6, c16
	b.ne comparison_fail
	.inst 0xc24010b0 // ldr c16, [x5, #4]
	.inst 0xc2d0a561 // chkeq c11, c16
	b.ne comparison_fail
	.inst 0xc24014b0 // ldr c16, [x5, #5]
	.inst 0xc2d0a5e1 // chkeq c15, c16
	b.ne comparison_fail
	.inst 0xc24018b0 // ldr c16, [x5, #6]
	.inst 0xc2d0a641 // chkeq c18, c16
	b.ne comparison_fail
	.inst 0xc2401cb0 // ldr c16, [x5, #7]
	.inst 0xc2d0a681 // chkeq c20, c16
	b.ne comparison_fail
	.inst 0xc24020b0 // ldr c16, [x5, #8]
	.inst 0xc2d0a6c1 // chkeq c22, c16
	b.ne comparison_fail
	.inst 0xc24024b0 // ldr c16, [x5, #9]
	.inst 0xc2d0a721 // chkeq c25, c16
	b.ne comparison_fail
	.inst 0xc24028b0 // ldr c16, [x5, #10]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000017fc
	ldr x1, =check_data0
	ldr x2, =0x000017fe
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffc
	ldr x1, =check_data1
	ldr x2, =0x00001ffe
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
	ldr x0, =0x004abff8
	ldr x1, =check_data3
	ldr x2, =0x004abffc
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
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
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

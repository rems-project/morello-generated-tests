.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0xc2, 0x53, 0xc2, 0xc2, 0xf3, 0x07, 0xe9, 0xe2, 0x35, 0x5a, 0x0b, 0x79, 0x5f, 0x16, 0xa3, 0x6d
	.byte 0x62, 0xfd, 0x7f, 0x42, 0x40, 0x66, 0x4f, 0x38, 0x22, 0x29, 0xc1, 0xc2, 0x3d, 0x52, 0x22, 0x0a
	.byte 0xfa, 0x6d, 0x13, 0x9b, 0x20, 0xf0, 0xc0, 0xc2, 0x80, 0x12, 0xc2, 0xc2
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C9 */
	.octa 0x3fff800000000000000000000000
	/* C11 */
	.octa 0x400d50
	/* C17 */
	.octa 0x400000001000c0080000000000001008
	/* C18 */
	.octa 0xc0000000000100060000000000002038
	/* C21 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000900794bf0000000000400005
final_cap_values:
	/* C2 */
	.octa 0x3fff800000000000000000000000
	/* C9 */
	.octa 0x3fff800000000000000000000000
	/* C11 */
	.octa 0x400d50
	/* C17 */
	.octa 0x400000001000c0080000000000001008
	/* C18 */
	.octa 0xc0000000000100060000000000001f5e
	/* C21 */
	.octa 0x0
	/* C29 */
	.octa 0x1008
	/* C30 */
	.octa 0x20008000900794bf0000000000400005
initial_SP_EL3_value:
	.octa 0x400000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000007c0090000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000600040000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c253c2 // RETS-C-C 00010:00010 Cn:30 100:100 opc:10 11000010110000100:11000010110000100
	.inst 0xe2e907f3 // ALDUR-V.RI-D Rt:19 Rn:31 op2:01 imm9:010010000 V:1 op1:11 11100010:11100010
	.inst 0x790b5a35 // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:21 Rn:17 imm12:001011010110 opc:00 111001:111001 size:01
	.inst 0x6da3165f // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:31 Rn:18 Rt2:00101 imm7:1000110 L:0 1011011:1011011 opc:01
	.inst 0x427ffd62 // ALDAR-R.R-32 Rt:2 Rn:11 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x384f6640 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:18 01:01 imm9:011110110 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c12922 // BICFLGS-C.CR-C Cd:2 Cn:9 1010:1010 opc:00 Rm:1 11000010110:11000010110
	.inst 0x0a22523d // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:29 Rn:17 imm6:010100 Rm:2 N:1 shift:00 01010:01010 opc:00 sf:0
	.inst 0x9b136dfa // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:26 Rn:15 Ra:27 o0:0 Rm:19 0011011000:0011011000 sf:1
	.inst 0xc2c0f020 // GCTYPE-R.C-C Rd:0 Cn:1 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xc2c21280
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x14, cptr_el3
	orr x14, x14, #0x200
	msr cptr_el3, x14
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c9 // ldr c9, [x14, #0]
	.inst 0xc24005cb // ldr c11, [x14, #1]
	.inst 0xc24009d1 // ldr c17, [x14, #2]
	.inst 0xc2400dd2 // ldr c18, [x14, #3]
	.inst 0xc24011d5 // ldr c21, [x14, #4]
	.inst 0xc24015de // ldr c30, [x14, #5]
	/* Vector registers */
	mrs x14, cptr_el3
	bfc x14, #10, #1
	msr cptr_el3, x14
	isb
	ldr q5, =0x0
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =initial_SP_EL3_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2c1d1df // cpy c31, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30850032
	msr SCTLR_EL3, x14
	ldr x14, =0x4
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x8260328e // ldr c14, [c20, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x8260128e // ldr c14, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001d4 // ldr c20, [x14, #0]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc24005d4 // ldr c20, [x14, #1]
	.inst 0xc2d4a521 // chkeq c9, c20
	b.ne comparison_fail
	.inst 0xc24009d4 // ldr c20, [x14, #2]
	.inst 0xc2d4a561 // chkeq c11, c20
	b.ne comparison_fail
	.inst 0xc2400dd4 // ldr c20, [x14, #3]
	.inst 0xc2d4a621 // chkeq c17, c20
	b.ne comparison_fail
	.inst 0xc24011d4 // ldr c20, [x14, #4]
	.inst 0xc2d4a641 // chkeq c18, c20
	b.ne comparison_fail
	.inst 0xc24015d4 // ldr c20, [x14, #5]
	.inst 0xc2d4a6a1 // chkeq c21, c20
	b.ne comparison_fail
	.inst 0xc24019d4 // ldr c20, [x14, #6]
	.inst 0xc2d4a7a1 // chkeq c29, c20
	b.ne comparison_fail
	.inst 0xc2401dd4 // ldr c20, [x14, #7]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0x0
	mov x20, v5.d[0]
	cmp x14, x20
	b.ne comparison_fail
	ldr x14, =0x0
	mov x20, v5.d[1]
	cmp x14, x20
	b.ne comparison_fail
	ldr x14, =0x0
	mov x20, v19.d[0]
	cmp x14, x20
	b.ne comparison_fail
	ldr x14, =0x0
	mov x20, v19.d[1]
	cmp x14, x20
	b.ne comparison_fail
	ldr x14, =0x0
	mov x20, v31.d[0]
	cmp x14, x20
	b.ne comparison_fail
	ldr x14, =0x0
	mov x20, v31.d[1]
	cmp x14, x20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000015b4
	ldr x1, =check_data0
	ldr x2, =0x000015b6
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001e68
	ldr x1, =check_data1
	ldr x2, =0x00001e78
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
	ldr x0, =0x00400090
	ldr x1, =check_data3
	ldr x2, =0x00400098
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400d50
	ldr x1, =check_data4
	ldr x2, =0x00400d54
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
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
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

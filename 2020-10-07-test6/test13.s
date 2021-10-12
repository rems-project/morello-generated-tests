.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x20, 0x30, 0xc5, 0xc2, 0x3f, 0x10, 0xc2, 0x2a, 0xbf, 0xfe, 0x01, 0xe2, 0x0b, 0x80, 0xc1, 0xc2
	.byte 0x50, 0xfb, 0x28, 0x35
.data
check_data3:
	.byte 0x5f, 0x3b, 0x03, 0xd5, 0xbe, 0x47, 0x95, 0x38, 0x5f, 0x14, 0x0c, 0x7c, 0x5f, 0xf0, 0xc0, 0xc2
	.byte 0x4c, 0x48, 0xde, 0xc2, 0x40, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x40000000000100050000000000001ffc
	/* C16 */
	.octa 0xffffffff
	/* C21 */
	.octa 0x1000
	/* C29 */
	.octa 0x800000000001000700000000004ffefe
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x400000000001000500000000000020bd
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x400000000001000500000000000020bd
	/* C16 */
	.octa 0xffffffff
	/* C21 */
	.octa 0x1000
	/* C29 */
	.octa 0x800000000001000700000000004ffe52
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001e0740000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000200010000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c53020 // CVTP-R.C-C Rd:0 Cn:1 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0x2ac2103f // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:1 imm6:000100 Rm:2 N:0 shift:11 01010:01010 opc:01 sf:0
	.inst 0xe201febf // ALDURSB-R.RI-32 Rt:31 Rn:21 op2:11 imm9:000011111 V:0 op1:00 11100010:11100010
	.inst 0xc2c1800b // SCTAG-C.CR-C Cd:11 Cn:0 000:000 0:0 10:10 Rm:1 11000010110:11000010110
	.inst 0x3528fb50 // cbnz:aarch64/instrs/branch/conditional/compare Rt:16 imm19:0010100011111011010 op:1 011010:011010 sf:0
	.zero 335716
	.inst 0xd5033b5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1011 11010101000000110011:11010101000000110011
	.inst 0x389547be // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:29 01:01 imm9:101010100 0:0 opc:10 111000:111000 size:00
	.inst 0x7c0c145f // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:31 Rn:2 01:01 imm9:011000001 0:0 opc:00 111100:111100 size:01
	.inst 0xc2c0f05f // GCTYPE-R.C-C Rd:31 Cn:2 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xc2de484c // UNSEAL-C.CC-C Cd:12 Cn:2 0010:0010 opc:01 Cm:30 11000010110:11000010110
	.inst 0xc2c21240
	.zero 712816
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
	.inst 0xc24001c1 // ldr c1, [x14, #0]
	.inst 0xc24005c2 // ldr c2, [x14, #1]
	.inst 0xc24009d0 // ldr c16, [x14, #2]
	.inst 0xc2400dd5 // ldr c21, [x14, #3]
	.inst 0xc24011dd // ldr c29, [x14, #4]
	/* Vector registers */
	mrs x14, cptr_el3
	bfc x14, #10, #1
	msr cptr_el3, x14
	isb
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30850032
	msr SCTLR_EL3, x14
	ldr x14, =0x4
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x8260324e // ldr c14, [c18, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x8260124e // ldr c14, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x18, #0xf
	and x14, x14, x18
	cmp x14, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001d2 // ldr c18, [x14, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc24005d2 // ldr c18, [x14, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc24009d2 // ldr c18, [x14, #2]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400dd2 // ldr c18, [x14, #3]
	.inst 0xc2d2a561 // chkeq c11, c18
	b.ne comparison_fail
	.inst 0xc24011d2 // ldr c18, [x14, #4]
	.inst 0xc2d2a581 // chkeq c12, c18
	b.ne comparison_fail
	.inst 0xc24015d2 // ldr c18, [x14, #5]
	.inst 0xc2d2a601 // chkeq c16, c18
	b.ne comparison_fail
	.inst 0xc24019d2 // ldr c18, [x14, #6]
	.inst 0xc2d2a6a1 // chkeq c21, c18
	b.ne comparison_fail
	.inst 0xc2401dd2 // ldr c18, [x14, #7]
	.inst 0xc2d2a7a1 // chkeq c29, c18
	b.ne comparison_fail
	.inst 0xc24021d2 // ldr c18, [x14, #8]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0x0
	mov x18, v31.d[0]
	cmp x14, x18
	b.ne comparison_fail
	ldr x14, =0x0
	mov x18, v31.d[1]
	cmp x14, x18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000101f
	ldr x1, =check_data0
	ldr x2, =0x00001020
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
	ldr x2, =0x00400014
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00451f78
	ldr x1, =check_data3
	ldr x2, =0x00451f90
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004ffefe
	ldr x1, =check_data4
	ldr x2, =0x004ffeff
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

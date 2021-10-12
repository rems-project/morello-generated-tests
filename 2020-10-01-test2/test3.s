.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x02, 0x10
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0x02, 0x43, 0xde, 0xc2, 0xeb, 0x91, 0xc0, 0xc2, 0x20, 0x89, 0x81, 0x34, 0x02, 0x20, 0x50, 0xe2
	.byte 0xda, 0x1d, 0xc5, 0x78, 0xc0, 0xbf, 0x0e, 0x38, 0x89, 0x7f, 0x80, 0x82, 0x3f, 0xfc, 0xc2, 0xe2
	.byte 0xe2, 0xfb, 0xe2, 0x3c, 0x9a, 0x57, 0x89, 0x9a, 0x60, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2000
	/* C1 */
	.octa 0x1f11
	/* C9 */
	.octa 0x0
	/* C14 */
	.octa 0x800000004007000100000000003fffb1
	/* C15 */
	.octa 0x0
	/* C24 */
	.octa 0x4002004e0000000000010001
	/* C28 */
	.octa 0xffffffffffffd000
	/* C30 */
	.octa 0x40000000000180060000000000001002
final_cap_values:
	/* C0 */
	.octa 0x2000
	/* C1 */
	.octa 0x1f11
	/* C2 */
	.octa 0x4002004e0000000000001002
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x1
	/* C14 */
	.octa 0x80000000400700010000000000400002
	/* C15 */
	.octa 0x0
	/* C24 */
	.octa 0x4002004e0000000000010001
	/* C26 */
	.octa 0x1
	/* C28 */
	.octa 0xffffffffffffd000
	/* C30 */
	.octa 0x400000000001800600000000000010ed
initial_csp_value:
	.octa 0x8000000000010005ffffffffffff10d0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000180060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000600200000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001f40
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 112
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 160
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2de4302 // SCVALUE-C.CR-C Cd:2 Cn:24 000:000 opc:10 0:0 Rm:30 11000010110:11000010110
	.inst 0xc2c091eb // GCTAG-R.C-C Rd:11 Cn:15 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0x34818920 // cbz:aarch64/instrs/branch/conditional/compare Rt:0 imm19:1000000110001001001 op:0 011010:011010 sf:0
	.inst 0xe2502002 // ASTURH-R.RI-32 Rt:2 Rn:0 op2:00 imm9:100000010 V:0 op1:01 11100010:11100010
	.inst 0x78c51dda // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:26 Rn:14 11:11 imm9:001010001 0:0 opc:11 111000:111000 size:01
	.inst 0x380ebfc0 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:30 11:11 imm9:011101011 0:0 opc:00 111000:111000 size:00
	.inst 0x82807f89 // ASTRH-R.RRB-32 Rt:9 Rn:28 opc:11 S:1 option:011 Rm:0 0:0 L:0 100000101:100000101
	.inst 0xe2c2fc3f // ALDUR-C.RI-C Ct:31 Rn:1 op2:11 imm9:000101111 V:0 op1:11 11100010:11100010
	.inst 0x3ce2fbe2 // ldr_reg_fpsimd:aarch64/instrs/memory/single/simdfp/register Rt:2 Rn:31 10:10 S:1 option:111 Rm:2 1:1 opc:11 111100:111100 size:00
	.inst 0x9a89579a // csinc:aarch64/instrs/integer/conditional/select Rd:26 Rn:28 o2:1 0:0 cond:0101 Rm:9 011010100:011010100 op:0 sf:1
	.inst 0xc2c21360
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
	ldr x10, =initial_cap_values
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400541 // ldr c1, [x10, #1]
	.inst 0xc2400949 // ldr c9, [x10, #2]
	.inst 0xc2400d4e // ldr c14, [x10, #3]
	.inst 0xc240114f // ldr c15, [x10, #4]
	.inst 0xc2401558 // ldr c24, [x10, #5]
	.inst 0xc240195c // ldr c28, [x10, #6]
	.inst 0xc2401d5e // ldr c30, [x10, #7]
	/* Set up flags and system registers */
	mov x10, #0x80000000
	msr nzcv, x10
	ldr x10, =initial_csp_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2c1d15f // cpy c31, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30850032
	msr SCTLR_EL3, x10
	ldr x10, =0x4
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x8260336a // ldr c10, [c27, #3]
	.inst 0xc28b412a // msr ddc_el3, c10
	isb
	.inst 0x8260136a // ldr c10, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr ddc_el3, c10
	isb
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x27, #0x8
	and x10, x10, x27
	cmp x10, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc240015b // ldr c27, [x10, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240055b // ldr c27, [x10, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc240095b // ldr c27, [x10, #2]
	.inst 0xc2dba441 // chkeq c2, c27
	b.ne comparison_fail
	.inst 0xc2400d5b // ldr c27, [x10, #3]
	.inst 0xc2dba521 // chkeq c9, c27
	b.ne comparison_fail
	.inst 0xc240115b // ldr c27, [x10, #4]
	.inst 0xc2dba561 // chkeq c11, c27
	b.ne comparison_fail
	.inst 0xc240155b // ldr c27, [x10, #5]
	.inst 0xc2dba5c1 // chkeq c14, c27
	b.ne comparison_fail
	.inst 0xc240195b // ldr c27, [x10, #6]
	.inst 0xc2dba5e1 // chkeq c15, c27
	b.ne comparison_fail
	.inst 0xc2401d5b // ldr c27, [x10, #7]
	.inst 0xc2dba701 // chkeq c24, c27
	b.ne comparison_fail
	.inst 0xc240215b // ldr c27, [x10, #8]
	.inst 0xc2dba741 // chkeq c26, c27
	b.ne comparison_fail
	.inst 0xc240255b // ldr c27, [x10, #9]
	.inst 0xc2dba781 // chkeq c28, c27
	b.ne comparison_fail
	.inst 0xc240295b // ldr c27, [x10, #10]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x10, =0x0
	mov x27, v2.d[0]
	cmp x10, x27
	b.ne comparison_fail
	ldr x10, =0x0
	mov x27, v2.d[1]
	cmp x10, x27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010ed
	ldr x1, =check_data1
	ldr x2, =0x000010ee
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010f0
	ldr x1, =check_data2
	ldr x2, =0x00001100
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f02
	ldr x1, =check_data3
	ldr x2, =0x00001f04
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f40
	ldr x1, =check_data4
	ldr x2, =0x00001f50
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
	.inst 0xc28b412a // msr ddc_el3, c10
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

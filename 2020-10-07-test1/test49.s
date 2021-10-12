.section data0, #alloc, #write
	.byte 0x20, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 4080
.data
check_data0:
	.byte 0x20, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x1b, 0x30, 0xc5, 0xc2, 0xea, 0x73, 0x63, 0x71, 0x41, 0xd0, 0x2c, 0xd1, 0xc2, 0x2b, 0xc1, 0xc2
	.byte 0x20, 0x70, 0xc6, 0xc2, 0x64, 0xa4, 0x68, 0xe2, 0x88, 0x77, 0xdf, 0x82, 0x60, 0x52, 0xdd, 0xc2
	.byte 0xcc, 0x47, 0x0e, 0x78, 0x40, 0x02, 0x5f, 0xd6
.data
check_data3:
	.byte 0xc0, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C3 */
	.octa 0x1f72
	/* C12 */
	.octa 0x0
	/* C18 */
	.octa 0x400080
	/* C19 */
	.octa 0x90000000000100050000000000001160
	/* C28 */
	.octa 0x4ffffe
	/* C30 */
	.octa 0x800000000000000000001ffc
final_cap_values:
	/* C2 */
	.octa 0x800000000000000000001ffc
	/* C3 */
	.octa 0x1f72
	/* C8 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C18 */
	.octa 0x400080
	/* C19 */
	.octa 0x90000000000100050000000000001160
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x4ffffe
	/* C30 */
	.octa 0x20e0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c5301b // CVTP-R.C-C Rd:27 Cn:0 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0x716373ea // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:10 Rn:31 imm12:100011011100 sh:1 0:0 10001:10001 S:1 op:1 sf:0
	.inst 0xd12cd041 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:1 Rn:2 imm12:101100110100 sh:0 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0xc2c12bc2 // BICFLGS-C.CR-C Cd:2 Cn:30 1010:1010 opc:00 Rm:1 11000010110:11000010110
	.inst 0xc2c67020 // CLRPERM-C.CI-C Cd:0 Cn:1 100:100 perm:011 1100001011000110:1100001011000110
	.inst 0xe268a464 // ALDUR-V.RI-H Rt:4 Rn:3 op2:01 imm9:010001010 V:1 op1:01 11100010:11100010
	.inst 0x82df7788 // ALDRSB-R.RRB-32 Rt:8 Rn:28 opc:01 S:1 option:011 Rm:31 0:0 L:1 100000101:100000101
	.inst 0xc2dd5260 // BR-CI-C 0:0 0000:0000 Cn:19 100:100 imm7:1101010 110000101101:110000101101
	.inst 0x780e47cc // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:12 Rn:30 01:01 imm9:011100100 0:0 opc:00 111000:111000 size:01
	.inst 0xd65f0240 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:18 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 88
	.inst 0xc2c212c0
	.zero 1048444
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
	.inst 0xc2400563 // ldr c3, [x11, #1]
	.inst 0xc240096c // ldr c12, [x11, #2]
	.inst 0xc2400d72 // ldr c18, [x11, #3]
	.inst 0xc2401173 // ldr c19, [x11, #4]
	.inst 0xc240157c // ldr c28, [x11, #5]
	.inst 0xc240197e // ldr c30, [x11, #6]
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
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032cb // ldr c11, [c22, #3]
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	.inst 0x826012cb // ldr c11, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
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
	.inst 0xc2400176 // ldr c22, [x11, #0]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400576 // ldr c22, [x11, #1]
	.inst 0xc2d6a461 // chkeq c3, c22
	b.ne comparison_fail
	.inst 0xc2400976 // ldr c22, [x11, #2]
	.inst 0xc2d6a501 // chkeq c8, c22
	b.ne comparison_fail
	.inst 0xc2400d76 // ldr c22, [x11, #3]
	.inst 0xc2d6a581 // chkeq c12, c22
	b.ne comparison_fail
	.inst 0xc2401176 // ldr c22, [x11, #4]
	.inst 0xc2d6a641 // chkeq c18, c22
	b.ne comparison_fail
	.inst 0xc2401576 // ldr c22, [x11, #5]
	.inst 0xc2d6a661 // chkeq c19, c22
	b.ne comparison_fail
	.inst 0xc2401976 // ldr c22, [x11, #6]
	.inst 0xc2d6a761 // chkeq c27, c22
	b.ne comparison_fail
	.inst 0xc2401d76 // ldr c22, [x11, #7]
	.inst 0xc2d6a781 // chkeq c28, c22
	b.ne comparison_fail
	.inst 0xc2402176 // ldr c22, [x11, #8]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x11, =0x0
	mov x22, v4.d[0]
	cmp x11, x22
	b.ne comparison_fail
	ldr x11, =0x0
	mov x22, v4.d[1]
	cmp x11, x22
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
	ldr x2, =0x00400028
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400080
	ldr x1, =check_data3
	ldr x2, =0x00400084
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004ffffe
	ldr x1, =check_data4
	ldr x2, =0x004fffff
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

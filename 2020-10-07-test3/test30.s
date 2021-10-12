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
	.zero 1
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xc2, 0xc7, 0x1a, 0x38, 0xff, 0xa2, 0x68, 0x82, 0x22, 0xac, 0xc2, 0xe2, 0xde, 0xa7, 0x99, 0x9a
	.byte 0xc6, 0xc7, 0x83, 0x82, 0x01, 0x0c, 0xc7, 0x1a, 0x60, 0x01, 0x1f, 0x7a, 0x1f, 0x58, 0xdb, 0xc2
	.byte 0x56, 0xf3, 0x25, 0xf0, 0xe0, 0xa3, 0x82, 0xda, 0x80, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1006
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0xfffff544
	/* C7 */
	.octa 0x0
	/* C11 */
	.octa 0x4
	/* C23 */
	.octa 0x800
	/* C30 */
	.octa 0x40000000000100070000000000001f0e
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0xfffff544
	/* C6 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C11 */
	.octa 0x4
	/* C22 */
	.octa 0x800000000003000600ffc0004be6b000
	/* C23 */
	.octa 0x800
	/* C30 */
	.octa 0x1eba
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080003006200f0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000003000600ffc00000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001030
	.dword initial_cap_values + 96
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x381ac7c2 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:2 Rn:30 01:01 imm9:110101100 0:0 opc:00 111000:111000 size:00
	.inst 0x8268a2ff // ALDR-C.RI-C Ct:31 Rn:23 op:00 imm9:010001010 L:1 1000001001:1000001001
	.inst 0xe2c2ac22 // ALDUR-C.RI-C Ct:2 Rn:1 op2:11 imm9:000101010 V:0 op1:11 11100010:11100010
	.inst 0x9a99a7de // csinc:aarch64/instrs/integer/conditional/select Rd:30 Rn:30 o2:1 0:0 cond:1010 Rm:25 011010100:011010100 op:0 sf:1
	.inst 0x8283c7c6 // ALDRSB-R.RRB-64 Rt:6 Rn:30 opc:01 S:0 option:110 Rm:3 0:0 L:0 100000101:100000101
	.inst 0x1ac70c01 // sdiv:aarch64/instrs/integer/arithmetic/div Rd:1 Rn:0 o1:1 00001:00001 Rm:7 0011010110:0011010110 sf:0
	.inst 0x7a1f0160 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:0 Rn:11 000000:000000 Rm:31 11010000:11010000 S:1 op:1 sf:0
	.inst 0xc2db581f // ALIGNU-C.CI-C Cd:31 Cn:0 0110:0110 U:1 imm6:110110 11000010110:11000010110
	.inst 0xf025f356 // ADRP-C.I-C Rd:22 immhi:010010111110011010 P:0 10000:10000 immlo:11 op:1
	.inst 0xda82a3e0 // csinv:aarch64/instrs/integer/conditional/select Rd:0 Rn:31 o2:0 0:0 cond:1010 Rm:2 011010100:011010100 op:1 sf:1
	.inst 0xc2c21080
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x19, cptr_el3
	orr x19, x19, #0x200
	msr cptr_el3, x19
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
	ldr x19, =initial_cap_values
	.inst 0xc2400261 // ldr c1, [x19, #0]
	.inst 0xc2400662 // ldr c2, [x19, #1]
	.inst 0xc2400a63 // ldr c3, [x19, #2]
	.inst 0xc2400e67 // ldr c7, [x19, #3]
	.inst 0xc240126b // ldr c11, [x19, #4]
	.inst 0xc2401677 // ldr c23, [x19, #5]
	.inst 0xc2401a7e // ldr c30, [x19, #6]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30850032
	msr SCTLR_EL3, x19
	ldr x19, =0x0
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82603093 // ldr c19, [c4, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x82601093 // ldr c19, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x4, #0xf
	and x19, x19, x4
	cmp x19, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400264 // ldr c4, [x19, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc2400664 // ldr c4, [x19, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400a64 // ldr c4, [x19, #2]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc2400e64 // ldr c4, [x19, #3]
	.inst 0xc2c4a461 // chkeq c3, c4
	b.ne comparison_fail
	.inst 0xc2401264 // ldr c4, [x19, #4]
	.inst 0xc2c4a4c1 // chkeq c6, c4
	b.ne comparison_fail
	.inst 0xc2401664 // ldr c4, [x19, #5]
	.inst 0xc2c4a4e1 // chkeq c7, c4
	b.ne comparison_fail
	.inst 0xc2401a64 // ldr c4, [x19, #6]
	.inst 0xc2c4a561 // chkeq c11, c4
	b.ne comparison_fail
	.inst 0xc2401e64 // ldr c4, [x19, #7]
	.inst 0xc2c4a6c1 // chkeq c22, c4
	b.ne comparison_fail
	.inst 0xc2402264 // ldr c4, [x19, #8]
	.inst 0xc2c4a6e1 // chkeq c23, c4
	b.ne comparison_fail
	.inst 0xc2402664 // ldr c4, [x19, #9]
	.inst 0xc2c4a7c1 // chkeq c30, c4
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
	ldr x0, =0x000010a0
	ldr x1, =check_data1
	ldr x2, =0x000010b0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000013fe
	ldr x1, =check_data2
	ldr x2, =0x000013ff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f0e
	ldr x1, =check_data3
	ldr x2, =0x00001f0f
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
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
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

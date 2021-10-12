.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0x42, 0x80, 0xd2, 0xe2, 0xbf, 0x67, 0x96, 0xd8, 0x80, 0x03, 0x3f, 0xd6
.data
check_data5:
	.byte 0xc0, 0x09, 0x47, 0x8a, 0xbe, 0xf6, 0x00, 0x6d, 0xc1, 0x54, 0x56, 0x82, 0xe0, 0x73, 0xc2, 0xc2
	.byte 0x10, 0x50, 0x83, 0xe2, 0x5f, 0x7e, 0xce, 0x38, 0x5f, 0x34, 0x84, 0x5a, 0xc0, 0x12, 0xc2, 0xc2
.data
check_data6:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x400000004004080a0000000000001100
	/* C6 */
	.octa 0x40000000580008020000000000001004
	/* C7 */
	.octa 0x65fc
	/* C14 */
	.octa 0x17ff
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x8000000040000001000000000048ff1a
	/* C21 */
	.octa 0x1850
	/* C28 */
	.octa 0x401ffc
final_cap_values:
	/* C0 */
	.octa 0x117f
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x400000004004080a0000000000001100
	/* C6 */
	.octa 0x40000000580008020000000000001004
	/* C7 */
	.octa 0x65fc
	/* C14 */
	.octa 0x17ff
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x80000000400000010000000000490001
	/* C21 */
	.octa 0x1850
	/* C28 */
	.octa 0x401ffc
	/* C30 */
	.octa 0x40000c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000500030000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000000007002a00fffffffffc0001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2d28042 // ASTUR-R.RI-64 Rt:2 Rn:2 op2:00 imm9:100101000 V:0 op1:11 11100010:11100010
	.inst 0xd89667bf // prfm_lit:aarch64/instrs/memory/literal/general Rt:31 imm19:1001011001100111101 011000:011000 opc:11
	.inst 0xd63f0380 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:28 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 8176
	.inst 0x8a4709c0 // and_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:0 Rn:14 imm6:000010 Rm:7 N:0 shift:01 01010:01010 opc:00 sf:1
	.inst 0x6d00f6be // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:30 Rn:21 Rt2:11101 imm7:0000001 L:0 1011010:1011010 opc:01
	.inst 0x825654c1 // ASTRB-R.RI-B Rt:1 Rn:6 op:01 imm9:101100101 L:0 1000001001:1000001001
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xe2835010 // ASTUR-R.RI-32 Rt:16 Rn:0 op2:00 imm9:000110101 V:0 op1:10 11100010:11100010
	.inst 0x38ce7e5f // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:18 11:11 imm9:011100111 0:0 opc:11 111000:111000 size:00
	.inst 0x5a84345f // csneg:aarch64/instrs/integer/conditional/select Rd:31 Rn:2 o2:1 0:0 cond:0011 Rm:4 011010100:011010100 op:1 sf:0
	.inst 0xc2c212c0
	.zero 1040356
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x23, cptr_el3
	orr x23, x23, #0x200
	msr cptr_el3, x23
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e1 // ldr c1, [x23, #0]
	.inst 0xc24006e2 // ldr c2, [x23, #1]
	.inst 0xc2400ae6 // ldr c6, [x23, #2]
	.inst 0xc2400ee7 // ldr c7, [x23, #3]
	.inst 0xc24012ee // ldr c14, [x23, #4]
	.inst 0xc24016f0 // ldr c16, [x23, #5]
	.inst 0xc2401af2 // ldr c18, [x23, #6]
	.inst 0xc2401ef5 // ldr c21, [x23, #7]
	.inst 0xc24022fc // ldr c28, [x23, #8]
	/* Vector registers */
	mrs x23, cptr_el3
	bfc x23, #10, #1
	msr cptr_el3, x23
	isb
	ldr q29, =0x0
	ldr q30, =0x0
	/* Set up flags and system registers */
	mov x23, #0x00000000
	msr nzcv, x23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	ldr x23, =0x0
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032d7 // ldr c23, [c22, #3]
	.inst 0xc28b4137 // msr ddc_el3, c23
	isb
	.inst 0x826012d7 // ldr c23, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c212e0 // br c23
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr ddc_el3, c23
	isb
	/* Check processor flags */
	mrs x23, nzcv
	ubfx x23, x23, #28, #4
	mov x22, #0x2
	and x23, x23, x22
	cmp x23, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002f6 // ldr c22, [x23, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc24006f6 // ldr c22, [x23, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400af6 // ldr c22, [x23, #2]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400ef6 // ldr c22, [x23, #3]
	.inst 0xc2d6a4c1 // chkeq c6, c22
	b.ne comparison_fail
	.inst 0xc24012f6 // ldr c22, [x23, #4]
	.inst 0xc2d6a4e1 // chkeq c7, c22
	b.ne comparison_fail
	.inst 0xc24016f6 // ldr c22, [x23, #5]
	.inst 0xc2d6a5c1 // chkeq c14, c22
	b.ne comparison_fail
	.inst 0xc2401af6 // ldr c22, [x23, #6]
	.inst 0xc2d6a601 // chkeq c16, c22
	b.ne comparison_fail
	.inst 0xc2401ef6 // ldr c22, [x23, #7]
	.inst 0xc2d6a641 // chkeq c18, c22
	b.ne comparison_fail
	.inst 0xc24022f6 // ldr c22, [x23, #8]
	.inst 0xc2d6a6a1 // chkeq c21, c22
	b.ne comparison_fail
	.inst 0xc24026f6 // ldr c22, [x23, #9]
	.inst 0xc2d6a781 // chkeq c28, c22
	b.ne comparison_fail
	.inst 0xc2402af6 // ldr c22, [x23, #10]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x23, =0x0
	mov x22, v29.d[0]
	cmp x23, x22
	b.ne comparison_fail
	ldr x23, =0x0
	mov x22, v29.d[1]
	cmp x23, x22
	b.ne comparison_fail
	ldr x23, =0x0
	mov x22, v30.d[0]
	cmp x23, x22
	b.ne comparison_fail
	ldr x23, =0x0
	mov x22, v30.d[1]
	cmp x23, x22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001028
	ldr x1, =check_data0
	ldr x2, =0x00001030
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001169
	ldr x1, =check_data1
	ldr x2, =0x0000116a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011b4
	ldr x1, =check_data2
	ldr x2, =0x000011b8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001858
	ldr x1, =check_data3
	ldr x2, =0x00001868
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040000c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00401ffc
	ldr x1, =check_data5
	ldr x2, =0x0040201c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00490001
	ldr x1, =check_data6
	ldr x2, =0x00490002
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr ddc_el3, c23
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

.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x41, 0x05, 0x00, 0xc3
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x19, 0x43, 0x7c, 0xe2, 0xe0, 0xc3, 0xe8, 0xf2, 0x53, 0x3c, 0xba, 0x6a, 0xd3, 0x0b, 0xc1, 0xc2
	.byte 0x2f, 0x04, 0x0f, 0xb1, 0xa1, 0xda, 0x7c, 0x38, 0x21, 0x61, 0xde, 0xc2, 0x4a, 0x85, 0xe5, 0xe2
	.byte 0x33, 0xee, 0x5a, 0x78, 0xaf, 0xa8, 0x4b, 0x82, 0xc0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc3000180
	/* C2 */
	.octa 0xffffffff
	/* C5 */
	.octa 0x1600
	/* C9 */
	.octa 0x800001a0040000e80604004000
	/* C10 */
	.octa 0x1000
	/* C17 */
	.octa 0x80000000000000000000000000001154
	/* C21 */
	.octa 0x8000000000010007ffffffff80800000
	/* C24 */
	.octa 0x2000
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x7f801000
	/* C30 */
	.octa 0x1000824005c00
final_cap_values:
	/* C1 */
	.octa 0x800001a0040001000824005c00
	/* C2 */
	.octa 0xffffffff
	/* C5 */
	.octa 0x1600
	/* C9 */
	.octa 0x800001a0040000e80604004000
	/* C10 */
	.octa 0x1000
	/* C15 */
	.octa 0xc3000541
	/* C17 */
	.octa 0x80000000000000000000000000001102
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x8000000000010007ffffffff80800000
	/* C24 */
	.octa 0x2000
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x7f801000
	/* C30 */
	.octa 0x1000824005c00
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000700070000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 160
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 192
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe27c4319 // ASTUR-V.RI-H Rt:25 Rn:24 op2:00 imm9:111000100 V:1 op1:01 11100010:11100010
	.inst 0xf2e8c3e0 // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:0 imm16:0100011000011111 hw:11 100101:100101 opc:11 sf:1
	.inst 0x6aba3c53 // bics:aarch64/instrs/integer/logical/shiftedreg Rd:19 Rn:2 imm6:001111 Rm:26 N:1 shift:10 01010:01010 opc:11 sf:0
	.inst 0xc2c10bd3 // SEAL-C.CC-C Cd:19 Cn:30 0010:0010 opc:00 Cm:1 11000010110:11000010110
	.inst 0xb10f042f // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:15 Rn:1 imm12:001111000001 sh:0 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0x387cdaa1 // ldrb_reg:aarch64/instrs/memory/single/general/register Rt:1 Rn:21 10:10 S:1 option:110 Rm:28 1:1 opc:01 111000:111000 size:00
	.inst 0xc2de6121 // SCOFF-C.CR-C Cd:1 Cn:9 000:000 opc:11 0:0 Rm:30 11000010110:11000010110
	.inst 0xe2e5854a // ALDUR-V.RI-D Rt:10 Rn:10 op2:01 imm9:001011000 V:1 op1:11 11100010:11100010
	.inst 0x785aee33 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:19 Rn:17 11:11 imm9:110101110 0:0 opc:01 111000:111000 size:01
	.inst 0x824ba8af // ASTR-R.RI-32 Rt:15 Rn:5 op:10 imm9:010111010 L:0 1000001001:1000001001
	.inst 0xc2c211c0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x22, cptr_el3
	orr x22, x22, #0x200
	msr cptr_el3, x22
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c1 // ldr c1, [x22, #0]
	.inst 0xc24006c2 // ldr c2, [x22, #1]
	.inst 0xc2400ac5 // ldr c5, [x22, #2]
	.inst 0xc2400ec9 // ldr c9, [x22, #3]
	.inst 0xc24012ca // ldr c10, [x22, #4]
	.inst 0xc24016d1 // ldr c17, [x22, #5]
	.inst 0xc2401ad5 // ldr c21, [x22, #6]
	.inst 0xc2401ed8 // ldr c24, [x22, #7]
	.inst 0xc24022da // ldr c26, [x22, #8]
	.inst 0xc24026dc // ldr c28, [x22, #9]
	.inst 0xc2402ade // ldr c30, [x22, #10]
	/* Vector registers */
	mrs x22, cptr_el3
	bfc x22, #10, #1
	msr cptr_el3, x22
	isb
	ldr q25, =0x0
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
	ldr x22, =0x4
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031d6 // ldr c22, [c14, #3]
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	.inst 0x826011d6 // ldr c22, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	/* Check processor flags */
	mrs x22, nzcv
	ubfx x22, x22, #28, #4
	mov x14, #0xf
	and x22, x22, x14
	cmp x22, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002ce // ldr c14, [x22, #0]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc24006ce // ldr c14, [x22, #1]
	.inst 0xc2cea441 // chkeq c2, c14
	b.ne comparison_fail
	.inst 0xc2400ace // ldr c14, [x22, #2]
	.inst 0xc2cea4a1 // chkeq c5, c14
	b.ne comparison_fail
	.inst 0xc2400ece // ldr c14, [x22, #3]
	.inst 0xc2cea521 // chkeq c9, c14
	b.ne comparison_fail
	.inst 0xc24012ce // ldr c14, [x22, #4]
	.inst 0xc2cea541 // chkeq c10, c14
	b.ne comparison_fail
	.inst 0xc24016ce // ldr c14, [x22, #5]
	.inst 0xc2cea5e1 // chkeq c15, c14
	b.ne comparison_fail
	.inst 0xc2401ace // ldr c14, [x22, #6]
	.inst 0xc2cea621 // chkeq c17, c14
	b.ne comparison_fail
	.inst 0xc2401ece // ldr c14, [x22, #7]
	.inst 0xc2cea661 // chkeq c19, c14
	b.ne comparison_fail
	.inst 0xc24022ce // ldr c14, [x22, #8]
	.inst 0xc2cea6a1 // chkeq c21, c14
	b.ne comparison_fail
	.inst 0xc24026ce // ldr c14, [x22, #9]
	.inst 0xc2cea701 // chkeq c24, c14
	b.ne comparison_fail
	.inst 0xc2402ace // ldr c14, [x22, #10]
	.inst 0xc2cea741 // chkeq c26, c14
	b.ne comparison_fail
	.inst 0xc2402ece // ldr c14, [x22, #11]
	.inst 0xc2cea781 // chkeq c28, c14
	b.ne comparison_fail
	.inst 0xc24032ce // ldr c14, [x22, #12]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check vector registers */
	ldr x22, =0x0
	mov x14, v10.d[0]
	cmp x22, x14
	b.ne comparison_fail
	ldr x22, =0x0
	mov x14, v10.d[1]
	cmp x22, x14
	b.ne comparison_fail
	ldr x22, =0x0
	mov x14, v25.d[0]
	cmp x22, x14
	b.ne comparison_fail
	ldr x22, =0x0
	mov x14, v25.d[1]
	cmp x22, x14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001058
	ldr x1, =check_data1
	ldr x2, =0x00001060
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001102
	ldr x1, =check_data2
	ldr x2, =0x00001104
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000018e8
	ldr x1, =check_data3
	ldr x2, =0x000018ec
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fc4
	ldr x1, =check_data4
	ldr x2, =0x00001fc6
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
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
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

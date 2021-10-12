.section data0, #alloc, #write
	.zero 3392
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
	.zero 688
.data
check_data0:
	.zero 32
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x82, 0x10, 0xc2, 0xc2
.data
check_data5:
	.byte 0x3f, 0x70, 0x3e, 0xb8, 0x69, 0x73, 0x7f, 0x22, 0xfe, 0x65, 0xde, 0xc2, 0x1f, 0x40, 0xdd, 0xc2
	.byte 0x83, 0x84, 0x20, 0x22, 0xfe, 0xcf, 0x54, 0x78, 0x29, 0x4c, 0xce, 0xe2, 0xbf, 0x3b, 0xd2, 0xc2
	.byte 0xbd, 0x27, 0xa8, 0x02, 0xa0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x7200700a0000000006001
	/* C1 */
	.octa 0x80100000004140050000000000001d4c
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x20008000800100070000000000400080
	/* C15 */
	.octa 0x800100040000000000000000
	/* C27 */
	.octa 0x1000
	/* C29 */
	.octa 0x800120030000000000002000
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x80100000004140050000000000001d4c
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x20008000800100070000000000400080
	/* C9 */
	.octa 0x0
	/* C15 */
	.octa 0x800100040000000000000000
	/* C27 */
	.octa 0x1000
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x8001200300000000000015f7
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc0000000003000700ffe00000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c21082 // BRS-C-C 00010:00010 Cn:4 100:100 opc:00 11000010110000100:11000010110000100
	.zero 124
	.inst 0xb83e703f // stumin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:111 o3:0 Rs:30 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0x227f7369 // 0x227f7369
	.inst 0xc2de65fe // CPYVALUE-C.C-C Cd:30 Cn:15 001:001 opc:11 0:0 Cm:30 11000010110:11000010110
	.inst 0xc2dd401f // SCVALUE-C.CR-C Cd:31 Cn:0 000:000 opc:10 0:0 Rm:29 11000010110:11000010110
	.inst 0x22208483 // 0x22208483
	.inst 0x7854cffe // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:31 11:11 imm9:101001100 0:0 opc:01 111000:111000 size:01
	.inst 0xe2ce4c29 // ALDUR-C.RI-C Ct:9 Rn:1 op2:11 imm9:011100100 V:0 op1:11 11100010:11100010
	.inst 0xc2d23bbf // SCBNDS-C.CI-C Cd:31 Cn:29 1110:1110 S:0 imm6:100100 11000010110:11000010110
	.inst 0x02a827bd // SUB-C.CIS-C Cd:29 Cn:29 imm12:101000001001 sh:0 A:1 00000010:00000010
	.inst 0xc2c212a0
	.zero 1048408
.text
.global preamble
preamble:
	/* Ensure Morello is on */
	mov x0, 0x200
	msr cptr_el3, x0
	isb
	/* Set exception handler */
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	mov x0, #0xff
	msr mair_el3, x0
	ldr x0, =0x0d001519
	msr tcr_el3, x0
	isb
	tlbi alle3
	dsb sy
	isb
	/* Write tags to memory */
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
	.inst 0xc24002c0 // ldr c0, [x22, #0]
	.inst 0xc24006c1 // ldr c1, [x22, #1]
	.inst 0xc2400ac3 // ldr c3, [x22, #2]
	.inst 0xc2400ec4 // ldr c4, [x22, #3]
	.inst 0xc24012cf // ldr c15, [x22, #4]
	.inst 0xc24016db // ldr c27, [x22, #5]
	.inst 0xc2401add // ldr c29, [x22, #6]
	.inst 0xc2401ede // ldr c30, [x22, #7]
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30851037
	msr SCTLR_EL3, x22
	ldr x22, =0x4
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032b6 // ldr c22, [c21, #3]
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	.inst 0x826012b6 // ldr c22, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30851035
	msr SCTLR_EL3, x22
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002d5 // ldr c21, [x22, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc24006d5 // ldr c21, [x22, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400ad5 // ldr c21, [x22, #2]
	.inst 0xc2d5a461 // chkeq c3, c21
	b.ne comparison_fail
	.inst 0xc2400ed5 // ldr c21, [x22, #3]
	.inst 0xc2d5a481 // chkeq c4, c21
	b.ne comparison_fail
	.inst 0xc24012d5 // ldr c21, [x22, #4]
	.inst 0xc2d5a521 // chkeq c9, c21
	b.ne comparison_fail
	.inst 0xc24016d5 // ldr c21, [x22, #5]
	.inst 0xc2d5a5e1 // chkeq c15, c21
	b.ne comparison_fail
	.inst 0xc2401ad5 // ldr c21, [x22, #6]
	.inst 0xc2d5a761 // chkeq c27, c21
	b.ne comparison_fail
	.inst 0xc2401ed5 // ldr c21, [x22, #7]
	.inst 0xc2d5a781 // chkeq c28, c21
	b.ne comparison_fail
	.inst 0xc24022d5 // ldr c21, [x22, #8]
	.inst 0xc2d5a7a1 // chkeq c29, c21
	b.ne comparison_fail
	.inst 0xc24026d5 // ldr c21, [x22, #9]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001d4c
	ldr x1, =check_data1
	ldr x2, =0x00001d50
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001e30
	ldr x1, =check_data2
	ldr x2, =0x00001e40
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f4c
	ldr x1, =check_data3
	ldr x2, =0x00001f4e
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400004
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400080
	ldr x1, =check_data5
	ldr x2, =0x004000a8
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
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

.section vector_table, #alloc, #execinstr
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

	/* Translation table, single entry, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000701
	.fill 4088, 1, 0

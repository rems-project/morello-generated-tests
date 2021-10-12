.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x8d, 0x25, 0x63, 0xd2, 0x81, 0x71, 0xe3, 0xf0, 0x5f, 0x30, 0xb4, 0xc2, 0x5e, 0x42, 0x47, 0xf9
	.byte 0x5a, 0x1b, 0x8a, 0x72, 0x68, 0x6b, 0x21, 0xb8, 0xfe, 0xcf, 0x31, 0xe2, 0x2f, 0x52, 0xc0, 0xc2
	.byte 0x1e, 0x7f, 0xbe, 0xa2, 0x04, 0xcc, 0x0f, 0x78, 0xc0, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000100050000000000001f00
	/* C2 */
	.octa 0x7000600000000004a4004
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C18 */
	.octa 0x80000000400000020000000000000ff0
	/* C20 */
	.octa 0x5c0c
	/* C24 */
	.octa 0xd0000000000100050000000000001000
	/* C27 */
	.octa 0x40000000000100050000000038dce630
final_cap_values:
	/* C0 */
	.octa 0x40000000000100050000000000001ffc
	/* C1 */
	.octa 0x2000800000004008ffffffffc7233000
	/* C2 */
	.octa 0x7000600000000004a4004
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C18 */
	.octa 0x80000000400000020000000000000ff0
	/* C20 */
	.octa 0x5c0c
	/* C24 */
	.octa 0xd0000000000100050000000000001000
	/* C27 */
	.octa 0x40000000000100050000000038dce630
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd263258d // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:13 Rn:12 imms:001001 immr:100011 N:1 100100:100100 opc:10 sf:1
	.inst 0xf0e37181 // ADRP-C.IP-C Rd:1 immhi:110001101110001100 P:1 10000:10000 immlo:11 op:1
	.inst 0xc2b4305f // ADD-C.CRI-C Cd:31 Cn:2 imm3:100 option:001 Rm:20 11000010101:11000010101
	.inst 0xf947425e // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:18 imm12:000111010000 opc:01 111001:111001 size:11
	.inst 0x728a1b5a // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:26 imm16:0101000011011010 hw:00 100101:100101 opc:11 sf:0
	.inst 0xb8216b68 // str_reg_gen:aarch64/instrs/memory/single/general/register Rt:8 Rn:27 10:10 S:0 option:011 Rm:1 1:1 opc:00 111000:111000 size:10
	.inst 0xe231cffe // ALDUR-V.RI-Q Rt:30 Rn:31 op2:11 imm9:100011100 V:1 op1:00 11100010:11100010
	.inst 0xc2c0522f // GCVALUE-R.C-C Rd:15 Cn:17 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0xa2be7f1e // CAS-C.R-C Ct:30 Rn:24 11111:11111 R:0 Cs:30 1:1 L:0 1:1 10100010:10100010
	.inst 0x780fcc04 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:4 Rn:0 11:11 imm9:011111100 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c212c0
	.zero 1048532
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c2 // ldr c2, [x6, #1]
	.inst 0xc24008c4 // ldr c4, [x6, #2]
	.inst 0xc2400cc8 // ldr c8, [x6, #3]
	.inst 0xc24010d2 // ldr c18, [x6, #4]
	.inst 0xc24014d4 // ldr c20, [x6, #5]
	.inst 0xc24018d8 // ldr c24, [x6, #6]
	.inst 0xc2401cdb // ldr c27, [x6, #7]
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30851037
	msr SCTLR_EL3, x6
	ldr x6, =0x0
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032c6 // ldr c6, [c22, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x826012c6 // ldr c6, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000d6 // ldr c22, [x6, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc24004d6 // ldr c22, [x6, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc24008d6 // ldr c22, [x6, #2]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400cd6 // ldr c22, [x6, #3]
	.inst 0xc2d6a481 // chkeq c4, c22
	b.ne comparison_fail
	.inst 0xc24010d6 // ldr c22, [x6, #4]
	.inst 0xc2d6a501 // chkeq c8, c22
	b.ne comparison_fail
	.inst 0xc24014d6 // ldr c22, [x6, #5]
	.inst 0xc2d6a641 // chkeq c18, c22
	b.ne comparison_fail
	.inst 0xc24018d6 // ldr c22, [x6, #6]
	.inst 0xc2d6a681 // chkeq c20, c22
	b.ne comparison_fail
	.inst 0xc2401cd6 // ldr c22, [x6, #7]
	.inst 0xc2d6a701 // chkeq c24, c22
	b.ne comparison_fail
	.inst 0xc24020d6 // ldr c22, [x6, #8]
	.inst 0xc2d6a761 // chkeq c27, c22
	b.ne comparison_fail
	.inst 0xc24024d6 // ldr c22, [x6, #9]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x22, v30.d[0]
	cmp x6, x22
	b.ne comparison_fail
	ldr x6, =0x0
	mov x22, v30.d[1]
	cmp x6, x22
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
	ldr x0, =0x00001630
	ldr x1, =check_data1
	ldr x2, =0x00001634
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001e70
	ldr x1, =check_data2
	ldr x2, =0x00001e78
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffc
	ldr x1, =check_data3
	ldr x2, =0x00001ffe
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
	ldr x0, =0x004fffe0
	ldr x1, =check_data5
	ldr x2, =0x004ffff0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
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

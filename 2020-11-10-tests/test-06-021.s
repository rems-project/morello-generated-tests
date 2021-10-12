.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x5e
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0xff
.data
check_data5:
	.zero 8
.data
check_data6:
	.byte 0x06, 0x55, 0x16, 0xb8, 0xe0, 0x73, 0xc2, 0xc2, 0x22, 0x10, 0x92, 0x2a, 0x44, 0x18, 0xe2, 0xc2
	.byte 0x24, 0x74, 0x04, 0x39, 0x01, 0x68, 0x95, 0xe2, 0x59, 0xcc, 0x41, 0xe2, 0x01, 0xe0, 0xc1, 0xc2
	.byte 0xff, 0xf2, 0x4a, 0xf8, 0x08, 0x94, 0x53, 0x82, 0x20, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000000000000001417
	/* C1 */
	.octa 0x400000004000000400000000000016e1
	/* C6 */
	.octa 0x0
	/* C8 */
	.octa 0x14f9
	/* C18 */
	.octa 0x1e0
	/* C23 */
	.octa 0x80000000000100050000000000001f41
final_cap_values:
	/* C0 */
	.octa 0x800000000000000000001417
	/* C1 */
	.octa 0x800000000000000000001417
	/* C2 */
	.octa 0x16ff
	/* C4 */
	.octa 0x16ff
	/* C6 */
	.octa 0x0
	/* C8 */
	.octa 0x145e
	/* C18 */
	.octa 0x1e0
	/* C23 */
	.octa 0x80000000000100050000000000001f41
	/* C25 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000500170000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005a11000700ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb8165506 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:6 Rn:8 01:01 imm9:101100101 0:0 opc:00 111000:111000 size:10
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0x2a921022 // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:2 Rn:1 imm6:000100 Rm:18 N:0 shift:10 01010:01010 opc:01 sf:0
	.inst 0xc2e21844 // CVT-C.CR-C Cd:4 Cn:2 0110:0110 0:0 0:0 Rm:2 11000010111:11000010111
	.inst 0x39047424 // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:4 Rn:1 imm12:000100011101 opc:00 111001:111001 size:00
	.inst 0xe2956801 // ALDURSW-R.RI-64 Rt:1 Rn:0 op2:10 imm9:101010110 V:0 op1:10 11100010:11100010
	.inst 0xe241cc59 // ALDURSH-R.RI-32 Rt:25 Rn:2 op2:11 imm9:000011100 V:0 op1:01 11100010:11100010
	.inst 0xc2c1e001 // SCFLGS-C.CR-C Cd:1 Cn:0 111000:111000 Rm:1 11000010110:11000010110
	.inst 0xf84af2ff // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:23 00:00 imm9:010101111 0:0 opc:01 111000:111000 size:11
	.inst 0x82539408 // ASTRB-R.RI-B Rt:8 Rn:0 op:01 imm9:100111001 L:0 1000001001:1000001001
	.inst 0xc2c21220
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
	ldr x20, =initial_cap_values
	.inst 0xc2400280 // ldr c0, [x20, #0]
	.inst 0xc2400681 // ldr c1, [x20, #1]
	.inst 0xc2400a86 // ldr c6, [x20, #2]
	.inst 0xc2400e88 // ldr c8, [x20, #3]
	.inst 0xc2401292 // ldr c18, [x20, #4]
	.inst 0xc2401697 // ldr c23, [x20, #5]
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	ldr x20, =0x4
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82603234 // ldr c20, [c17, #3]
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	.inst 0x82601234 // ldr c20, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc2400291 // ldr c17, [x20, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc2400691 // ldr c17, [x20, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400a91 // ldr c17, [x20, #2]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc2400e91 // ldr c17, [x20, #3]
	.inst 0xc2d1a481 // chkeq c4, c17
	b.ne comparison_fail
	.inst 0xc2401291 // ldr c17, [x20, #4]
	.inst 0xc2d1a4c1 // chkeq c6, c17
	b.ne comparison_fail
	.inst 0xc2401691 // ldr c17, [x20, #5]
	.inst 0xc2d1a501 // chkeq c8, c17
	b.ne comparison_fail
	.inst 0xc2401a91 // ldr c17, [x20, #6]
	.inst 0xc2d1a641 // chkeq c18, c17
	b.ne comparison_fail
	.inst 0xc2401e91 // ldr c17, [x20, #7]
	.inst 0xc2d1a6e1 // chkeq c23, c17
	b.ne comparison_fail
	.inst 0xc2402291 // ldr c17, [x20, #8]
	.inst 0xc2d1a721 // chkeq c25, c17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001374
	ldr x1, =check_data0
	ldr x2, =0x00001378
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001500
	ldr x1, =check_data1
	ldr x2, =0x00001504
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001557
	ldr x1, =check_data2
	ldr x2, =0x00001558
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001722
	ldr x1, =check_data3
	ldr x2, =0x00001724
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000017fe
	ldr x1, =check_data4
	ldr x2, =0x000017ff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ff0
	ldr x1, =check_data5
	ldr x2, =0x00001ff8
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
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

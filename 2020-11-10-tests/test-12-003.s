.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x10, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0a, 0x00, 0x00, 0x40, 0x00, 0xc0, 0x00, 0x20
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
	.zero 16
.data
check_data5:
	.byte 0x73, 0x5b, 0x37, 0x78, 0x00, 0x54, 0x64, 0xfd, 0x42, 0xba, 0x06, 0xa2, 0x43, 0x30, 0xc2, 0xc2
	.byte 0x2a, 0xac, 0x5b, 0xa2, 0x3f, 0x5a, 0xff, 0xc2, 0xe1, 0xfd, 0x5f, 0x22, 0x1f, 0x10, 0xc0, 0xc2
	.byte 0x21, 0x49, 0xbe, 0xb8, 0x89, 0x1a, 0x09, 0xe2, 0x60, 0x10, 0xc2, 0xc2
.data
check_data6:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000006c02000200000000003fe000
	/* C1 */
	.octa 0x2440
	/* C2 */
	.octa 0x2000c0004000000a0000000000400010
	/* C9 */
	.octa 0xffffffffffc013b7
	/* C15 */
	.octa 0x1400
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x48000000000300070000000000000950
	/* C19 */
	.octa 0x4000
	/* C20 */
	.octa 0x80000000000600070000000000000f8e
	/* C23 */
	.octa 0x400
	/* C27 */
	.octa 0x40000000000700070000000000000800
final_cap_values:
	/* C0 */
	.octa 0x800000006c02000200000000003fe000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x2000c0004000000a0000000000400010
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C15 */
	.octa 0x1400
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x48000000000300070000000000000950
	/* C19 */
	.octa 0x4000
	/* C20 */
	.octa 0x80000000000600070000000000000f8e
	/* C23 */
	.octa 0x400
	/* C27 */
	.octa 0x40000000000700070000000000000800
	/* C30 */
	.octa 0x20008000480400000000000000400011
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000480400000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x801000004000120000ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001400
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword initial_cap_values + 128
	.dword initial_cap_values + 160
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword final_cap_values + 176
	.dword final_cap_values + 192
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x78375b73 // strh_reg:aarch64/instrs/memory/single/general/register Rt:19 Rn:27 10:10 S:1 option:010 Rm:23 1:1 opc:00 111000:111000 size:01
	.inst 0xfd645400 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:0 Rn:0 imm12:100100010101 opc:01 111101:111101 size:11
	.inst 0xa206ba42 // STTR-C.RIB-C Ct:2 Rn:18 10:10 imm9:001101011 0:0 opc:00 10100010:10100010
	.inst 0xc2c23043 // BLRR-C-C 00011:00011 Cn:2 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xa25bac2a // LDR-C.RIBW-C Ct:10 Rn:1 11:11 imm9:110111010 0:0 opc:01 10100010:10100010
	.inst 0xc2ff5a3f // CVTZ-C.CR-C Cd:31 Cn:17 0110:0110 1:1 0:0 Rm:31 11000010111:11000010111
	.inst 0x225ffde1 // LDAXR-C.R-C Ct:1 Rn:15 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0xc2c0101f // GCBASE-R.C-C Rd:31 Cn:0 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0xb8be4921 // ldrsw_reg:aarch64/instrs/memory/single/general/register Rt:1 Rn:9 10:10 S:0 option:010 Rm:30 1:1 opc:10 111000:111000 size:10
	.inst 0xe2091a89 // ALDURSB-R.RI-64 Rt:9 Rn:20 op2:10 imm9:010010001 V:0 op1:00 11100010:11100010
	.inst 0xc2c21060
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400601 // ldr c1, [x16, #1]
	.inst 0xc2400a02 // ldr c2, [x16, #2]
	.inst 0xc2400e09 // ldr c9, [x16, #3]
	.inst 0xc240120f // ldr c15, [x16, #4]
	.inst 0xc2401611 // ldr c17, [x16, #5]
	.inst 0xc2401a12 // ldr c18, [x16, #6]
	.inst 0xc2401e13 // ldr c19, [x16, #7]
	.inst 0xc2402214 // ldr c20, [x16, #8]
	.inst 0xc2402617 // ldr c23, [x16, #9]
	.inst 0xc2402a1b // ldr c27, [x16, #10]
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	ldr x16, =0x0
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82603070 // ldr c16, [c3, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x82601070 // ldr c16, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400203 // ldr c3, [x16, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc2400603 // ldr c3, [x16, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400a03 // ldr c3, [x16, #2]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400e03 // ldr c3, [x16, #3]
	.inst 0xc2c3a521 // chkeq c9, c3
	b.ne comparison_fail
	.inst 0xc2401203 // ldr c3, [x16, #4]
	.inst 0xc2c3a541 // chkeq c10, c3
	b.ne comparison_fail
	.inst 0xc2401603 // ldr c3, [x16, #5]
	.inst 0xc2c3a5e1 // chkeq c15, c3
	b.ne comparison_fail
	.inst 0xc2401a03 // ldr c3, [x16, #6]
	.inst 0xc2c3a621 // chkeq c17, c3
	b.ne comparison_fail
	.inst 0xc2401e03 // ldr c3, [x16, #7]
	.inst 0xc2c3a641 // chkeq c18, c3
	b.ne comparison_fail
	.inst 0xc2402203 // ldr c3, [x16, #8]
	.inst 0xc2c3a661 // chkeq c19, c3
	b.ne comparison_fail
	.inst 0xc2402603 // ldr c3, [x16, #9]
	.inst 0xc2c3a681 // chkeq c20, c3
	b.ne comparison_fail
	.inst 0xc2402a03 // ldr c3, [x16, #10]
	.inst 0xc2c3a6e1 // chkeq c23, c3
	b.ne comparison_fail
	.inst 0xc2402e03 // ldr c3, [x16, #11]
	.inst 0xc2c3a761 // chkeq c27, c3
	b.ne comparison_fail
	.inst 0xc2403203 // ldr c3, [x16, #12]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x0
	mov x3, v0.d[0]
	cmp x16, x3
	b.ne comparison_fail
	ldr x16, =0x0
	mov x3, v0.d[1]
	cmp x16, x3
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
	ldr x0, =0x0000101f
	ldr x1, =check_data1
	ldr x2, =0x00001020
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000013c8
	ldr x1, =check_data2
	ldr x2, =0x000013cc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001400
	ldr x1, =check_data3
	ldr x2, =0x00001410
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fe0
	ldr x1, =check_data4
	ldr x2, =0x00001ff0
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
	ldr x0, =0x004028a8
	ldr x1, =check_data6
	ldr x2, =0x004028b0
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
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

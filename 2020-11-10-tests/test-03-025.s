.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0xde, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0x55, 0xe8, 0xbf, 0x38, 0x20, 0xa7, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0xdf, 0x7a, 0x12, 0x79, 0x1f, 0x00, 0x7e, 0x78, 0xc2, 0xf3, 0xc6, 0xc2, 0xe1, 0x12, 0x77, 0x39
	.byte 0x02, 0x48, 0x38, 0xd1, 0x65, 0x11, 0xcd, 0x6c, 0x82, 0xff, 0x50, 0x82, 0x13, 0xfc, 0xdf, 0xc8
	.byte 0xa0, 0x11, 0xc2, 0xc2
.data
check_data7:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000000300060000000000001ff0
	/* C2 */
	.octa 0x400004000000000000000000001b36
	/* C11 */
	.octa 0x800000004001c002000000000040ff40
	/* C22 */
	.octa 0x400000004001000200000000000008c4
	/* C23 */
	.octa 0x800000004601020400000000003ff800
	/* C25 */
	.octa 0x204080040007800f0000000000408009
	/* C28 */
	.octa 0x1008
final_cap_values:
	/* C0 */
	.octa 0xc0000000000300060000000000001ff0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x11de
	/* C11 */
	.octa 0x800000004001c0020000000000410010
	/* C19 */
	.octa 0x8
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x400000004001000200000000000008c4
	/* C23 */
	.octa 0x800000004601020400000000003ff800
	/* C25 */
	.octa 0x204080040007800f0000000000408009
	/* C28 */
	.octa 0x1008
	/* C29 */
	.octa 0x400000000000000000000000001b36
	/* C30 */
	.octa 0x20008000400900000000000000400008
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000400900000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000006124000000ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x38bfe855 // ldrsb_reg:aarch64/instrs/memory/single/general/register Rt:21 Rn:2 10:10 S:0 option:111 Rm:31 1:1 opc:10 111000:111000 size:00
	.inst 0xc2c2a720 // BLRS-C.C-C 00000:00000 Cn:25 001:001 opc:01 1:1 Cm:2 11000010110:11000010110
	.zero 32768
	.inst 0x79127adf // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:22 imm12:010010011110 opc:00 111001:111001 size:01
	.inst 0x787e001f // staddh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:000 o3:0 Rs:30 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c6f3c2 // CLRPERM-C.CI-C Cd:2 Cn:30 100:100 perm:111 1100001011000110:1100001011000110
	.inst 0x397712e1 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:23 imm12:110111000100 opc:01 111001:111001 size:00
	.inst 0xd1384802 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:2 Rn:0 imm12:111000010010 sh:0 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0x6ccd1165 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:5 Rn:11 Rt2:00100 imm7:0011010 L:1 1011001:1011001 opc:01
	.inst 0x8250ff82 // ASTR-R.RI-64 Rt:2 Rn:28 op:11 imm9:100001111 L:0 1000001001:1000001001
	.inst 0xc8dffc13 // ldar:aarch64/instrs/memory/ordered Rt:19 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0xc2c211a0
	.zero 1015764
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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400762 // ldr c2, [x27, #1]
	.inst 0xc2400b6b // ldr c11, [x27, #2]
	.inst 0xc2400f76 // ldr c22, [x27, #3]
	.inst 0xc2401377 // ldr c23, [x27, #4]
	.inst 0xc2401779 // ldr c25, [x27, #5]
	.inst 0xc2401b7c // ldr c28, [x27, #6]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30851035
	msr SCTLR_EL3, x27
	ldr x27, =0x4
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031bb // ldr c27, [c13, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x826011bb // ldr c27, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30851035
	msr SCTLR_EL3, x27
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc240036d // ldr c13, [x27, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240076d // ldr c13, [x27, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc2400b6d // ldr c13, [x27, #2]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc2400f6d // ldr c13, [x27, #3]
	.inst 0xc2cda561 // chkeq c11, c13
	b.ne comparison_fail
	.inst 0xc240136d // ldr c13, [x27, #4]
	.inst 0xc2cda661 // chkeq c19, c13
	b.ne comparison_fail
	.inst 0xc240176d // ldr c13, [x27, #5]
	.inst 0xc2cda6a1 // chkeq c21, c13
	b.ne comparison_fail
	.inst 0xc2401b6d // ldr c13, [x27, #6]
	.inst 0xc2cda6c1 // chkeq c22, c13
	b.ne comparison_fail
	.inst 0xc2401f6d // ldr c13, [x27, #7]
	.inst 0xc2cda6e1 // chkeq c23, c13
	b.ne comparison_fail
	.inst 0xc240236d // ldr c13, [x27, #8]
	.inst 0xc2cda721 // chkeq c25, c13
	b.ne comparison_fail
	.inst 0xc240276d // ldr c13, [x27, #9]
	.inst 0xc2cda781 // chkeq c28, c13
	b.ne comparison_fail
	.inst 0xc2402b6d // ldr c13, [x27, #10]
	.inst 0xc2cda7a1 // chkeq c29, c13
	b.ne comparison_fail
	.inst 0xc2402f6d // ldr c13, [x27, #11]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check vector registers */
	ldr x27, =0x0
	mov x13, v4.d[0]
	cmp x27, x13
	b.ne comparison_fail
	ldr x27, =0x0
	mov x13, v4.d[1]
	cmp x27, x13
	b.ne comparison_fail
	ldr x27, =0x0
	mov x13, v5.d[0]
	cmp x27, x13
	b.ne comparison_fail
	ldr x27, =0x0
	mov x13, v5.d[1]
	cmp x27, x13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001200
	ldr x1, =check_data0
	ldr x2, =0x00001202
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001880
	ldr x1, =check_data1
	ldr x2, =0x00001888
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001b36
	ldr x1, =check_data2
	ldr x2, =0x00001b37
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff0
	ldr x1, =check_data3
	ldr x2, =0x00001ff8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400008
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004005c4
	ldr x1, =check_data5
	ldr x2, =0x004005c5
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00408008
	ldr x1, =check_data6
	ldr x2, =0x0040802c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x0040ff40
	ldr x1, =check_data7
	ldr x2, =0x0040ff50
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
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

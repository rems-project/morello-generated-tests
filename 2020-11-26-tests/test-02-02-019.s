.section data0, #alloc, #write
	.zero 2048
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x84, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x90, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 32
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x00, 0x00, 0x00, 0x00, 0x84, 0x10, 0x00, 0x00
.data
check_data6:
	.zero 8
.data
check_data7:
	.byte 0x62, 0x72, 0xc0, 0xc2, 0xf6, 0xa3, 0x52, 0x38, 0xe9, 0xeb, 0x68, 0x29, 0x5d, 0x93, 0x3f, 0x29
	.byte 0xff, 0x63, 0x7d, 0x78, 0xad, 0xf3, 0x14, 0x62, 0x37, 0xaa, 0xdd, 0xc2, 0xa1, 0x1f, 0x17, 0xe2
	.byte 0x5f, 0xa7, 0x5d, 0x29, 0x1b, 0x60, 0x24, 0xfd, 0xc0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xffffffffffffd000
	/* C4 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x400000000000000000000000
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000000600070000000000001090
final_cap_values:
	/* C0 */
	.octa 0xffffffffffffd000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x400000000000000000000000
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C26 */
	.octa 0x1084
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000000600070000000000001090
initial_SP_EL3_value:
	.octa 0x18c0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000000ef04ff00ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 96
	.dword final_cap_values + 192
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c07262 // GCOFF-R.C-C Rd:2 Cn:19 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0x3852a3f6 // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:22 Rn:31 00:00 imm9:100101010 0:0 opc:01 111000:111000 size:00
	.inst 0x2968ebe9 // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:9 Rn:31 Rt2:11010 imm7:1010001 L:1 1010010:1010010 opc:00
	.inst 0x293f935d // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:29 Rn:26 Rt2:00100 imm7:1111111 L:0 1010010:1010010 opc:00
	.inst 0x787d63ff // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:110 o3:0 Rs:29 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x6214f3ad // STNP-C.RIB-C Ct:13 Rn:29 Ct2:11100 imm7:0101001 L:0 011000100:011000100
	.inst 0xc2ddaa37 // EORFLGS-C.CR-C Cd:23 Cn:17 1010:1010 opc:10 Rm:29 11000010110:11000010110
	.inst 0xe2171fa1 // ALDURSB-R.RI-32 Rt:1 Rn:29 op2:11 imm9:101110001 V:0 op1:00 11100010:11100010
	.inst 0x295da75f // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:31 Rn:26 Rt2:01001 imm7:0111011 L:1 1010010:1010010 opc:00
	.inst 0xfd24601b // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:27 Rn:0 imm12:100100011000 opc:00 111101:111101 size:11
	.inst 0xc2c211c0
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
	ldr x30, =initial_cap_values
	.inst 0xc24003c0 // ldr c0, [x30, #0]
	.inst 0xc24007c4 // ldr c4, [x30, #1]
	.inst 0xc2400bcd // ldr c13, [x30, #2]
	.inst 0xc2400fd1 // ldr c17, [x30, #3]
	.inst 0xc24013d3 // ldr c19, [x30, #4]
	.inst 0xc24017dc // ldr c28, [x30, #5]
	.inst 0xc2401bdd // ldr c29, [x30, #6]
	/* Vector registers */
	mrs x30, cptr_el3
	bfc x30, #10, #1
	msr cptr_el3, x30
	isb
	ldr q27, =0x0
	/* Set up flags and system registers */
	mov x30, #0x00000000
	msr nzcv, x30
	ldr x30, =initial_SP_EL3_value
	.inst 0xc24003de // ldr c30, [x30, #0]
	.inst 0xc2c1d3df // cpy c31, c30
	ldr x30, =0x200
	msr CPTR_EL3, x30
	ldr x30, =0x3085103d
	msr SCTLR_EL3, x30
	ldr x30, =0x0
	msr S3_6_C1_C2_2, x30 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031de // ldr c30, [c14, #3]
	.inst 0xc28b413e // msr DDC_EL3, c30
	isb
	.inst 0x826011de // ldr c30, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c213c0 // br c30
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01e // cvtp c30, x0
	.inst 0xc2df43de // scvalue c30, c30, x31
	.inst 0xc28b413e // msr DDC_EL3, c30
	ldr x30, =0x30851035
	msr SCTLR_EL3, x30
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x30, =final_cap_values
	.inst 0xc24003ce // ldr c14, [x30, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc24007ce // ldr c14, [x30, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc2400bce // ldr c14, [x30, #2]
	.inst 0xc2cea441 // chkeq c2, c14
	b.ne comparison_fail
	.inst 0xc2400fce // ldr c14, [x30, #3]
	.inst 0xc2cea481 // chkeq c4, c14
	b.ne comparison_fail
	.inst 0xc24013ce // ldr c14, [x30, #4]
	.inst 0xc2cea521 // chkeq c9, c14
	b.ne comparison_fail
	.inst 0xc24017ce // ldr c14, [x30, #5]
	.inst 0xc2cea5a1 // chkeq c13, c14
	b.ne comparison_fail
	.inst 0xc2401bce // ldr c14, [x30, #6]
	.inst 0xc2cea621 // chkeq c17, c14
	b.ne comparison_fail
	.inst 0xc2401fce // ldr c14, [x30, #7]
	.inst 0xc2cea661 // chkeq c19, c14
	b.ne comparison_fail
	.inst 0xc24023ce // ldr c14, [x30, #8]
	.inst 0xc2cea6c1 // chkeq c22, c14
	b.ne comparison_fail
	.inst 0xc24027ce // ldr c14, [x30, #9]
	.inst 0xc2cea6e1 // chkeq c23, c14
	b.ne comparison_fail
	.inst 0xc2402bce // ldr c14, [x30, #10]
	.inst 0xc2cea741 // chkeq c26, c14
	b.ne comparison_fail
	.inst 0xc2402fce // ldr c14, [x30, #11]
	.inst 0xc2cea781 // chkeq c28, c14
	b.ne comparison_fail
	.inst 0xc24033ce // ldr c14, [x30, #12]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	/* Check vector registers */
	ldr x30, =0x0
	mov x14, v27.d[0]
	cmp x30, x14
	b.ne comparison_fail
	ldr x30, =0x0
	mov x14, v27.d[1]
	cmp x30, x14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001001
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001088
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001170
	ldr x1, =check_data2
	ldr x2, =0x00001178
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001320
	ldr x1, =check_data3
	ldr x2, =0x00001340
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000017ea
	ldr x1, =check_data4
	ldr x2, =0x000017eb
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001804
	ldr x1, =check_data5
	ldr x2, =0x0000180c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x000018c0
	ldr x1, =check_data6
	ldr x2, =0x000018c8
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400000
	ldr x1, =check_data7
	ldr x2, =0x0040002c
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x30, =0x30850030
	msr SCTLR_EL3, x30
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01e // cvtp c30, x0
	.inst 0xc2df43de // scvalue c30, c30, x31
	.inst 0xc28b413e // msr DDC_EL3, c30
	ldr x30, =0x30850030
	msr SCTLR_EL3, x30
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

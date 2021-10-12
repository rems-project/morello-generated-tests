.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0x36, 0x7c, 0x0a, 0xc8, 0xa0, 0x67, 0x69, 0x82, 0x10, 0xb3, 0x51, 0x38, 0xe3, 0x12, 0xc2, 0xc2
	.byte 0xe0, 0x93, 0xbf, 0x39, 0xd5, 0x2b, 0x8d, 0x78, 0x3e, 0x48, 0xa8, 0x78, 0x3c, 0x7c, 0x5f, 0x42
	.byte 0xbe, 0xe7, 0x1c, 0xfc, 0xe0, 0xb3, 0x6c, 0xe2, 0x40, 0x10, 0xc2, 0xc2
.data
check_data7:
	.zero 2
.data
check_data8:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x800000000000800800000000000011f0
	/* C8 */
	.octa 0x4fee0c
	/* C23 */
	.octa 0x200080000000c0000000000000400011
	/* C24 */
	.octa 0x1166
	/* C29 */
	.octa 0xc0000000200020000000000000001770
	/* C30 */
	.octa 0x80000000000100050000000000407f2a
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x800000000000800800000000000011f0
	/* C8 */
	.octa 0x4fee0c
	/* C10 */
	.octa 0x1
	/* C16 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C23 */
	.octa 0x200080000000c0000000000000400011
	/* C24 */
	.octa 0x1166
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0xc000000020002000000000000000173e
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x80000000000100050000000000000fc3
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd010000053fc04120000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000011f0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc80a7c36 // stxr:aarch64/instrs/memory/exclusive/single Rt:22 Rn:1 Rt2:11111 o0:0 Rs:10 0:0 L:0 0010000:0010000 size:11
	.inst 0x826967a0 // ALDRB-R.RI-B Rt:0 Rn:29 op:01 imm9:010010110 L:1 1000001001:1000001001
	.inst 0x3851b310 // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:16 Rn:24 00:00 imm9:100011011 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c212e3 // BRR-C-C 00011:00011 Cn:23 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0x39bf93e0 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:31 imm12:111111100100 opc:10 111001:111001 size:00
	.inst 0x788d2bd5 // ldtrsh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:21 Rn:30 10:10 imm9:011010010 0:0 opc:10 111000:111000 size:01
	.inst 0x78a8483e // ldrsh_reg:aarch64/instrs/memory/single/general/register Rt:30 Rn:1 10:10 S:0 option:010 Rm:8 1:1 opc:10 111000:111000 size:01
	.inst 0x425f7c3c // ALDAR-C.R-C Ct:28 Rn:1 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xfc1ce7be // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:30 Rn:29 01:01 imm9:111001110 0:0 opc:00 111100:111100 size:11
	.inst 0xe26cb3e0 // ASTUR-V.RI-H Rt:0 Rn:31 op2:00 imm9:011001011 V:1 op1:01 11100010:11100010
	.inst 0xc2c21040
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
	ldr x27, =initial_cap_values
	.inst 0xc2400361 // ldr c1, [x27, #0]
	.inst 0xc2400768 // ldr c8, [x27, #1]
	.inst 0xc2400b77 // ldr c23, [x27, #2]
	.inst 0xc2400f78 // ldr c24, [x27, #3]
	.inst 0xc240137d // ldr c29, [x27, #4]
	.inst 0xc240177e // ldr c30, [x27, #5]
	/* Vector registers */
	mrs x27, cptr_el3
	bfc x27, #10, #1
	msr cptr_el3, x27
	isb
	ldr q0, =0x0
	ldr q30, =0x0
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =initial_SP_EL3_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2c1d37f // cpy c31, c27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30851037
	msr SCTLR_EL3, x27
	ldr x27, =0x0
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x2, =pcc_return_ddc_capabilities
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0x8260305b // ldr c27, [c2, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x8260105b // ldr c27, [c2, #1]
	.inst 0x82602042 // ldr c2, [c2, #2]
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
	.inst 0xc2400362 // ldr c2, [x27, #0]
	.inst 0xc2c2a401 // chkeq c0, c2
	b.ne comparison_fail
	.inst 0xc2400762 // ldr c2, [x27, #1]
	.inst 0xc2c2a421 // chkeq c1, c2
	b.ne comparison_fail
	.inst 0xc2400b62 // ldr c2, [x27, #2]
	.inst 0xc2c2a501 // chkeq c8, c2
	b.ne comparison_fail
	.inst 0xc2400f62 // ldr c2, [x27, #3]
	.inst 0xc2c2a541 // chkeq c10, c2
	b.ne comparison_fail
	.inst 0xc2401362 // ldr c2, [x27, #4]
	.inst 0xc2c2a601 // chkeq c16, c2
	b.ne comparison_fail
	.inst 0xc2401762 // ldr c2, [x27, #5]
	.inst 0xc2c2a6a1 // chkeq c21, c2
	b.ne comparison_fail
	.inst 0xc2401b62 // ldr c2, [x27, #6]
	.inst 0xc2c2a6e1 // chkeq c23, c2
	b.ne comparison_fail
	.inst 0xc2401f62 // ldr c2, [x27, #7]
	.inst 0xc2c2a701 // chkeq c24, c2
	b.ne comparison_fail
	.inst 0xc2402362 // ldr c2, [x27, #8]
	.inst 0xc2c2a781 // chkeq c28, c2
	b.ne comparison_fail
	.inst 0xc2402762 // ldr c2, [x27, #9]
	.inst 0xc2c2a7a1 // chkeq c29, c2
	b.ne comparison_fail
	.inst 0xc2402b62 // ldr c2, [x27, #10]
	.inst 0xc2c2a7c1 // chkeq c30, c2
	b.ne comparison_fail
	/* Check vector registers */
	ldr x27, =0x0
	mov x2, v0.d[0]
	cmp x27, x2
	b.ne comparison_fail
	ldr x27, =0x0
	mov x2, v0.d[1]
	cmp x27, x2
	b.ne comparison_fail
	ldr x27, =0x0
	mov x2, v30.d[0]
	cmp x27, x2
	b.ne comparison_fail
	ldr x27, =0x0
	mov x2, v30.d[1]
	cmp x27, x2
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001081
	ldr x1, =check_data0
	ldr x2, =0x00001082
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000108e
	ldr x1, =check_data1
	ldr x2, =0x00001090
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011f0
	ldr x1, =check_data2
	ldr x2, =0x00001200
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001770
	ldr x1, =check_data3
	ldr x2, =0x00001778
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001806
	ldr x1, =check_data4
	ldr x2, =0x00001807
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001fa7
	ldr x1, =check_data5
	ldr x2, =0x00001fa8
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
	ldr x0, =0x00407ffc
	ldr x1, =check_data7
	ldr x2, =0x00407ffe
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x004ffffc
	ldr x1, =check_data8
	ldr x2, =0x004ffffe
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
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

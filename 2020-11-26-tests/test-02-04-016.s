.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x5a
.data
check_data4:
	.zero 16
.data
check_data5:
	.zero 32
.data
check_data6:
	.byte 0xe1, 0xff, 0x07, 0xc8, 0x24, 0x0c, 0x77, 0xac, 0x21, 0xd1, 0x0e, 0x38, 0xd6, 0x7b, 0x83, 0xb8
	.byte 0xa0, 0xa3, 0x93, 0xe2, 0x3c, 0x98, 0xd4, 0xc2, 0x1e, 0x30, 0xc1, 0xc2, 0xbe, 0x93, 0xc4, 0xc2
	.byte 0xbd, 0xff, 0xba, 0xa2, 0x7e, 0x63, 0xcc, 0xc2, 0x80, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x13f2120460000000000001c5a
	/* C9 */
	.octa 0x1010
	/* C12 */
	.octa 0x0
	/* C26 */
	.octa 0xffffffffffffffffffffffffffffffff
	/* C27 */
	.octa 0x4000000000ffffffffffe000
	/* C29 */
	.octa 0x4000000060010024000000000000120a
	/* C30 */
	.octa 0xc83
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x13f2120460000000000001c5a
	/* C7 */
	.octa 0x1
	/* C9 */
	.octa 0x1010
	/* C12 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x4000000000ffffffffffe000
	/* C28 */
	.octa 0x13f2120460000000000000000
	/* C29 */
	.octa 0x4000000060010024000000000000120a
	/* C30 */
	.octa 0x400000000000000000000000
initial_SP_EL3_value:
	.octa 0xc02
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000420000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xdc0000006004043600ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc807ffe1 // stlxr:aarch64/instrs/memory/exclusive/single Rt:1 Rn:31 Rt2:11111 o0:1 Rs:7 0:0 L:0 0010000:0010000 size:11
	.inst 0xac770c24 // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:4 Rn:1 Rt2:00011 imm7:1101110 L:1 1011000:1011000 opc:10
	.inst 0x380ed121 // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:9 00:00 imm9:011101101 0:0 opc:00 111000:111000 size:00
	.inst 0xb8837bd6 // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:22 Rn:30 10:10 imm9:000110111 0:0 opc:10 111000:111000 size:10
	.inst 0xe293a3a0 // ASTUR-R.RI-32 Rt:0 Rn:29 op2:00 imm9:100111010 V:0 op1:10 11100010:11100010
	.inst 0xc2d4983c // ALIGND-C.CI-C Cd:28 Cn:1 0110:0110 U:0 imm6:101001 11000010110:11000010110
	.inst 0xc2c1301e // GCFLGS-R.C-C Rd:30 Cn:0 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xc2c493be // STCT-R.R-_ Rt:30 Rn:29 100:100 opc:00 11000010110001001:11000010110001001
	.inst 0xa2baffbd // CASL-C.R-C Ct:29 Rn:29 11111:11111 R:1 Cs:26 1:1 L:0 1:1 10100010:10100010
	.inst 0xc2cc637e // SCOFF-C.CR-C Cd:30 Cn:27 000:000 opc:11 0:0 Rm:12 11000010110:11000010110
	.inst 0xc2c21080
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e0 // ldr c0, [x23, #0]
	.inst 0xc24006e1 // ldr c1, [x23, #1]
	.inst 0xc2400ae9 // ldr c9, [x23, #2]
	.inst 0xc2400eec // ldr c12, [x23, #3]
	.inst 0xc24012fa // ldr c26, [x23, #4]
	.inst 0xc24016fb // ldr c27, [x23, #5]
	.inst 0xc2401afd // ldr c29, [x23, #6]
	.inst 0xc2401efe // ldr c30, [x23, #7]
	/* Set up flags and system registers */
	mov x23, #0x00000000
	msr nzcv, x23
	ldr x23, =initial_SP_EL3_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2c1d2ff // cpy c31, c23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30851037
	msr SCTLR_EL3, x23
	ldr x23, =0x4
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82603097 // ldr c23, [c4, #3]
	.inst 0xc28b4137 // msr DDC_EL3, c23
	isb
	.inst 0x82601097 // ldr c23, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c212e0 // br c23
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002e4 // ldr c4, [x23, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc24006e4 // ldr c4, [x23, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400ae4 // ldr c4, [x23, #2]
	.inst 0xc2c4a4e1 // chkeq c7, c4
	b.ne comparison_fail
	.inst 0xc2400ee4 // ldr c4, [x23, #3]
	.inst 0xc2c4a521 // chkeq c9, c4
	b.ne comparison_fail
	.inst 0xc24012e4 // ldr c4, [x23, #4]
	.inst 0xc2c4a581 // chkeq c12, c4
	b.ne comparison_fail
	.inst 0xc24016e4 // ldr c4, [x23, #5]
	.inst 0xc2c4a6c1 // chkeq c22, c4
	b.ne comparison_fail
	.inst 0xc2401ae4 // ldr c4, [x23, #6]
	.inst 0xc2c4a741 // chkeq c26, c4
	b.ne comparison_fail
	.inst 0xc2401ee4 // ldr c4, [x23, #7]
	.inst 0xc2c4a761 // chkeq c27, c4
	b.ne comparison_fail
	.inst 0xc24022e4 // ldr c4, [x23, #8]
	.inst 0xc2c4a781 // chkeq c28, c4
	b.ne comparison_fail
	.inst 0xc24026e4 // ldr c4, [x23, #9]
	.inst 0xc2c4a7a1 // chkeq c29, c4
	b.ne comparison_fail
	.inst 0xc2402ae4 // ldr c4, [x23, #10]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check vector registers */
	ldr x23, =0x0
	mov x4, v3.d[0]
	cmp x23, x4
	b.ne comparison_fail
	ldr x23, =0x0
	mov x4, v3.d[1]
	cmp x23, x4
	b.ne comparison_fail
	ldr x23, =0x0
	mov x4, v4.d[0]
	cmp x23, x4
	b.ne comparison_fail
	ldr x23, =0x0
	mov x4, v4.d[1]
	cmp x23, x4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001038
	ldr x1, =check_data0
	ldr x2, =0x00001040
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010f0
	ldr x1, =check_data1
	ldr x2, =0x000010f4
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001144
	ldr x1, =check_data2
	ldr x2, =0x00001148
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001533
	ldr x1, =check_data3
	ldr x2, =0x00001534
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001640
	ldr x1, =check_data4
	ldr x2, =0x00001650
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001f70
	ldr x1, =check_data5
	ldr x2, =0x00001f90
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
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
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

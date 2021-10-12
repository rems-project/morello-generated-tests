.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x0c, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0f, 0x00, 0x05, 0x00, 0x00, 0xc0, 0x00, 0x20
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x3d, 0xe4, 0x21, 0xab, 0xcb, 0x96, 0xc0, 0xea, 0xc2, 0x33, 0xc2, 0xc2
.data
check_data4:
	.byte 0xad, 0xd3, 0xc0, 0xc2, 0x13, 0xd4, 0x06, 0x78, 0x21, 0x30, 0xc2, 0xc2, 0x40, 0x82, 0xfe, 0xa2
	.byte 0x1d, 0x91, 0x21, 0x22, 0x6c, 0x5d, 0x91, 0xcb, 0xe0, 0x27, 0x58, 0xe2, 0x40, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000200000100000000000001000
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x4000000000000000000000000000
	/* C8 */
	.octa 0x48000000400401040000000000001c00
	/* C18 */
	.octa 0xd8100000000700070000000000001040
	/* C19 */
	.octa 0x0
	/* C22 */
	.octa 0xffffffffffffffff
	/* C30 */
	.octa 0x20008000c20200000000000000480001
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1
	/* C4 */
	.octa 0x4000000000000000000000000000
	/* C8 */
	.octa 0x48000000400401040000000000001c00
	/* C11 */
	.octa 0x8000000000
	/* C13 */
	.octa 0x0
	/* C18 */
	.octa 0xd8100000000700070000000000001040
	/* C19 */
	.octa 0x0
	/* C22 */
	.octa 0xffffffffffffffff
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x2000c0000005000f000000000040000c
initial_SP_EL3_value:
	.octa 0x2000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x2000c0000005000f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x8000000001f980060080000000000001
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
	.dword initial_cap_values + 112
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xab21e43d // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:29 Rn:1 imm3:001 option:111 Rm:1 01011001:01011001 S:1 op:0 sf:1
	.inst 0xeac096cb // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:11 Rn:22 imm6:100101 Rm:0 N:0 shift:11 01010:01010 opc:11 sf:1
	.inst 0xc2c233c2 // BLRS-C-C 00010:00010 Cn:30 100:100 opc:01 11000010110000100:11000010110000100
	.zero 524276
	.inst 0xc2c0d3ad // GCPERM-R.C-C Rd:13 Cn:29 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0x7806d413 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:19 Rn:0 01:01 imm9:001101101 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c23021 // CHKTGD-C-C 00001:00001 Cn:1 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xa2fe8240 // SWPAL-CC.R-C Ct:0 Rn:18 100000:100000 Cs:30 1:1 R:1 A:1 10100010:10100010
	.inst 0x2221911d // STLXP-R.CR-C Ct:29 Rn:8 Ct2:00100 1:1 Rs:1 1:1 L:0 001000100:001000100
	.inst 0xcb915d6c // sub_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:12 Rn:11 imm6:010111 Rm:17 0:0 shift:10 01011:01011 S:0 op:1 sf:1
	.inst 0xe25827e0 // ALDURH-R.RI-32 Rt:0 Rn:31 op2:01 imm9:110000010 V:0 op1:01 11100010:11100010
	.inst 0xc2c21140
	.zero 524256
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
	ldr x2, =initial_cap_values
	.inst 0xc2400040 // ldr c0, [x2, #0]
	.inst 0xc2400441 // ldr c1, [x2, #1]
	.inst 0xc2400844 // ldr c4, [x2, #2]
	.inst 0xc2400c48 // ldr c8, [x2, #3]
	.inst 0xc2401052 // ldr c18, [x2, #4]
	.inst 0xc2401453 // ldr c19, [x2, #5]
	.inst 0xc2401856 // ldr c22, [x2, #6]
	.inst 0xc2401c5e // ldr c30, [x2, #7]
	/* Set up flags and system registers */
	mov x2, #0x00000000
	msr nzcv, x2
	ldr x2, =initial_SP_EL3_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2c1d05f // cpy c31, c2
	ldr x2, =0x200
	msr CPTR_EL3, x2
	ldr x2, =0x3085103d
	msr SCTLR_EL3, x2
	ldr x2, =0x4
	msr S3_6_C1_C2_2, x2 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603142 // ldr c2, [c10, #3]
	.inst 0xc28b4122 // msr DDC_EL3, c2
	isb
	.inst 0x82601142 // ldr c2, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21040 // br c2
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30851035
	msr SCTLR_EL3, x2
	isb
	/* Check processor flags */
	mrs x2, nzcv
	ubfx x2, x2, #28, #4
	mov x10, #0xf
	and x2, x2, x10
	cmp x2, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x2, =final_cap_values
	.inst 0xc240004a // ldr c10, [x2, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240044a // ldr c10, [x2, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc240084a // ldr c10, [x2, #2]
	.inst 0xc2caa481 // chkeq c4, c10
	b.ne comparison_fail
	.inst 0xc2400c4a // ldr c10, [x2, #3]
	.inst 0xc2caa501 // chkeq c8, c10
	b.ne comparison_fail
	.inst 0xc240104a // ldr c10, [x2, #4]
	.inst 0xc2caa561 // chkeq c11, c10
	b.ne comparison_fail
	.inst 0xc240144a // ldr c10, [x2, #5]
	.inst 0xc2caa5a1 // chkeq c13, c10
	b.ne comparison_fail
	.inst 0xc240184a // ldr c10, [x2, #6]
	.inst 0xc2caa641 // chkeq c18, c10
	b.ne comparison_fail
	.inst 0xc2401c4a // ldr c10, [x2, #7]
	.inst 0xc2caa661 // chkeq c19, c10
	b.ne comparison_fail
	.inst 0xc240204a // ldr c10, [x2, #8]
	.inst 0xc2caa6c1 // chkeq c22, c10
	b.ne comparison_fail
	.inst 0xc240244a // ldr c10, [x2, #9]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	.inst 0xc240284a // ldr c10, [x2, #10]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001050
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f82
	ldr x1, =check_data2
	ldr x2, =0x00001f84
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040000c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00480000
	ldr x1, =check_data4
	ldr x2, =0x00480020
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
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

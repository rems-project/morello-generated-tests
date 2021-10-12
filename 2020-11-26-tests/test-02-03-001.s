.section data0, #alloc, #write
	.zero 272
	.byte 0x5b, 0x7b, 0xfc, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3808
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x5b, 0x7b, 0xfc, 0xff
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data6:
	.byte 0xc0, 0x33, 0xc7, 0xc2, 0xe4, 0xd8, 0x64, 0xb9, 0xb1, 0x7f, 0x1f, 0xc8, 0xfc, 0x7f, 0x1d, 0xc8
	.byte 0xde, 0x8a, 0xf0, 0xc2, 0x3f, 0x10, 0x72, 0xb8, 0x60, 0xd0, 0x11, 0x9b, 0xbd, 0x03, 0x2d, 0x38
	.byte 0x6b, 0x79, 0x60, 0x82, 0xbb, 0xad, 0x4e, 0x82, 0x80, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc
	/* C7 */
	.octa 0xffffffffffffdf2c
	/* C11 */
	.octa 0x80000000000100070000000000000ff0
	/* C13 */
	.octa 0x400000000011c0050000000000001000
	/* C18 */
	.octa 0x0
	/* C22 */
	.octa 0x3fff800000000000000000000000
	/* C27 */
	.octa 0x40000
	/* C29 */
	.octa 0x4
	/* C30 */
	.octa 0x218000
final_cap_values:
	/* C1 */
	.octa 0xc
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0xffffffffffffdf2c
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x400000000011c0050000000000001000
	/* C18 */
	.octa 0x0
	/* C22 */
	.octa 0x3fff800000000000000000000000
	/* C27 */
	.octa 0x40000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x3fff800000008400000000000000
initial_SP_EL3_value:
	.octa 0xfc
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000410100000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005581110400ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c733c0 // RRMASK-R.R-C Rd:0 Rn:30 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0xb964d8e4 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:4 Rn:7 imm12:100100110110 opc:01 111001:111001 size:10
	.inst 0xc81f7fb1 // stxr:aarch64/instrs/memory/exclusive/single Rt:17 Rn:29 Rt2:11111 o0:0 Rs:31 0:0 L:0 0010000:0010000 size:11
	.inst 0xc81d7ffc // stxr:aarch64/instrs/memory/exclusive/single Rt:28 Rn:31 Rt2:11111 o0:0 Rs:29 0:0 L:0 0010000:0010000 size:11
	.inst 0xc2f08ade // ORRFLGS-C.CI-C Cd:30 Cn:22 0:0 01:01 imm8:10000100 11000010111:11000010111
	.inst 0xb872103f // stclr:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:001 o3:0 Rs:18 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0x9b11d060 // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:0 Rn:3 Ra:20 o0:1 Rm:17 0011011000:0011011000 sf:1
	.inst 0x382d03bd // ldaddb:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:29 00:00 opc:000 0:0 Rs:13 1:1 R:0 A:0 111000:111000 size:00
	.inst 0x8260796b // ALDR-R.RI-32 Rt:11 Rn:11 op:10 imm9:000000111 L:1 1000001001:1000001001
	.inst 0x824eadbb // ASTR-R.RI-64 Rt:27 Rn:13 op:11 imm9:011101010 L:0 1000001001:1000001001
	.inst 0xc2c21180
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c1 // ldr c1, [x14, #0]
	.inst 0xc24005c7 // ldr c7, [x14, #1]
	.inst 0xc24009cb // ldr c11, [x14, #2]
	.inst 0xc2400dcd // ldr c13, [x14, #3]
	.inst 0xc24011d2 // ldr c18, [x14, #4]
	.inst 0xc24015d6 // ldr c22, [x14, #5]
	.inst 0xc24019db // ldr c27, [x14, #6]
	.inst 0xc2401ddd // ldr c29, [x14, #7]
	.inst 0xc24021de // ldr c30, [x14, #8]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =initial_SP_EL3_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2c1d1df // cpy c31, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	ldr x14, =0x4
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x8260318e // ldr c14, [c12, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x8260118e // ldr c14, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001cc // ldr c12, [x14, #0]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc24005cc // ldr c12, [x14, #1]
	.inst 0xc2cca481 // chkeq c4, c12
	b.ne comparison_fail
	.inst 0xc24009cc // ldr c12, [x14, #2]
	.inst 0xc2cca4e1 // chkeq c7, c12
	b.ne comparison_fail
	.inst 0xc2400dcc // ldr c12, [x14, #3]
	.inst 0xc2cca561 // chkeq c11, c12
	b.ne comparison_fail
	.inst 0xc24011cc // ldr c12, [x14, #4]
	.inst 0xc2cca5a1 // chkeq c13, c12
	b.ne comparison_fail
	.inst 0xc24015cc // ldr c12, [x14, #5]
	.inst 0xc2cca641 // chkeq c18, c12
	b.ne comparison_fail
	.inst 0xc24019cc // ldr c12, [x14, #6]
	.inst 0xc2cca6c1 // chkeq c22, c12
	b.ne comparison_fail
	.inst 0xc2401dcc // ldr c12, [x14, #7]
	.inst 0xc2cca761 // chkeq c27, c12
	b.ne comparison_fail
	.inst 0xc24021cc // ldr c12, [x14, #8]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	.inst 0xc24025cc // ldr c12, [x14, #9]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000100c
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001105
	ldr x1, =check_data1
	ldr x2, =0x00001106
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001108
	ldr x1, =check_data2
	ldr x2, =0x00001114
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001200
	ldr x1, =check_data3
	ldr x2, =0x00001208
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001508
	ldr x1, =check_data4
	ldr x2, =0x0000150c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001750
	ldr x1, =check_data5
	ldr x2, =0x00001758
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
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
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

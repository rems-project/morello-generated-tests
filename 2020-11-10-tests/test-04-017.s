.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x1f, 0x10, 0xc1, 0xc2, 0xcf, 0x7f, 0x5f, 0xc8, 0xc2, 0x8b, 0xc2, 0xc2, 0xc0, 0xb3, 0xc5, 0xc2
	.byte 0x40, 0xe0, 0x7f, 0x22, 0x5f, 0x8c, 0x8f, 0x38, 0x00, 0xe5, 0x5d, 0xa2, 0x3f, 0x10, 0x9a, 0xf8
	.byte 0xe1, 0xc8, 0x15, 0xb8, 0xe1, 0xfc, 0x02, 0x8b, 0xc0, 0x11, 0xc2, 0xc2
.data
check_data2:
	.zero 32
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x600120010000000000000001
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x5000300fffffe00000000
	/* C7 */
	.octa 0x10dc
	/* C8 */
	.octa 0x4fffe0
	/* C30 */
	.octa 0x529404c400000000004fe000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x10dc
	/* C2 */
	.octa 0x4fe0f8
	/* C7 */
	.octa 0x10dc
	/* C8 */
	.octa 0x4ffdc0
	/* C15 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C30 */
	.octa 0x529404c400000000004fe000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000001f80260000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c1101f // GCLIM-R.C-C Rd:31 Cn:0 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0xc85f7fcf // ldxr:aarch64/instrs/memory/exclusive/single Rt:15 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:11
	.inst 0xc2c28bc2 // CHKSSU-C.CC-C Cd:2 Cn:30 0010:0010 opc:10 Cm:2 11000010110:11000010110
	.inst 0xc2c5b3c0 // CVTP-C.R-C Cd:0 Rn:30 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0x227fe040 // LDAXP-C.R-C Ct:0 Rn:2 Ct2:11000 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.inst 0x388f8c5f // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:2 11:11 imm9:011111000 0:0 opc:10 111000:111000 size:00
	.inst 0xa25de500 // LDR-C.RIAW-C Ct:0 Rn:8 01:01 imm9:111011110 0:0 opc:01 10100010:10100010
	.inst 0xf89a103f // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:1 00:00 imm9:110100001 0:0 opc:10 111000:111000 size:11
	.inst 0xb815c8e1 // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:7 10:10 imm9:101011100 0:0 opc:00 111000:111000 size:10
	.inst 0x8b02fce1 // add_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:1 Rn:7 imm6:111111 Rm:2 0:0 shift:00 01011:01011 S:0 op:0 sf:1
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
	ldr x4, =initial_cap_values
	.inst 0xc2400080 // ldr c0, [x4, #0]
	.inst 0xc2400481 // ldr c1, [x4, #1]
	.inst 0xc2400882 // ldr c2, [x4, #2]
	.inst 0xc2400c87 // ldr c7, [x4, #3]
	.inst 0xc2401088 // ldr c8, [x4, #4]
	.inst 0xc240149e // ldr c30, [x4, #5]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	ldr x4, =0x8
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031c4 // ldr c4, [c14, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x826011c4 // ldr c4, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	isb
	/* Check processor flags */
	mrs x4, nzcv
	ubfx x4, x4, #28, #4
	mov x14, #0xf
	and x4, x4, x14
	cmp x4, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc240008e // ldr c14, [x4, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc240048e // ldr c14, [x4, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc240088e // ldr c14, [x4, #2]
	.inst 0xc2cea441 // chkeq c2, c14
	b.ne comparison_fail
	.inst 0xc2400c8e // ldr c14, [x4, #3]
	.inst 0xc2cea4e1 // chkeq c7, c14
	b.ne comparison_fail
	.inst 0xc240108e // ldr c14, [x4, #4]
	.inst 0xc2cea501 // chkeq c8, c14
	b.ne comparison_fail
	.inst 0xc240148e // ldr c14, [x4, #5]
	.inst 0xc2cea5e1 // chkeq c15, c14
	b.ne comparison_fail
	.inst 0xc240188e // ldr c14, [x4, #6]
	.inst 0xc2cea701 // chkeq c24, c14
	b.ne comparison_fail
	.inst 0xc2401c8e // ldr c14, [x4, #7]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001038
	ldr x1, =check_data0
	ldr x2, =0x0000103c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x004fe000
	ldr x1, =check_data2
	ldr x2, =0x004fe020
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004fe0f8
	ldr x1, =check_data3
	ldr x2, =0x004fe0f9
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004fffe0
	ldr x1, =check_data4
	ldr x2, =0x004ffff0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
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

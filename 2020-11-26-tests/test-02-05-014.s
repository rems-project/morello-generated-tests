.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x78
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0xdf, 0x57, 0x6d, 0x39, 0x20, 0xaa, 0x13, 0x79, 0x73, 0xf8, 0x39, 0x38, 0xf1, 0x7f, 0xa1, 0xa2
	.byte 0xa1, 0x6f, 0xd8, 0x38, 0xa9, 0x13, 0xc0, 0xda, 0x9f, 0x93, 0x62, 0xd1, 0xbe, 0x10, 0xdd, 0x0a
	.byte 0xa0, 0x6f, 0xa4, 0xb9, 0x3f, 0x00, 0x15, 0xda, 0x40, 0x11, 0xc2, 0xc2
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C17 */
	.octa 0x78000000000000000000000000000000
	/* C19 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x400402
	/* C30 */
	.octa 0x3ff200
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C9 */
	.octa 0x29
	/* C17 */
	.octa 0x78000000000000000000000000000000
	/* C19 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x400388
initial_SP_EL3_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xdc0000002006001700ffffffffe00001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x396d57df // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:30 imm12:101101010101 opc:01 111001:111001 size:00
	.inst 0x7913aa20 // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:17 imm12:010011101010 opc:00 111001:111001 size:01
	.inst 0x3839f873 // strb_reg:aarch64/instrs/memory/single/general/register Rt:19 Rn:3 10:10 S:1 option:111 Rm:25 1:1 opc:00 111000:111000 size:00
	.inst 0xa2a17ff1 // CAS-C.R-C Ct:17 Rn:31 11111:11111 R:0 Cs:1 1:1 L:0 1:1 10100010:10100010
	.inst 0x38d86fa1 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:29 11:11 imm9:110000110 0:0 opc:11 111000:111000 size:00
	.inst 0xdac013a9 // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:9 Rn:29 op:0 10110101100000000010:10110101100000000010 sf:1
	.inst 0xd162939f // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:28 imm12:100010100100 sh:1 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0x0add10be // and_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:5 imm6:000100 Rm:29 N:0 shift:11 01010:01010 opc:00 sf:0
	.inst 0xb9a46fa0 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:29 imm12:100100011011 opc:10 111001:111001 size:10
	.inst 0xda15003f // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:31 Rn:1 000000:000000 Rm:21 11010000:11010000 S:0 op:1 sf:1
	.inst 0xc2c21140
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
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c1 // ldr c1, [x14, #1]
	.inst 0xc24009c3 // ldr c3, [x14, #2]
	.inst 0xc2400dd1 // ldr c17, [x14, #3]
	.inst 0xc24011d3 // ldr c19, [x14, #4]
	.inst 0xc24015d9 // ldr c25, [x14, #5]
	.inst 0xc24019dd // ldr c29, [x14, #6]
	.inst 0xc2401dde // ldr c30, [x14, #7]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =initial_SP_EL3_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2c1d1df // cpy c31, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x3085103d
	msr SCTLR_EL3, x14
	ldr x14, =0x4
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x8260314e // ldr c14, [c10, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x8260114e // ldr c14, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
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
	.inst 0xc24001ca // ldr c10, [x14, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc24005ca // ldr c10, [x14, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc24009ca // ldr c10, [x14, #2]
	.inst 0xc2caa461 // chkeq c3, c10
	b.ne comparison_fail
	.inst 0xc2400dca // ldr c10, [x14, #3]
	.inst 0xc2caa521 // chkeq c9, c10
	b.ne comparison_fail
	.inst 0xc24011ca // ldr c10, [x14, #4]
	.inst 0xc2caa621 // chkeq c17, c10
	b.ne comparison_fail
	.inst 0xc24015ca // ldr c10, [x14, #5]
	.inst 0xc2caa661 // chkeq c19, c10
	b.ne comparison_fail
	.inst 0xc24019ca // ldr c10, [x14, #6]
	.inst 0xc2caa721 // chkeq c25, c10
	b.ne comparison_fail
	.inst 0xc2401dca // ldr c10, [x14, #7]
	.inst 0xc2caa7a1 // chkeq c29, c10
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
	ldr x0, =0x000019d4
	ldr x1, =check_data1
	ldr x2, =0x000019d6
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400d55
	ldr x1, =check_data3
	ldr x2, =0x00400d56
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00401388
	ldr x1, =check_data4
	ldr x2, =0x00401389
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004037f4
	ldr x1, =check_data5
	ldr x2, =0x004037f8
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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

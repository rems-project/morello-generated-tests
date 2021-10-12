.section data0, #alloc, #write
	.zero 64
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4016
.data
check_data0:
	.zero 16
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xc2, 0x1b, 0x4d, 0x2d, 0x97, 0xeb, 0x51, 0x62, 0x5e, 0xd0, 0xc5, 0xc2, 0x00, 0x79, 0x33, 0x38
	.byte 0xe1, 0x3f, 0x41, 0x38, 0x80, 0x91, 0xc1, 0xc2, 0x21, 0x84, 0xda, 0xc2, 0x4f, 0x56, 0x7f, 0xc8
	.byte 0x88, 0x54, 0x62, 0x54, 0x02, 0x2f, 0xe2, 0x8a, 0x60, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 16
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0xe000
	/* C8 */
	.octa 0x40000000000500070000000000000001
	/* C18 */
	.octa 0x800000000001000500000000004abfe0
	/* C19 */
	.octa 0x1ffd
	/* C28 */
	.octa 0x90000000000082000000000000000e00
	/* C30 */
	.octa 0x80000000000080080000000000001504
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C8 */
	.octa 0x40000000000500070000000000000001
	/* C15 */
	.octa 0x0
	/* C18 */
	.octa 0x800000000001000500000000004abfe0
	/* C19 */
	.octa 0x1ffd
	/* C21 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C26 */
	.octa 0x100050000000000000001
	/* C28 */
	.octa 0x90000000000082000000000000000e00
	/* C30 */
	.octa 0x80071fff000000000000e000
initial_SP_EL3_value:
	.octa 0x800000004002400400000000004f3ff2
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80071fff0000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001030
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x2d4d1bc2 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:2 Rn:30 Rt2:00110 imm7:0011010 L:1 1011010:1011010 opc:00
	.inst 0x6251eb97 // LDNP-C.RIB-C Ct:23 Rn:28 Ct2:11010 imm7:0100011 L:1 011000100:011000100
	.inst 0xc2c5d05e // CVTDZ-C.R-C Cd:30 Rn:2 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0x38337900 // strb_reg:aarch64/instrs/memory/single/general/register Rt:0 Rn:8 10:10 S:1 option:011 Rm:19 1:1 opc:00 111000:111000 size:00
	.inst 0x38413fe1 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:31 11:11 imm9:000010011 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c19180 // CLRTAG-C.C-C Cd:0 Cn:12 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xc2da8421 // CHKSS-_.CC-C 00001:00001 Cn:1 001:001 opc:00 1:1 Cm:26 11000010110:11000010110
	.inst 0xc87f564f // ldxp:aarch64/instrs/memory/exclusive/pair Rt:15 Rn:18 Rt2:10101 o0:0 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.inst 0x54625488 // b_cond:aarch64/instrs/branch/conditional/cond cond:1000 0:0 imm19:0110001001010100100 01010100:01010100
	.inst 0x8ae22f02 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:2 Rn:24 imm6:001011 Rm:2 N:1 shift:11 01010:01010 opc:00 sf:1
	.inst 0xc2c21160
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
	.inst 0xc24005c2 // ldr c2, [x14, #1]
	.inst 0xc24009c8 // ldr c8, [x14, #2]
	.inst 0xc2400dd2 // ldr c18, [x14, #3]
	.inst 0xc24011d3 // ldr c19, [x14, #4]
	.inst 0xc24015dc // ldr c28, [x14, #5]
	.inst 0xc24019de // ldr c30, [x14, #6]
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
	ldr x14, =0x0
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x8260316e // ldr c14, [c11, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x8260116e // ldr c14, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x11, #0xf
	and x14, x14, x11
	cmp x14, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001cb // ldr c11, [x14, #0]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc24005cb // ldr c11, [x14, #1]
	.inst 0xc2cba501 // chkeq c8, c11
	b.ne comparison_fail
	.inst 0xc24009cb // ldr c11, [x14, #2]
	.inst 0xc2cba5e1 // chkeq c15, c11
	b.ne comparison_fail
	.inst 0xc2400dcb // ldr c11, [x14, #3]
	.inst 0xc2cba641 // chkeq c18, c11
	b.ne comparison_fail
	.inst 0xc24011cb // ldr c11, [x14, #4]
	.inst 0xc2cba661 // chkeq c19, c11
	b.ne comparison_fail
	.inst 0xc24015cb // ldr c11, [x14, #5]
	.inst 0xc2cba6a1 // chkeq c21, c11
	b.ne comparison_fail
	.inst 0xc24019cb // ldr c11, [x14, #6]
	.inst 0xc2cba6e1 // chkeq c23, c11
	b.ne comparison_fail
	.inst 0xc2401dcb // ldr c11, [x14, #7]
	.inst 0xc2cba741 // chkeq c26, c11
	b.ne comparison_fail
	.inst 0xc24021cb // ldr c11, [x14, #8]
	.inst 0xc2cba781 // chkeq c28, c11
	b.ne comparison_fail
	.inst 0xc24025cb // ldr c11, [x14, #9]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0x0
	mov x11, v2.d[0]
	cmp x14, x11
	b.ne comparison_fail
	ldr x14, =0x0
	mov x11, v2.d[1]
	cmp x14, x11
	b.ne comparison_fail
	ldr x14, =0x0
	mov x11, v6.d[0]
	cmp x14, x11
	b.ne comparison_fail
	ldr x14, =0x0
	mov x11, v6.d[1]
	cmp x14, x11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001030
	ldr x1, =check_data0
	ldr x2, =0x00001050
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000156c
	ldr x1, =check_data1
	ldr x2, =0x00001574
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004abfe0
	ldr x1, =check_data4
	ldr x2, =0x004abff0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004f4005
	ldr x1, =check_data5
	ldr x2, =0x004f4006
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

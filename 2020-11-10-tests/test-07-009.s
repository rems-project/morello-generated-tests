.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 18
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x60, 0xb8, 0x7f, 0x22, 0x1e, 0x83, 0x27, 0x39, 0xb0, 0x23, 0x22, 0x38, 0x53, 0x6c, 0x9e, 0x82
	.byte 0xda, 0x67, 0x9c, 0x82, 0x20, 0xa4, 0xd7, 0xc2
.data
check_data4:
	.byte 0xe2, 0x4f, 0x43, 0x39, 0x1a, 0x7e, 0x46, 0x9b, 0xa5, 0x5e, 0x43, 0x90, 0xbf, 0xaf, 0x06, 0xbc
	.byte 0xc0, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
check_data6:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x204080020000c0000000000000401021
	/* C2 */
	.octa 0x40000000000100071fffffffffc40020
	/* C3 */
	.octa 0x1000
	/* C19 */
	.octa 0x0
	/* C23 */
	.octa 0x40400002000100070000000000001186
	/* C24 */
	.octa 0x1400
	/* C28 */
	.octa 0x2000000000100287
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x800000000007000ae0000000003c1000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x204080020000c0000000000000401021
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x1000
	/* C5 */
	.octa 0xc010000000010005000120580add4000
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C23 */
	.octa 0x40400002000100070000000000001186
	/* C24 */
	.octa 0x1400
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x2000000000100287
	/* C29 */
	.octa 0x404000000001000700000000000011f0
	/* C30 */
	.octa 0x20008000200020000000000000400018
initial_SP_EL3_value:
	.octa 0x80000000000100050000000000407f2b
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200020000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0100000000100050001205784200000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 128
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 128
	.dword final_cap_values + 192
	.dword final_cap_values + 208
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x227fb860 // LDAXP-C.R-C Ct:0 Rn:3 Ct2:01110 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.inst 0x3927831e // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:24 imm12:100111100000 opc:00 111001:111001 size:00
	.inst 0x382223b0 // ldeorb:aarch64/instrs/memory/atomicops/ld Rt:16 Rn:29 00:00 opc:010 0:0 Rs:2 1:1 R:0 A:0 111000:111000 size:00
	.inst 0x829e6c53 // ASTRH-R.RRB-32 Rt:19 Rn:2 opc:11 S:0 option:011 Rm:30 0:0 L:0 100000101:100000101
	.inst 0x829c67da // ALDRSB-R.RRB-64 Rt:26 Rn:30 opc:01 S:0 option:011 Rm:28 0:0 L:0 100000101:100000101
	.inst 0xc2d7a420 // BLRS-C.C-C 00000:00000 Cn:1 001:001 opc:01 1:1 Cm:23 11000010110:11000010110
	.zero 4104
	.inst 0x39434fe2 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:31 imm12:000011010011 opc:01 111001:111001 size:00
	.inst 0x9b467e1a // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:26 Rn:16 Ra:11111 0:0 Rm:6 10:10 U:0 10011011:10011011
	.inst 0x90435ea5 // ADRDP-C.ID-C Rd:5 immhi:100001101011110101 P:0 10000:10000 immlo:00 op:1
	.inst 0xbc06afbf // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:31 Rn:29 11:11 imm9:001101010 0:0 opc:00 111100:111100 size:10
	.inst 0xc2c212c0
	.zero 1044428
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e1 // ldr c1, [x15, #0]
	.inst 0xc24005e2 // ldr c2, [x15, #1]
	.inst 0xc24009e3 // ldr c3, [x15, #2]
	.inst 0xc2400df3 // ldr c19, [x15, #3]
	.inst 0xc24011f7 // ldr c23, [x15, #4]
	.inst 0xc24015f8 // ldr c24, [x15, #5]
	.inst 0xc24019fc // ldr c28, [x15, #6]
	.inst 0xc2401dfd // ldr c29, [x15, #7]
	.inst 0xc24021fe // ldr c30, [x15, #8]
	/* Vector registers */
	mrs x15, cptr_el3
	bfc x15, #10, #1
	msr cptr_el3, x15
	isb
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =initial_SP_EL3_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2c1d1ff // cpy c31, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30851037
	msr SCTLR_EL3, x15
	ldr x15, =0x4
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032cf // ldr c15, [c22, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x826012cf // ldr c15, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001f6 // ldr c22, [x15, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc24005f6 // ldr c22, [x15, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc24009f6 // ldr c22, [x15, #2]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400df6 // ldr c22, [x15, #3]
	.inst 0xc2d6a461 // chkeq c3, c22
	b.ne comparison_fail
	.inst 0xc24011f6 // ldr c22, [x15, #4]
	.inst 0xc2d6a4a1 // chkeq c5, c22
	b.ne comparison_fail
	.inst 0xc24015f6 // ldr c22, [x15, #5]
	.inst 0xc2d6a5c1 // chkeq c14, c22
	b.ne comparison_fail
	.inst 0xc24019f6 // ldr c22, [x15, #6]
	.inst 0xc2d6a601 // chkeq c16, c22
	b.ne comparison_fail
	.inst 0xc2401df6 // ldr c22, [x15, #7]
	.inst 0xc2d6a661 // chkeq c19, c22
	b.ne comparison_fail
	.inst 0xc24021f6 // ldr c22, [x15, #8]
	.inst 0xc2d6a6e1 // chkeq c23, c22
	b.ne comparison_fail
	.inst 0xc24025f6 // ldr c22, [x15, #9]
	.inst 0xc2d6a701 // chkeq c24, c22
	b.ne comparison_fail
	.inst 0xc24029f6 // ldr c22, [x15, #10]
	.inst 0xc2d6a741 // chkeq c26, c22
	b.ne comparison_fail
	.inst 0xc2402df6 // ldr c22, [x15, #11]
	.inst 0xc2d6a781 // chkeq c28, c22
	b.ne comparison_fail
	.inst 0xc24031f6 // ldr c22, [x15, #12]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc24035f6 // ldr c22, [x15, #13]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x15, =0x0
	mov x22, v31.d[0]
	cmp x15, x22
	b.ne comparison_fail
	ldr x15, =0x0
	mov x22, v31.d[1]
	cmp x15, x22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001022
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000011f0
	ldr x1, =check_data1
	ldr x2, =0x000011f4
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001de0
	ldr x1, =check_data2
	ldr x2, =0x00001de1
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400018
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00401020
	ldr x1, =check_data4
	ldr x2, =0x00401034
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00407ffe
	ldr x1, =check_data5
	ldr x2, =0x00407fff
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004c1287
	ldr x1, =check_data6
	ldr x2, =0x004c1288
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
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

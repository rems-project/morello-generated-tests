.section data0, #alloc, #write
	.zero 2960
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x20, 0x00, 0x00, 0x00
	.zero 1120
.data
check_data0:
	.byte 0x40, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x20, 0x00, 0x00, 0x00
	.zero 16
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0xe1, 0xc1, 0xd7, 0x3c, 0xbf, 0x98, 0xf1, 0xc2, 0x5f, 0x39, 0x41, 0x38, 0xfc, 0x31, 0x18, 0x38
	.byte 0xd1, 0x5f, 0x93, 0x78, 0x3e, 0xd0, 0x0f, 0xf8, 0x4f, 0x06, 0xde, 0xc2, 0xce, 0xf7, 0xe2, 0x62
	.byte 0xe1, 0x5b, 0x80, 0x82, 0xa2, 0x93, 0x5e, 0xfa, 0xa0, 0x12, 0xc2, 0xc2
.data
check_data6:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x103f
	/* C1 */
	.octa 0xf4b
	/* C5 */
	.octa 0x99f0002200200000
	/* C10 */
	.octa 0x15a0
	/* C15 */
	.octa 0x2004
	/* C17 */
	.octa 0x99effc99ff08a73f
	/* C18 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x200b
final_cap_values:
	/* C0 */
	.octa 0x103f
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0x99f0002200200000
	/* C10 */
	.octa 0x15a0
	/* C14 */
	.octa 0x20800000000000000000000000
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1b90
initial_SP_EL3_value:
	.octa 0x80000000408080010000000000416000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000500030000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd00000000003000700ffe0200000e003
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001b90
	.dword 0x0000000000001ba0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3cd7c1e1 // ldur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:1 Rn:15 00:00 imm9:101111100 0:0 opc:11 111100:111100 size:00
	.inst 0xc2f198bf // SUBS-R.CC-C Rd:31 Cn:5 100110:100110 Cm:17 11000010111:11000010111
	.inst 0x3841395f // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:10 10:10 imm9:000010011 0:0 opc:01 111000:111000 size:00
	.inst 0x381831fc // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:28 Rn:15 00:00 imm9:110000011 0:0 opc:00 111000:111000 size:00
	.inst 0x78935fd1 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:17 Rn:30 11:11 imm9:100110101 0:0 opc:10 111000:111000 size:01
	.inst 0xf80fd03e // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:1 00:00 imm9:011111101 0:0 opc:00 111000:111000 size:11
	.inst 0xc2de064f // BUILD-C.C-C Cd:15 Cn:18 001:001 opc:00 0:0 Cm:30 11000010110:11000010110
	.inst 0x62e2f7ce // LDP-C.RIBW-C Ct:14 Rn:30 Ct2:11101 imm7:1000101 L:1 011000101:011000101
	.inst 0x82805be1 // ALDRSH-R.RRB-64 Rt:1 Rn:31 opc:10 S:1 option:010 Rm:0 0:0 L:0 100000101:100000101
	.inst 0xfa5e93a2 // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0010 0:0 Rn:29 00:00 cond:1001 Rm:30 111010010:111010010 op:1 sf:1
	.inst 0xc2c212a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x13, cptr_el3
	orr x13, x13, #0x200
	msr cptr_el3, x13
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a1 // ldr c1, [x13, #1]
	.inst 0xc24009a5 // ldr c5, [x13, #2]
	.inst 0xc2400daa // ldr c10, [x13, #3]
	.inst 0xc24011af // ldr c15, [x13, #4]
	.inst 0xc24015b1 // ldr c17, [x13, #5]
	.inst 0xc24019b2 // ldr c18, [x13, #6]
	.inst 0xc2401dbc // ldr c28, [x13, #7]
	.inst 0xc24021be // ldr c30, [x13, #8]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =initial_SP_EL3_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2c1d1bf // cpy c31, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x3085003a
	msr SCTLR_EL3, x13
	ldr x13, =0x4
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032ad // ldr c13, [c21, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x826012ad // ldr c13, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x21, #0xf
	and x13, x13, x21
	cmp x13, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001b5 // ldr c21, [x13, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc24005b5 // ldr c21, [x13, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc24009b5 // ldr c21, [x13, #2]
	.inst 0xc2d5a4a1 // chkeq c5, c21
	b.ne comparison_fail
	.inst 0xc2400db5 // ldr c21, [x13, #3]
	.inst 0xc2d5a541 // chkeq c10, c21
	b.ne comparison_fail
	.inst 0xc24011b5 // ldr c21, [x13, #4]
	.inst 0xc2d5a5c1 // chkeq c14, c21
	b.ne comparison_fail
	.inst 0xc24015b5 // ldr c21, [x13, #5]
	.inst 0xc2d5a5e1 // chkeq c15, c21
	b.ne comparison_fail
	.inst 0xc24019b5 // ldr c21, [x13, #6]
	.inst 0xc2d5a621 // chkeq c17, c21
	b.ne comparison_fail
	.inst 0xc2401db5 // ldr c21, [x13, #7]
	.inst 0xc2d5a641 // chkeq c18, c21
	b.ne comparison_fail
	.inst 0xc24021b5 // ldr c21, [x13, #8]
	.inst 0xc2d5a781 // chkeq c28, c21
	b.ne comparison_fail
	.inst 0xc24025b5 // ldr c21, [x13, #9]
	.inst 0xc2d5a7a1 // chkeq c29, c21
	b.ne comparison_fail
	.inst 0xc24029b5 // ldr c21, [x13, #10]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0x0
	mov x21, v1.d[0]
	cmp x13, x21
	b.ne comparison_fail
	ldr x13, =0x0
	mov x21, v1.d[1]
	cmp x13, x21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001048
	ldr x1, =check_data0
	ldr x2, =0x00001050
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000015b3
	ldr x1, =check_data1
	ldr x2, =0x000015b4
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001b90
	ldr x1, =check_data2
	ldr x2, =0x00001bb0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f40
	ldr x1, =check_data3
	ldr x2, =0x00001f42
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f80
	ldr x1, =check_data4
	ldr x2, =0x00001f90
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0041807e
	ldr x1, =check_data6
	ldr x2, =0x00418080
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
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

	.balign 128
vector_table:
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

.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 32
.data
check_data3:
	.byte 0xff, 0xf7, 0xff, 0xc2, 0x02, 0x5f, 0xdd, 0xb0, 0x11, 0x7c, 0xdf, 0x48, 0xdf, 0xff, 0x9f, 0x48
	.byte 0x01, 0x28, 0x4a, 0x62, 0x82, 0x32, 0xc7, 0xc2, 0x17, 0x64, 0xc4, 0xc2, 0x56, 0x2c, 0x06, 0xf1
	.byte 0x2a, 0x3d, 0x09, 0x90, 0x30, 0x21, 0x01, 0x78, 0x20, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2000000700070000000000001000
	/* C4 */
	.octa 0x4010040003e001
	/* C9 */
	.octa 0x1002
	/* C16 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x2000000700070000000000001000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xffffffffffffffff
	/* C4 */
	.octa 0x4010040003e001
	/* C9 */
	.octa 0x1002
	/* C10 */
	.octa 0x127a4000
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0xfffffffffffffe74
	/* C23 */
	.octa 0x200000070007004010040003e001
	/* C30 */
	.octa 0x1000
initial_SP_EL3_value:
	.octa 0x400000005044006c0000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000460100000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc01000000007000700ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001150
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2fff7ff // ASTR-C.RRB-C Ct:31 Rn:31 1:1 L:0 S:1 option:111 Rm:31 11000010111:11000010111
	.inst 0xb0dd5f02 // ADRP-C.I-C Rd:2 immhi:101110101011111000 P:1 10000:10000 immlo:01 op:1
	.inst 0x48df7c11 // ldlarh:aarch64/instrs/memory/ordered Rt:17 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0x489fffdf // stlrh:aarch64/instrs/memory/ordered Rt:31 Rn:30 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x624a2801 // LDNP-C.RIB-C Ct:1 Rn:0 Ct2:01010 imm7:0010100 L:1 011000100:011000100
	.inst 0xc2c73282 // RRMASK-R.R-C Rd:2 Rn:20 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0xc2c46417 // CPYVALUE-C.C-C Cd:23 Cn:0 001:001 opc:11 0:0 Cm:4 11000010110:11000010110
	.inst 0xf1062c56 // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:22 Rn:2 imm12:000110001011 sh:0 0:0 10001:10001 S:1 op:1 sf:1
	.inst 0x90093d2a // ADRDP-C.ID-C Rd:10 immhi:000100100111101001 P:0 10000:10000 immlo:00 op:1
	.inst 0x78012130 // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:16 Rn:9 00:00 imm9:000010010 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c21320
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004e4 // ldr c4, [x7, #1]
	.inst 0xc24008e9 // ldr c9, [x7, #2]
	.inst 0xc2400cf0 // ldr c16, [x7, #3]
	.inst 0xc24010f4 // ldr c20, [x7, #4]
	.inst 0xc24014fe // ldr c30, [x7, #5]
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =initial_SP_EL3_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2c1d0ff // cpy c31, c7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x3085103d
	msr SCTLR_EL3, x7
	ldr x7, =0xc
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82603327 // ldr c7, [c25, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x82601327 // ldr c7, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30851035
	msr SCTLR_EL3, x7
	isb
	/* Check processor flags */
	mrs x7, nzcv
	ubfx x7, x7, #28, #4
	mov x25, #0xf
	and x7, x7, x25
	cmp x7, #0xa
	b.ne comparison_fail
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000f9 // ldr c25, [x7, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc24004f9 // ldr c25, [x7, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc24008f9 // ldr c25, [x7, #2]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400cf9 // ldr c25, [x7, #3]
	.inst 0xc2d9a481 // chkeq c4, c25
	b.ne comparison_fail
	.inst 0xc24010f9 // ldr c25, [x7, #4]
	.inst 0xc2d9a521 // chkeq c9, c25
	b.ne comparison_fail
	.inst 0xc24014f9 // ldr c25, [x7, #5]
	.inst 0xc2d9a541 // chkeq c10, c25
	b.ne comparison_fail
	.inst 0xc24018f9 // ldr c25, [x7, #6]
	.inst 0xc2d9a601 // chkeq c16, c25
	b.ne comparison_fail
	.inst 0xc2401cf9 // ldr c25, [x7, #7]
	.inst 0xc2d9a621 // chkeq c17, c25
	b.ne comparison_fail
	.inst 0xc24020f9 // ldr c25, [x7, #8]
	.inst 0xc2d9a681 // chkeq c20, c25
	b.ne comparison_fail
	.inst 0xc24024f9 // ldr c25, [x7, #9]
	.inst 0xc2d9a6c1 // chkeq c22, c25
	b.ne comparison_fail
	.inst 0xc24028f9 // ldr c25, [x7, #10]
	.inst 0xc2d9a6e1 // chkeq c23, c25
	b.ne comparison_fail
	.inst 0xc2402cf9 // ldr c25, [x7, #11]
	.inst 0xc2d9a7c1 // chkeq c30, c25
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
	ldr x0, =0x00001014
	ldr x1, =check_data1
	ldr x2, =0x00001016
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001140
	ldr x1, =check_data2
	ldr x2, =0x00001160
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
	/* Done print message */
	/* turn off MMU */
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
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

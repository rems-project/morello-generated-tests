.section data0, #alloc, #write
	.zero 720
	.byte 0x00, 0x00, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 240
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3104
.data
check_data0:
	.byte 0x90, 0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x02, 0x08, 0x00
.data
check_data1:
	.byte 0x00, 0x00, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x76, 0xdc, 0xbd, 0xea, 0x15, 0xc0, 0xc3, 0xc2, 0xc2, 0x83, 0xbe, 0xa2, 0xc1, 0x62, 0x61, 0xf8
	.byte 0x14, 0xc0, 0xbf, 0x78, 0x19, 0x50, 0xc1, 0xc2, 0xa1, 0x71, 0xdd, 0xc2
.data
check_data5:
	.byte 0xde, 0x23, 0xa7, 0xf9, 0x0a, 0x41, 0xb2, 0xb0, 0xdf, 0xc2, 0xbf, 0xb8, 0xe0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1502
	/* C1 */
	.octa 0x1000000000000000
	/* C3 */
	.octa 0x13d0
	/* C13 */
	.octa 0x90000000000700070000000000001420
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x80200000010000000000000001290
final_cap_values:
	/* C0 */
	.octa 0x1502
	/* C1 */
	.octa 0x400000000000000
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x13d0
	/* C10 */
	.octa 0xffffffff64ca1000
	/* C13 */
	.octa 0x90000000000700070000000000001420
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x13d0
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000a0010005000000000040001c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200100050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd01000000003000700ffe00000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001290
	.dword 0x00000000000012d0
	.dword initial_cap_values + 48
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xeabddc76 // bics:aarch64/instrs/integer/logical/shiftedreg Rd:22 Rn:3 imm6:110111 Rm:29 N:1 shift:10 01010:01010 opc:11 sf:1
	.inst 0xc2c3c015 // CVT-R.CC-C Rd:21 Cn:0 110000:110000 Cm:3 11000010110:11000010110
	.inst 0xa2be83c2 // SWPA-CC.R-C Ct:2 Rn:30 100000:100000 Cs:30 1:1 R:0 A:1 10100010:10100010
	.inst 0xf86162c1 // ldumax:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:22 00:00 opc:110 0:0 Rs:1 1:1 R:1 A:0 111000:111000 size:11
	.inst 0x78bfc014 // ldaprh:aarch64/instrs/memory/ordered-rcpc Rt:20 Rn:0 110000:110000 Rs:11111 111000101:111000101 size:01
	.inst 0xc2c15019 // CFHI-R.C-C Rd:25 Cn:0 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xc2dd71a1 // BLR-CI-C 1:1 0000:0000 Cn:13 100:100 imm7:1101011 110000101101:110000101101
	.zero 524260
	.inst 0xf9a723de // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:30 imm12:100111001000 opc:10 111001:111001 size:11
	.inst 0xb0b2410a // ADRP-C.I-C Rd:10 immhi:011001001000001000 P:1 10000:10000 immlo:01 op:1
	.inst 0xb8bfc2df // ldapr:aarch64/instrs/memory/ordered-rcpc Rt:31 Rn:22 110000:110000 Rs:11111 111000101:111000101 size:10
	.inst 0xc2c211e0
	.zero 524272
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
	.inst 0xc2400ae3 // ldr c3, [x23, #2]
	.inst 0xc2400eed // ldr c13, [x23, #3]
	.inst 0xc24012fd // ldr c29, [x23, #4]
	.inst 0xc24016fe // ldr c30, [x23, #5]
	/* Set up flags and system registers */
	mov x23, #0x00000000
	msr nzcv, x23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	ldr x23, =0x80
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031f7 // ldr c23, [c15, #3]
	.inst 0xc28b4137 // msr DDC_EL3, c23
	isb
	.inst 0x826011f7 // ldr c23, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c212e0 // br c23
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	isb
	/* Check processor flags */
	mrs x23, nzcv
	ubfx x23, x23, #28, #4
	mov x15, #0xf
	and x23, x23, x15
	cmp x23, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002ef // ldr c15, [x23, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc24006ef // ldr c15, [x23, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc2400aef // ldr c15, [x23, #2]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc2400eef // ldr c15, [x23, #3]
	.inst 0xc2cfa461 // chkeq c3, c15
	b.ne comparison_fail
	.inst 0xc24012ef // ldr c15, [x23, #4]
	.inst 0xc2cfa541 // chkeq c10, c15
	b.ne comparison_fail
	.inst 0xc24016ef // ldr c15, [x23, #5]
	.inst 0xc2cfa5a1 // chkeq c13, c15
	b.ne comparison_fail
	.inst 0xc2401aef // ldr c15, [x23, #6]
	.inst 0xc2cfa681 // chkeq c20, c15
	b.ne comparison_fail
	.inst 0xc2401eef // ldr c15, [x23, #7]
	.inst 0xc2cfa6a1 // chkeq c21, c15
	b.ne comparison_fail
	.inst 0xc24022ef // ldr c15, [x23, #8]
	.inst 0xc2cfa6c1 // chkeq c22, c15
	b.ne comparison_fail
	.inst 0xc24026ef // ldr c15, [x23, #9]
	.inst 0xc2cfa721 // chkeq c25, c15
	b.ne comparison_fail
	.inst 0xc2402aef // ldr c15, [x23, #10]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc2402eef // ldr c15, [x23, #11]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001290
	ldr x1, =check_data0
	ldr x2, =0x000012a0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000012d0
	ldr x1, =check_data1
	ldr x2, =0x000012e0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000013d0
	ldr x1, =check_data2
	ldr x2, =0x000013d8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001502
	ldr x1, =check_data3
	ldr x2, =0x00001504
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040001c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00480000
	ldr x1, =check_data5
	ldr x2, =0x00480010
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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

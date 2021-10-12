.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x72, 0x6c, 0x46, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x03, 0x14, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.byte 0x9e, 0x63, 0x33, 0x50, 0x01, 0x8c, 0x07, 0xf1, 0x42, 0xe0, 0xc1, 0xc2, 0xf1, 0x64, 0x8c, 0x3c
	.byte 0x57, 0xfc, 0x7f, 0x42, 0xa0, 0xff, 0xdf, 0x88, 0x7f, 0xc2, 0xbf, 0x78, 0x65, 0x68, 0x12, 0xb8
	.byte 0x4e, 0xaa, 0xc4, 0xc2, 0x5e, 0x7c, 0xa1, 0xa2, 0x60, 0x13, 0xc2, 0xc2
.data
check_data3:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1e3
	/* C2 */
	.octa 0xdc000000200300070000000000001f40
	/* C3 */
	.octa 0x4000000040020f5c0000000000002026
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x40000000000100070000000000001000
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x800000007000c001000000000048e000
	/* C29 */
	.octa 0x80000000000600070000000000001000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xdc000000200300070000000000001f40
	/* C3 */
	.octa 0x4000000040020f5c0000000000002026
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x400000000001000700000000000010c6
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x800000007000c001000000000048e000
	/* C23 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000000600070000000000001000
	/* C30 */
	.octa 0x20008000140300070000000000466c72
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000140300070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100070000000000006000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x5033639e // ADR-C.I-C Rd:30 immhi:011001101100011100 P:0 10000:10000 immlo:10 op:0
	.inst 0xf1078c01 // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:1 Rn:0 imm12:000111100011 sh:0 0:0 10001:10001 S:1 op:1 sf:1
	.inst 0xc2c1e042 // SCFLGS-C.CR-C Cd:2 Cn:2 111000:111000 Rm:1 11000010110:11000010110
	.inst 0x3c8c64f1 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:17 Rn:7 01:01 imm9:011000110 0:0 opc:10 111100:111100 size:00
	.inst 0x427ffc57 // ALDAR-R.R-32 Rt:23 Rn:2 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x88dfffa0 // ldar:aarch64/instrs/memory/ordered Rt:0 Rn:29 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0x78bfc27f // ldaprh:aarch64/instrs/memory/ordered-rcpc Rt:31 Rn:19 110000:110000 Rs:11111 111000101:111000101 size:01
	.inst 0xb8126865 // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:5 Rn:3 10:10 imm9:100100110 0:0 opc:00 111000:111000 size:10
	.inst 0xc2c4aa4e // EORFLGS-C.CR-C Cd:14 Cn:18 1010:1010 opc:10 Rm:4 11000010110:11000010110
	.inst 0xa2a17c5e // CAS-C.R-C Ct:30 Rn:2 11111:11111 R:0 Cs:1 1:1 L:0 1:1 10100010:10100010
	.inst 0xc2c21360
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
	ldr x9, =initial_cap_values
	.inst 0xc2400120 // ldr c0, [x9, #0]
	.inst 0xc2400522 // ldr c2, [x9, #1]
	.inst 0xc2400923 // ldr c3, [x9, #2]
	.inst 0xc2400d25 // ldr c5, [x9, #3]
	.inst 0xc2401127 // ldr c7, [x9, #4]
	.inst 0xc2401532 // ldr c18, [x9, #5]
	.inst 0xc2401933 // ldr c19, [x9, #6]
	.inst 0xc2401d3d // ldr c29, [x9, #7]
	/* Vector registers */
	mrs x9, cptr_el3
	bfc x9, #10, #1
	msr cptr_el3, x9
	isb
	ldr q17, =0x0
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30851035
	msr SCTLR_EL3, x9
	ldr x9, =0x4
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82603369 // ldr c9, [c27, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x82601369 // ldr c9, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30851035
	msr SCTLR_EL3, x9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x27, #0xf
	and x9, x9, x27
	cmp x9, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc240013b // ldr c27, [x9, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240053b // ldr c27, [x9, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc240093b // ldr c27, [x9, #2]
	.inst 0xc2dba441 // chkeq c2, c27
	b.ne comparison_fail
	.inst 0xc2400d3b // ldr c27, [x9, #3]
	.inst 0xc2dba461 // chkeq c3, c27
	b.ne comparison_fail
	.inst 0xc240113b // ldr c27, [x9, #4]
	.inst 0xc2dba4a1 // chkeq c5, c27
	b.ne comparison_fail
	.inst 0xc240153b // ldr c27, [x9, #5]
	.inst 0xc2dba4e1 // chkeq c7, c27
	b.ne comparison_fail
	.inst 0xc240193b // ldr c27, [x9, #6]
	.inst 0xc2dba641 // chkeq c18, c27
	b.ne comparison_fail
	.inst 0xc2401d3b // ldr c27, [x9, #7]
	.inst 0xc2dba661 // chkeq c19, c27
	b.ne comparison_fail
	.inst 0xc240213b // ldr c27, [x9, #8]
	.inst 0xc2dba6e1 // chkeq c23, c27
	b.ne comparison_fail
	.inst 0xc240253b // ldr c27, [x9, #9]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	.inst 0xc240293b // ldr c27, [x9, #10]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0x0
	mov x27, v17.d[0]
	cmp x9, x27
	b.ne comparison_fail
	ldr x9, =0x0
	mov x27, v17.d[1]
	cmp x9, x27
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
	ldr x0, =0x00001f40
	ldr x1, =check_data1
	ldr x2, =0x00001f50
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
	ldr x0, =0x0048e000
	ldr x1, =check_data3
	ldr x2, =0x0048e002
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
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

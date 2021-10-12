.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0xe0, 0x10, 0xe1, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xe1, 0x07, 0x43, 0x38, 0x4d, 0x2a, 0xdd, 0xc2, 0xbf, 0x77, 0x6b, 0x82, 0xfd, 0x77, 0x38, 0x9b
	.byte 0xdf, 0xf3, 0xab, 0x22, 0xe1, 0x7f, 0xe1, 0x08, 0xbc, 0x37, 0x00, 0x1b, 0xbd, 0xa5, 0x80, 0xda
	.byte 0xb5, 0xfb, 0x3f, 0x78, 0xe3, 0x30, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0x60, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xffffffffffffeeff
	/* C7 */
	.octa 0x20000000800100050000000000400100
	/* C18 */
	.octa 0x3fff800000000000000000000000
	/* C21 */
	.octa 0x0
	/* C28 */
	.octa 0xe110e0000001000000000400000000
	/* C29 */
	.octa 0x800000004104c4000000000000400007
	/* C30 */
	.octa 0xeff
final_cap_values:
	/* C0 */
	.octa 0xffffffffffffeeff
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0x20000000800100050000000000400100
	/* C13 */
	.octa 0x3fff800000000000000000000000
	/* C18 */
	.octa 0x3fff800000000000000000000000
	/* C21 */
	.octa 0x0
	/* C28 */
	.octa 0xbfbf88f9
	/* C29 */
	.octa 0x1101
	/* C30 */
	.octa 0x200080008000c0000000000000400028
initial_SP_EL3_value:
	.octa 0x1300
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000c0000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005600010100ffffffffffe118
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword final_cap_values + 32
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x384307e1 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:31 01:01 imm9:000110000 0:0 opc:01 111000:111000 size:00
	.inst 0xc2dd2a4d // BICFLGS-C.CR-C Cd:13 Cn:18 1010:1010 opc:00 Rm:29 11000010110:11000010110
	.inst 0x826b77bf // ALDRB-R.RI-B Rt:31 Rn:29 op:01 imm9:010110111 L:1 1000001001:1000001001
	.inst 0x9b3877fd // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:29 Rn:31 Ra:29 o0:0 Rm:24 01:01 U:0 10011011:10011011
	.inst 0x22abf3df // STP-CC.RIAW-C Ct:31 Rn:30 Ct2:11100 imm7:1010111 L:0 001000101:001000101
	.inst 0x08e17fe1 // casb:aarch64/instrs/memory/atomicops/cas/single Rt:1 Rn:31 11111:11111 o0:0 Rs:1 1:1 L:1 0010001:0010001 size:00
	.inst 0x1b0037bc // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:28 Rn:29 Ra:13 o0:0 Rm:0 0011011000:0011011000 sf:0
	.inst 0xda80a5bd // csneg:aarch64/instrs/integer/conditional/select Rd:29 Rn:13 o2:1 0:0 cond:1010 Rm:0 011010100:011010100 op:1 sf:1
	.inst 0x783ffbb5 // strh_reg:aarch64/instrs/memory/single/general/register Rt:21 Rn:29 10:10 S:1 option:111 Rm:31 1:1 opc:00 111000:111000 size:01
	.inst 0xc2c230e3 // BLRR-C-C 00011:00011 Cn:7 100:100 opc:01 11000010110000100:11000010110000100
	.zero 216
	.inst 0xc2c21360
	.zero 1048316
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
	ldr x8, =initial_cap_values
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400507 // ldr c7, [x8, #1]
	.inst 0xc2400912 // ldr c18, [x8, #2]
	.inst 0xc2400d15 // ldr c21, [x8, #3]
	.inst 0xc240111c // ldr c28, [x8, #4]
	.inst 0xc240151d // ldr c29, [x8, #5]
	.inst 0xc240191e // ldr c30, [x8, #6]
	/* Set up flags and system registers */
	mov x8, #0x80000000
	msr nzcv, x8
	ldr x8, =initial_SP_EL3_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2c1d11f // cpy c31, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x3085103d
	msr SCTLR_EL3, x8
	ldr x8, =0x84
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82603368 // ldr c8, [c27, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x82601368 // ldr c8, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* Check processor flags */
	mrs x8, nzcv
	ubfx x8, x8, #28, #4
	mov x27, #0x9
	and x8, x8, x27
	cmp x8, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc240011b // ldr c27, [x8, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240051b // ldr c27, [x8, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc240091b // ldr c27, [x8, #2]
	.inst 0xc2dba4e1 // chkeq c7, c27
	b.ne comparison_fail
	.inst 0xc2400d1b // ldr c27, [x8, #3]
	.inst 0xc2dba5a1 // chkeq c13, c27
	b.ne comparison_fail
	.inst 0xc240111b // ldr c27, [x8, #4]
	.inst 0xc2dba641 // chkeq c18, c27
	b.ne comparison_fail
	.inst 0xc240151b // ldr c27, [x8, #5]
	.inst 0xc2dba6a1 // chkeq c21, c27
	b.ne comparison_fail
	.inst 0xc240191b // ldr c27, [x8, #6]
	.inst 0xc2dba781 // chkeq c28, c27
	b.ne comparison_fail
	.inst 0xc2401d1b // ldr c27, [x8, #7]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	.inst 0xc240211b // ldr c27, [x8, #8]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001202
	ldr x1, =check_data1
	ldr x2, =0x00001204
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001401
	ldr x1, =check_data2
	ldr x2, =0x00001402
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001431
	ldr x1, =check_data3
	ldr x2, =0x00001432
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400028
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004000be
	ldr x1, =check_data5
	ldr x2, =0x004000bf
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400100
	ldr x1, =check_data6
	ldr x2, =0x00400104
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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

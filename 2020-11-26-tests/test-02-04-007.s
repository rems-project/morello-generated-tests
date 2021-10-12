.section data0, #alloc, #write
	.byte 0xff, 0xef, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x41, 0x00, 0x00
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x35, 0x10, 0x3d, 0x78, 0x21, 0xdd, 0x9e, 0xcb, 0xa1, 0x8b, 0x4f, 0x78, 0x16, 0xfc, 0x1f, 0x42
	.byte 0x7d, 0x10, 0x3e, 0x39, 0x4e, 0xd2, 0x62, 0x93, 0x7e, 0x84, 0x5f, 0x38, 0x5f, 0xc2, 0xbf, 0x78
	.byte 0x99, 0x87, 0x0b, 0x38, 0xa5, 0x13, 0x46, 0x82, 0x40, 0x13, 0xc2, 0xc2
.data
check_data6:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x1000
	/* C3 */
	.octa 0x1000
	/* C5 */
	.octa 0x4100000000000000000000000000
	/* C18 */
	.octa 0x4ffffc
	/* C22 */
	.octa 0x4000000000000000000000000000
	/* C25 */
	.octa 0x0
	/* C28 */
	.octa 0x173c
	/* C29 */
	.octa 0x48000000000100050000000000001000
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0xff8
	/* C5 */
	.octa 0x4100000000000000000000000000
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0x4ffffc
	/* C21 */
	.octa 0xefff
	/* C22 */
	.octa 0x4000000000000000000000000000
	/* C25 */
	.octa 0x0
	/* C28 */
	.octa 0x17f4
	/* C29 */
	.octa 0x48000000000100050000000000001000
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200620070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc80000000009c0050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 128
	.dword final_cap_values + 48
	.dword final_cap_values + 112
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x783d1035 // ldclrh:aarch64/instrs/memory/atomicops/ld Rt:21 Rn:1 00:00 opc:001 0:0 Rs:29 1:1 R:0 A:0 111000:111000 size:01
	.inst 0xcb9edd21 // sub_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:1 Rn:9 imm6:110111 Rm:30 0:0 shift:10 01011:01011 S:0 op:1 sf:1
	.inst 0x784f8ba1 // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:29 10:10 imm9:011111000 0:0 opc:01 111000:111000 size:01
	.inst 0x421ffc16 // STLR-C.R-C Ct:22 Rn:0 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0x393e107d // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:29 Rn:3 imm12:111110000100 opc:00 111001:111001 size:00
	.inst 0x9362d24e // sbfm:aarch64/instrs/integer/bitfield Rd:14 Rn:18 imms:110100 immr:100010 N:1 100110:100110 opc:00 sf:1
	.inst 0x385f847e // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:3 01:01 imm9:111111000 0:0 opc:01 111000:111000 size:00
	.inst 0x78bfc25f // ldaprh:aarch64/instrs/memory/ordered-rcpc Rt:31 Rn:18 110000:110000 Rs:11111 111000101:111000101 size:01
	.inst 0x380b8799 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:25 Rn:28 01:01 imm9:010111000 0:0 opc:00 111000:111000 size:00
	.inst 0x824613a5 // ASTR-C.RI-C Ct:5 Rn:29 op:00 imm9:001100001 L:0 1000001001:1000001001
	.inst 0xc2c21340
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400601 // ldr c1, [x16, #1]
	.inst 0xc2400a03 // ldr c3, [x16, #2]
	.inst 0xc2400e05 // ldr c5, [x16, #3]
	.inst 0xc2401212 // ldr c18, [x16, #4]
	.inst 0xc2401616 // ldr c22, [x16, #5]
	.inst 0xc2401a19 // ldr c25, [x16, #6]
	.inst 0xc2401e1c // ldr c28, [x16, #7]
	.inst 0xc240221d // ldr c29, [x16, #8]
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	ldr x16, =0x0
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82603350 // ldr c16, [c26, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x82601350 // ldr c16, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc240021a // ldr c26, [x16, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240061a // ldr c26, [x16, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc2400a1a // ldr c26, [x16, #2]
	.inst 0xc2daa461 // chkeq c3, c26
	b.ne comparison_fail
	.inst 0xc2400e1a // ldr c26, [x16, #3]
	.inst 0xc2daa4a1 // chkeq c5, c26
	b.ne comparison_fail
	.inst 0xc240121a // ldr c26, [x16, #4]
	.inst 0xc2daa5c1 // chkeq c14, c26
	b.ne comparison_fail
	.inst 0xc240161a // ldr c26, [x16, #5]
	.inst 0xc2daa641 // chkeq c18, c26
	b.ne comparison_fail
	.inst 0xc2401a1a // ldr c26, [x16, #6]
	.inst 0xc2daa6a1 // chkeq c21, c26
	b.ne comparison_fail
	.inst 0xc2401e1a // ldr c26, [x16, #7]
	.inst 0xc2daa6c1 // chkeq c22, c26
	b.ne comparison_fail
	.inst 0xc240221a // ldr c26, [x16, #8]
	.inst 0xc2daa721 // chkeq c25, c26
	b.ne comparison_fail
	.inst 0xc240261a // ldr c26, [x16, #9]
	.inst 0xc2daa781 // chkeq c28, c26
	b.ne comparison_fail
	.inst 0xc2402a1a // ldr c26, [x16, #10]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc2402e1a // ldr c26, [x16, #11]
	.inst 0xc2daa7c1 // chkeq c30, c26
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
	ldr x0, =0x000010f8
	ldr x1, =check_data1
	ldr x2, =0x000010fa
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001610
	ldr x1, =check_data2
	ldr x2, =0x00001620
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000173c
	ldr x1, =check_data3
	ldr x2, =0x0000173d
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f84
	ldr x1, =check_data4
	ldr x2, =0x00001f85
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
	ldr x0, =0x004ffffc
	ldr x1, =check_data6
	ldr x2, =0x004ffffe
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
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

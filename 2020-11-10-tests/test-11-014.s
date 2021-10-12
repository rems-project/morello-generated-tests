.section data0, #alloc, #write
	.byte 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x18
.data
check_data1:
	.byte 0x00, 0x10, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x0c, 0x64, 0x1d, 0xa8, 0x40, 0x00, 0x07, 0xda, 0x47, 0xb2, 0xc0, 0xc2, 0x81, 0x53, 0xfe, 0x78
	.byte 0xbb, 0x6b, 0xc0, 0xc2, 0xca, 0xfc, 0xdf, 0x48, 0xdf, 0x07, 0x14, 0xb8, 0x42, 0x18, 0x40, 0x82
	.byte 0xbe, 0x20, 0xd4, 0x1a, 0x00, 0x52, 0xc2, 0xc2
.data
check_data6:
	.byte 0x40, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000580102610000000000000e80
	/* C2 */
	.octa 0x1000
	/* C6 */
	.octa 0x800000005bfd1c020000000000001e00
	/* C12 */
	.octa 0x0
	/* C16 */
	.octa 0x20008000100140050000000000408080
	/* C18 */
	.octa 0x0
	/* C25 */
	.octa 0x4000000000
	/* C28 */
	.octa 0xc0000000400000080000000000001000
	/* C29 */
	.octa 0x3fff800000000000000000000000
	/* C30 */
	.octa 0x40000000000100050000000000001800
final_cap_values:
	/* C1 */
	.octa 0x4000
	/* C2 */
	.octa 0x1000
	/* C6 */
	.octa 0x800000005bfd1c020000000000001e00
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C16 */
	.octa 0x20008000100140050000000000408080
	/* C18 */
	.octa 0x0
	/* C25 */
	.octa 0x4000000000
	/* C28 */
	.octa 0xc0000000400000080000000000001000
	/* C29 */
	.octa 0x3fff800000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000005082000000ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 112
	.dword initial_cap_values + 144
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa81d640c // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:12 Rn:0 Rt2:11001 imm7:0111010 L:0 1010000:1010000 opc:10
	.inst 0xda070040 // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:0 Rn:2 000000:000000 Rm:7 11010000:11010000 S:0 op:1 sf:1
	.inst 0xc2c0b247 // GCSEAL-R.C-C Rd:7 Cn:18 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0x78fe5381 // ldsminh:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:28 00:00 opc:101 0:0 Rs:30 1:1 R:1 A:1 111000:111000 size:01
	.inst 0xc2c06bbb // ORRFLGS-C.CR-C Cd:27 Cn:29 1010:1010 opc:01 Rm:0 11000010110:11000010110
	.inst 0x48dffcca // ldarh:aarch64/instrs/memory/ordered Rt:10 Rn:6 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xb81407df // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:30 01:01 imm9:101000000 0:0 opc:00 111000:111000 size:10
	.inst 0x82401842 // ASTR-R.RI-32 Rt:2 Rn:2 op:10 imm9:000000001 L:0 1000001001:1000001001
	.inst 0x1ad420be // lslv:aarch64/instrs/integer/shift/variable Rd:30 Rn:5 op2:00 0010:0010 Rm:20 0011010110:0011010110 sf:0
	.inst 0xc2c25200 // RET-C-C 00000:00000 Cn:16 100:100 opc:10 11000010110000100:11000010110000100
	.zero 32856
	.inst 0xc2c21340
	.zero 1015676
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
	.inst 0xc2400502 // ldr c2, [x8, #1]
	.inst 0xc2400906 // ldr c6, [x8, #2]
	.inst 0xc2400d0c // ldr c12, [x8, #3]
	.inst 0xc2401110 // ldr c16, [x8, #4]
	.inst 0xc2401512 // ldr c18, [x8, #5]
	.inst 0xc2401919 // ldr c25, [x8, #6]
	.inst 0xc2401d1c // ldr c28, [x8, #7]
	.inst 0xc240211d // ldr c29, [x8, #8]
	.inst 0xc240251e // ldr c30, [x8, #9]
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	ldr x8, =0x4
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82603348 // ldr c8, [c26, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x82601348 // ldr c8, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc240011a // ldr c26, [x8, #0]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc240051a // ldr c26, [x8, #1]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc240091a // ldr c26, [x8, #2]
	.inst 0xc2daa4c1 // chkeq c6, c26
	b.ne comparison_fail
	.inst 0xc2400d1a // ldr c26, [x8, #3]
	.inst 0xc2daa4e1 // chkeq c7, c26
	b.ne comparison_fail
	.inst 0xc240111a // ldr c26, [x8, #4]
	.inst 0xc2daa541 // chkeq c10, c26
	b.ne comparison_fail
	.inst 0xc240151a // ldr c26, [x8, #5]
	.inst 0xc2daa581 // chkeq c12, c26
	b.ne comparison_fail
	.inst 0xc240191a // ldr c26, [x8, #6]
	.inst 0xc2daa601 // chkeq c16, c26
	b.ne comparison_fail
	.inst 0xc2401d1a // ldr c26, [x8, #7]
	.inst 0xc2daa641 // chkeq c18, c26
	b.ne comparison_fail
	.inst 0xc240211a // ldr c26, [x8, #8]
	.inst 0xc2daa721 // chkeq c25, c26
	b.ne comparison_fail
	.inst 0xc240251a // ldr c26, [x8, #9]
	.inst 0xc2daa781 // chkeq c28, c26
	b.ne comparison_fail
	.inst 0xc240291a // ldr c26, [x8, #10]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001004
	ldr x1, =check_data1
	ldr x2, =0x00001008
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001050
	ldr x1, =check_data2
	ldr x2, =0x00001060
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001804
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001e00
	ldr x1, =check_data4
	ldr x2, =0x00001e02
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400028
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00408080
	ldr x1, =check_data6
	ldr x2, =0x00408084
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

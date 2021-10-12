.section data0, #alloc, #write
	.zero 1024
	.byte 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2384
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0e, 0x10, 0x00, 0x00
	.zero 656
.data
check_data0:
	.zero 17
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x44, 0x00
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0x0e, 0x10, 0x00, 0x00
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0xac, 0x9b, 0xef, 0x68, 0x1e, 0x28, 0x5d, 0xb9, 0x0c, 0x19, 0xe0, 0xc2, 0xbf, 0x7f, 0x1f, 0x42
	.byte 0x1d, 0xd0, 0xc0, 0xc2, 0xaa, 0x60, 0xe0, 0x78, 0x80, 0xe6, 0xdf, 0x82, 0x61, 0x02, 0x09, 0x5a
	.byte 0xc4, 0x2f, 0xdf, 0xe2, 0xe1, 0x0a, 0x17, 0xe2, 0x80, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000400000040000000000000044
	/* C5 */
	.octa 0xc0000000000600170000000000001400
	/* C8 */
	.octa 0x800000030000000000000000
	/* C20 */
	.octa 0x1fbb
	/* C23 */
	.octa 0x10a0
	/* C29 */
	.octa 0x80000000000100070000000000001404
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0xc0000000000600170000000000001400
	/* C6 */
	.octa 0x0
	/* C8 */
	.octa 0x800000030000000000000000
	/* C10 */
	.octa 0x2
	/* C12 */
	.octa 0x800000030000000000000044
	/* C20 */
	.octa 0x1fbb
	/* C23 */
	.octa 0x10a0
	/* C29 */
	.octa 0x20000
	/* C30 */
	.octa 0x100e
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd00000000003000700ffe00000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x68ef9bac // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:12 Rn:29 Rt2:00110 imm7:1011111 L:1 1010001:1010001 opc:01
	.inst 0xb95d281e // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:0 imm12:011101001010 opc:01 111001:111001 size:10
	.inst 0xc2e0190c // CVT-C.CR-C Cd:12 Cn:8 0110:0110 0:0 0:0 Rm:0 11000010111:11000010111
	.inst 0x421f7fbf // ASTLR-C.R-C Ct:31 Rn:29 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xc2c0d01d // GCPERM-R.C-C Rd:29 Cn:0 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0x78e060aa // ldumaxh:aarch64/instrs/memory/atomicops/ld Rt:10 Rn:5 00:00 opc:110 0:0 Rs:0 1:1 R:1 A:1 111000:111000 size:01
	.inst 0x82dfe680 // ALDRSB-R.RRB-32 Rt:0 Rn:20 opc:01 S:0 option:111 Rm:31 0:0 L:1 100000101:100000101
	.inst 0x5a090261 // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:19 000000:000000 Rm:9 11010000:11010000 S:0 op:1 sf:0
	.inst 0xe2df2fc4 // ALDUR-C.RI-C Ct:4 Rn:30 op2:11 imm9:111110010 V:0 op1:11 11100010:11100010
	.inst 0xe2170ae1 // ALDURSB-R.RI-64 Rt:1 Rn:23 op2:10 imm9:101110000 V:0 op1:00 11100010:11100010
	.inst 0xc2c21380
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
	ldr x18, =initial_cap_values
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc2400645 // ldr c5, [x18, #1]
	.inst 0xc2400a48 // ldr c8, [x18, #2]
	.inst 0xc2400e54 // ldr c20, [x18, #3]
	.inst 0xc2401257 // ldr c23, [x18, #4]
	.inst 0xc240165d // ldr c29, [x18, #5]
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	ldr x18, =0x0
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82603392 // ldr c18, [c28, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x82601392 // ldr c18, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc240025c // ldr c28, [x18, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc240065c // ldr c28, [x18, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc2400a5c // ldr c28, [x18, #2]
	.inst 0xc2dca481 // chkeq c4, c28
	b.ne comparison_fail
	.inst 0xc2400e5c // ldr c28, [x18, #3]
	.inst 0xc2dca4a1 // chkeq c5, c28
	b.ne comparison_fail
	.inst 0xc240125c // ldr c28, [x18, #4]
	.inst 0xc2dca4c1 // chkeq c6, c28
	b.ne comparison_fail
	.inst 0xc240165c // ldr c28, [x18, #5]
	.inst 0xc2dca501 // chkeq c8, c28
	b.ne comparison_fail
	.inst 0xc2401a5c // ldr c28, [x18, #6]
	.inst 0xc2dca541 // chkeq c10, c28
	b.ne comparison_fail
	.inst 0xc2401e5c // ldr c28, [x18, #7]
	.inst 0xc2dca581 // chkeq c12, c28
	b.ne comparison_fail
	.inst 0xc240225c // ldr c28, [x18, #8]
	.inst 0xc2dca681 // chkeq c20, c28
	b.ne comparison_fail
	.inst 0xc240265c // ldr c28, [x18, #9]
	.inst 0xc2dca6e1 // chkeq c23, c28
	b.ne comparison_fail
	.inst 0xc2402a5c // ldr c28, [x18, #10]
	.inst 0xc2dca7a1 // chkeq c29, c28
	b.ne comparison_fail
	.inst 0xc2402e5c // ldr c28, [x18, #11]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001011
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001380
	ldr x1, =check_data1
	ldr x2, =0x00001390
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001400
	ldr x1, =check_data2
	ldr x2, =0x00001402
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001404
	ldr x1, =check_data3
	ldr x2, =0x0000140c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001d6c
	ldr x1, =check_data4
	ldr x2, =0x00001d70
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001fbb
	ldr x1, =check_data5
	ldr x2, =0x00001fbc
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
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

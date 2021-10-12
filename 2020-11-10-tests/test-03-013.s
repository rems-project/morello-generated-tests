.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x04
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x04
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0x21, 0x04, 0x2f, 0x88, 0xc1, 0xff, 0x9f, 0x08, 0x41, 0xdd, 0x16, 0xf8, 0xa8, 0x41, 0xa0, 0xf8
	.byte 0x32, 0x04, 0xc0, 0x5a, 0x3c, 0x0c, 0xc0, 0xda, 0x9e, 0x03, 0x12, 0x7a, 0x56, 0xfc, 0x1e, 0x08
	.byte 0xb6, 0x5a, 0x50, 0x38, 0x73, 0x79, 0x61, 0x71, 0x00, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1000
	/* C2 */
	.octa 0x101e
	/* C10 */
	.octa 0x2013
	/* C13 */
	.octa 0x1008
	/* C21 */
	.octa 0x2000
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1000
	/* C2 */
	.octa 0x101e
	/* C8 */
	.octa 0x408000000000002
	/* C10 */
	.octa 0x1f80
	/* C13 */
	.octa 0x1008
	/* C15 */
	.octa 0x1
	/* C18 */
	.octa 0x10
	/* C21 */
	.octa 0x2000
	/* C22 */
	.octa 0x0
	/* C28 */
	.octa 0x10000000000000
	/* C30 */
	.octa 0x1
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000620070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000007000700ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x882f0421 // stxp:aarch64/instrs/memory/exclusive/pair Rt:1 Rn:1 Rt2:00001 o0:0 Rs:15 1:1 L:0 0010000:0010000 sz:0 1:1
	.inst 0x089fffc1 // stlrb:aarch64/instrs/memory/ordered Rt:1 Rn:30 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xf816dd41 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:10 11:11 imm9:101101101 0:0 opc:00 111000:111000 size:11
	.inst 0xf8a041a8 // ldsmax:aarch64/instrs/memory/atomicops/ld Rt:8 Rn:13 00:00 opc:100 0:0 Rs:0 1:1 R:0 A:1 111000:111000 size:11
	.inst 0x5ac00432 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:18 Rn:1 opc:01 1011010110000000000:1011010110000000000 sf:0
	.inst 0xdac00c3c // rev:aarch64/instrs/integer/arithmetic/rev Rd:28 Rn:1 opc:11 1011010110000000000:1011010110000000000 sf:1
	.inst 0x7a12039e // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:30 Rn:28 000000:000000 Rm:18 11010000:11010000 S:1 op:1 sf:0
	.inst 0x081efc56 // stlxrb:aarch64/instrs/memory/exclusive/single Rt:22 Rn:2 Rt2:11111 o0:1 Rs:30 0:0 L:0 0010000:0010000 size:00
	.inst 0x38505ab6 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:22 Rn:21 10:10 imm9:100000101 0:0 opc:01 111000:111000 size:00
	.inst 0x71617973 // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:19 Rn:11 imm12:100001011110 sh:1 0:0 10001:10001 S:1 op:1 sf:0
	.inst 0xc2c21200
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
	ldr x29, =initial_cap_values
	.inst 0xc24003a0 // ldr c0, [x29, #0]
	.inst 0xc24007a1 // ldr c1, [x29, #1]
	.inst 0xc2400ba2 // ldr c2, [x29, #2]
	.inst 0xc2400faa // ldr c10, [x29, #3]
	.inst 0xc24013ad // ldr c13, [x29, #4]
	.inst 0xc24017b5 // ldr c21, [x29, #5]
	.inst 0xc2401bbe // ldr c30, [x29, #6]
	/* Set up flags and system registers */
	mov x29, #0x00000000
	msr nzcv, x29
	ldr x29, =0x30851037
	msr SCTLR_EL3, x29
	ldr x29, =0x0
	msr S3_6_C1_C2_2, x29 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x8260321d // ldr c29, [c16, #3]
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	.inst 0x8260121d // ldr c29, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c213a0 // br c29
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	ldr x29, =0x30851035
	msr SCTLR_EL3, x29
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003b0 // ldr c16, [x29, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc24007b0 // ldr c16, [x29, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400bb0 // ldr c16, [x29, #2]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400fb0 // ldr c16, [x29, #3]
	.inst 0xc2d0a501 // chkeq c8, c16
	b.ne comparison_fail
	.inst 0xc24013b0 // ldr c16, [x29, #4]
	.inst 0xc2d0a541 // chkeq c10, c16
	b.ne comparison_fail
	.inst 0xc24017b0 // ldr c16, [x29, #5]
	.inst 0xc2d0a5a1 // chkeq c13, c16
	b.ne comparison_fail
	.inst 0xc2401bb0 // ldr c16, [x29, #6]
	.inst 0xc2d0a5e1 // chkeq c15, c16
	b.ne comparison_fail
	.inst 0xc2401fb0 // ldr c16, [x29, #7]
	.inst 0xc2d0a641 // chkeq c18, c16
	b.ne comparison_fail
	.inst 0xc24023b0 // ldr c16, [x29, #8]
	.inst 0xc2d0a6a1 // chkeq c21, c16
	b.ne comparison_fail
	.inst 0xc24027b0 // ldr c16, [x29, #9]
	.inst 0xc2d0a6c1 // chkeq c22, c16
	b.ne comparison_fail
	.inst 0xc2402bb0 // ldr c16, [x29, #10]
	.inst 0xc2d0a781 // chkeq c28, c16
	b.ne comparison_fail
	.inst 0xc2402fb0 // ldr c16, [x29, #11]
	.inst 0xc2d0a7c1 // chkeq c30, c16
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
	ldr x0, =0x0000101e
	ldr x1, =check_data1
	ldr x2, =0x0000101f
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f05
	ldr x1, =check_data2
	ldr x2, =0x00001f06
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f80
	ldr x1, =check_data3
	ldr x2, =0x00001f88
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x29, =0x30850030
	msr SCTLR_EL3, x29
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	ldr x29, =0x30850030
	msr SCTLR_EL3, x29
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

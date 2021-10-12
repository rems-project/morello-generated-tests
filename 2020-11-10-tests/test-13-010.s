.section data0, #alloc, #write
	.zero 512
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1520
	.byte 0x82, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x01
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xdc, 0x43, 0x39, 0x38, 0x08, 0xc1, 0xbf, 0xf8, 0x9f, 0x7f, 0x59, 0x51, 0x40, 0x14, 0x87, 0x38
	.byte 0x54, 0x43, 0xbe, 0x12, 0x71, 0x76, 0xdc, 0x68, 0xbf, 0x71, 0x21, 0x38, 0xe0, 0xf3, 0x12, 0x9b
	.byte 0x00, 0x03, 0x5f, 0xd6
.data
check_data6:
	.byte 0xb3, 0xb0, 0x99, 0xb8, 0x40, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1ff1
	/* C5 */
	.octa 0x1069
	/* C8 */
	.octa 0x1000
	/* C13 */
	.octa 0x1200
	/* C19 */
	.octa 0x1e3c
	/* C24 */
	.octa 0x410b10
	/* C25 */
	.octa 0x1
	/* C30 */
	.octa 0x1800
final_cap_values:
	/* C0 */
	.octa 0x82
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x2062
	/* C5 */
	.octa 0x1069
	/* C8 */
	.octa 0x0
	/* C13 */
	.octa 0x1200
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C20 */
	.octa 0xde5ffff
	/* C24 */
	.octa 0x410b10
	/* C25 */
	.octa 0x1
	/* C28 */
	.octa 0x82
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000807004e00ffffffffffc001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x383943dc // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:28 Rn:30 00:00 opc:100 0:0 Rs:25 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xf8bfc108 // ldapr:aarch64/instrs/memory/ordered-rcpc Rt:8 Rn:8 110000:110000 Rs:11111 111000101:111000101 size:11
	.inst 0x51597f9f // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:28 imm12:011001011111 sh:1 0:0 10001:10001 S:0 op:1 sf:0
	.inst 0x38871440 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:2 01:01 imm9:001110001 0:0 opc:10 111000:111000 size:00
	.inst 0x12be4354 // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:20 imm16:1111001000011010 hw:01 100101:100101 opc:00 sf:0
	.inst 0x68dc7671 // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:17 Rn:19 Rt2:11101 imm7:0111000 L:1 1010001:1010001 opc:01
	.inst 0x382171bf // stuminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:13 00:00 opc:111 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x9b12f3e0 // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:0 Rn:31 Ra:28 o0:1 Rm:18 0011011000:0011011000 sf:1
	.inst 0xd65f0300 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:24 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 68332
	.inst 0xb899b0b3 // ldursw:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:19 Rn:5 00:00 imm9:110011011 0:0 opc:10 111000:111000 size:10
	.inst 0xc2c21340
	.zero 980200
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c1 // ldr c1, [x14, #0]
	.inst 0xc24005c2 // ldr c2, [x14, #1]
	.inst 0xc24009c5 // ldr c5, [x14, #2]
	.inst 0xc2400dc8 // ldr c8, [x14, #3]
	.inst 0xc24011cd // ldr c13, [x14, #4]
	.inst 0xc24015d3 // ldr c19, [x14, #5]
	.inst 0xc24019d8 // ldr c24, [x14, #6]
	.inst 0xc2401dd9 // ldr c25, [x14, #7]
	.inst 0xc24021de // ldr c30, [x14, #8]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	ldr x14, =0x0
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x8260334e // ldr c14, [c26, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x8260134e // ldr c14, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001da // ldr c26, [x14, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc24005da // ldr c26, [x14, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc24009da // ldr c26, [x14, #2]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400dda // ldr c26, [x14, #3]
	.inst 0xc2daa4a1 // chkeq c5, c26
	b.ne comparison_fail
	.inst 0xc24011da // ldr c26, [x14, #4]
	.inst 0xc2daa501 // chkeq c8, c26
	b.ne comparison_fail
	.inst 0xc24015da // ldr c26, [x14, #5]
	.inst 0xc2daa5a1 // chkeq c13, c26
	b.ne comparison_fail
	.inst 0xc24019da // ldr c26, [x14, #6]
	.inst 0xc2daa621 // chkeq c17, c26
	b.ne comparison_fail
	.inst 0xc2401dda // ldr c26, [x14, #7]
	.inst 0xc2daa661 // chkeq c19, c26
	b.ne comparison_fail
	.inst 0xc24021da // ldr c26, [x14, #8]
	.inst 0xc2daa681 // chkeq c20, c26
	b.ne comparison_fail
	.inst 0xc24025da // ldr c26, [x14, #9]
	.inst 0xc2daa701 // chkeq c24, c26
	b.ne comparison_fail
	.inst 0xc24029da // ldr c26, [x14, #10]
	.inst 0xc2daa721 // chkeq c25, c26
	b.ne comparison_fail
	.inst 0xc2402dda // ldr c26, [x14, #11]
	.inst 0xc2daa781 // chkeq c28, c26
	b.ne comparison_fail
	.inst 0xc24031da // ldr c26, [x14, #12]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc24035da // ldr c26, [x14, #13]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001200
	ldr x1, =check_data1
	ldr x2, =0x00001201
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001801
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001e3c
	ldr x1, =check_data3
	ldr x2, =0x00001e44
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ff1
	ldr x1, =check_data4
	ldr x2, =0x00001ff2
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400024
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00410b10
	ldr x1, =check_data6
	ldr x2, =0x00410b18
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
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

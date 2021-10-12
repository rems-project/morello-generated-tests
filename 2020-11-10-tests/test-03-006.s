.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00
	.zero 16
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4048
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x1f, 0x73, 0x44, 0xf8, 0x32, 0x91, 0x33, 0x88, 0x1f, 0x72, 0x20, 0x78, 0x7f, 0x86, 0xe1, 0xf2
	.byte 0xc3, 0x7f, 0x9f, 0xc8, 0x9b, 0x80, 0x48, 0x11, 0x50, 0x80, 0xec, 0xa2, 0x22, 0x84, 0x5e, 0xaa
	.byte 0xc1, 0xea, 0x7f, 0x82, 0x61, 0x33, 0xc1, 0xc2, 0xa0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0xdc000000000100050000000000001000
	/* C3 */
	.octa 0x0
	/* C9 */
	.octa 0x400000000021c0050000000000400010
	/* C12 */
	.octa 0x0
	/* C16 */
	.octa 0xc0000000000100050000000000001020
	/* C22 */
	.octa 0x11c0
	/* C24 */
	.octa 0x800000006007000000000000003fffc1
	/* C30 */
	.octa 0x40000000000100050000000000001020
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C9 */
	.octa 0x400000000021c0050000000000400010
	/* C12 */
	.octa 0x0
	/* C16 */
	.octa 0x2000000000000000000000000000
	/* C19 */
	.octa 0x1
	/* C22 */
	.octa 0x11c0
	/* C24 */
	.octa 0x800000006007000000000000003fffc1
	/* C30 */
	.octa 0x40000000000100050000000000001020
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000480000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000208700260000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword initial_cap_values + 128
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf844731f // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:24 00:00 imm9:001000111 0:0 opc:01 111000:111000 size:11
	.inst 0x88339132 // stlxp:aarch64/instrs/memory/exclusive/pair Rt:18 Rn:9 Rt2:00100 o0:1 Rs:19 1:1 L:0 0010000:0010000 sz:0 1:1
	.inst 0x7820721f // stuminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:16 00:00 opc:111 o3:0 Rs:0 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xf2e1867f // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:31 imm16:0000110000110011 hw:11 100101:100101 opc:11 sf:1
	.inst 0xc89f7fc3 // stllr:aarch64/instrs/memory/ordered Rt:3 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0x1148809b // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:27 Rn:4 imm12:001000100000 sh:1 0:0 10001:10001 S:0 op:0 sf:0
	.inst 0xa2ec8050 // SWPAL-CC.R-C Ct:16 Rn:2 100000:100000 Cs:12 1:1 R:1 A:1 10100010:10100010
	.inst 0xaa5e8422 // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:2 Rn:1 imm6:100001 Rm:30 N:0 shift:01 01010:01010 opc:01 sf:1
	.inst 0x827feac1 // ALDR-R.RI-32 Rt:1 Rn:22 op:10 imm9:111111110 L:1 1000001001:1000001001
	.inst 0xc2c13361 // GCFLGS-R.C-C Rd:1 Cn:27 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xc2c212a0
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c2 // ldr c2, [x14, #1]
	.inst 0xc24009c3 // ldr c3, [x14, #2]
	.inst 0xc2400dc9 // ldr c9, [x14, #3]
	.inst 0xc24011cc // ldr c12, [x14, #4]
	.inst 0xc24015d0 // ldr c16, [x14, #5]
	.inst 0xc24019d6 // ldr c22, [x14, #6]
	.inst 0xc2401dd8 // ldr c24, [x14, #7]
	.inst 0xc24021de // ldr c30, [x14, #8]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30851037
	msr SCTLR_EL3, x14
	ldr x14, =0x4
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032ae // ldr c14, [c21, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x826012ae // ldr c14, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
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
	.inst 0xc24001d5 // ldr c21, [x14, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc24005d5 // ldr c21, [x14, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc24009d5 // ldr c21, [x14, #2]
	.inst 0xc2d5a461 // chkeq c3, c21
	b.ne comparison_fail
	.inst 0xc2400dd5 // ldr c21, [x14, #3]
	.inst 0xc2d5a521 // chkeq c9, c21
	b.ne comparison_fail
	.inst 0xc24011d5 // ldr c21, [x14, #4]
	.inst 0xc2d5a581 // chkeq c12, c21
	b.ne comparison_fail
	.inst 0xc24015d5 // ldr c21, [x14, #5]
	.inst 0xc2d5a601 // chkeq c16, c21
	b.ne comparison_fail
	.inst 0xc24019d5 // ldr c21, [x14, #6]
	.inst 0xc2d5a661 // chkeq c19, c21
	b.ne comparison_fail
	.inst 0xc2401dd5 // ldr c21, [x14, #7]
	.inst 0xc2d5a6c1 // chkeq c22, c21
	b.ne comparison_fail
	.inst 0xc24021d5 // ldr c21, [x14, #8]
	.inst 0xc2d5a701 // chkeq c24, c21
	b.ne comparison_fail
	.inst 0xc24025d5 // ldr c21, [x14, #9]
	.inst 0xc2d5a7c1 // chkeq c30, c21
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001028
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000019f8
	ldr x1, =check_data2
	ldr x2, =0x000019fc
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

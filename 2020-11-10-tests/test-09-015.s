.section data0, #alloc, #write
	.zero 4080
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0x3c, 0x01, 0x0f, 0xba, 0x5e, 0xc1, 0xbf, 0x38, 0x67, 0x21, 0x42, 0xfa, 0xcc, 0x0a, 0xc0, 0xda
	.byte 0x1e, 0x10, 0xc1, 0xc2, 0x00, 0xa4, 0xc1, 0xc2, 0xa1, 0x79, 0x73, 0x82, 0x5f, 0x10, 0x3f, 0xb8
	.byte 0xe0, 0x30, 0x8e, 0xda, 0x7f, 0x0a, 0xdc, 0x93, 0xa0, 0x12, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20408002400000080000000000400019
	/* C1 */
	.octa 0x400002000000000000000000000000
	/* C2 */
	.octa 0xc0000000000100050000000000001ff8
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x4fffee
	/* C13 */
	.octa 0x400004
	/* C15 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0xc2c2c2c2
	/* C2 */
	.octa 0xc0000000000100050000000000001ff8
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x4fffee
	/* C13 */
	.octa 0x400004
	/* C15 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x400000000000000000000000000000
	/* C30 */
	.octa 0x20008000000080080000000000400018
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000000c0000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 16
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xba0f013c // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:28 Rn:9 000000:000000 Rm:15 11010000:11010000 S:1 op:0 sf:1
	.inst 0x38bfc15e // ldaprb:aarch64/instrs/memory/ordered-rcpc Rt:30 Rn:10 110000:110000 Rs:11111 111000101:111000101 size:00
	.inst 0xfa422167 // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0111 0:0 Rn:11 00:00 cond:0010 Rm:2 111010010:111010010 op:1 sf:1
	.inst 0xdac00acc // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:12 Rn:22 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2c1101e // GCLIM-R.C-C Rd:30 Cn:0 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0xc2c1a400 // BLRS-C.C-C 00000:00000 Cn:0 001:001 opc:01 1:1 Cm:1 11000010110:11000010110
	.inst 0x827379a1 // ALDR-R.RI-32 Rt:1 Rn:13 op:10 imm9:100110111 L:1 1000001001:1000001001
	.inst 0xb83f105f // stclr:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:2 00:00 opc:001 o3:0 Rs:31 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0xda8e30e0 // csinv:aarch64/instrs/integer/conditional/select Rd:0 Rn:7 o2:0 0:0 cond:0011 Rm:14 011010100:011010100 op:1 sf:1
	.inst 0x93dc0a7f // extr:aarch64/instrs/integer/ins-ext/extract/immediate Rd:31 Rn:19 imms:000010 Rm:28 0:0 N:1 00100111:00100111 sf:1
	.inst 0xc2c212a0
	.zero 1204
	.inst 0xc2c2c2c2
	.zero 1047304
	.inst 0x00c20000
	.zero 16
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
	.inst 0xc2400a02 // ldr c2, [x16, #2]
	.inst 0xc2400e09 // ldr c9, [x16, #3]
	.inst 0xc240120a // ldr c10, [x16, #4]
	.inst 0xc240160d // ldr c13, [x16, #5]
	.inst 0xc2401a0f // ldr c15, [x16, #6]
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	ldr x16, =0x4
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032b0 // ldr c16, [c21, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x826012b0 // ldr c16, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	isb
	/* Check processor flags */
	mrs x16, nzcv
	ubfx x16, x16, #28, #4
	mov x21, #0xf
	and x16, x16, x21
	cmp x16, #0x7
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400215 // ldr c21, [x16, #0]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400615 // ldr c21, [x16, #1]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400a15 // ldr c21, [x16, #2]
	.inst 0xc2d5a521 // chkeq c9, c21
	b.ne comparison_fail
	.inst 0xc2400e15 // ldr c21, [x16, #3]
	.inst 0xc2d5a541 // chkeq c10, c21
	b.ne comparison_fail
	.inst 0xc2401215 // ldr c21, [x16, #4]
	.inst 0xc2d5a5a1 // chkeq c13, c21
	b.ne comparison_fail
	.inst 0xc2401615 // ldr c21, [x16, #5]
	.inst 0xc2d5a5e1 // chkeq c15, c21
	b.ne comparison_fail
	.inst 0xc2401a15 // ldr c21, [x16, #6]
	.inst 0xc2d5a781 // chkeq c28, c21
	b.ne comparison_fail
	.inst 0xc2401e15 // ldr c21, [x16, #7]
	.inst 0xc2d5a7a1 // chkeq c29, c21
	b.ne comparison_fail
	.inst 0xc2402215 // ldr c21, [x16, #8]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001ff8
	ldr x1, =check_data0
	ldr x2, =0x00001ffc
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x004004e0
	ldr x1, =check_data2
	ldr x2, =0x004004e4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004fffee
	ldr x1, =check_data3
	ldr x2, =0x004fffef
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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

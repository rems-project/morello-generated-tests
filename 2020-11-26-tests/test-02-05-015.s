.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x70, 0x7f, 0xdf, 0x07, 0xbe, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xbd, 0xd3, 0xdb, 0xf0, 0x06, 0x43, 0xe2, 0xc2, 0x34, 0xf8, 0xf7, 0x02, 0xff, 0xb1, 0x46, 0xf8
	.byte 0xc1, 0x06, 0x1c, 0xd2, 0x7e, 0x7c, 0x5d, 0x9b, 0xff, 0xfe, 0x9f, 0x08, 0xfe, 0x9b, 0x7f, 0xc8
	.byte 0x5e, 0xf5, 0xb6, 0x9b, 0x3d, 0x80, 0x3e, 0xa2, 0xc0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x2000000040020000000000000000
	/* C10 */
	.octa 0x40ed403
	/* C15 */
	.octa 0x1005
	/* C22 */
	.octa 0x3000001030
	/* C23 */
	.octa 0x1ffe
	/* C24 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0x1000
	/* C6 */
	.octa 0x0
	/* C10 */
	.octa 0x40ed403
	/* C15 */
	.octa 0x1005
	/* C20 */
	.octa 0x200000004002ffffffffff202000
	/* C22 */
	.octa 0x3000001030
	/* C23 */
	.octa 0x1ffe
	/* C24 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0xffffffbe07df7f70
initial_SP_EL3_value:
	.octa 0x10d0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000002fcb00070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf0dbd3bd // ADRP-C.IP-C Rd:29 immhi:101101111010011101 P:1 10000:10000 immlo:11 op:1
	.inst 0xc2e24306 // BICFLGS-C.CI-C Cd:6 Cn:24 0:0 00:00 imm8:00010010 11000010111:11000010111
	.inst 0x02f7f834 // SUB-C.CIS-C Cd:20 Cn:1 imm12:110111111110 sh:1 A:1 00000010:00000010
	.inst 0xf846b1ff // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:15 00:00 imm9:001101011 0:0 opc:01 111000:111000 size:11
	.inst 0xd21c06c1 // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:1 Rn:22 imms:000001 immr:011100 N:0 100100:100100 opc:10 sf:1
	.inst 0x9b5d7c7e // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:30 Rn:3 Ra:11111 0:0 Rm:29 10:10 U:0 10011011:10011011
	.inst 0x089ffeff // stlrb:aarch64/instrs/memory/ordered Rt:31 Rn:23 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc87f9bfe // ldaxp:aarch64/instrs/memory/exclusive/pair Rt:30 Rn:31 Rt2:00110 o0:1 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.inst 0x9bb6f55e // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:30 Rn:10 Ra:29 o0:1 Rm:22 01:01 U:1 10011011:10011011
	.inst 0xa23e803d // SWP-CC.R-C Ct:29 Rn:1 100000:100000 Cs:30 1:1 R:0 A:0 10100010:10100010
	.inst 0xc2c211c0
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
	ldr x19, =initial_cap_values
	.inst 0xc2400261 // ldr c1, [x19, #0]
	.inst 0xc240066a // ldr c10, [x19, #1]
	.inst 0xc2400a6f // ldr c15, [x19, #2]
	.inst 0xc2400e76 // ldr c22, [x19, #3]
	.inst 0xc2401277 // ldr c23, [x19, #4]
	.inst 0xc2401678 // ldr c24, [x19, #5]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =initial_SP_EL3_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2c1d27f // cpy c31, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x3085103f
	msr SCTLR_EL3, x19
	ldr x19, =0xc
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031d3 // ldr c19, [c14, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x826011d3 // ldr c19, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc240026e // ldr c14, [x19, #0]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc240066e // ldr c14, [x19, #1]
	.inst 0xc2cea4c1 // chkeq c6, c14
	b.ne comparison_fail
	.inst 0xc2400a6e // ldr c14, [x19, #2]
	.inst 0xc2cea541 // chkeq c10, c14
	b.ne comparison_fail
	.inst 0xc2400e6e // ldr c14, [x19, #3]
	.inst 0xc2cea5e1 // chkeq c15, c14
	b.ne comparison_fail
	.inst 0xc240126e // ldr c14, [x19, #4]
	.inst 0xc2cea681 // chkeq c20, c14
	b.ne comparison_fail
	.inst 0xc240166e // ldr c14, [x19, #5]
	.inst 0xc2cea6c1 // chkeq c22, c14
	b.ne comparison_fail
	.inst 0xc2401a6e // ldr c14, [x19, #6]
	.inst 0xc2cea6e1 // chkeq c23, c14
	b.ne comparison_fail
	.inst 0xc2401e6e // ldr c14, [x19, #7]
	.inst 0xc2cea701 // chkeq c24, c14
	b.ne comparison_fail
	.inst 0xc240226e // ldr c14, [x19, #8]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	.inst 0xc240266e // ldr c14, [x19, #9]
	.inst 0xc2cea7c1 // chkeq c30, c14
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
	ldr x0, =0x00001070
	ldr x1, =check_data1
	ldr x2, =0x00001078
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010d0
	ldr x1, =check_data2
	ldr x2, =0x000010e0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
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
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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

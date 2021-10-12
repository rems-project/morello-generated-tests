.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x90
.data
check_data1:
	.byte 0x65, 0x21, 0xa1, 0x78, 0x41, 0x7c, 0x26, 0x79, 0xb2, 0x0f, 0xb7, 0xa9, 0x79, 0xfe, 0x9f, 0x08
	.byte 0x04, 0x7a, 0x47, 0xfa, 0xfe, 0xf3, 0xc5, 0xc2, 0x9e, 0x89, 0x1a, 0xe2, 0xe5, 0xf3, 0xc5, 0xc2
	.byte 0x70, 0x53, 0xbe, 0x78, 0x1f, 0x30, 0x72, 0xf8, 0xe0, 0x11, 0xc2, 0xc2
.data
check_data2:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x2000
	/* C2 */
	.octa 0xfffffffffffffcc8
	/* C3 */
	.octa 0x0
	/* C11 */
	.octa 0x1000
	/* C12 */
	.octa 0x800000000007c107000000000040e060
	/* C18 */
	.octa 0x2000000000200000
	/* C19 */
	.octa 0x100f
	/* C25 */
	.octa 0x90
	/* C27 */
	.octa 0x100e
	/* C29 */
	.octa 0x1090
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x2000
	/* C2 */
	.octa 0xfffffffffffffcc8
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C11 */
	.octa 0x1000
	/* C12 */
	.octa 0x800000000007c107000000000040e060
	/* C16 */
	.octa 0x9000
	/* C18 */
	.octa 0x2000000000200000
	/* C19 */
	.octa 0x100f
	/* C25 */
	.octa 0x90
	/* C27 */
	.octa 0x100e
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000500030000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000407000f00ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x78a12165 // ldeorh:aarch64/instrs/memory/atomicops/ld Rt:5 Rn:11 00:00 opc:010 0:0 Rs:1 1:1 R:0 A:1 111000:111000 size:01
	.inst 0x79267c41 // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:2 imm12:100110011111 opc:00 111001:111001 size:01
	.inst 0xa9b70fb2 // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:18 Rn:29 Rt2:00011 imm7:1101110 L:0 1010011:1010011 opc:10
	.inst 0x089ffe79 // stlrb:aarch64/instrs/memory/ordered Rt:25 Rn:19 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xfa477a04 // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0100 0:0 Rn:16 10:10 cond:0111 imm5:00111 111010010:111010010 op:1 sf:1
	.inst 0xc2c5f3fe // CVTPZ-C.R-C Cd:30 Rn:31 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0xe21a899e // ALDURSB-R.RI-64 Rt:30 Rn:12 op2:10 imm9:110101000 V:0 op1:00 11100010:11100010
	.inst 0xc2c5f3e5 // CVTPZ-C.R-C Cd:5 Rn:31 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0x78be5370 // ldsminh:aarch64/instrs/memory/atomicops/ld Rt:16 Rn:27 00:00 opc:101 0:0 Rs:30 1:1 R:0 A:1 111000:111000 size:01
	.inst 0xf872301f // stset:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:011 o3:0 Rs:18 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0xc2c211e0
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c1 // ldr c1, [x6, #1]
	.inst 0xc24008c2 // ldr c2, [x6, #2]
	.inst 0xc2400cc3 // ldr c3, [x6, #3]
	.inst 0xc24010cb // ldr c11, [x6, #4]
	.inst 0xc24014cc // ldr c12, [x6, #5]
	.inst 0xc24018d2 // ldr c18, [x6, #6]
	.inst 0xc2401cd3 // ldr c19, [x6, #7]
	.inst 0xc24020d9 // ldr c25, [x6, #8]
	.inst 0xc24024db // ldr c27, [x6, #9]
	.inst 0xc24028dd // ldr c29, [x6, #10]
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30851037
	msr SCTLR_EL3, x6
	ldr x6, =0x0
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031e6 // ldr c6, [c15, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x826011e6 // ldr c6, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000cf // ldr c15, [x6, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc24004cf // ldr c15, [x6, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc24008cf // ldr c15, [x6, #2]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc2400ccf // ldr c15, [x6, #3]
	.inst 0xc2cfa461 // chkeq c3, c15
	b.ne comparison_fail
	.inst 0xc24010cf // ldr c15, [x6, #4]
	.inst 0xc2cfa4a1 // chkeq c5, c15
	b.ne comparison_fail
	.inst 0xc24014cf // ldr c15, [x6, #5]
	.inst 0xc2cfa561 // chkeq c11, c15
	b.ne comparison_fail
	.inst 0xc24018cf // ldr c15, [x6, #6]
	.inst 0xc2cfa581 // chkeq c12, c15
	b.ne comparison_fail
	.inst 0xc2401ccf // ldr c15, [x6, #7]
	.inst 0xc2cfa601 // chkeq c16, c15
	b.ne comparison_fail
	.inst 0xc24020cf // ldr c15, [x6, #8]
	.inst 0xc2cfa641 // chkeq c18, c15
	b.ne comparison_fail
	.inst 0xc24024cf // ldr c15, [x6, #9]
	.inst 0xc2cfa661 // chkeq c19, c15
	b.ne comparison_fail
	.inst 0xc24028cf // ldr c15, [x6, #10]
	.inst 0xc2cfa721 // chkeq c25, c15
	b.ne comparison_fail
	.inst 0xc2402ccf // ldr c15, [x6, #11]
	.inst 0xc2cfa761 // chkeq c27, c15
	b.ne comparison_fail
	.inst 0xc24030cf // ldr c15, [x6, #12]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc24034cf // ldr c15, [x6, #13]
	.inst 0xc2cfa7c1 // chkeq c30, c15
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
	ldr x0, =0x0040e008
	ldr x1, =check_data2
	ldr x2, =0x0040e009
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	/* Done print message */
	/* turn off MMU */
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
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

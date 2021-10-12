.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00
.data
check_data1:
	.byte 0xff, 0x47, 0x1c, 0xf1, 0x5f, 0x7c, 0x1f, 0x42, 0x5f, 0x3a, 0x03, 0xd5, 0x74, 0xed, 0xa2, 0x30
	.byte 0x33, 0xd2, 0xd5, 0xd0, 0x42, 0x6b, 0xdf, 0xc2, 0xa0, 0xfb, 0x03, 0xb5
.data
check_data2:
	.byte 0xff, 0xea, 0x5e, 0xea, 0x5f, 0x60, 0xf9, 0x78, 0x36, 0x78, 0x00, 0x1b, 0x60, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xffffffffffffffff
	/* C2 */
	.octa 0x40000000000500030000000000001000
	/* C23 */
	.octa 0xffffffffffffffc0
	/* C25 */
	.octa 0x8000
	/* C26 */
	.octa 0x100c
	/* C30 */
	.octa 0xfc00000000000000
final_cap_values:
	/* C0 */
	.octa 0xffffffffffffffff
	/* C2 */
	.octa 0x100c
	/* C19 */
	.octa 0xffffffffaba46000
	/* C20 */
	.octa 0xfffffffffff45db9
	/* C23 */
	.octa 0xffffffffffffffc0
	/* C25 */
	.octa 0x8000
	/* C26 */
	.octa 0x100c
	/* C30 */
	.octa 0xfc00000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080003fc700070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000000010007000000000021e003
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf11c47ff // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:31 imm12:011100010001 sh:0 0:0 10001:10001 S:1 op:1 sf:1
	.inst 0x421f7c5f // ASTLR-C.R-C Ct:31 Rn:2 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xd5033a5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1010 11010101000000110011:11010101000000110011
	.inst 0x30a2ed74 // ADR-C.I-C Rd:20 immhi:010001011101101011 P:1 10000:10000 immlo:01 op:0
	.inst 0xd0d5d233 // ADRP-C.IP-C Rd:19 immhi:101010111010010001 P:1 10000:10000 immlo:10 op:1
	.inst 0xc2df6b42 // ORRFLGS-C.CR-C Cd:2 Cn:26 1010:1010 opc:01 Rm:31 11000010110:11000010110
	.inst 0xb503fba0 // cbnz:aarch64/instrs/branch/conditional/compare Rt:0 imm19:0000001111111011101 op:1 011010:011010 sf:1
	.zero 32624
	.inst 0xea5eeaff // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:23 imm6:111010 Rm:30 N:0 shift:01 01010:01010 opc:11 sf:1
	.inst 0x78f9605f // ldumaxh:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:2 00:00 opc:110 0:0 Rs:25 1:1 R:1 A:1 111000:111000 size:01
	.inst 0x1b007836 // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:22 Rn:1 Ra:30 o0:0 Rm:0 0011011000:0011011000 sf:0
	.inst 0xc2c21360
	.zero 1015908
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004a2 // ldr c2, [x5, #1]
	.inst 0xc24008b7 // ldr c23, [x5, #2]
	.inst 0xc2400cb9 // ldr c25, [x5, #3]
	.inst 0xc24010ba // ldr c26, [x5, #4]
	.inst 0xc24014be // ldr c30, [x5, #5]
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	ldr x5, =0xc
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82603365 // ldr c5, [c27, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x82601365 // ldr c5, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	isb
	/* Check processor flags */
	mrs x5, nzcv
	ubfx x5, x5, #28, #4
	mov x27, #0xf
	and x5, x5, x27
	cmp x5, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000bb // ldr c27, [x5, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc24004bb // ldr c27, [x5, #1]
	.inst 0xc2dba441 // chkeq c2, c27
	b.ne comparison_fail
	.inst 0xc24008bb // ldr c27, [x5, #2]
	.inst 0xc2dba661 // chkeq c19, c27
	b.ne comparison_fail
	.inst 0xc2400cbb // ldr c27, [x5, #3]
	.inst 0xc2dba681 // chkeq c20, c27
	b.ne comparison_fail
	.inst 0xc24010bb // ldr c27, [x5, #4]
	.inst 0xc2dba6e1 // chkeq c23, c27
	b.ne comparison_fail
	.inst 0xc24014bb // ldr c27, [x5, #5]
	.inst 0xc2dba721 // chkeq c25, c27
	b.ne comparison_fail
	.inst 0xc24018bb // ldr c27, [x5, #6]
	.inst 0xc2dba741 // chkeq c26, c27
	b.ne comparison_fail
	.inst 0xc2401cbb // ldr c27, [x5, #7]
	.inst 0xc2dba7c1 // chkeq c30, c27
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
	ldr x2, =0x0040001c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00407f8c
	ldr x1, =check_data2
	ldr x2, =0x00407f9c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	/* Done print message */
	/* turn off MMU */
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
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

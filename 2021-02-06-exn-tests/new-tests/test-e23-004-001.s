.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2ee7c3b // CASA-C.R-C Ct:27 Rn:1 11111:11111 R:0 Cs:14 1:1 L:1 1:1 10100010:10100010
	.inst 0x085ffcfd // ldaxrb:aarch64/instrs/memory/exclusive/single Rt:29 Rn:7 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0x30cb0201 // ADR-C.I-C Rd:1 immhi:100101100000010000 P:1 10000:10000 immlo:01 op:0
	.inst 0xc2f8b3f4 // EORFLGS-C.CI-C Cd:20 Cn:31 0:0 10:10 imm8:11000101 11000010111:11000010111
	.inst 0xc2c49001 // STCT-R.R-_ Rt:1 Rn:0 100:100 opc:00 11000010110001001:11000010110001001
	.zero 1004
	.inst 0x22fc1190 // LDP-CC.RIAW-C Ct:16 Rn:12 Ct2:00100 imm7:1111000 L:1 001000101:001000101
	.inst 0xf86031de // ldset:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:14 00:00 opc:011 0:0 Rs:0 1:1 R:1 A:0 111000:111000 size:11
	.inst 0x9a98d3bd // csel:aarch64/instrs/integer/conditional/select Rd:29 Rn:29 o2:0 0:0 cond:1101 Rm:24 011010100:011010100 op:0 sf:1
	.inst 0x715a2081 // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:1 Rn:4 imm12:011010001000 sh:1 0:0 10001:10001 S:1 op:1 sf:0
	.inst 0xd4000001
	.zero 64492
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
	ldr x0, =vector_table_el1
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc288c001 // msr CVBAR_EL1, c1
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	msr ttbr0_el1, x0
	mov x0, #0xff
	msr mair_el3, x0
	msr mair_el1, x0
	ldr x0, =0x0d003519
	msr tcr_el3, x0
	ldr x0, =0x0000320000803519 // No cap effects, inner shareable, normal, outer write-back read-allocate write-allocate cacheable
	msr tcr_el1, x0
	isb
	tlbi alle3
	tlbi alle1
	dsb sy
	ldr x0, =0x30851035
	msr sctlr_el3, x0
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e1 // ldr c1, [x15, #1]
	.inst 0xc24009e7 // ldr c7, [x15, #2]
	.inst 0xc2400dec // ldr c12, [x15, #3]
	.inst 0xc24011ee // ldr c14, [x15, #4]
	.inst 0xc24015fb // ldr c27, [x15, #5]
	/* Set up flags and system registers */
	ldr x15, =0x84000000
	msr SPSR_EL3, x15
	ldr x15, =initial_SP_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc288410f // msr CSP_EL0, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30d5d99f
	msr SCTLR_EL1, x15
	ldr x15, =0xc0000
	msr CPACR_EL1, x15
	ldr x15, =0x4
	msr S3_0_C1_C2_2, x15 // CCTLR_EL1
	ldr x15, =initial_DDC_EL1_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc28c412f // msr DDC_EL1, c15
	ldr x15, =0x80000000
	msr HCR_EL2, x15
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x8260114f // ldr c15, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc28e402f // msr CELR_EL3, c15
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	isb
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x10, #0xf
	and x15, x15, x10
	cmp x15, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001ea // ldr c10, [x15, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc24005ea // ldr c10, [x15, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc24009ea // ldr c10, [x15, #2]
	.inst 0xc2caa481 // chkeq c4, c10
	b.ne comparison_fail
	.inst 0xc2400dea // ldr c10, [x15, #3]
	.inst 0xc2caa4e1 // chkeq c7, c10
	b.ne comparison_fail
	.inst 0xc24011ea // ldr c10, [x15, #4]
	.inst 0xc2caa581 // chkeq c12, c10
	b.ne comparison_fail
	.inst 0xc24015ea // ldr c10, [x15, #5]
	.inst 0xc2caa5c1 // chkeq c14, c10
	b.ne comparison_fail
	.inst 0xc24019ea // ldr c10, [x15, #6]
	.inst 0xc2caa601 // chkeq c16, c10
	b.ne comparison_fail
	.inst 0xc2401dea // ldr c10, [x15, #7]
	.inst 0xc2caa681 // chkeq c20, c10
	b.ne comparison_fail
	.inst 0xc24021ea // ldr c10, [x15, #8]
	.inst 0xc2caa761 // chkeq c27, c10
	b.ne comparison_fail
	.inst 0xc24025ea // ldr c10, [x15, #9]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	.inst 0xc24029ea // ldr c10, [x15, #10]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check system registers */
	ldr x15, =final_SP_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc298410a // mrs c10, CSP_EL0
	.inst 0xc2caa5e1 // chkeq c15, c10
	b.ne comparison_fail
	ldr x15, =final_PCC_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc298402a // mrs c10, CELR_EL1
	.inst 0xc2caa5e1 // chkeq c15, c10
	b.ne comparison_fail
	ldr x15, =esr_el1_dump_address
	ldr x15, [x15]
	ldr x10, =0x2000000
	cmp x10, x15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001110
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400014
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400400
	ldr x1, =check_data3
	ldr x2, =0x40400414
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =final_tag_set_locations
check_set_tags_loop:
	ldr x1, [x0], #8
	cbz x1, check_set_tags_end
	.inst 0xc2400023 // ldr c3, [x1, #0]
	.inst 0xc2c23061 // chktgd c3
	b.cc comparison_fail
	b check_set_tags_loop
check_set_tags_end:
	ldr x0, =final_tag_unset_locations
check_unset_tags_loop:
	ldr x1, [x0], #8
	cbz x1, check_unset_tags_end
	.inst 0xc2400023 // ldr c3, [x1, #0]
	.inst 0xc2c23061 // chktgd c3
	b.cs comparison_fail
	b check_unset_tags_loop
check_unset_tags_end:
	/* Done print message */
	/* turn off MMU */
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
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

.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 240
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3824
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x3b, 0x7c, 0xee, 0xa2, 0xfd, 0xfc, 0x5f, 0x08, 0x01, 0x02, 0xcb, 0x30, 0xf4, 0xb3, 0xf8, 0xc2
	.byte 0x01, 0x90, 0xc4, 0xc2
.data
check_data3:
	.byte 0x90, 0x11, 0xfc, 0x22, 0xde, 0x31, 0x60, 0xf8, 0xbd, 0xd3, 0x98, 0x9a, 0x81, 0x20, 0x5a, 0x71
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xc0100000014b00060000000000001100
	/* C7 */
	.octa 0x80000000621100010000000000001000
	/* C12 */
	.octa 0x1000
	/* C14 */
	.octa 0x1000
	/* C27 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xff978000
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x80000000621100010000000000001000
	/* C12 */
	.octa 0xf80
	/* C14 */
	.octa 0x1000
	/* C16 */
	.octa 0x400000000000
	/* C20 */
	.octa 0x3fff80000000c500000000000000
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x400000000000
initial_SP_EL0_value:
	.octa 0x3fff800000000000000000000000
initial_DDC_EL1_value:
	.octa 0xd01000000001000700800000000fe001
initial_VBAR_EL1_value:
	.octa 0x20008000500001090000000040400000
final_SP_EL0_value:
	.octa 0x3fff800000000000000000000000
final_PCC_value:
	.octa 0x20008000500001090000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100050000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword 0x0000000000001100
	.dword 0
esr_el1_dump_address:
	.dword 0

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
	b finish
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

.section vector_table_el1, #alloc, #execinstr
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x82600d4f // ldr x15, [c10, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d4f // str x15, [c10, #0]
	ldr x15, =0x40400414
	mrs x10, ELR_EL1
	sub x15, x15, x10
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x8260014f // ldr c15, [c10, #0]
	.inst 0x020001ef // add c15, c15, #0
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x82600d4f // ldr x15, [c10, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d4f // str x15, [c10, #0]
	ldr x15, =0x40400414
	mrs x10, ELR_EL1
	sub x15, x15, x10
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x8260014f // ldr c15, [c10, #0]
	.inst 0x020201ef // add c15, c15, #128
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x82600d4f // ldr x15, [c10, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d4f // str x15, [c10, #0]
	ldr x15, =0x40400414
	mrs x10, ELR_EL1
	sub x15, x15, x10
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x8260014f // ldr c15, [c10, #0]
	.inst 0x020401ef // add c15, c15, #256
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x82600d4f // ldr x15, [c10, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d4f // str x15, [c10, #0]
	ldr x15, =0x40400414
	mrs x10, ELR_EL1
	sub x15, x15, x10
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x8260014f // ldr c15, [c10, #0]
	.inst 0x020601ef // add c15, c15, #384
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x82600d4f // ldr x15, [c10, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d4f // str x15, [c10, #0]
	ldr x15, =0x40400414
	mrs x10, ELR_EL1
	sub x15, x15, x10
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x8260014f // ldr c15, [c10, #0]
	.inst 0x020801ef // add c15, c15, #512
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x82600d4f // ldr x15, [c10, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d4f // str x15, [c10, #0]
	ldr x15, =0x40400414
	mrs x10, ELR_EL1
	sub x15, x15, x10
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x8260014f // ldr c15, [c10, #0]
	.inst 0x020a01ef // add c15, c15, #640
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x82600d4f // ldr x15, [c10, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d4f // str x15, [c10, #0]
	ldr x15, =0x40400414
	mrs x10, ELR_EL1
	sub x15, x15, x10
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x8260014f // ldr c15, [c10, #0]
	.inst 0x020c01ef // add c15, c15, #768
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x82600d4f // ldr x15, [c10, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d4f // str x15, [c10, #0]
	ldr x15, =0x40400414
	mrs x10, ELR_EL1
	sub x15, x15, x10
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x8260014f // ldr c15, [c10, #0]
	.inst 0x020e01ef // add c15, c15, #896
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x82600d4f // ldr x15, [c10, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d4f // str x15, [c10, #0]
	ldr x15, =0x40400414
	mrs x10, ELR_EL1
	sub x15, x15, x10
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x8260014f // ldr c15, [c10, #0]
	.inst 0x021001ef // add c15, c15, #1024
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x82600d4f // ldr x15, [c10, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d4f // str x15, [c10, #0]
	ldr x15, =0x40400414
	mrs x10, ELR_EL1
	sub x15, x15, x10
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x8260014f // ldr c15, [c10, #0]
	.inst 0x021201ef // add c15, c15, #1152
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x82600d4f // ldr x15, [c10, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d4f // str x15, [c10, #0]
	ldr x15, =0x40400414
	mrs x10, ELR_EL1
	sub x15, x15, x10
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x8260014f // ldr c15, [c10, #0]
	.inst 0x021401ef // add c15, c15, #1280
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x82600d4f // ldr x15, [c10, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d4f // str x15, [c10, #0]
	ldr x15, =0x40400414
	mrs x10, ELR_EL1
	sub x15, x15, x10
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x8260014f // ldr c15, [c10, #0]
	.inst 0x021601ef // add c15, c15, #1408
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x82600d4f // ldr x15, [c10, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d4f // str x15, [c10, #0]
	ldr x15, =0x40400414
	mrs x10, ELR_EL1
	sub x15, x15, x10
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x8260014f // ldr c15, [c10, #0]
	.inst 0x021801ef // add c15, c15, #1536
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x82600d4f // ldr x15, [c10, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d4f // str x15, [c10, #0]
	ldr x15, =0x40400414
	mrs x10, ELR_EL1
	sub x15, x15, x10
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x8260014f // ldr c15, [c10, #0]
	.inst 0x021a01ef // add c15, c15, #1664
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x82600d4f // ldr x15, [c10, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d4f // str x15, [c10, #0]
	ldr x15, =0x40400414
	mrs x10, ELR_EL1
	sub x15, x15, x10
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x8260014f // ldr c15, [c10, #0]
	.inst 0x021c01ef // add c15, c15, #1792
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x82600d4f // ldr x15, [c10, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d4f // str x15, [c10, #0]
	ldr x15, =0x40400414
	mrs x10, ELR_EL1
	sub x15, x15, x10
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ea // cvtp c10, x15
	.inst 0xc2cf414a // scvalue c10, c10, x15
	.inst 0x8260014f // ldr c15, [c10, #0]
	.inst 0x021e01ef // add c15, c15, #1920
	.inst 0xc2c211e0 // br c15

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0

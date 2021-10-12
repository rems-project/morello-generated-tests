.section text0, #alloc, #execinstr
test_start:
	.inst 0x3890de2c // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:12 Rn:17 11:11 imm9:100001101 0:0 opc:10 111000:111000 size:00
	.inst 0xc2c5f01e // CVTPZ-C.R-C Cd:30 Rn:0 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0x2c8623e6 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:6 Rn:31 Rt2:01000 imm7:0001100 L:0 1011001:1011001 opc:00
	.inst 0xc2dda3b6 // CLRPERM-C.CR-C Cd:22 Cn:29 000:000 1:1 10:10 Rm:29 11000010110:11000010110
	.inst 0xda85a52b // csneg:aarch64/instrs/integer/conditional/select Rd:11 Rn:9 o2:1 0:0 cond:1010 Rm:5 011010100:011010100 op:1 sf:1
	.inst 0xc2c4b38c // LDCT-R.R-_ Rt:12 Rn:28 100:100 opc:01 11000010110001001:11000010110001001
	.inst 0x08df7ca1 // ldlarb:aarch64/instrs/memory/ordered Rt:1 Rn:5 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x3822137f // stclrb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:27 00:00 opc:001 o3:0 Rs:2 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xa2a3822d // SWPA-CC.R-C Ct:13 Rn:17 100000:100000 Cs:3 1:1 R:0 A:1 10100010:10100010
	.inst 0xd4000001
	.zero 65496
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c2 // ldr c2, [x14, #1]
	.inst 0xc24009c3 // ldr c3, [x14, #2]
	.inst 0xc2400dc5 // ldr c5, [x14, #3]
	.inst 0xc24011d1 // ldr c17, [x14, #4]
	.inst 0xc24015db // ldr c27, [x14, #5]
	.inst 0xc24019dc // ldr c28, [x14, #6]
	.inst 0xc2401ddd // ldr c29, [x14, #7]
	/* Vector registers */
	mrs x14, cptr_el3
	bfc x14, #10, #1
	msr cptr_el3, x14
	isb
	ldr q6, =0x0
	ldr q8, =0xc3000000
	/* Set up flags and system registers */
	ldr x14, =0x0
	msr SPSR_EL3, x14
	ldr x14, =initial_SP_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc288410e // msr CSP_EL0, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30d5d99f
	msr SCTLR_EL1, x14
	ldr x14, =0x3c0000
	msr CPACR_EL1, x14
	ldr x14, =0x0
	msr S3_0_C1_C2_2, x14 // CCTLR_EL1
	ldr x14, =0x4
	msr S3_3_C1_C2_2, x14 // CCTLR_EL0
	ldr x14, =initial_DDC_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc288412e // msr DDC_EL0, c14
	ldr x14, =0x80000000
	msr HCR_EL2, x14
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x8260114e // ldr c14, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc28e402e // msr CELR_EL3, c14
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x10, #0x9
	and x14, x14, x10
	cmp x14, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001ca // ldr c10, [x14, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc24005ca // ldr c10, [x14, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc24009ca // ldr c10, [x14, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400dca // ldr c10, [x14, #3]
	.inst 0xc2caa461 // chkeq c3, c10
	b.ne comparison_fail
	.inst 0xc24011ca // ldr c10, [x14, #4]
	.inst 0xc2caa4a1 // chkeq c5, c10
	b.ne comparison_fail
	.inst 0xc24015ca // ldr c10, [x14, #5]
	.inst 0xc2caa581 // chkeq c12, c10
	b.ne comparison_fail
	.inst 0xc24019ca // ldr c10, [x14, #6]
	.inst 0xc2caa5a1 // chkeq c13, c10
	b.ne comparison_fail
	.inst 0xc2401dca // ldr c10, [x14, #7]
	.inst 0xc2caa621 // chkeq c17, c10
	b.ne comparison_fail
	.inst 0xc24021ca // ldr c10, [x14, #8]
	.inst 0xc2caa6c1 // chkeq c22, c10
	b.ne comparison_fail
	.inst 0xc24025ca // ldr c10, [x14, #9]
	.inst 0xc2caa761 // chkeq c27, c10
	b.ne comparison_fail
	.inst 0xc24029ca // ldr c10, [x14, #10]
	.inst 0xc2caa781 // chkeq c28, c10
	b.ne comparison_fail
	.inst 0xc2402dca // ldr c10, [x14, #11]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	.inst 0xc24031ca // ldr c10, [x14, #12]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0x0
	mov x10, v6.d[0]
	cmp x14, x10
	b.ne comparison_fail
	ldr x14, =0x0
	mov x10, v6.d[1]
	cmp x14, x10
	b.ne comparison_fail
	ldr x14, =0xc3000000
	mov x10, v8.d[0]
	cmp x14, x10
	b.ne comparison_fail
	ldr x14, =0x0
	mov x10, v8.d[1]
	cmp x14, x10
	b.ne comparison_fail
	/* Check system registers */
	ldr x14, =final_SP_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc298410a // mrs c10, CSP_EL0
	.inst 0xc2caa5c1 // chkeq c14, c10
	b.ne comparison_fail
	ldr x14, =final_PCC_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc298402a // mrs c10, CELR_EL1
	.inst 0xc2caa5c1 // chkeq c14, c10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001020
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001200
	ldr x1, =check_data2
	ldr x2, =0x00001208
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f40
	ldr x1, =check_data3
	ldr x2, =0x00001f80
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400028
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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

.section data0, #alloc, #write
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xff
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x40, 0xd4, 0x00, 0x40, 0x10, 0x00, 0x02, 0x02, 0x00, 0xd4
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc3
.data
check_data3:
	.zero 64
.data
check_data4:
	.byte 0x2c, 0xde, 0x90, 0x38, 0x1e, 0xf0, 0xc5, 0xc2, 0xe6, 0x23, 0x86, 0x2c, 0xb6, 0xa3, 0xdd, 0xc2
	.byte 0x2b, 0xa5, 0x85, 0xda, 0x8c, 0xb3, 0xc4, 0xc2, 0xa1, 0x7c, 0xdf, 0x08, 0x7f, 0x13, 0x22, 0x38
	.byte 0x2d, 0x82, 0xa3, 0xa2, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0xd400020200104000d440800000000000
	/* C5 */
	.octa 0x1000
	/* C17 */
	.octa 0x1103
	/* C27 */
	.octa 0x1000
	/* C28 */
	.octa 0x1f40
	/* C29 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xff
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0xd400020200104000d440800000000000
	/* C5 */
	.octa 0x1000
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C17 */
	.octa 0x1010
	/* C22 */
	.octa 0x0
	/* C27 */
	.octa 0x1000
	/* C28 */
	.octa 0x1f40
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x1200
initial_DDC_EL0_value:
	.octa 0xc00000000003000700ffe00000100001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x1230
final_PCC_value:
	.octa 0x20008000000080080000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001f40
	.dword 0x0000000000001f50
	.dword 0x0000000000001f60
	.dword el1_vector_jump_cap
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
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
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1ca // cvtp c10, x14
	.inst 0xc2ce414a // scvalue c10, c10, x14
	.inst 0x82600d4e // ldr x14, [c10, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d4e // str x14, [c10, #0]
	ldr x14, =0x40400028
	mrs x10, ELR_EL1
	sub x14, x14, x10
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ca // cvtp c10, x14
	.inst 0xc2ce414a // scvalue c10, c10, x14
	.inst 0x8260014e // ldr c14, [c10, #0]
	.inst 0x020001ce // add c14, c14, #0
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1ca // cvtp c10, x14
	.inst 0xc2ce414a // scvalue c10, c10, x14
	.inst 0x82600d4e // ldr x14, [c10, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d4e // str x14, [c10, #0]
	ldr x14, =0x40400028
	mrs x10, ELR_EL1
	sub x14, x14, x10
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ca // cvtp c10, x14
	.inst 0xc2ce414a // scvalue c10, c10, x14
	.inst 0x8260014e // ldr c14, [c10, #0]
	.inst 0x020201ce // add c14, c14, #128
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1ca // cvtp c10, x14
	.inst 0xc2ce414a // scvalue c10, c10, x14
	.inst 0x82600d4e // ldr x14, [c10, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d4e // str x14, [c10, #0]
	ldr x14, =0x40400028
	mrs x10, ELR_EL1
	sub x14, x14, x10
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ca // cvtp c10, x14
	.inst 0xc2ce414a // scvalue c10, c10, x14
	.inst 0x8260014e // ldr c14, [c10, #0]
	.inst 0x020401ce // add c14, c14, #256
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1ca // cvtp c10, x14
	.inst 0xc2ce414a // scvalue c10, c10, x14
	.inst 0x82600d4e // ldr x14, [c10, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d4e // str x14, [c10, #0]
	ldr x14, =0x40400028
	mrs x10, ELR_EL1
	sub x14, x14, x10
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ca // cvtp c10, x14
	.inst 0xc2ce414a // scvalue c10, c10, x14
	.inst 0x8260014e // ldr c14, [c10, #0]
	.inst 0x020601ce // add c14, c14, #384
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1ca // cvtp c10, x14
	.inst 0xc2ce414a // scvalue c10, c10, x14
	.inst 0x82600d4e // ldr x14, [c10, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d4e // str x14, [c10, #0]
	ldr x14, =0x40400028
	mrs x10, ELR_EL1
	sub x14, x14, x10
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ca // cvtp c10, x14
	.inst 0xc2ce414a // scvalue c10, c10, x14
	.inst 0x8260014e // ldr c14, [c10, #0]
	.inst 0x020801ce // add c14, c14, #512
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1ca // cvtp c10, x14
	.inst 0xc2ce414a // scvalue c10, c10, x14
	.inst 0x82600d4e // ldr x14, [c10, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d4e // str x14, [c10, #0]
	ldr x14, =0x40400028
	mrs x10, ELR_EL1
	sub x14, x14, x10
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ca // cvtp c10, x14
	.inst 0xc2ce414a // scvalue c10, c10, x14
	.inst 0x8260014e // ldr c14, [c10, #0]
	.inst 0x020a01ce // add c14, c14, #640
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1ca // cvtp c10, x14
	.inst 0xc2ce414a // scvalue c10, c10, x14
	.inst 0x82600d4e // ldr x14, [c10, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d4e // str x14, [c10, #0]
	ldr x14, =0x40400028
	mrs x10, ELR_EL1
	sub x14, x14, x10
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ca // cvtp c10, x14
	.inst 0xc2ce414a // scvalue c10, c10, x14
	.inst 0x8260014e // ldr c14, [c10, #0]
	.inst 0x020c01ce // add c14, c14, #768
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1ca // cvtp c10, x14
	.inst 0xc2ce414a // scvalue c10, c10, x14
	.inst 0x82600d4e // ldr x14, [c10, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d4e // str x14, [c10, #0]
	ldr x14, =0x40400028
	mrs x10, ELR_EL1
	sub x14, x14, x10
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ca // cvtp c10, x14
	.inst 0xc2ce414a // scvalue c10, c10, x14
	.inst 0x8260014e // ldr c14, [c10, #0]
	.inst 0x020e01ce // add c14, c14, #896
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1ca // cvtp c10, x14
	.inst 0xc2ce414a // scvalue c10, c10, x14
	.inst 0x82600d4e // ldr x14, [c10, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d4e // str x14, [c10, #0]
	ldr x14, =0x40400028
	mrs x10, ELR_EL1
	sub x14, x14, x10
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ca // cvtp c10, x14
	.inst 0xc2ce414a // scvalue c10, c10, x14
	.inst 0x8260014e // ldr c14, [c10, #0]
	.inst 0x021001ce // add c14, c14, #1024
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1ca // cvtp c10, x14
	.inst 0xc2ce414a // scvalue c10, c10, x14
	.inst 0x82600d4e // ldr x14, [c10, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d4e // str x14, [c10, #0]
	ldr x14, =0x40400028
	mrs x10, ELR_EL1
	sub x14, x14, x10
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ca // cvtp c10, x14
	.inst 0xc2ce414a // scvalue c10, c10, x14
	.inst 0x8260014e // ldr c14, [c10, #0]
	.inst 0x021201ce // add c14, c14, #1152
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1ca // cvtp c10, x14
	.inst 0xc2ce414a // scvalue c10, c10, x14
	.inst 0x82600d4e // ldr x14, [c10, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d4e // str x14, [c10, #0]
	ldr x14, =0x40400028
	mrs x10, ELR_EL1
	sub x14, x14, x10
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ca // cvtp c10, x14
	.inst 0xc2ce414a // scvalue c10, c10, x14
	.inst 0x8260014e // ldr c14, [c10, #0]
	.inst 0x021401ce // add c14, c14, #1280
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1ca // cvtp c10, x14
	.inst 0xc2ce414a // scvalue c10, c10, x14
	.inst 0x82600d4e // ldr x14, [c10, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d4e // str x14, [c10, #0]
	ldr x14, =0x40400028
	mrs x10, ELR_EL1
	sub x14, x14, x10
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ca // cvtp c10, x14
	.inst 0xc2ce414a // scvalue c10, c10, x14
	.inst 0x8260014e // ldr c14, [c10, #0]
	.inst 0x021601ce // add c14, c14, #1408
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1ca // cvtp c10, x14
	.inst 0xc2ce414a // scvalue c10, c10, x14
	.inst 0x82600d4e // ldr x14, [c10, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d4e // str x14, [c10, #0]
	ldr x14, =0x40400028
	mrs x10, ELR_EL1
	sub x14, x14, x10
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ca // cvtp c10, x14
	.inst 0xc2ce414a // scvalue c10, c10, x14
	.inst 0x8260014e // ldr c14, [c10, #0]
	.inst 0x021801ce // add c14, c14, #1536
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1ca // cvtp c10, x14
	.inst 0xc2ce414a // scvalue c10, c10, x14
	.inst 0x82600d4e // ldr x14, [c10, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d4e // str x14, [c10, #0]
	ldr x14, =0x40400028
	mrs x10, ELR_EL1
	sub x14, x14, x10
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ca // cvtp c10, x14
	.inst 0xc2ce414a // scvalue c10, c10, x14
	.inst 0x8260014e // ldr c14, [c10, #0]
	.inst 0x021a01ce // add c14, c14, #1664
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1ca // cvtp c10, x14
	.inst 0xc2ce414a // scvalue c10, c10, x14
	.inst 0x82600d4e // ldr x14, [c10, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d4e // str x14, [c10, #0]
	ldr x14, =0x40400028
	mrs x10, ELR_EL1
	sub x14, x14, x10
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ca // cvtp c10, x14
	.inst 0xc2ce414a // scvalue c10, c10, x14
	.inst 0x8260014e // ldr c14, [c10, #0]
	.inst 0x021c01ce // add c14, c14, #1792
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1ca // cvtp c10, x14
	.inst 0xc2ce414a // scvalue c10, c10, x14
	.inst 0x82600d4e // ldr x14, [c10, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400d4e // str x14, [c10, #0]
	ldr x14, =0x40400028
	mrs x10, ELR_EL1
	sub x14, x14, x10
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ca // cvtp c10, x14
	.inst 0xc2ce414a // scvalue c10, c10, x14
	.inst 0x8260014e // ldr c14, [c10, #0]
	.inst 0x021e01ce // add c14, c14, #1920
	.inst 0xc2c211c0 // br c14

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0

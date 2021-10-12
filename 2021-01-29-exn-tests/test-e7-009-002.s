.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c18421 // CHKSS-_.CC-C 00001:00001 Cn:1 001:001 opc:00 1:1 Cm:1 11000010110:11000010110
	.inst 0x6253e40c // LDNP-C.RIB-C Ct:12 Rn:0 Ct2:11001 imm7:0100111 L:1 011000100:011000100
	.inst 0x0b3dc91f // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:31 Rn:8 imm3:010 option:110 Rm:29 01011001:01011001 S:0 op:0 sf:0
	.inst 0x78bd613e // ldumaxh:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:9 00:00 opc:110 0:0 Rs:29 1:1 R:0 A:1 111000:111000 size:01
	.inst 0xc2df06ad // BUILD-C.C-C Cd:13 Cn:21 001:001 opc:00 0:0 Cm:31 11000010110:11000010110
	.inst 0x785e537f // 0x785e537f
	.inst 0x38e241fa // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:26 Rn:15 00:00 opc:100 0:0 Rs:2 1:1 R:1 A:1 111000:111000 size:00
	.inst 0x425fffbf // LDAR-C.R-C Ct:31 Rn:29 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0x7a4883ce // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1110 0:0 Rn:30 00:00 cond:1000 Rm:8 111010010:111010010 op:1 sf:0
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
	.inst 0xc24005c1 // ldr c1, [x14, #1]
	.inst 0xc24009c2 // ldr c2, [x14, #2]
	.inst 0xc2400dc9 // ldr c9, [x14, #3]
	.inst 0xc24011cf // ldr c15, [x14, #4]
	.inst 0xc24015d5 // ldr c21, [x14, #5]
	.inst 0xc24019db // ldr c27, [x14, #6]
	.inst 0xc2401ddd // ldr c29, [x14, #7]
	/* Set up flags and system registers */
	ldr x14, =0x4000000
	msr SPSR_EL3, x14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30d5d99f
	msr SCTLR_EL1, x14
	ldr x14, =0xc0000
	msr CPACR_EL1, x14
	ldr x14, =0x0
	msr S3_0_C1_C2_2, x14 // CCTLR_EL1
	ldr x14, =0x80000000
	msr HCR_EL2, x14
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x8260124e // ldr c14, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
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
	mov x18, #0xf
	and x14, x14, x18
	cmp x14, #0xe
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001d2 // ldr c18, [x14, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc24005d2 // ldr c18, [x14, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc24009d2 // ldr c18, [x14, #2]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400dd2 // ldr c18, [x14, #3]
	.inst 0xc2d2a521 // chkeq c9, c18
	b.ne comparison_fail
	.inst 0xc24011d2 // ldr c18, [x14, #4]
	.inst 0xc2d2a581 // chkeq c12, c18
	b.ne comparison_fail
	.inst 0xc24015d2 // ldr c18, [x14, #5]
	.inst 0xc2d2a5a1 // chkeq c13, c18
	b.ne comparison_fail
	.inst 0xc24019d2 // ldr c18, [x14, #6]
	.inst 0xc2d2a5e1 // chkeq c15, c18
	b.ne comparison_fail
	.inst 0xc2401dd2 // ldr c18, [x14, #7]
	.inst 0xc2d2a6a1 // chkeq c21, c18
	b.ne comparison_fail
	.inst 0xc24021d2 // ldr c18, [x14, #8]
	.inst 0xc2d2a721 // chkeq c25, c18
	b.ne comparison_fail
	.inst 0xc24025d2 // ldr c18, [x14, #9]
	.inst 0xc2d2a741 // chkeq c26, c18
	b.ne comparison_fail
	.inst 0xc24029d2 // ldr c18, [x14, #10]
	.inst 0xc2d2a761 // chkeq c27, c18
	b.ne comparison_fail
	.inst 0xc2402dd2 // ldr c18, [x14, #11]
	.inst 0xc2d2a7a1 // chkeq c29, c18
	b.ne comparison_fail
	.inst 0xc24031d2 // ldr c18, [x14, #12]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check system registers */
	ldr x14, =final_PCC_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2984032 // mrs c18, CELR_EL1
	.inst 0xc2d2a5c1 // chkeq c14, c18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001480
	ldr x1, =check_data0
	ldr x2, =0x000014a0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000017e6
	ldr x1, =check_data1
	ldr x2, =0x000017e8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017fc
	ldr x1, =check_data2
	ldr x2, =0x000017fe
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
	ldr x0, =0x404001e0
	ldr x1, =check_data5
	ldr x2, =0x404001f0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
	.zero 2032
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xe1, 0x01, 0x00, 0x00
	.zero 2032
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x81, 0x00
.data
check_data0:
	.zero 32
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0xe1, 0x01
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x21, 0x84, 0xc1, 0xc2, 0x0c, 0xe4, 0x53, 0x62, 0x1f, 0xc9, 0x3d, 0x0b, 0x3e, 0x61, 0xbd, 0x78
	.byte 0xad, 0x06, 0xdf, 0xc2, 0x7f, 0x53, 0x5e, 0x78, 0xfa, 0x41, 0xe2, 0x38, 0xbf, 0xff, 0x5f, 0x42
	.byte 0xce, 0x83, 0x48, 0x7a, 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.zero 16

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8010000054a004a10000000000001210
	/* C1 */
	.octa 0x100000000000000000000
	/* C2 */
	.octa 0x0
	/* C9 */
	.octa 0xc00000000001000500000000000017fc
	/* C15 */
	.octa 0xc0000000000100050000000000001ffe
	/* C21 */
	.octa 0x0
	/* C27 */
	.octa 0x80000000000100050000000000001801
	/* C29 */
	.octa 0x800000000001000500000000404001e0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x8010000054a004a10000000000001210
	/* C1 */
	.octa 0x100000000000000000000
	/* C2 */
	.octa 0x0
	/* C9 */
	.octa 0xc00000000001000500000000000017fc
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0xc0000000000100050000000000001ffe
	/* C21 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x81
	/* C27 */
	.octa 0x80000000000100050000000000001801
	/* C29 */
	.octa 0x800000000001000500000000404001e0
	/* C30 */
	.octa 0x1e1
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
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
	.dword 0x0000000000001480
	.dword 0x0000000000001490
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 160
	.dword final_cap_values + 176
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
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x82600e4e // ldr x14, [c18, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400e4e // str x14, [c18, #0]
	ldr x14, =0x40400028
	mrs x18, ELR_EL1
	sub x14, x14, x18
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x8260024e // ldr c14, [c18, #0]
	.inst 0x020001ce // add c14, c14, #0
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x82600e4e // ldr x14, [c18, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400e4e // str x14, [c18, #0]
	ldr x14, =0x40400028
	mrs x18, ELR_EL1
	sub x14, x14, x18
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x8260024e // ldr c14, [c18, #0]
	.inst 0x020201ce // add c14, c14, #128
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x82600e4e // ldr x14, [c18, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400e4e // str x14, [c18, #0]
	ldr x14, =0x40400028
	mrs x18, ELR_EL1
	sub x14, x14, x18
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x8260024e // ldr c14, [c18, #0]
	.inst 0x020401ce // add c14, c14, #256
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x82600e4e // ldr x14, [c18, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400e4e // str x14, [c18, #0]
	ldr x14, =0x40400028
	mrs x18, ELR_EL1
	sub x14, x14, x18
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x8260024e // ldr c14, [c18, #0]
	.inst 0x020601ce // add c14, c14, #384
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x82600e4e // ldr x14, [c18, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400e4e // str x14, [c18, #0]
	ldr x14, =0x40400028
	mrs x18, ELR_EL1
	sub x14, x14, x18
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x8260024e // ldr c14, [c18, #0]
	.inst 0x020801ce // add c14, c14, #512
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x82600e4e // ldr x14, [c18, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400e4e // str x14, [c18, #0]
	ldr x14, =0x40400028
	mrs x18, ELR_EL1
	sub x14, x14, x18
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x8260024e // ldr c14, [c18, #0]
	.inst 0x020a01ce // add c14, c14, #640
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x82600e4e // ldr x14, [c18, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400e4e // str x14, [c18, #0]
	ldr x14, =0x40400028
	mrs x18, ELR_EL1
	sub x14, x14, x18
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x8260024e // ldr c14, [c18, #0]
	.inst 0x020c01ce // add c14, c14, #768
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x82600e4e // ldr x14, [c18, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400e4e // str x14, [c18, #0]
	ldr x14, =0x40400028
	mrs x18, ELR_EL1
	sub x14, x14, x18
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x8260024e // ldr c14, [c18, #0]
	.inst 0x020e01ce // add c14, c14, #896
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x82600e4e // ldr x14, [c18, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400e4e // str x14, [c18, #0]
	ldr x14, =0x40400028
	mrs x18, ELR_EL1
	sub x14, x14, x18
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x8260024e // ldr c14, [c18, #0]
	.inst 0x021001ce // add c14, c14, #1024
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x82600e4e // ldr x14, [c18, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400e4e // str x14, [c18, #0]
	ldr x14, =0x40400028
	mrs x18, ELR_EL1
	sub x14, x14, x18
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x8260024e // ldr c14, [c18, #0]
	.inst 0x021201ce // add c14, c14, #1152
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x82600e4e // ldr x14, [c18, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400e4e // str x14, [c18, #0]
	ldr x14, =0x40400028
	mrs x18, ELR_EL1
	sub x14, x14, x18
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x8260024e // ldr c14, [c18, #0]
	.inst 0x021401ce // add c14, c14, #1280
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x82600e4e // ldr x14, [c18, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400e4e // str x14, [c18, #0]
	ldr x14, =0x40400028
	mrs x18, ELR_EL1
	sub x14, x14, x18
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x8260024e // ldr c14, [c18, #0]
	.inst 0x021601ce // add c14, c14, #1408
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x82600e4e // ldr x14, [c18, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400e4e // str x14, [c18, #0]
	ldr x14, =0x40400028
	mrs x18, ELR_EL1
	sub x14, x14, x18
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x8260024e // ldr c14, [c18, #0]
	.inst 0x021801ce // add c14, c14, #1536
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x82600e4e // ldr x14, [c18, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400e4e // str x14, [c18, #0]
	ldr x14, =0x40400028
	mrs x18, ELR_EL1
	sub x14, x14, x18
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x8260024e // ldr c14, [c18, #0]
	.inst 0x021a01ce // add c14, c14, #1664
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x82600e4e // ldr x14, [c18, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400e4e // str x14, [c18, #0]
	ldr x14, =0x40400028
	mrs x18, ELR_EL1
	sub x14, x14, x18
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x8260024e // ldr c14, [c18, #0]
	.inst 0x021c01ce // add c14, c14, #1792
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x82600e4e // ldr x14, [c18, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400e4e // str x14, [c18, #0]
	ldr x14, =0x40400028
	mrs x18, ELR_EL1
	sub x14, x14, x18
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x8260024e // ldr c14, [c18, #0]
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

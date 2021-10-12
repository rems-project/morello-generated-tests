.section text0, #alloc, #execinstr
test_start:
	.inst 0x78c6bc3b // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:27 Rn:1 11:11 imm9:001101011 0:0 opc:11 111000:111000 size:01
	.inst 0x11451bcf // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:15 Rn:30 imm12:000101000110 sh:1 0:0 10001:10001 S:0 op:0 sf:0
	.inst 0xa25e19c1 // LDTR-C.RIB-C Ct:1 Rn:14 10:10 imm9:111100001 0:0 opc:01 10100010:10100010
	.inst 0x0b2029c4 // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:4 Rn:14 imm3:010 option:001 Rm:0 01011001:01011001 S:0 op:0 sf:0
	.inst 0xc2dd067f // BUILD-C.C-C Cd:31 Cn:19 001:001 opc:00 0:0 Cm:29 11000010110:11000010110
	.inst 0xc2c19032 // 0xc2c19032
	.inst 0xc2c233c1 // 0xc2c233c1
	.inst 0x82c6cc29 // 0x82c6cc29
	.inst 0xf874101d // 0xf874101d
	.inst 0xd4000001
	.zero 2008
	.inst 0x38069cb8
	.zero 63484
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
	ldr x26, =initial_cap_values
	.inst 0xc2400340 // ldr c0, [x26, #0]
	.inst 0xc2400741 // ldr c1, [x26, #1]
	.inst 0xc2400b46 // ldr c6, [x26, #2]
	.inst 0xc2400f4e // ldr c14, [x26, #3]
	.inst 0xc2401353 // ldr c19, [x26, #4]
	.inst 0xc2401754 // ldr c20, [x26, #5]
	.inst 0xc2401b5d // ldr c29, [x26, #6]
	.inst 0xc2401f5e // ldr c30, [x26, #7]
	/* Set up flags and system registers */
	ldr x26, =0x4000000
	msr SPSR_EL3, x26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30d5d99f
	msr SCTLR_EL1, x26
	ldr x26, =0xc0000
	msr CPACR_EL1, x26
	ldr x26, =0x0
	msr S3_0_C1_C2_2, x26 // CCTLR_EL1
	ldr x26, =0x4
	msr S3_3_C1_C2_2, x26 // CCTLR_EL0
	ldr x26, =initial_DDC_EL0_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc288413a // msr DDC_EL0, c26
	ldr x26, =0x80000000
	msr HCR_EL2, x26
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826011ba // ldr c26, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc28e403a // msr CELR_EL3, c26
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30851035
	msr SCTLR_EL3, x26
	isb
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x13, #0xf
	and x26, x26, x13
	cmp x26, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc240034d // ldr c13, [x26, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240074d // ldr c13, [x26, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc2400b4d // ldr c13, [x26, #2]
	.inst 0xc2cda481 // chkeq c4, c13
	b.ne comparison_fail
	.inst 0xc2400f4d // ldr c13, [x26, #3]
	.inst 0xc2cda4c1 // chkeq c6, c13
	b.ne comparison_fail
	.inst 0xc240134d // ldr c13, [x26, #4]
	.inst 0xc2cda521 // chkeq c9, c13
	b.ne comparison_fail
	.inst 0xc240174d // ldr c13, [x26, #5]
	.inst 0xc2cda5c1 // chkeq c14, c13
	b.ne comparison_fail
	.inst 0xc2401b4d // ldr c13, [x26, #6]
	.inst 0xc2cda5e1 // chkeq c15, c13
	b.ne comparison_fail
	.inst 0xc2401f4d // ldr c13, [x26, #7]
	.inst 0xc2cda641 // chkeq c18, c13
	b.ne comparison_fail
	.inst 0xc240234d // ldr c13, [x26, #8]
	.inst 0xc2cda661 // chkeq c19, c13
	b.ne comparison_fail
	.inst 0xc240274d // ldr c13, [x26, #9]
	.inst 0xc2cda681 // chkeq c20, c13
	b.ne comparison_fail
	.inst 0xc2402b4d // ldr c13, [x26, #10]
	.inst 0xc2cda761 // chkeq c27, c13
	b.ne comparison_fail
	.inst 0xc2402f4d // ldr c13, [x26, #11]
	.inst 0xc2cda7a1 // chkeq c29, c13
	b.ne comparison_fail
	.inst 0xc240334d // ldr c13, [x26, #12]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check system registers */
	ldr x26, =final_SP_EL0_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc298410d // mrs c13, CSP_EL0
	.inst 0xc2cda741 // chkeq c26, c13
	b.ne comparison_fail
	ldr x26, =final_PCC_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc298402d // mrs c13, CELR_EL1
	.inst 0xc2cda741 // chkeq c26, c13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001ff0
	ldr x1, =check_data0
	ldr x2, =0x00001ff8
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x40400000
	ldr x1, =check_data1
	ldr x2, =0x40400028
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x4040056c
	ldr x1, =check_data2
	ldr x2, =0x4040056e
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400800
	ldr x1, =check_data3
	ldr x2, =0x40400810
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400842
	ldr x1, =check_data4
	ldr x2, =0x40400844
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
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
	.zero 4080
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
.data
check_data1:
	.byte 0x3b, 0xbc, 0xc6, 0x78, 0xcf, 0x1b, 0x45, 0x11, 0xc1, 0x19, 0x5e, 0xa2, 0xc4, 0x29, 0x20, 0x0b
	.byte 0x7f, 0x06, 0xdd, 0xc2, 0x32, 0x90, 0xc1, 0xc2, 0xc1, 0x33, 0xc2, 0xc2, 0x29, 0xcc, 0xc6, 0x82
	.byte 0x1d, 0x10, 0x74, 0xf8, 0x01, 0x00, 0x00, 0xd4
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0xb8, 0x9c, 0x06, 0x38, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000000100050000000000001ff0
	/* C1 */
	.octa 0x800000002006c3020000000040400501
	/* C6 */
	.octa 0x396b8a
	/* C14 */
	.octa 0x800000000001000500000000404009f0
	/* C19 */
	.octa 0x4000000200a0ebfd8f58e000
	/* C20 */
	.octa 0x0
	/* C29 */
	.octa 0x13ff50000000000000001
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xc0000000000100050000000000001ff0
	/* C1 */
	.octa 0x38069cb8
	/* C4 */
	.octa 0x404089b0
	/* C6 */
	.octa 0x396b8a
	/* C9 */
	.octa 0x0
	/* C14 */
	.octa 0x800000000001000500000000404009f0
	/* C15 */
	.octa 0x146000
	/* C18 */
	.octa 0x38069cb8
	/* C19 */
	.octa 0x4000000200a0ebfd8f58e000
	/* C20 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0xffffffffffffffff
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x80000000000500420000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x4000000200a0ebfd8f58e000
final_PCC_value:
	.octa 0x20008000200060000000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200060000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword final_cap_values + 192
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
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34d // cvtp c13, x26
	.inst 0xc2da41ad // scvalue c13, c13, x26
	.inst 0x82600dba // ldr x26, [c13, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400dba // str x26, [c13, #0]
	ldr x26, =0x40400028
	mrs x13, ELR_EL1
	sub x26, x26, x13
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34d // cvtp c13, x26
	.inst 0xc2da41ad // scvalue c13, c13, x26
	.inst 0x826001ba // ldr c26, [c13, #0]
	.inst 0x0200035a // add c26, c26, #0
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34d // cvtp c13, x26
	.inst 0xc2da41ad // scvalue c13, c13, x26
	.inst 0x82600dba // ldr x26, [c13, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400dba // str x26, [c13, #0]
	ldr x26, =0x40400028
	mrs x13, ELR_EL1
	sub x26, x26, x13
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34d // cvtp c13, x26
	.inst 0xc2da41ad // scvalue c13, c13, x26
	.inst 0x826001ba // ldr c26, [c13, #0]
	.inst 0x0202035a // add c26, c26, #128
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34d // cvtp c13, x26
	.inst 0xc2da41ad // scvalue c13, c13, x26
	.inst 0x82600dba // ldr x26, [c13, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400dba // str x26, [c13, #0]
	ldr x26, =0x40400028
	mrs x13, ELR_EL1
	sub x26, x26, x13
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34d // cvtp c13, x26
	.inst 0xc2da41ad // scvalue c13, c13, x26
	.inst 0x826001ba // ldr c26, [c13, #0]
	.inst 0x0204035a // add c26, c26, #256
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34d // cvtp c13, x26
	.inst 0xc2da41ad // scvalue c13, c13, x26
	.inst 0x82600dba // ldr x26, [c13, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400dba // str x26, [c13, #0]
	ldr x26, =0x40400028
	mrs x13, ELR_EL1
	sub x26, x26, x13
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34d // cvtp c13, x26
	.inst 0xc2da41ad // scvalue c13, c13, x26
	.inst 0x826001ba // ldr c26, [c13, #0]
	.inst 0x0206035a // add c26, c26, #384
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34d // cvtp c13, x26
	.inst 0xc2da41ad // scvalue c13, c13, x26
	.inst 0x82600dba // ldr x26, [c13, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400dba // str x26, [c13, #0]
	ldr x26, =0x40400028
	mrs x13, ELR_EL1
	sub x26, x26, x13
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34d // cvtp c13, x26
	.inst 0xc2da41ad // scvalue c13, c13, x26
	.inst 0x826001ba // ldr c26, [c13, #0]
	.inst 0x0208035a // add c26, c26, #512
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34d // cvtp c13, x26
	.inst 0xc2da41ad // scvalue c13, c13, x26
	.inst 0x82600dba // ldr x26, [c13, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400dba // str x26, [c13, #0]
	ldr x26, =0x40400028
	mrs x13, ELR_EL1
	sub x26, x26, x13
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34d // cvtp c13, x26
	.inst 0xc2da41ad // scvalue c13, c13, x26
	.inst 0x826001ba // ldr c26, [c13, #0]
	.inst 0x020a035a // add c26, c26, #640
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34d // cvtp c13, x26
	.inst 0xc2da41ad // scvalue c13, c13, x26
	.inst 0x82600dba // ldr x26, [c13, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400dba // str x26, [c13, #0]
	ldr x26, =0x40400028
	mrs x13, ELR_EL1
	sub x26, x26, x13
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34d // cvtp c13, x26
	.inst 0xc2da41ad // scvalue c13, c13, x26
	.inst 0x826001ba // ldr c26, [c13, #0]
	.inst 0x020c035a // add c26, c26, #768
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34d // cvtp c13, x26
	.inst 0xc2da41ad // scvalue c13, c13, x26
	.inst 0x82600dba // ldr x26, [c13, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400dba // str x26, [c13, #0]
	ldr x26, =0x40400028
	mrs x13, ELR_EL1
	sub x26, x26, x13
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34d // cvtp c13, x26
	.inst 0xc2da41ad // scvalue c13, c13, x26
	.inst 0x826001ba // ldr c26, [c13, #0]
	.inst 0x020e035a // add c26, c26, #896
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34d // cvtp c13, x26
	.inst 0xc2da41ad // scvalue c13, c13, x26
	.inst 0x82600dba // ldr x26, [c13, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400dba // str x26, [c13, #0]
	ldr x26, =0x40400028
	mrs x13, ELR_EL1
	sub x26, x26, x13
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34d // cvtp c13, x26
	.inst 0xc2da41ad // scvalue c13, c13, x26
	.inst 0x826001ba // ldr c26, [c13, #0]
	.inst 0x0210035a // add c26, c26, #1024
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34d // cvtp c13, x26
	.inst 0xc2da41ad // scvalue c13, c13, x26
	.inst 0x82600dba // ldr x26, [c13, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400dba // str x26, [c13, #0]
	ldr x26, =0x40400028
	mrs x13, ELR_EL1
	sub x26, x26, x13
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34d // cvtp c13, x26
	.inst 0xc2da41ad // scvalue c13, c13, x26
	.inst 0x826001ba // ldr c26, [c13, #0]
	.inst 0x0212035a // add c26, c26, #1152
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34d // cvtp c13, x26
	.inst 0xc2da41ad // scvalue c13, c13, x26
	.inst 0x82600dba // ldr x26, [c13, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400dba // str x26, [c13, #0]
	ldr x26, =0x40400028
	mrs x13, ELR_EL1
	sub x26, x26, x13
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34d // cvtp c13, x26
	.inst 0xc2da41ad // scvalue c13, c13, x26
	.inst 0x826001ba // ldr c26, [c13, #0]
	.inst 0x0214035a // add c26, c26, #1280
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34d // cvtp c13, x26
	.inst 0xc2da41ad // scvalue c13, c13, x26
	.inst 0x82600dba // ldr x26, [c13, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400dba // str x26, [c13, #0]
	ldr x26, =0x40400028
	mrs x13, ELR_EL1
	sub x26, x26, x13
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34d // cvtp c13, x26
	.inst 0xc2da41ad // scvalue c13, c13, x26
	.inst 0x826001ba // ldr c26, [c13, #0]
	.inst 0x0216035a // add c26, c26, #1408
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34d // cvtp c13, x26
	.inst 0xc2da41ad // scvalue c13, c13, x26
	.inst 0x82600dba // ldr x26, [c13, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400dba // str x26, [c13, #0]
	ldr x26, =0x40400028
	mrs x13, ELR_EL1
	sub x26, x26, x13
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34d // cvtp c13, x26
	.inst 0xc2da41ad // scvalue c13, c13, x26
	.inst 0x826001ba // ldr c26, [c13, #0]
	.inst 0x0218035a // add c26, c26, #1536
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34d // cvtp c13, x26
	.inst 0xc2da41ad // scvalue c13, c13, x26
	.inst 0x82600dba // ldr x26, [c13, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400dba // str x26, [c13, #0]
	ldr x26, =0x40400028
	mrs x13, ELR_EL1
	sub x26, x26, x13
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34d // cvtp c13, x26
	.inst 0xc2da41ad // scvalue c13, c13, x26
	.inst 0x826001ba // ldr c26, [c13, #0]
	.inst 0x021a035a // add c26, c26, #1664
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34d // cvtp c13, x26
	.inst 0xc2da41ad // scvalue c13, c13, x26
	.inst 0x82600dba // ldr x26, [c13, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400dba // str x26, [c13, #0]
	ldr x26, =0x40400028
	mrs x13, ELR_EL1
	sub x26, x26, x13
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34d // cvtp c13, x26
	.inst 0xc2da41ad // scvalue c13, c13, x26
	.inst 0x826001ba // ldr c26, [c13, #0]
	.inst 0x021c035a // add c26, c26, #1792
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b34d // cvtp c13, x26
	.inst 0xc2da41ad // scvalue c13, c13, x26
	.inst 0x82600dba // ldr x26, [c13, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400dba // str x26, [c13, #0]
	ldr x26, =0x40400028
	mrs x13, ELR_EL1
	sub x26, x26, x13
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b34d // cvtp c13, x26
	.inst 0xc2da41ad // scvalue c13, c13, x26
	.inst 0x826001ba // ldr c26, [c13, #0]
	.inst 0x021e035a // add c26, c26, #1920
	.inst 0xc2c21340 // br c26

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0

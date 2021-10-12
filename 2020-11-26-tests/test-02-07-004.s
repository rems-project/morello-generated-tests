.section data0, #alloc, #write
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x10, 0x10, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x10, 0x10, 0x00, 0x00
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0xa0, 0x87, 0xc6, 0xc2, 0x7f, 0x75, 0xf7, 0x82, 0xc0, 0xff, 0xe0, 0x08, 0x1f, 0x18, 0xf0, 0xc2
	.byte 0x3f, 0x28, 0xcc, 0x02, 0xcd, 0x85, 0x3a, 0x98, 0x1b, 0xae, 0xf8, 0x22, 0x8b, 0xdf, 0x73, 0x02
	.byte 0x47, 0x7e, 0xfd, 0x08, 0x1e, 0x0c, 0x7c, 0xb1, 0x80, 0x10, 0xc2, 0xc2
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x2000006a0070040000000011e00
	/* C6 */
	.octa 0x400004000000000000000000000001
	/* C11 */
	.octa 0x80000000000100050000000000000000
	/* C16 */
	.octa 0x1000
	/* C18 */
	.octa 0x401ffe
	/* C23 */
	.octa 0x3fe
	/* C28 */
	.octa 0xc0002000007fffffff800000
	/* C29 */
	.octa 0xa0408004000300070000000000400004
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x2000006a0070040000000011e00
	/* C6 */
	.octa 0x400004000000000000000000000001
	/* C11 */
	.octa 0xc000200000800000004f7000
	/* C13 */
	.octa 0x0
	/* C16 */
	.octa 0xf10
	/* C18 */
	.octa 0x401ffe
	/* C23 */
	.octa 0x3fe
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0xc0002000007fffffff800000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0xf03000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700010000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000020100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 128
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c687a0 // BRS-C.C-C 00000:00000 Cn:29 001:001 opc:00 1:1 Cm:6 11000010110:11000010110
	.inst 0x82f7757f // ALDR-R.RRB-64 Rt:31 Rn:11 opc:01 S:1 option:011 Rm:23 1:1 L:1 100000101:100000101
	.inst 0x08e0ffc0 // casb:aarch64/instrs/memory/atomicops/cas/single Rt:0 Rn:30 11111:11111 o0:1 Rs:0 1:1 L:1 0010001:0010001 size:00
	.inst 0xc2f0181f // CVT-C.CR-C Cd:31 Cn:0 0110:0110 0:0 0:0 Rm:16 11000010111:11000010111
	.inst 0x02cc283f // SUB-C.CIS-C Cd:31 Cn:1 imm12:001100001010 sh:1 A:1 00000010:00000010
	.inst 0x983a85cd // ldrsw_lit:aarch64/instrs/memory/literal/general Rt:13 imm19:0011101010000101110 011000:011000 opc:10
	.inst 0x22f8ae1b // LDP-CC.RIAW-C Ct:27 Rn:16 Ct2:01011 imm7:1110001 L:1 001000101:001000101
	.inst 0x0273df8b // ADD-C.CIS-C Cd:11 Cn:28 imm12:110011110111 sh:1 A:0 00000010:00000010
	.inst 0x08fd7e47 // casb:aarch64/instrs/memory/atomicops/cas/single Rt:7 Rn:18 11111:11111 o0:0 Rs:29 1:1 L:1 0010001:0010001 size:00
	.inst 0xb17c0c1e // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:30 Rn:0 imm12:111100000011 sh:1 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0xc2c21080
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
	ldr x3, =initial_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400461 // ldr c1, [x3, #1]
	.inst 0xc2400866 // ldr c6, [x3, #2]
	.inst 0xc2400c6b // ldr c11, [x3, #3]
	.inst 0xc2401070 // ldr c16, [x3, #4]
	.inst 0xc2401472 // ldr c18, [x3, #5]
	.inst 0xc2401877 // ldr c23, [x3, #6]
	.inst 0xc2401c7c // ldr c28, [x3, #7]
	.inst 0xc240207d // ldr c29, [x3, #8]
	.inst 0xc240247e // ldr c30, [x3, #9]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30851037
	msr SCTLR_EL3, x3
	ldr x3, =0x4
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82603083 // ldr c3, [c4, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x82601083 // ldr c3, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x4, #0xf
	and x3, x3, x4
	cmp x3, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400064 // ldr c4, [x3, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc2400464 // ldr c4, [x3, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400864 // ldr c4, [x3, #2]
	.inst 0xc2c4a4c1 // chkeq c6, c4
	b.ne comparison_fail
	.inst 0xc2400c64 // ldr c4, [x3, #3]
	.inst 0xc2c4a561 // chkeq c11, c4
	b.ne comparison_fail
	.inst 0xc2401064 // ldr c4, [x3, #4]
	.inst 0xc2c4a5a1 // chkeq c13, c4
	b.ne comparison_fail
	.inst 0xc2401464 // ldr c4, [x3, #5]
	.inst 0xc2c4a601 // chkeq c16, c4
	b.ne comparison_fail
	.inst 0xc2401864 // ldr c4, [x3, #6]
	.inst 0xc2c4a641 // chkeq c18, c4
	b.ne comparison_fail
	.inst 0xc2401c64 // ldr c4, [x3, #7]
	.inst 0xc2c4a6e1 // chkeq c23, c4
	b.ne comparison_fail
	.inst 0xc2402064 // ldr c4, [x3, #8]
	.inst 0xc2c4a761 // chkeq c27, c4
	b.ne comparison_fail
	.inst 0xc2402464 // ldr c4, [x3, #9]
	.inst 0xc2c4a781 // chkeq c28, c4
	b.ne comparison_fail
	.inst 0xc2402864 // ldr c4, [x3, #10]
	.inst 0xc2c4a7a1 // chkeq c29, c4
	b.ne comparison_fail
	.inst 0xc2402c64 // ldr c4, [x3, #11]
	.inst 0xc2c4a7c1 // chkeq c30, c4
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
	ldr x0, =0x00001ff0
	ldr x1, =check_data1
	ldr x2, =0x00001ff8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00401ffe
	ldr x1, =check_data3
	ldr x2, =0x00401fff
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004750cc
	ldr x1, =check_data4
	ldr x2, =0x004750d0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
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

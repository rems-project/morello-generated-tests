.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0xcc, 0x53, 0xa1, 0xa9, 0xb9, 0x8d, 0x40, 0x78, 0x94, 0x2f, 0xcc, 0x1a, 0x00, 0x91, 0xc1, 0xc2
	.byte 0x40, 0xc6, 0xb9, 0xe2, 0x1e, 0x90, 0xc1, 0xc2, 0xe1, 0x7f, 0x1e, 0x48, 0xc1, 0x0a, 0x20, 0x9b
	.byte 0xad, 0x79, 0x4a, 0x7a, 0xe7, 0xff, 0xe0, 0xc8, 0xc0, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C8 */
	.octa 0xffffffffffffffff
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x800000001901c0050000000000001ff4
	/* C18 */
	.octa 0x2000
	/* C20 */
	.octa 0x0
	/* C30 */
	.octa 0x400000000607160f0000000000001870
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C8 */
	.octa 0xffffffffffffffff
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x800000001901c0050000000000001ffc
	/* C18 */
	.octa 0x2000
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0x1
initial_SP_EL3_value:
	.octa 0xc00000005001c00400000000004ac800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000005fc1000a0000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 48
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa9a153cc // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:12 Rn:30 Rt2:10100 imm7:1000010 L:0 1010011:1010011 opc:10
	.inst 0x78408db9 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:25 Rn:13 11:11 imm9:000001000 0:0 opc:01 111000:111000 size:01
	.inst 0x1acc2f94 // rorv:aarch64/instrs/integer/shift/variable Rd:20 Rn:28 op2:11 0010:0010 Rm:12 0011010110:0011010110 sf:0
	.inst 0xc2c19100 // CLRTAG-C.C-C Cd:0 Cn:8 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xe2b9c640 // ALDUR-V.RI-S Rt:0 Rn:18 op2:01 imm9:110011100 V:1 op1:10 11100010:11100010
	.inst 0xc2c1901e // CLRTAG-C.C-C Cd:30 Cn:0 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0x481e7fe1 // stxrh:aarch64/instrs/memory/exclusive/single Rt:1 Rn:31 Rt2:11111 o0:0 Rs:30 0:0 L:0 0010000:0010000 size:01
	.inst 0x9b200ac1 // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:1 Rn:22 Ra:2 o0:0 Rm:0 01:01 U:0 10011011:10011011
	.inst 0x7a4a79ad // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1101 0:0 Rn:13 10:10 cond:0111 imm5:01010 111010010:111010010 op:1 sf:0
	.inst 0xc8e0ffe7 // cas:aarch64/instrs/memory/atomicops/cas/single Rt:7 Rn:31 11111:11111 o0:1 Rs:0 1:1 L:1 0010001:0010001 size:11
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
	ldr x3, =initial_cap_values
	.inst 0xc2400068 // ldr c8, [x3, #0]
	.inst 0xc240046c // ldr c12, [x3, #1]
	.inst 0xc240086d // ldr c13, [x3, #2]
	.inst 0xc2400c72 // ldr c18, [x3, #3]
	.inst 0xc2401074 // ldr c20, [x3, #4]
	.inst 0xc240147e // ldr c30, [x3, #5]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =initial_SP_EL3_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2c1d07f // cpy c31, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30851037
	msr SCTLR_EL3, x3
	ldr x3, =0x0
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031c3 // ldr c3, [c14, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x826011c3 // ldr c3, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
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
	mov x14, #0xf
	and x3, x3, x14
	cmp x3, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc240006e // ldr c14, [x3, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc240046e // ldr c14, [x3, #1]
	.inst 0xc2cea501 // chkeq c8, c14
	b.ne comparison_fail
	.inst 0xc240086e // ldr c14, [x3, #2]
	.inst 0xc2cea581 // chkeq c12, c14
	b.ne comparison_fail
	.inst 0xc2400c6e // ldr c14, [x3, #3]
	.inst 0xc2cea5a1 // chkeq c13, c14
	b.ne comparison_fail
	.inst 0xc240106e // ldr c14, [x3, #4]
	.inst 0xc2cea641 // chkeq c18, c14
	b.ne comparison_fail
	.inst 0xc240146e // ldr c14, [x3, #5]
	.inst 0xc2cea721 // chkeq c25, c14
	b.ne comparison_fail
	.inst 0xc240186e // ldr c14, [x3, #6]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0x0
	mov x14, v0.d[0]
	cmp x3, x14
	b.ne comparison_fail
	ldr x3, =0x0
	mov x14, v0.d[1]
	cmp x3, x14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001680
	ldr x1, =check_data0
	ldr x2, =0x00001690
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001f9c
	ldr x1, =check_data1
	ldr x2, =0x00001fa0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffc
	ldr x1, =check_data2
	ldr x2, =0x00001ffe
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
	ldr x0, =0x004ac800
	ldr x1, =check_data4
	ldr x2, =0x004ac808
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

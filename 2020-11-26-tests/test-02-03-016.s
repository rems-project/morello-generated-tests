.section data0, #alloc, #write
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2304
	.byte 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1744
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00
.data
check_data0:
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x80
.data
check_data4:
	.byte 0x1e, 0xfd, 0xfc, 0xa2, 0x37, 0x18, 0xc7, 0xc2, 0xe0, 0xfd, 0xdf, 0x48, 0x80, 0x7e, 0x7f, 0x42
	.byte 0xd4, 0xc4, 0xe5, 0x82, 0xed, 0x37, 0x9e, 0x5a, 0x10, 0x7c, 0x5f, 0x88, 0x69, 0x52, 0x74, 0xb8
	.byte 0xa7, 0x90, 0xc5, 0xc2, 0x3d, 0x04, 0x05, 0xab, 0xc0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x200400291010008000000006000
	/* C5 */
	.octa 0x8000022000030c
	/* C6 */
	.octa 0x8000000000030003ffffffffe0001604
	/* C8 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C20 */
	.octa 0x80000000000300070000000000001ffe
	/* C28 */
	.octa 0xfffffffffffffffffffffffffffffffe
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x80
	/* C1 */
	.octa 0x200400291010008000000006000
	/* C5 */
	.octa 0x8000022000030c
	/* C6 */
	.octa 0x8000000000030003ffffffffe0001604
	/* C7 */
	.octa 0xc000000058011000008000022000130c
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x1
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C20 */
	.octa 0x40000000
	/* C23 */
	.octa 0x200400291010008000000004000
	/* C28 */
	.octa 0x1
	/* C29 */
	.octa 0x108000440006618
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005801100000ffffffffffff04
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2fcfd1e // CASAL-C.R-C Ct:30 Rn:8 11111:11111 R:1 Cs:28 1:1 L:1 1:1 10100010:10100010
	.inst 0xc2c71837 // ALIGND-C.CI-C Cd:23 Cn:1 0110:0110 U:0 imm6:001110 11000010110:11000010110
	.inst 0x48dffde0 // ldarh:aarch64/instrs/memory/ordered Rt:0 Rn:15 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0x427f7e80 // ALDARB-R.R-B Rt:0 Rn:20 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x82e5c4d4 // ALDR-R.RRB-64 Rt:20 Rn:6 opc:01 S:0 option:110 Rm:5 1:1 L:1 100000101:100000101
	.inst 0x5a9e37ed // csneg:aarch64/instrs/integer/conditional/select Rd:13 Rn:31 o2:1 0:0 cond:0011 Rm:30 011010100:011010100 op:1 sf:0
	.inst 0x885f7c10 // ldxr:aarch64/instrs/memory/exclusive/single Rt:16 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:10
	.inst 0xb8745269 // ldsmin:aarch64/instrs/memory/atomicops/ld Rt:9 Rn:19 00:00 opc:101 0:0 Rs:20 1:1 R:1 A:0 111000:111000 size:10
	.inst 0xc2c590a7 // CVTD-C.R-C Cd:7 Rn:5 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0xab05043d // adds_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:29 Rn:1 imm6:000001 Rm:5 0:0 shift:00 01011:01011 S:1 op:0 sf:1
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
	ldr x10, =initial_cap_values
	.inst 0xc2400141 // ldr c1, [x10, #0]
	.inst 0xc2400545 // ldr c5, [x10, #1]
	.inst 0xc2400946 // ldr c6, [x10, #2]
	.inst 0xc2400d48 // ldr c8, [x10, #3]
	.inst 0xc240114f // ldr c15, [x10, #4]
	.inst 0xc2401553 // ldr c19, [x10, #5]
	.inst 0xc2401954 // ldr c20, [x10, #6]
	.inst 0xc2401d5c // ldr c28, [x10, #7]
	.inst 0xc240215e // ldr c30, [x10, #8]
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30851037
	msr SCTLR_EL3, x10
	ldr x10, =0x4
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031ca // ldr c10, [c14, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x826011ca // ldr c10, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x14, #0xf
	and x10, x10, x14
	cmp x10, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc240014e // ldr c14, [x10, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc240054e // ldr c14, [x10, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc240094e // ldr c14, [x10, #2]
	.inst 0xc2cea4a1 // chkeq c5, c14
	b.ne comparison_fail
	.inst 0xc2400d4e // ldr c14, [x10, #3]
	.inst 0xc2cea4c1 // chkeq c6, c14
	b.ne comparison_fail
	.inst 0xc240114e // ldr c14, [x10, #4]
	.inst 0xc2cea4e1 // chkeq c7, c14
	b.ne comparison_fail
	.inst 0xc240154e // ldr c14, [x10, #5]
	.inst 0xc2cea501 // chkeq c8, c14
	b.ne comparison_fail
	.inst 0xc240194e // ldr c14, [x10, #6]
	.inst 0xc2cea521 // chkeq c9, c14
	b.ne comparison_fail
	.inst 0xc2401d4e // ldr c14, [x10, #7]
	.inst 0xc2cea5a1 // chkeq c13, c14
	b.ne comparison_fail
	.inst 0xc240214e // ldr c14, [x10, #8]
	.inst 0xc2cea5e1 // chkeq c15, c14
	b.ne comparison_fail
	.inst 0xc240254e // ldr c14, [x10, #9]
	.inst 0xc2cea601 // chkeq c16, c14
	b.ne comparison_fail
	.inst 0xc240294e // ldr c14, [x10, #10]
	.inst 0xc2cea661 // chkeq c19, c14
	b.ne comparison_fail
	.inst 0xc2402d4e // ldr c14, [x10, #11]
	.inst 0xc2cea681 // chkeq c20, c14
	b.ne comparison_fail
	.inst 0xc240314e // ldr c14, [x10, #12]
	.inst 0xc2cea6e1 // chkeq c23, c14
	b.ne comparison_fail
	.inst 0xc240354e // ldr c14, [x10, #13]
	.inst 0xc2cea781 // chkeq c28, c14
	b.ne comparison_fail
	.inst 0xc240394e // ldr c14, [x10, #14]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	.inst 0xc2403d4e // ldr c14, [x10, #15]
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
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001084
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001910
	ldr x1, =check_data2
	ldr x2, =0x00001918
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
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
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

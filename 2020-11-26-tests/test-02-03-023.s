.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x40, 0x00, 0x00, 0x08, 0x40, 0x00, 0x00, 0x30
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0xe0, 0x73, 0xc2, 0xc2, 0xc4, 0xb7, 0x06, 0xf8, 0xb5, 0x43, 0x61, 0xb8, 0x61, 0x7f, 0x9d, 0x82
	.byte 0xd9, 0x33, 0xc7, 0xc2, 0x13, 0x98, 0x21, 0x22, 0x27, 0xb0, 0x06, 0x7d, 0x23, 0x24, 0x7f, 0x88
	.byte 0xc1, 0xb9, 0x65, 0x51, 0x65, 0x32, 0x43, 0x3a, 0x00, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x30000040
	/* C4 */
	.octa 0x40008000000
	/* C6 */
	.octa 0x0
	/* C19 */
	.octa 0x4000000000000000000000000000
	/* C27 */
	.octa 0x400000000007000f0000000000000ff6
	/* C29 */
	.octa 0x5
	/* C30 */
	.octa 0x1
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C3 */
	.octa 0x8000040
	/* C4 */
	.octa 0x40008000000
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0x30000040
	/* C19 */
	.octa 0x4000000000000000000000000000
	/* C21 */
	.octa 0x400
	/* C25 */
	.octa 0xffffffffffffffff
	/* C27 */
	.octa 0x400000000007000f0000000000000ff6
	/* C29 */
	.octa 0x5
	/* C30 */
	.octa 0x6c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000202100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc00000040040fff00ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xf806b7c4 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:4 Rn:30 01:01 imm9:001101011 0:0 opc:00 111000:111000 size:11
	.inst 0xb86143b5 // ldsmax:aarch64/instrs/memory/atomicops/ld Rt:21 Rn:29 00:00 opc:100 0:0 Rs:1 1:1 R:1 A:0 111000:111000 size:10
	.inst 0x829d7f61 // ASTRH-R.RRB-32 Rt:1 Rn:27 opc:11 S:1 option:011 Rm:29 0:0 L:0 100000101:100000101
	.inst 0xc2c733d9 // RRMASK-R.R-C Rd:25 Rn:30 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0x22219813 // STLXP-R.CR-C Ct:19 Rn:0 Ct2:00110 1:1 Rs:1 1:1 L:0 001000100:001000100
	.inst 0x7d06b027 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:7 Rn:1 imm12:000110101100 opc:00 111101:111101 size:01
	.inst 0x887f2423 // ldxp:aarch64/instrs/memory/exclusive/pair Rt:3 Rn:1 Rt2:01001 o0:0 Rs:11111 1:1 L:1 0010000:0010000 sz:0 1:1
	.inst 0x5165b9c1 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:1 Rn:14 imm12:100101101110 sh:1 0:0 10001:10001 S:0 op:1 sf:0
	.inst 0x3a433265 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0101 0:0 Rn:19 00:00 cond:0011 Rm:3 111010010:111010010 op:0 sf:0
	.inst 0xc2c21200
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c0 // ldr c0, [x22, #0]
	.inst 0xc24006c1 // ldr c1, [x22, #1]
	.inst 0xc2400ac4 // ldr c4, [x22, #2]
	.inst 0xc2400ec6 // ldr c6, [x22, #3]
	.inst 0xc24012d3 // ldr c19, [x22, #4]
	.inst 0xc24016db // ldr c27, [x22, #5]
	.inst 0xc2401add // ldr c29, [x22, #6]
	.inst 0xc2401ede // ldr c30, [x22, #7]
	/* Vector registers */
	mrs x22, cptr_el3
	bfc x22, #10, #1
	msr cptr_el3, x22
	isb
	ldr q7, =0x0
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30851037
	msr SCTLR_EL3, x22
	ldr x22, =0x4
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82603216 // ldr c22, [c16, #3]
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	.inst 0x82601216 // ldr c22, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30851035
	msr SCTLR_EL3, x22
	isb
	/* Check processor flags */
	mrs x22, nzcv
	ubfx x22, x22, #28, #4
	mov x16, #0xf
	and x22, x22, x16
	cmp x22, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002d0 // ldr c16, [x22, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc24006d0 // ldr c16, [x22, #1]
	.inst 0xc2d0a461 // chkeq c3, c16
	b.ne comparison_fail
	.inst 0xc2400ad0 // ldr c16, [x22, #2]
	.inst 0xc2d0a481 // chkeq c4, c16
	b.ne comparison_fail
	.inst 0xc2400ed0 // ldr c16, [x22, #3]
	.inst 0xc2d0a4c1 // chkeq c6, c16
	b.ne comparison_fail
	.inst 0xc24012d0 // ldr c16, [x22, #4]
	.inst 0xc2d0a521 // chkeq c9, c16
	b.ne comparison_fail
	.inst 0xc24016d0 // ldr c16, [x22, #5]
	.inst 0xc2d0a661 // chkeq c19, c16
	b.ne comparison_fail
	.inst 0xc2401ad0 // ldr c16, [x22, #6]
	.inst 0xc2d0a6a1 // chkeq c21, c16
	b.ne comparison_fail
	.inst 0xc2401ed0 // ldr c16, [x22, #7]
	.inst 0xc2d0a721 // chkeq c25, c16
	b.ne comparison_fail
	.inst 0xc24022d0 // ldr c16, [x22, #8]
	.inst 0xc2d0a761 // chkeq c27, c16
	b.ne comparison_fail
	.inst 0xc24026d0 // ldr c16, [x22, #9]
	.inst 0xc2d0a7a1 // chkeq c29, c16
	b.ne comparison_fail
	.inst 0xc2402ad0 // ldr c16, [x22, #10]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check vector registers */
	ldr x22, =0x0
	mov x16, v7.d[0]
	cmp x22, x16
	b.ne comparison_fail
	ldr x22, =0x0
	mov x16, v7.d[1]
	cmp x22, x16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001358
	ldr x1, =check_data1
	ldr x2, =0x0000135a
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
	/* Done print message */
	/* turn off MMU */
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
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

.section data0, #alloc, #write
	.zero 4080
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x48, 0x00
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xa1, 0xa7, 0xd6, 0xc2, 0xbd, 0x6f, 0xd4, 0x3c, 0x5f, 0x96, 0x19, 0x31, 0x2e, 0xb0, 0xc5, 0xc2
	.byte 0x3f, 0x68, 0x60, 0x78, 0xf0, 0x53, 0xc1, 0xc2, 0x2d, 0xd8, 0x78, 0x82, 0x26, 0xc0, 0x95, 0xda
	.byte 0x5f, 0x23, 0x60, 0x38, 0x8d, 0x52, 0xc0, 0xc2, 0x20, 0x13, 0xc2, 0xc2
.data
check_data4:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xfffffffffffff748
	/* C1 */
	.octa 0x800000000001000500000000000019c4
	/* C18 */
	.octa 0xfffff99b
	/* C22 */
	.octa 0x7ffffffffff8dff0ffffffffffbfdef5
	/* C26 */
	.octa 0xc0000000000100050000000000001ffe
	/* C29 */
	.octa 0x800000000007200f000000000040210a
final_cap_values:
	/* C0 */
	.octa 0xfffffffffffff748
	/* C1 */
	.octa 0x800000000001000500000000000019c4
	/* C14 */
	.octa 0x200080000000800800000000000019c4
	/* C18 */
	.octa 0xfffff99b
	/* C22 */
	.octa 0x7ffffffffff8dff0ffffffffffbfdef5
	/* C26 */
	.octa 0xc0000000000100050000000000001ffe
	/* C29 */
	.octa 0x800000000007200f0000000000402050
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d6a7a1 // CHKEQ-_.CC-C 00001:00001 Cn:29 001:001 opc:01 1:1 Cm:22 11000010110:11000010110
	.inst 0x3cd46fbd // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:29 Rn:29 11:11 imm9:101000110 0:0 opc:11 111100:111100 size:00
	.inst 0x3119965f // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:18 imm12:011001100101 sh:0 0:0 10001:10001 S:1 op:0 sf:0
	.inst 0xc2c5b02e // CVTP-C.R-C Cd:14 Rn:1 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0x7860683f // ldrh_reg:aarch64/instrs/memory/single/general/register Rt:31 Rn:1 10:10 S:0 option:011 Rm:0 1:1 opc:01 111000:111000 size:01
	.inst 0xc2c153f0 // 0xc2c153f0
	.inst 0x8278d82d // ALDR-R.RI-32 Rt:13 Rn:1 op:10 imm9:110001101 L:1 1000001001:1000001001
	.inst 0xda95c026 // csinv:aarch64/instrs/integer/conditional/select Rd:6 Rn:1 o2:0 0:0 cond:1100 Rm:21 011010100:011010100 op:1 sf:1
	.inst 0x3860235f // steorb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:26 00:00 opc:010 o3:0 Rs:0 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2c0528d // GCVALUE-R.C-C Rd:13 Cn:20 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0xc2c21320
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
	.inst 0xc2400872 // ldr c18, [x3, #2]
	.inst 0xc2400c76 // ldr c22, [x3, #3]
	.inst 0xc240107a // ldr c26, [x3, #4]
	.inst 0xc240147d // ldr c29, [x3, #5]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30851037
	msr SCTLR_EL3, x3
	ldr x3, =0x8
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82603323 // ldr c3, [c25, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x82601323 // ldr c3, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
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
	mov x25, #0xf
	and x3, x3, x25
	cmp x3, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400079 // ldr c25, [x3, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc2400479 // ldr c25, [x3, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400879 // ldr c25, [x3, #2]
	.inst 0xc2d9a5c1 // chkeq c14, c25
	b.ne comparison_fail
	.inst 0xc2400c79 // ldr c25, [x3, #3]
	.inst 0xc2d9a641 // chkeq c18, c25
	b.ne comparison_fail
	.inst 0xc2401079 // ldr c25, [x3, #4]
	.inst 0xc2d9a6c1 // chkeq c22, c25
	b.ne comparison_fail
	.inst 0xc2401479 // ldr c25, [x3, #5]
	.inst 0xc2d9a741 // chkeq c26, c25
	b.ne comparison_fail
	.inst 0xc2401879 // ldr c25, [x3, #6]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0x0
	mov x25, v29.d[0]
	cmp x3, x25
	b.ne comparison_fail
	ldr x3, =0x0
	mov x25, v29.d[1]
	cmp x3, x25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000110c
	ldr x1, =check_data0
	ldr x2, =0x0000110e
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ff8
	ldr x1, =check_data1
	ldr x2, =0x00001ffc
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
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
	ldr x0, =0x00402050
	ldr x1, =check_data4
	ldr x2, =0x00402060
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

.section data0, #alloc, #write
	.byte 0x81, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3824
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x00, 0x00
	.zero 240
.data
check_data0:
	.byte 0x81
.data
check_data1:
	.byte 0xc2
.data
check_data2:
	.byte 0xaf, 0x5d, 0x42, 0x79, 0x42, 0x0a, 0xa3, 0xf9, 0x5f, 0x50, 0x21, 0x38, 0xd7, 0xab, 0xca, 0xc2
	.byte 0x2a, 0x84, 0x21, 0x9b, 0x23, 0x0b, 0xc0, 0x5a, 0x02, 0x24, 0x3f, 0x0b, 0xa2, 0xbc, 0x10, 0xe2
	.byte 0xdf, 0x30, 0xc1, 0xc2, 0x02, 0x77, 0x35, 0x0a, 0x20, 0x12, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1000
	/* C5 */
	.octa 0x800000005f8400220000000000002002
	/* C13 */
	.octa 0x4001d2
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0x800000005f8400220000000000002002
	/* C10 */
	.octa 0x0
	/* C13 */
	.octa 0x4001d2
	/* C15 */
	.octa 0xc2c2
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001e0700070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000003000700ffe00000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x79425daf // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:15 Rn:13 imm12:000010010111 opc:01 111001:111001 size:01
	.inst 0xf9a30a42 // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:18 imm12:100011000010 opc:10 111001:111001 size:11
	.inst 0x3821505f // stsminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:2 00:00 opc:101 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2caabd7 // EORFLGS-C.CR-C Cd:23 Cn:30 1010:1010 opc:10 Rm:10 11000010110:11000010110
	.inst 0x9b21842a // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:10 Rn:1 Ra:1 o0:1 Rm:1 01:01 U:0 10011011:10011011
	.inst 0x5ac00b23 // rev:aarch64/instrs/integer/arithmetic/rev Rd:3 Rn:25 opc:10 1011010110000000000:1011010110000000000 sf:0
	.inst 0x0b3f2402 // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:2 Rn:0 imm3:001 option:001 Rm:31 01011001:01011001 S:0 op:0 sf:0
	.inst 0xe210bca2 // ALDURSB-R.RI-32 Rt:2 Rn:5 op2:11 imm9:100001011 V:0 op1:00 11100010:11100010
	.inst 0xc2c130df // GCFLGS-R.C-C Rd:31 Cn:6 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0x0a357702 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:2 Rn:24 imm6:011101 Rm:21 N:1 shift:00 01010:01010 opc:00 sf:0
	.inst 0xc2c21220
	.zero 724
	.inst 0x0000c2c2
	.zero 1047804
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
	ldr x19, =initial_cap_values
	.inst 0xc2400261 // ldr c1, [x19, #0]
	.inst 0xc2400662 // ldr c2, [x19, #1]
	.inst 0xc2400a65 // ldr c5, [x19, #2]
	.inst 0xc2400e6d // ldr c13, [x19, #3]
	.inst 0xc240127e // ldr c30, [x19, #4]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	ldr x19, =0x4
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82603233 // ldr c19, [c17, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x82601233 // ldr c19, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400271 // ldr c17, [x19, #0]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400671 // ldr c17, [x19, #1]
	.inst 0xc2d1a4a1 // chkeq c5, c17
	b.ne comparison_fail
	.inst 0xc2400a71 // ldr c17, [x19, #2]
	.inst 0xc2d1a541 // chkeq c10, c17
	b.ne comparison_fail
	.inst 0xc2400e71 // ldr c17, [x19, #3]
	.inst 0xc2d1a5a1 // chkeq c13, c17
	b.ne comparison_fail
	.inst 0xc2401271 // ldr c17, [x19, #4]
	.inst 0xc2d1a5e1 // chkeq c15, c17
	b.ne comparison_fail
	.inst 0xc2401671 // ldr c17, [x19, #5]
	.inst 0xc2d1a7c1 // chkeq c30, c17
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
	ldr x0, =0x00001f0d
	ldr x1, =check_data1
	ldr x2, =0x00001f0e
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
	ldr x0, =0x00400300
	ldr x1, =check_data3
	ldr x2, =0x00400302
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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

.section data0, #alloc, #write
	.zero 4064
	.byte 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data0:
	.byte 0xff, 0xff
.data
check_data1:
	.byte 0x40, 0x00, 0x3f, 0xd6, 0x9f, 0x68, 0xde, 0xc2, 0x0a, 0x0c, 0x00, 0xe2, 0x5e, 0x46, 0x20, 0x2b
	.byte 0x2b, 0x90, 0x5e, 0xfa, 0xbb, 0x91, 0xc0, 0xc2, 0x3f, 0x12, 0x64, 0x78, 0x20, 0xfc, 0x60, 0xad
	.byte 0x82, 0x06, 0xc4, 0xc2, 0x02, 0x1e, 0x9b, 0x38, 0xc0, 0x10, 0xc2, 0xc2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 32
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4fdffe
	/* C1 */
	.octa 0x80000000000100050000000000500000
	/* C2 */
	.octa 0x400004
	/* C4 */
	.octa 0x4000000000000000000000000
	/* C13 */
	.octa 0x0
	/* C16 */
	.octa 0x800000000116000f000000000040004f
	/* C17 */
	.octa 0xc0000000000100050000000000001fe0
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x4fdffe
	/* C1 */
	.octa 0x80000000000100050000000000500000
	/* C2 */
	.octa 0x40
	/* C4 */
	.octa 0x4000000000000000000000000
	/* C10 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C16 */
	.octa 0x800000000116000f0000000000400000
	/* C17 */
	.octa 0xc0000000000100050000000000001fe0
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x9fbffc
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001007902f0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 16
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd63f0040 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:2 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.inst 0xc2de689f // ORRFLGS-C.CR-C Cd:31 Cn:4 1010:1010 opc:01 Rm:30 11000010110:11000010110
	.inst 0xe2000c0a // ALDURSB-R.RI-32 Rt:10 Rn:0 op2:11 imm9:000000000 V:0 op1:00 11100010:11100010
	.inst 0x2b20465e // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:30 Rn:18 imm3:001 option:010 Rm:0 01011001:01011001 S:1 op:0 sf:0
	.inst 0xfa5e902b // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1011 0:0 Rn:1 00:00 cond:1001 Rm:30 111010010:111010010 op:1 sf:1
	.inst 0xc2c091bb // GCTAG-R.C-C Rd:27 Cn:13 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0x7864123f // stclrh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:17 00:00 opc:001 o3:0 Rs:4 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xad60fc20 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:0 Rn:1 Rt2:11111 imm7:1000001 L:1 1011010:1011010 opc:10
	.inst 0xc2c40682 // BUILD-C.C-C Cd:2 Cn:20 001:001 opc:00 0:0 Cm:4 11000010110:11000010110
	.inst 0x389b1e02 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:2 Rn:16 11:11 imm9:110110001 0:0 opc:10 111000:111000 size:00
	.inst 0xc2c210c0
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a0 // ldr c0, [x21, #0]
	.inst 0xc24006a1 // ldr c1, [x21, #1]
	.inst 0xc2400aa2 // ldr c2, [x21, #2]
	.inst 0xc2400ea4 // ldr c4, [x21, #3]
	.inst 0xc24012ad // ldr c13, [x21, #4]
	.inst 0xc24016b0 // ldr c16, [x21, #5]
	.inst 0xc2401ab1 // ldr c17, [x21, #6]
	.inst 0xc2401eb2 // ldr c18, [x21, #7]
	.inst 0xc24022b4 // ldr c20, [x21, #8]
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30851037
	msr SCTLR_EL3, x21
	ldr x21, =0x4
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030d5 // ldr c21, [c6, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x826010d5 // ldr c21, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	isb
	/* Check processor flags */
	mrs x21, nzcv
	ubfx x21, x21, #28, #4
	mov x6, #0xf
	and x21, x21, x6
	cmp x21, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002a6 // ldr c6, [x21, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc24006a6 // ldr c6, [x21, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400aa6 // ldr c6, [x21, #2]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400ea6 // ldr c6, [x21, #3]
	.inst 0xc2c6a481 // chkeq c4, c6
	b.ne comparison_fail
	.inst 0xc24012a6 // ldr c6, [x21, #4]
	.inst 0xc2c6a541 // chkeq c10, c6
	b.ne comparison_fail
	.inst 0xc24016a6 // ldr c6, [x21, #5]
	.inst 0xc2c6a5a1 // chkeq c13, c6
	b.ne comparison_fail
	.inst 0xc2401aa6 // ldr c6, [x21, #6]
	.inst 0xc2c6a601 // chkeq c16, c6
	b.ne comparison_fail
	.inst 0xc2401ea6 // ldr c6, [x21, #7]
	.inst 0xc2c6a621 // chkeq c17, c6
	b.ne comparison_fail
	.inst 0xc24022a6 // ldr c6, [x21, #8]
	.inst 0xc2c6a641 // chkeq c18, c6
	b.ne comparison_fail
	.inst 0xc24026a6 // ldr c6, [x21, #9]
	.inst 0xc2c6a681 // chkeq c20, c6
	b.ne comparison_fail
	.inst 0xc2402aa6 // ldr c6, [x21, #10]
	.inst 0xc2c6a761 // chkeq c27, c6
	b.ne comparison_fail
	.inst 0xc2402ea6 // ldr c6, [x21, #11]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check vector registers */
	ldr x21, =0x0
	mov x6, v0.d[0]
	cmp x21, x6
	b.ne comparison_fail
	ldr x21, =0x0
	mov x6, v0.d[1]
	cmp x21, x6
	b.ne comparison_fail
	ldr x21, =0x0
	mov x6, v31.d[0]
	cmp x21, x6
	b.ne comparison_fail
	ldr x21, =0x0
	mov x6, v31.d[1]
	cmp x21, x6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001fe0
	ldr x1, =check_data0
	ldr x2, =0x00001fe2
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x004fdffe
	ldr x1, =check_data2
	ldr x2, =0x004fdfff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004ffc10
	ldr x1, =check_data3
	ldr x2, =0x004ffc30
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
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

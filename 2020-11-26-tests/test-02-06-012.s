.section data0, #alloc, #write
	.zero 288
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3792
.data
check_data0:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0c, 0x00, 0x04, 0x40, 0x00, 0x00, 0x10, 0xcc
.data
check_data1:
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0xaa, 0x13, 0xc5, 0xc2, 0xff, 0x73, 0x76, 0xf8, 0x21, 0x7c, 0xbe, 0xa2, 0x59, 0xc3, 0xdd, 0xc2
	.byte 0x1f, 0x84, 0x1f, 0x38, 0x18, 0xbc, 0x67, 0x82, 0xd3, 0xeb, 0x1b, 0xf1, 0x01, 0x84, 0x28, 0x9b
	.byte 0xed, 0xe1, 0x3d, 0x22, 0xff, 0xe2, 0xc1, 0xc2, 0xc0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000600200050000000000001c00
	/* C1 */
	.octa 0xcc1000004004000c0000000000001000
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0x4c0000005800085a0000000000001040
	/* C22 */
	.octa 0x2000000000000000
	/* C23 */
	.octa 0x3fff800000000000000000000000
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x10000000
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x40000000600200050000000000001bf8
	/* C10 */
	.octa 0x10000000
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0x4c0000005800085a0000000000001040
	/* C19 */
	.octa 0xfffffffffffff906
	/* C22 */
	.octa 0x2000000000000000
	/* C23 */
	.octa 0x3fff800000000000000000000000
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0xc0000000000500030000000000001120
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x8000000010070fdf00ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c513aa // CVTD-R.C-C Rd:10 Cn:29 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0xf87673ff // stumin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:111 o3:0 Rs:22 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0xa2be7c21 // CAS-C.R-C Ct:1 Rn:1 11111:11111 R:0 Cs:30 1:1 L:0 1:1 10100010:10100010
	.inst 0xc2ddc359 // CVT-R.CC-C Rd:25 Cn:26 110000:110000 Cm:29 11000010110:11000010110
	.inst 0x381f841f // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:0 01:01 imm9:111111000 0:0 opc:00 111000:111000 size:00
	.inst 0x8267bc18 // ALDR-R.RI-64 Rt:24 Rn:0 op:11 imm9:001111011 L:1 1000001001:1000001001
	.inst 0xf11bebd3 // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:19 Rn:30 imm12:011011111010 sh:0 0:0 10001:10001 S:1 op:1 sf:1
	.inst 0x9b288401 // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:1 Rn:0 Ra:1 o0:1 Rm:8 01:01 U:0 10011011:10011011
	.inst 0x223de1ed // STLXP-R.CR-C Ct:13 Rn:15 Ct2:11000 1:1 Rs:29 1:1 L:0 001000100:001000100
	.inst 0xc2c1e2ff // SCFLGS-C.CR-C Cd:31 Cn:23 111000:111000 Rm:1 11000010110:11000010110
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
	ldr x17, =initial_cap_values
	.inst 0xc2400220 // ldr c0, [x17, #0]
	.inst 0xc2400621 // ldr c1, [x17, #1]
	.inst 0xc2400a2d // ldr c13, [x17, #2]
	.inst 0xc2400e2f // ldr c15, [x17, #3]
	.inst 0xc2401236 // ldr c22, [x17, #4]
	.inst 0xc2401637 // ldr c23, [x17, #5]
	.inst 0xc2401a3a // ldr c26, [x17, #6]
	.inst 0xc2401e3d // ldr c29, [x17, #7]
	.inst 0xc240223e // ldr c30, [x17, #8]
	/* Set up flags and system registers */
	mov x17, #0x00000000
	msr nzcv, x17
	ldr x17, =initial_SP_EL3_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2c1d23f // cpy c31, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30851035
	msr SCTLR_EL3, x17
	ldr x17, =0x0
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030d1 // ldr c17, [c6, #3]
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	.inst 0x826010d1 // ldr c17, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21220 // br c17
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30851035
	msr SCTLR_EL3, x17
	isb
	/* Check processor flags */
	mrs x17, nzcv
	ubfx x17, x17, #28, #4
	mov x6, #0xf
	and x17, x17, x6
	cmp x17, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400226 // ldr c6, [x17, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400626 // ldr c6, [x17, #1]
	.inst 0xc2c6a541 // chkeq c10, c6
	b.ne comparison_fail
	.inst 0xc2400a26 // ldr c6, [x17, #2]
	.inst 0xc2c6a5a1 // chkeq c13, c6
	b.ne comparison_fail
	.inst 0xc2400e26 // ldr c6, [x17, #3]
	.inst 0xc2c6a5e1 // chkeq c15, c6
	b.ne comparison_fail
	.inst 0xc2401226 // ldr c6, [x17, #4]
	.inst 0xc2c6a661 // chkeq c19, c6
	b.ne comparison_fail
	.inst 0xc2401626 // ldr c6, [x17, #5]
	.inst 0xc2c6a6c1 // chkeq c22, c6
	b.ne comparison_fail
	.inst 0xc2401a26 // ldr c6, [x17, #6]
	.inst 0xc2c6a6e1 // chkeq c23, c6
	b.ne comparison_fail
	.inst 0xc2401e26 // ldr c6, [x17, #7]
	.inst 0xc2c6a701 // chkeq c24, c6
	b.ne comparison_fail
	.inst 0xc2402226 // ldr c6, [x17, #8]
	.inst 0xc2c6a721 // chkeq c25, c6
	b.ne comparison_fail
	.inst 0xc2402626 // ldr c6, [x17, #9]
	.inst 0xc2c6a741 // chkeq c26, c6
	b.ne comparison_fail
	.inst 0xc2402a26 // ldr c6, [x17, #10]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	.inst 0xc2402e26 // ldr c6, [x17, #11]
	.inst 0xc2c6a7c1 // chkeq c30, c6
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
	ldr x0, =0x00001120
	ldr x1, =check_data1
	ldr x2, =0x00001128
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001c00
	ldr x1, =check_data2
	ldr x2, =0x00001c01
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fd0
	ldr x1, =check_data3
	ldr x2, =0x00001fd8
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
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
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

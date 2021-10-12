.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xb8, 0x1b, 0xeb, 0xc2, 0xae, 0x3f, 0xcf, 0x78, 0x20, 0x00, 0xc2, 0xc2, 0x5d, 0x28, 0xdf, 0xc2
	.byte 0x7d, 0xe0, 0xc7, 0xc2, 0x20, 0x12, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x8000703150000001fc7ff9281
	/* C2 */
	.octa 0x7ffd7f
	/* C3 */
	.octa 0x3fff800000000000000000000000
	/* C11 */
	.octa 0xfb5262de89e6ba
	/* C29 */
	.octa 0x800000000003000100000000004c65ad
final_cap_values:
	/* C0 */
	.octa 0x83fceffce0000001fc7ff9281
	/* C1 */
	.octa 0x8000703150000001fc7ff9281
	/* C2 */
	.octa 0x7ffd7f
	/* C3 */
	.octa 0x3fff800000000000000000000000
	/* C11 */
	.octa 0xfb5262de89e6ba
	/* C14 */
	.octa 0xffffc2c2
	/* C24 */
	.octa 0x800000000003000100fb5262de89e6ba
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x2000800001e900050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2eb1bb8 // CVT-C.CR-C Cd:24 Cn:29 0110:0110 0:0 0:0 Rm:11 11000010111:11000010111
	.inst 0x78cf3fae // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:14 Rn:29 11:11 imm9:011110011 0:0 opc:11 111000:111000 size:01
	.inst 0xc2c20020 // 0xc2c20020
	.inst 0xc2df285d // BICFLGS-C.CR-C Cd:29 Cn:2 1010:1010 opc:00 Rm:31 11000010110:11000010110
	.inst 0xc2c7e07d // SCFLGS-C.CR-C Cd:29 Cn:3 111000:111000 Rm:7 11000010110:11000010110
	.inst 0xc2c21220
	.zero 812680
	.inst 0x0000c2c2
	.zero 235868
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
	ldr x27, =initial_cap_values
	.inst 0xc2400361 // ldr c1, [x27, #0]
	.inst 0xc2400762 // ldr c2, [x27, #1]
	.inst 0xc2400b63 // ldr c3, [x27, #2]
	.inst 0xc2400f6b // ldr c11, [x27, #3]
	.inst 0xc240137d // ldr c29, [x27, #4]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30851037
	msr SCTLR_EL3, x27
	ldr x27, =0x4
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x8260123b // ldr c27, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30851035
	msr SCTLR_EL3, x27
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400371 // ldr c17, [x27, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc2400771 // ldr c17, [x27, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400b71 // ldr c17, [x27, #2]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc2400f71 // ldr c17, [x27, #3]
	.inst 0xc2d1a461 // chkeq c3, c17
	b.ne comparison_fail
	.inst 0xc2401371 // ldr c17, [x27, #4]
	.inst 0xc2d1a561 // chkeq c11, c17
	b.ne comparison_fail
	.inst 0xc2401771 // ldr c17, [x27, #5]
	.inst 0xc2d1a5c1 // chkeq c14, c17
	b.ne comparison_fail
	.inst 0xc2401b71 // ldr c17, [x27, #6]
	.inst 0xc2d1a701 // chkeq c24, c17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00400000
	ldr x1, =check_data0
	ldr x2, =0x00400018
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x004c66a0
	ldr x1, =check_data1
	ldr x2, =0x004c66a2
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	/* Done print message */
	/* turn off MMU */
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
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

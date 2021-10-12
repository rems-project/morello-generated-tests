.section data0, #alloc, #write
	.byte 0xde, 0x00, 0x00, 0x68, 0x00, 0x01, 0xb1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 48
	.byte 0xfe, 0xfd, 0x00, 0x82, 0x00, 0x1c, 0xff, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4016
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.byte 0xfe, 0xfd, 0x00, 0x82, 0x00, 0x1c, 0xff, 0x20
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x81, 0x84, 0xd4, 0xc2, 0xdf, 0x23, 0x2a, 0xf8, 0xbf, 0x11, 0x7e, 0xf8, 0x21, 0x23, 0xdb, 0x1a
	.byte 0xde, 0x83, 0xa2, 0xa2, 0x93, 0x72, 0xc6, 0xc2, 0x01, 0xd0, 0x9f, 0xda, 0xe9, 0xbf, 0x0a, 0xb8
	.byte 0xc2, 0xb3, 0xc5, 0xc2, 0x90, 0xc2, 0xbf, 0x78, 0xe0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x4000000000000000000000000000
	/* C4 */
	.octa 0x1c00700000000c0e08000
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x20310108680000de
	/* C13 */
	.octa 0x40
	/* C20 */
	.octa 0x70000000000000000
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0xffffffffffffffff
	/* C2 */
	.octa 0x200080004c4900002080000800000000
	/* C4 */
	.octa 0x1c00700000000c0e08000
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x20310108680000de
	/* C13 */
	.octa 0x40
	/* C16 */
	.octa 0x0
	/* C19 */
	.octa 0x70000000000000000
	/* C20 */
	.octa 0x70000000000000000
	/* C30 */
	.octa 0x2080000800000000
initial_SP_EL3_value:
	.octa 0xffffffffffffffd5
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004c4900000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd8100000020702040000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d48481 // CHKSS-_.CC-C 00001:00001 Cn:4 001:001 opc:00 1:1 Cm:20 11000010110:11000010110
	.inst 0xf82a23df // steor:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:010 o3:0 Rs:10 1:1 R:0 A:0 00:00 V:0 111:111 size:11
	.inst 0xf87e11bf // ldclr:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:13 00:00 opc:001 0:0 Rs:30 1:1 R:1 A:0 111000:111000 size:11
	.inst 0x1adb2321 // lslv:aarch64/instrs/integer/shift/variable Rd:1 Rn:25 op2:00 0010:0010 Rm:27 0011010110:0011010110 sf:0
	.inst 0xa2a283de // SWPA-CC.R-C Ct:30 Rn:30 100000:100000 Cs:2 1:1 R:0 A:1 10100010:10100010
	.inst 0xc2c67293 // CLRPERM-C.CI-C Cd:19 Cn:20 100:100 perm:011 1100001011000110:1100001011000110
	.inst 0xda9fd001 // csinv:aarch64/instrs/integer/conditional/select Rd:1 Rn:0 o2:0 0:0 cond:1101 Rm:31 011010100:011010100 op:1 sf:1
	.inst 0xb80abfe9 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:9 Rn:31 11:11 imm9:010101011 0:0 opc:00 111000:111000 size:10
	.inst 0xc2c5b3c2 // CVTP-C.R-C Cd:2 Rn:30 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0x78bfc290 // ldaprh:aarch64/instrs/memory/ordered-rcpc Rt:16 Rn:20 110000:110000 Rs:11111 111000101:111000101 size:01
	.inst 0xc2c211e0
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
	ldr x8, =initial_cap_values
	.inst 0xc2400102 // ldr c2, [x8, #0]
	.inst 0xc2400504 // ldr c4, [x8, #1]
	.inst 0xc2400909 // ldr c9, [x8, #2]
	.inst 0xc2400d0a // ldr c10, [x8, #3]
	.inst 0xc240110d // ldr c13, [x8, #4]
	.inst 0xc2401514 // ldr c20, [x8, #5]
	.inst 0xc240191e // ldr c30, [x8, #6]
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =initial_SP_EL3_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2c1d11f // cpy c31, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30851037
	msr SCTLR_EL3, x8
	ldr x8, =0x4
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031e8 // ldr c8, [c15, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x826011e8 // ldr c8, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* Check processor flags */
	mrs x8, nzcv
	ubfx x8, x8, #28, #4
	mov x15, #0xf
	and x8, x8, x15
	cmp x8, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc240010f // ldr c15, [x8, #0]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc240050f // ldr c15, [x8, #1]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc240090f // ldr c15, [x8, #2]
	.inst 0xc2cfa481 // chkeq c4, c15
	b.ne comparison_fail
	.inst 0xc2400d0f // ldr c15, [x8, #3]
	.inst 0xc2cfa521 // chkeq c9, c15
	b.ne comparison_fail
	.inst 0xc240110f // ldr c15, [x8, #4]
	.inst 0xc2cfa541 // chkeq c10, c15
	b.ne comparison_fail
	.inst 0xc240150f // ldr c15, [x8, #5]
	.inst 0xc2cfa5a1 // chkeq c13, c15
	b.ne comparison_fail
	.inst 0xc240190f // ldr c15, [x8, #6]
	.inst 0xc2cfa601 // chkeq c16, c15
	b.ne comparison_fail
	.inst 0xc2401d0f // ldr c15, [x8, #7]
	.inst 0xc2cfa661 // chkeq c19, c15
	b.ne comparison_fail
	.inst 0xc240210f // ldr c15, [x8, #8]
	.inst 0xc2cfa681 // chkeq c20, c15
	b.ne comparison_fail
	.inst 0xc240250f // ldr c15, [x8, #9]
	.inst 0xc2cfa7c1 // chkeq c30, c15
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
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001048
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001080
	ldr x1, =check_data2
	ldr x2, =0x00001084
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
	/* Done print message */
	/* turn off MMU */
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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

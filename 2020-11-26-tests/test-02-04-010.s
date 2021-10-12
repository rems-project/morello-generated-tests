.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0xbd, 0xc3, 0x2b, 0xd1, 0xdf, 0x13, 0xc5, 0xc2, 0xff, 0xfa, 0xbe, 0x9b, 0xc3, 0x7f, 0x42, 0x0a
	.byte 0x8b, 0x23, 0xa0, 0x78, 0x1f, 0xad, 0x0c, 0xf8, 0xbf, 0xdb, 0x21, 0xf1, 0x3e, 0x33, 0xc6, 0xc2
	.byte 0x9e, 0x01, 0x22, 0x38, 0xfd, 0x63, 0x46, 0xf8, 0xe0, 0x10, 0xc2, 0xc2
.data
check_data3:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C8 */
	.octa 0x1e56
	/* C12 */
	.octa 0x1000
	/* C25 */
	.octa 0x3fff800000000000000000000000
	/* C28 */
	.octa 0x1000
	/* C30 */
	.octa 0x1
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C8 */
	.octa 0x1f20
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x1000
	/* C25 */
	.octa 0x3fff800000000000000000000000
	/* C28 */
	.octa 0x1000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x40000a
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000e000f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000008140050080000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd12bc3bd // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:29 Rn:29 imm12:101011110000 sh:0 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0xc2c513df // CVTD-R.C-C Rd:31 Cn:30 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0x9bbefaff // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:31 Rn:23 Ra:30 o0:1 Rm:30 01:01 U:1 10011011:10011011
	.inst 0x0a427fc3 // and_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:3 Rn:30 imm6:011111 Rm:2 N:0 shift:01 01010:01010 opc:00 sf:0
	.inst 0x78a0238b // ldeorh:aarch64/instrs/memory/atomicops/ld Rt:11 Rn:28 00:00 opc:010 0:0 Rs:0 1:1 R:0 A:1 111000:111000 size:01
	.inst 0xf80cad1f // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:8 11:11 imm9:011001010 0:0 opc:00 111000:111000 size:11
	.inst 0xf121dbbf // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:29 imm12:100001110110 sh:0 0:0 10001:10001 S:1 op:1 sf:1
	.inst 0xc2c6333e // CLRPERM-C.CI-C Cd:30 Cn:25 100:100 perm:001 1100001011000110:1100001011000110
	.inst 0x3822019e // ldaddb:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:12 00:00 opc:000 0:0 Rs:2 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xf84663fd // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:29 Rn:31 00:00 imm9:001100110 0:0 opc:01 111000:111000 size:11
	.inst 0xc2c210e0
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c2 // ldr c2, [x14, #1]
	.inst 0xc24009c8 // ldr c8, [x14, #2]
	.inst 0xc2400dcc // ldr c12, [x14, #3]
	.inst 0xc24011d9 // ldr c25, [x14, #4]
	.inst 0xc24015dc // ldr c28, [x14, #5]
	.inst 0xc24019de // ldr c30, [x14, #6]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =initial_SP_EL3_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2c1d1df // cpy c31, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	ldr x14, =0x4
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030ee // ldr c14, [c7, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x826010ee // ldr c14, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001c7 // ldr c7, [x14, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc24005c7 // ldr c7, [x14, #1]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc24009c7 // ldr c7, [x14, #2]
	.inst 0xc2c7a461 // chkeq c3, c7
	b.ne comparison_fail
	.inst 0xc2400dc7 // ldr c7, [x14, #3]
	.inst 0xc2c7a501 // chkeq c8, c7
	b.ne comparison_fail
	.inst 0xc24011c7 // ldr c7, [x14, #4]
	.inst 0xc2c7a561 // chkeq c11, c7
	b.ne comparison_fail
	.inst 0xc24015c7 // ldr c7, [x14, #5]
	.inst 0xc2c7a581 // chkeq c12, c7
	b.ne comparison_fail
	.inst 0xc24019c7 // ldr c7, [x14, #6]
	.inst 0xc2c7a721 // chkeq c25, c7
	b.ne comparison_fail
	.inst 0xc2401dc7 // ldr c7, [x14, #7]
	.inst 0xc2c7a781 // chkeq c28, c7
	b.ne comparison_fail
	.inst 0xc24021c7 // ldr c7, [x14, #8]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc24025c7 // ldr c7, [x14, #9]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001f20
	ldr x1, =check_data1
	ldr x2, =0x00001f28
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
	ldr x0, =0x00400070
	ldr x1, =check_data3
	ldr x2, =0x00400078
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
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

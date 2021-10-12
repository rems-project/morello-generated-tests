.section data0, #alloc, #write
	.byte 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x00, 0x10, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xfe, 0xc1, 0x85, 0x82, 0x98, 0x2f, 0x64, 0xd0, 0xf5, 0x83, 0x3d, 0xb8, 0xa0, 0x08, 0xc0, 0xc2
	.byte 0x3f, 0x42, 0x64, 0xf8, 0xb9, 0x33, 0xc0, 0xc2, 0xc1, 0xb3, 0xc0, 0xc2, 0xf9, 0x5b, 0xd5, 0xc2
	.byte 0xff, 0xef, 0x28, 0x71, 0xaa, 0xfb, 0x81, 0x82, 0x40, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x1f0
	/* C15 */
	.octa 0x1000
	/* C17 */
	.octa 0xc0000000000100050000000000001000
	/* C29 */
	.octa 0x207ce070000000000001000
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x1f0
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x1f0
	/* C10 */
	.octa 0x4
	/* C15 */
	.octa 0x1000
	/* C17 */
	.octa 0xc0000000000100050000000000001000
	/* C21 */
	.octa 0x0
	/* C24 */
	.octa 0xc00000000403000701000000005f2000
	/* C25 */
	.octa 0xc0000000600000010000040000000000
	/* C29 */
	.octa 0x207ce070000000000001000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0xc0000000600000010000000000001020
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000403000700ffffff38000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x8285c1fe // ASTRB-R.RRB-B Rt:30 Rn:15 opc:00 S:0 option:110 Rm:5 0:0 L:0 100000101:100000101
	.inst 0xd0642f98 // ADRDP-C.ID-C Rd:24 immhi:110010000101111100 P:0 10000:10000 immlo:10 op:1
	.inst 0xb83d83f5 // swp:aarch64/instrs/memory/atomicops/swp Rt:21 Rn:31 100000:100000 Rs:29 1:1 R:0 A:0 111000:111000 size:10
	.inst 0xc2c008a0 // SEAL-C.CC-C Cd:0 Cn:5 0010:0010 opc:00 Cm:0 11000010110:11000010110
	.inst 0xf864423f // stsmax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:17 00:00 opc:100 o3:0 Rs:4 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0xc2c033b9 // GCLEN-R.C-C Rd:25 Cn:29 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0xc2c0b3c1 // GCSEAL-R.C-C Rd:1 Cn:30 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xc2d55bf9 // ALIGNU-C.CI-C Cd:25 Cn:31 0110:0110 U:1 imm6:101010 11000010110:11000010110
	.inst 0x7128efff // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:31 imm12:101000111011 sh:0 0:0 10001:10001 S:1 op:1 sf:0
	.inst 0x8281fbaa // ALDRSH-R.RRB-64 Rt:10 Rn:29 opc:10 S:1 option:111 Rm:1 0:0 L:0 100000101:100000101
	.inst 0xc2c21340
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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400664 // ldr c4, [x19, #1]
	.inst 0xc2400a65 // ldr c5, [x19, #2]
	.inst 0xc2400e6f // ldr c15, [x19, #3]
	.inst 0xc2401271 // ldr c17, [x19, #4]
	.inst 0xc240167d // ldr c29, [x19, #5]
	.inst 0xc2401a7e // ldr c30, [x19, #6]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =initial_SP_EL3_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2c1d27f // cpy c31, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x3085103f
	msr SCTLR_EL3, x19
	ldr x19, =0x0
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82603353 // ldr c19, [c26, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x82601353 // ldr c19, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x26, #0xf
	and x19, x19, x26
	cmp x19, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc240027a // ldr c26, [x19, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240067a // ldr c26, [x19, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc2400a7a // ldr c26, [x19, #2]
	.inst 0xc2daa481 // chkeq c4, c26
	b.ne comparison_fail
	.inst 0xc2400e7a // ldr c26, [x19, #3]
	.inst 0xc2daa4a1 // chkeq c5, c26
	b.ne comparison_fail
	.inst 0xc240127a // ldr c26, [x19, #4]
	.inst 0xc2daa541 // chkeq c10, c26
	b.ne comparison_fail
	.inst 0xc240167a // ldr c26, [x19, #5]
	.inst 0xc2daa5e1 // chkeq c15, c26
	b.ne comparison_fail
	.inst 0xc2401a7a // ldr c26, [x19, #6]
	.inst 0xc2daa621 // chkeq c17, c26
	b.ne comparison_fail
	.inst 0xc2401e7a // ldr c26, [x19, #7]
	.inst 0xc2daa6a1 // chkeq c21, c26
	b.ne comparison_fail
	.inst 0xc240227a // ldr c26, [x19, #8]
	.inst 0xc2daa701 // chkeq c24, c26
	b.ne comparison_fail
	.inst 0xc240267a // ldr c26, [x19, #9]
	.inst 0xc2daa721 // chkeq c25, c26
	b.ne comparison_fail
	.inst 0xc2402a7a // ldr c26, [x19, #10]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc2402e7a // ldr c26, [x19, #11]
	.inst 0xc2daa7c1 // chkeq c30, c26
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001024
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011f0
	ldr x1, =check_data2
	ldr x2, =0x000011f1
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

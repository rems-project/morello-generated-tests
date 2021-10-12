.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x20, 0xec, 0x10, 0xbc, 0x5e, 0x19, 0xe1, 0xc2, 0x10, 0x78, 0xc6, 0xc2, 0x4b, 0xc8, 0xff, 0x82
	.byte 0x1e, 0x5c, 0x26, 0xf1, 0x21, 0xca, 0xa2, 0xb8, 0x5e, 0xd2, 0xc0, 0xc2, 0x1e, 0xa3, 0xdd, 0xc2
	.byte 0x22, 0x14, 0xa6, 0xf9, 0xe7, 0x4b, 0x7e, 0xb8, 0x60, 0x10, 0xc2, 0xc2
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000020000000000000000
	/* C1 */
	.octa 0x10f2
	/* C2 */
	.octa 0x800000000001000500000000004fb6f0
	/* C10 */
	.octa 0x800300070000e00000000001
	/* C17 */
	.octa 0x4908
	/* C24 */
	.octa 0x1fc8
final_cap_values:
	/* C0 */
	.octa 0x800000020000000000000000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x800000000001000500000000004fb6f0
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0x800300070000e00000000001
	/* C16 */
	.octa 0xc0c000000000000000000000
	/* C17 */
	.octa 0x4908
	/* C24 */
	.octa 0x1fc8
	/* C30 */
	.octa 0x1fc8
initial_SP_EL3_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xbc10ec20 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:0 Rn:1 11:11 imm9:100001110 0:0 opc:00 111100:111100 size:10
	.inst 0xc2e1195e // CVT-C.CR-C Cd:30 Cn:10 0110:0110 0:0 0:0 Rm:1 11000010111:11000010111
	.inst 0xc2c67810 // SCBNDS-C.CI-S Cd:16 Cn:0 1110:1110 S:1 imm6:001100 11000010110:11000010110
	.inst 0x82ffc84b // ALDR-V.RRB-D Rt:11 Rn:2 opc:10 S:0 option:110 Rm:31 1:1 L:1 100000101:100000101
	.inst 0xf1265c1e // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:30 Rn:0 imm12:100110010111 sh:0 0:0 10001:10001 S:1 op:1 sf:1
	.inst 0xb8a2ca21 // ldrsw_reg:aarch64/instrs/memory/single/general/register Rt:1 Rn:17 10:10 S:0 option:110 Rm:2 1:1 opc:10 111000:111000 size:10
	.inst 0xc2c0d25e // GCPERM-R.C-C Rd:30 Cn:18 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0xc2dda31e // CLRPERM-C.CR-C Cd:30 Cn:24 000:000 1:1 10:10 Rm:29 11000010110:11000010110
	.inst 0xf9a61422 // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:1 imm12:100110000101 opc:10 111001:111001 size:11
	.inst 0xb87e4be7 // ldr_reg_gen:aarch64/instrs/memory/single/general/register Rt:7 Rn:31 10:10 S:0 option:010 Rm:30 1:1 opc:01 111000:111000 size:10
	.inst 0xc2c21060
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x6, cptr_el3
	orr x6, x6, #0x200
	msr cptr_el3, x6
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c1 // ldr c1, [x6, #1]
	.inst 0xc24008c2 // ldr c2, [x6, #2]
	.inst 0xc2400cca // ldr c10, [x6, #3]
	.inst 0xc24010d1 // ldr c17, [x6, #4]
	.inst 0xc24014d8 // ldr c24, [x6, #5]
	/* Vector registers */
	mrs x6, cptr_el3
	bfc x6, #10, #1
	msr cptr_el3, x6
	isb
	ldr q0, =0x0
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =initial_SP_EL3_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2c1d0df // cpy c31, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30850032
	msr SCTLR_EL3, x6
	ldr x6, =0x0
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82603066 // ldr c6, [c3, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x82601066 // ldr c6, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x3, #0xf
	and x6, x6, x3
	cmp x6, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000c3 // ldr c3, [x6, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc24004c3 // ldr c3, [x6, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc24008c3 // ldr c3, [x6, #2]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400cc3 // ldr c3, [x6, #3]
	.inst 0xc2c3a4e1 // chkeq c7, c3
	b.ne comparison_fail
	.inst 0xc24010c3 // ldr c3, [x6, #4]
	.inst 0xc2c3a541 // chkeq c10, c3
	b.ne comparison_fail
	.inst 0xc24014c3 // ldr c3, [x6, #5]
	.inst 0xc2c3a601 // chkeq c16, c3
	b.ne comparison_fail
	.inst 0xc24018c3 // ldr c3, [x6, #6]
	.inst 0xc2c3a621 // chkeq c17, c3
	b.ne comparison_fail
	.inst 0xc2401cc3 // ldr c3, [x6, #7]
	.inst 0xc2c3a701 // chkeq c24, c3
	b.ne comparison_fail
	.inst 0xc24020c3 // ldr c3, [x6, #8]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x3, v0.d[0]
	cmp x6, x3
	b.ne comparison_fail
	ldr x6, =0x0
	mov x3, v0.d[1]
	cmp x6, x3
	b.ne comparison_fail
	ldr x6, =0x0
	mov x3, v11.d[0]
	cmp x6, x3
	b.ne comparison_fail
	ldr x6, =0x0
	mov x3, v11.d[1]
	cmp x6, x3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001fc8
	ldr x1, =check_data1
	ldr x2, =0x00001fcc
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
	ldr x0, =0x004fb6f0
	ldr x1, =check_data3
	ldr x2, =0x004fb6f8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004ffff8
	ldr x1, =check_data4
	ldr x2, =0x004ffffc
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
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

	.balign 128
vector_table:
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
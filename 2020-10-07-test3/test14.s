.section data0, #alloc, #write
	.zero 4064
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0x15, 0x73, 0x1f, 0xab, 0x9e, 0x92, 0xc5, 0xc2, 0x00, 0x10, 0xc0, 0xc2, 0xff, 0xc3, 0xd5, 0xc2
	.byte 0x1e, 0x02, 0x50, 0x38, 0x18, 0xd0, 0xc1, 0xc2, 0x21, 0xb8, 0xd7, 0xc2, 0x32, 0x2a, 0x7c, 0x82
	.byte 0x2a, 0x7d, 0x19, 0x13, 0xf3, 0x63, 0x82, 0x9a, 0x80, 0x10, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x700060000000000000000
	/* C1 */
	.octa 0xc00000000000000000000000
	/* C16 */
	.octa 0x800000000001000500000000005000fe
	/* C17 */
	.octa 0x18e0
	/* C20 */
	.octa 0x40000060000001
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xc02f00000000000000000000
	/* C16 */
	.octa 0x800000000001000500000000005000fe
	/* C17 */
	.octa 0x18e0
	/* C18 */
	.octa 0xc2c2c2c2
	/* C20 */
	.octa 0x40000060000001
	/* C24 */
	.octa 0x0
	/* C30 */
	.octa 0xc2
initial_SP_EL3_value:
	.octa 0x1
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000500070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 32
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xab1f7315 // adds_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:21 Rn:24 imm6:011100 Rm:31 0:0 shift:00 01011:01011 S:1 op:0 sf:1
	.inst 0xc2c5929e // CVTD-C.R-C Cd:30 Rn:20 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0xc2c01000 // GCBASE-R.C-C Rd:0 Cn:0 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0xc2d5c3ff // CVT-R.CC-C Rd:31 Cn:31 110000:110000 Cm:21 11000010110:11000010110
	.inst 0x3850021e // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:16 00:00 imm9:100000000 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c1d018 // CPY-C.C-C Cd:24 Cn:0 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0xc2d7b821 // SCBNDS-C.CI-C Cd:1 Cn:1 1110:1110 S:0 imm6:101111 11000010110:11000010110
	.inst 0x827c2a32 // ALDR-R.RI-32 Rt:18 Rn:17 op:10 imm9:111000010 L:1 1000001001:1000001001
	.inst 0x13197d2a // sbfm:aarch64/instrs/integer/bitfield Rd:10 Rn:9 imms:011111 immr:011001 N:0 100110:100110 opc:00 sf:0
	.inst 0x9a8263f3 // csel:aarch64/instrs/integer/conditional/select Rd:19 Rn:31 o2:0 0:0 cond:0110 Rm:2 011010100:011010100 op:0 sf:1
	.inst 0xc2c21080
	.zero 1048528
	.inst 0x00c20000
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x14, cptr_el3
	orr x14, x14, #0x200
	msr cptr_el3, x14
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c1 // ldr c1, [x14, #1]
	.inst 0xc24009d0 // ldr c16, [x14, #2]
	.inst 0xc2400dd1 // ldr c17, [x14, #3]
	.inst 0xc24011d4 // ldr c20, [x14, #4]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =initial_SP_EL3_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2c1d1df // cpy c31, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	ldr x14, =0x0
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x8260308e // ldr c14, [c4, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x8260108e // ldr c14, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x4, #0xf
	and x14, x14, x4
	cmp x14, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001c4 // ldr c4, [x14, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc24005c4 // ldr c4, [x14, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc24009c4 // ldr c4, [x14, #2]
	.inst 0xc2c4a601 // chkeq c16, c4
	b.ne comparison_fail
	.inst 0xc2400dc4 // ldr c4, [x14, #3]
	.inst 0xc2c4a621 // chkeq c17, c4
	b.ne comparison_fail
	.inst 0xc24011c4 // ldr c4, [x14, #4]
	.inst 0xc2c4a641 // chkeq c18, c4
	b.ne comparison_fail
	.inst 0xc24015c4 // ldr c4, [x14, #5]
	.inst 0xc2c4a681 // chkeq c20, c4
	b.ne comparison_fail
	.inst 0xc24019c4 // ldr c4, [x14, #6]
	.inst 0xc2c4a701 // chkeq c24, c4
	b.ne comparison_fail
	.inst 0xc2401dc4 // ldr c4, [x14, #7]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001fe8
	ldr x1, =check_data0
	ldr x2, =0x00001fec
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
	ldr x0, =0x004ffffe
	ldr x1, =check_data2
	ldr x2, =0x004fffff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
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

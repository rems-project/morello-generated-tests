.section data0, #alloc, #write
	.zero 4000
	.byte 0x00, 0x00, 0x00, 0x00, 0x92, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 80
.data
check_data0:
	.byte 0x92, 0x1f
.data
check_data1:
	.byte 0x92, 0x1f
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x33, 0x8f, 0x4d, 0xe2, 0x20, 0x00, 0x3f, 0xd6
.data
check_data4:
	.byte 0xfa, 0x47, 0x99, 0xe2, 0xe5, 0x91, 0xc1, 0xc2, 0x41, 0x70, 0xff, 0x82, 0x13, 0xd0, 0x19, 0x78
	.byte 0x7e, 0x84, 0x1a, 0x92, 0x61, 0xc2, 0x06, 0xe2, 0xe2, 0x52, 0xc1, 0xc2, 0xc1, 0x84, 0xcc, 0xc2
	.byte 0x80, 0x10, 0xc2, 0xc2
.data
check_data5:
	.zero 4
.data
check_data6:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000100050000000000001069
	/* C1 */
	.octa 0x400010
	/* C2 */
	.octa 0x4ffff8
	/* C6 */
	.octa 0x1000c0000000000000001
	/* C12 */
	.octa 0x400100010000000000000001
	/* C25 */
	.octa 0x1ecc
final_cap_values:
	/* C0 */
	.octa 0x40000000000100050000000000001069
	/* C1 */
	.octa 0x0
	/* C6 */
	.octa 0x1000c0000000000000001
	/* C12 */
	.octa 0x400100010000000000000001
	/* C19 */
	.octa 0x1f92
	/* C25 */
	.octa 0x1ecc
	/* C26 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x410034
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000000080000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword final_cap_values + 0
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe24d8f33 // ALDURSH-R.RI-32 Rt:19 Rn:25 op2:11 imm9:011011000 V:0 op1:01 11100010:11100010
	.inst 0xd63f0020 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:1 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 8
	.inst 0xe29947fa // ALDUR-R.RI-32 Rt:26 Rn:31 op2:01 imm9:110010100 V:0 op1:10 11100010:11100010
	.inst 0xc2c191e5 // CLRTAG-C.C-C Cd:5 Cn:15 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0x82ff7041 // ALDR-R.RRB-32 Rt:1 Rn:2 opc:00 S:1 option:011 Rm:31 1:1 L:1 100000101:100000101
	.inst 0x7819d013 // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:19 Rn:0 00:00 imm9:110011101 0:0 opc:00 111000:111000 size:01
	.inst 0x921a847e // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:30 Rn:3 imms:100001 immr:011010 N:0 100100:100100 opc:00 sf:1
	.inst 0xe206c261 // ASTURB-R.RI-32 Rt:1 Rn:19 op2:00 imm9:001101100 V:0 op1:00 11100010:11100010
	.inst 0xc2c152e2 // CFHI-R.C-C Rd:2 Cn:23 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xc2cc84c1 // CHKSS-_.CC-C 00001:00001 Cn:6 001:001 opc:00 1:1 Cm:12 11000010110:11000010110
	.inst 0xc2c21080
	.zero 1048524
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x27, cptr_el3
	orr x27, x27, #0x200
	msr cptr_el3, x27
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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400761 // ldr c1, [x27, #1]
	.inst 0xc2400b62 // ldr c2, [x27, #2]
	.inst 0xc2400f66 // ldr c6, [x27, #3]
	.inst 0xc240136c // ldr c12, [x27, #4]
	.inst 0xc2401779 // ldr c25, [x27, #5]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =initial_SP_EL3_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2c1d37f // cpy c31, c27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
	ldr x27, =0x4
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x8260309b // ldr c27, [c4, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x8260109b // ldr c27, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	/* Check processor flags */
	mrs x27, nzcv
	ubfx x27, x27, #28, #4
	mov x4, #0xf
	and x27, x27, x4
	cmp x27, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400364 // ldr c4, [x27, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc2400764 // ldr c4, [x27, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400b64 // ldr c4, [x27, #2]
	.inst 0xc2c4a4c1 // chkeq c6, c4
	b.ne comparison_fail
	.inst 0xc2400f64 // ldr c4, [x27, #3]
	.inst 0xc2c4a581 // chkeq c12, c4
	b.ne comparison_fail
	.inst 0xc2401364 // ldr c4, [x27, #4]
	.inst 0xc2c4a661 // chkeq c19, c4
	b.ne comparison_fail
	.inst 0xc2401764 // ldr c4, [x27, #5]
	.inst 0xc2c4a721 // chkeq c25, c4
	b.ne comparison_fail
	.inst 0xc2401b64 // ldr c4, [x27, #6]
	.inst 0xc2c4a741 // chkeq c26, c4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001006
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001fa4
	ldr x1, =check_data1
	ldr x2, =0x00001fa6
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
	ldr x2, =0x00400008
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400010
	ldr x1, =check_data4
	ldr x2, =0x00400034
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0040ffc8
	ldr x1, =check_data5
	ldr x2, =0x0040ffcc
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004ffff8
	ldr x1, =check_data6
	ldr x2, =0x004ffffc
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
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

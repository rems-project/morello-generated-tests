.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0xd9, 0x93, 0xd2, 0xe2, 0xc5, 0x1b, 0x13, 0xf8, 0x20, 0x7d, 0xdf, 0x08, 0x40, 0xd8, 0xbf, 0xf8
	.byte 0xdf, 0x43, 0xdc, 0xc2, 0xff, 0x30, 0xc5, 0xc2, 0xff, 0xf8, 0xb0, 0xf8, 0x21, 0x7c, 0xdf, 0x48
	.byte 0xc2, 0x03, 0x1d, 0xfa, 0xfe, 0x2b, 0x41, 0x0a, 0xc0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x101c
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x400000
	/* C9 */
	.octa 0x1ec0
	/* C25 */
	.octa 0x0
	/* C28 */
	.octa 0xffffffffffe001
	/* C30 */
	.octa 0x4000000060020005000000000000205f
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x400000
	/* C9 */
	.octa 0x1ec0
	/* C25 */
	.octa 0x0
	/* C28 */
	.octa 0xffffffffffe001
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000240700070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000000010005000000000000e000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2d293d9 // ASTUR-R.RI-64 Rt:25 Rn:30 op2:00 imm9:100101001 V:0 op1:11 11100010:11100010
	.inst 0xf8131bc5 // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:5 Rn:30 10:10 imm9:100110001 0:0 opc:00 111000:111000 size:11
	.inst 0x08df7d20 // ldlarb:aarch64/instrs/memory/ordered Rt:0 Rn:9 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xf8bfd840 // prfm_reg:aarch64/instrs/memory/single/general/register Rt:0 Rn:2 10:10 S:1 option:110 Rm:31 1:1 opc:10 111000:111000 size:11
	.inst 0xc2dc43df // SCVALUE-C.CR-C Cd:31 Cn:30 000:000 opc:10 0:0 Rm:28 11000010110:11000010110
	.inst 0xc2c530ff // CVTP-R.C-C Rd:31 Cn:7 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0xf8b0f8ff // prfm_reg:aarch64/instrs/memory/single/general/register Rt:31 Rn:7 10:10 S:1 option:111 Rm:16 1:1 opc:10 111000:111000 size:11
	.inst 0x48df7c21 // ldlarh:aarch64/instrs/memory/ordered Rt:1 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xfa1d03c2 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:2 Rn:30 000000:000000 Rm:29 11010000:11010000 S:1 op:1 sf:1
	.inst 0x0a412bfe // and_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:31 imm6:001010 Rm:1 N:0 shift:01 01010:01010 opc:00 sf:0
	.inst 0xc2c211c0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x15, cptr_el3
	orr x15, x15, #0x200
	msr cptr_el3, x15
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr cvbar_el3, c1
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e1 // ldr c1, [x15, #0]
	.inst 0xc24005e5 // ldr c5, [x15, #1]
	.inst 0xc24009e7 // ldr c7, [x15, #2]
	.inst 0xc2400de9 // ldr c9, [x15, #3]
	.inst 0xc24011f9 // ldr c25, [x15, #4]
	.inst 0xc24015fc // ldr c28, [x15, #5]
	.inst 0xc24019fe // ldr c30, [x15, #6]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30850032
	msr SCTLR_EL3, x15
	ldr x15, =0xc
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031cf // ldr c15, [c14, #3]
	.inst 0xc28b412f // msr ddc_el3, c15
	isb
	.inst 0x826011cf // ldr c15, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr ddc_el3, c15
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001ee // ldr c14, [x15, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc24005ee // ldr c14, [x15, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc24009ee // ldr c14, [x15, #2]
	.inst 0xc2cea4a1 // chkeq c5, c14
	b.ne comparison_fail
	.inst 0xc2400dee // ldr c14, [x15, #3]
	.inst 0xc2cea4e1 // chkeq c7, c14
	b.ne comparison_fail
	.inst 0xc24011ee // ldr c14, [x15, #4]
	.inst 0xc2cea521 // chkeq c9, c14
	b.ne comparison_fail
	.inst 0xc24015ee // ldr c14, [x15, #5]
	.inst 0xc2cea721 // chkeq c25, c14
	b.ne comparison_fail
	.inst 0xc24019ee // ldr c14, [x15, #6]
	.inst 0xc2cea781 // chkeq c28, c14
	b.ne comparison_fail
	.inst 0xc2401dee // ldr c14, [x15, #7]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000101c
	ldr x1, =check_data0
	ldr x2, =0x0000101e
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ec0
	ldr x1, =check_data1
	ldr x2, =0x00001ec1
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f88
	ldr x1, =check_data2
	ldr x2, =0x00001f98
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr ddc_el3, c15
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

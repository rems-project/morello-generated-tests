.section data0, #alloc, #write
	.zero 32
	.byte 0x09, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 4048
.data
check_data0:
	.zero 32
	.byte 0x09, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x10, 0xe2, 0x45, 0xb8, 0x88, 0x32, 0xc4, 0xc2, 0xe0, 0x03, 0x1e, 0x1a, 0x3d, 0xd8, 0x55, 0xc2
	.byte 0x01, 0x7b, 0x49, 0x4b, 0xfe, 0x93, 0x3e, 0x6b, 0x8e, 0xba, 0x02, 0xf9, 0xdf, 0xd3, 0xc1, 0xc2
	.byte 0x81, 0xd0, 0xc5, 0xc2, 0xde, 0xab, 0xc2, 0xc2, 0xe0, 0x10, 0xc2, 0xc2
.data
check_data3:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x8000000000010007ffffffffffffb8a0
	/* C4 */
	.octa 0x80000000000000
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x444002
	/* C20 */
	.octa 0xd0100000580408140000000000001010
final_cap_values:
	/* C1 */
	.octa 0x800000005005203f0080000000000000
	/* C4 */
	.octa 0x80000000000000
	/* C8 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C20 */
	.octa 0xd0100000580408140000000000001010
	/* C29 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080400000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000005005203f000000000044e001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword 0x0000000000001020
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb845e210 // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:16 Rn:16 00:00 imm9:001011110 0:0 opc:01 111000:111000 size:10
	.inst 0xc2c43288 // LDPBLR-C.C-C Ct:8 Cn:20 100:100 opc:01 11000010110001000:11000010110001000
	.inst 0x1a1e03e0 // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:0 Rn:31 000000:000000 Rm:30 11010000:11010000 S:0 op:0 sf:0
	.inst 0xc255d83d // LDR-C.RIB-C Ct:29 Rn:1 imm12:010101110110 L:1 110000100:110000100
	.inst 0x4b497b01 // sub_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:1 Rn:24 imm6:011110 Rm:9 0:0 shift:01 01011:01011 S:0 op:1 sf:0
	.inst 0x6b3e93fe // subs_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:30 Rn:31 imm3:100 option:100 Rm:30 01011001:01011001 S:1 op:1 sf:0
	.inst 0xf902ba8e // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:14 Rn:20 imm12:000010101110 opc:00 111001:111001 size:11
	.inst 0xc2c1d3df // CPY-C.C-C Cd:31 Cn:30 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0xc2c5d081 // CVTDZ-C.R-C Cd:1 Rn:4 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0xc2c2abde // EORFLGS-C.CR-C Cd:30 Cn:30 1010:1010 opc:10 Rm:2 11000010110:11000010110
	.inst 0xc2c210e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x23, cptr_el3
	orr x23, x23, #0x200
	msr cptr_el3, x23
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e1 // ldr c1, [x23, #0]
	.inst 0xc24006e4 // ldr c4, [x23, #1]
	.inst 0xc2400aee // ldr c14, [x23, #2]
	.inst 0xc2400ef0 // ldr c16, [x23, #3]
	.inst 0xc24012f4 // ldr c20, [x23, #4]
	/* Set up flags and system registers */
	mov x23, #0x00000000
	msr nzcv, x23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30850032
	msr SCTLR_EL3, x23
	ldr x23, =0x80
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030f7 // ldr c23, [c7, #3]
	.inst 0xc28b4137 // msr DDC_EL3, c23
	isb
	.inst 0x826010f7 // ldr c23, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c212e0 // br c23
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002e7 // ldr c7, [x23, #0]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc24006e7 // ldr c7, [x23, #1]
	.inst 0xc2c7a481 // chkeq c4, c7
	b.ne comparison_fail
	.inst 0xc2400ae7 // ldr c7, [x23, #2]
	.inst 0xc2c7a501 // chkeq c8, c7
	b.ne comparison_fail
	.inst 0xc2400ee7 // ldr c7, [x23, #3]
	.inst 0xc2c7a5c1 // chkeq c14, c7
	b.ne comparison_fail
	.inst 0xc24012e7 // ldr c7, [x23, #4]
	.inst 0xc2c7a601 // chkeq c16, c7
	b.ne comparison_fail
	.inst 0xc24016e7 // ldr c7, [x23, #5]
	.inst 0xc2c7a681 // chkeq c20, c7
	b.ne comparison_fail
	.inst 0xc2401ae7 // ldr c7, [x23, #6]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001030
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001580
	ldr x1, =check_data1
	ldr x2, =0x00001588
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
	ldr x0, =0x00444060
	ldr x1, =check_data3
	ldr x2, =0x00444064
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
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
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

.section data0, #alloc, #write
	.zero 48
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2
	.zero 4032
.data
check_data0:
	.byte 0xc2
.data
check_data1:
	.byte 0x20, 0xf4, 0x03, 0xe2, 0xde, 0xfb, 0xa6, 0xf8, 0x1f, 0xf8, 0xc7, 0xc2, 0xe1, 0xe8, 0xdc, 0x78
	.byte 0x5e, 0x80, 0xc2, 0xc2, 0x16, 0x10, 0xc0, 0xc2, 0x1f, 0x30, 0x7b, 0xd1, 0x32, 0x48, 0x3e, 0x4b
	.byte 0xc0, 0x7f, 0x41, 0x9b, 0x05, 0x10, 0xc5, 0xc2, 0x20, 0x13, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1000
	/* C2 */
	.octa 0x0
	/* C7 */
	.octa 0x80000000202720230000000000460034
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xffffc2c2
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x80000000202720230000000000460034
	/* C18 */
	.octa 0xffffc2c2
	/* C22 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000005104000000ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe203f420 // ALDURB-R.RI-32 Rt:0 Rn:1 op2:01 imm9:000111111 V:0 op1:00 11100010:11100010
	.inst 0xf8a6fbde // prfm_reg:aarch64/instrs/memory/single/general/register Rt:30 Rn:30 10:10 S:1 option:111 Rm:6 1:1 opc:10 111000:111000 size:11
	.inst 0xc2c7f81f // SCBNDS-C.CI-S Cd:31 Cn:0 1110:1110 S:1 imm6:001111 11000010110:11000010110
	.inst 0x78dce8e1 // ldtrsh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:7 10:10 imm9:111001110 0:0 opc:11 111000:111000 size:01
	.inst 0xc2c2805e // SCTAG-C.CR-C Cd:30 Cn:2 000:000 0:0 10:10 Rm:2 11000010110:11000010110
	.inst 0xc2c01016 // GCBASE-R.C-C Rd:22 Cn:0 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0xd17b301f // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:0 imm12:111011001100 sh:1 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0x4b3e4832 // sub_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:18 Rn:1 imm3:010 option:010 Rm:30 01011001:01011001 S:0 op:1 sf:0
	.inst 0x9b417fc0 // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:0 Rn:30 Ra:11111 0:0 Rm:1 10:10 U:0 10011011:10011011
	.inst 0xc2c51005 // CVTD-R.C-C Rd:5 Cn:0 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0xc2c21320
	.zero 393172
	.inst 0xc2c20000
	.zero 655356
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x29, cptr_el3
	orr x29, x29, #0x200
	msr cptr_el3, x29
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
	ldr x29, =initial_cap_values
	.inst 0xc24003a1 // ldr c1, [x29, #0]
	.inst 0xc24007a2 // ldr c2, [x29, #1]
	.inst 0xc2400ba7 // ldr c7, [x29, #2]
	/* Set up flags and system registers */
	mov x29, #0x00000000
	msr nzcv, x29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x30850030
	msr SCTLR_EL3, x29
	ldr x29, =0x4
	msr S3_6_C1_C2_2, x29 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x8260333d // ldr c29, [c25, #3]
	.inst 0xc28b413d // msr ddc_el3, c29
	isb
	.inst 0x8260133d // ldr c29, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c213a0 // br c29
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr ddc_el3, c29
	isb
	/* Check processor flags */
	mrs x29, nzcv
	ubfx x29, x29, #28, #4
	mov x25, #0xf
	and x29, x29, x25
	cmp x29, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003b9 // ldr c25, [x29, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc24007b9 // ldr c25, [x29, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400bb9 // ldr c25, [x29, #2]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400fb9 // ldr c25, [x29, #3]
	.inst 0xc2d9a4a1 // chkeq c5, c25
	b.ne comparison_fail
	.inst 0xc24013b9 // ldr c25, [x29, #4]
	.inst 0xc2d9a4e1 // chkeq c7, c25
	b.ne comparison_fail
	.inst 0xc24017b9 // ldr c25, [x29, #5]
	.inst 0xc2d9a641 // chkeq c18, c25
	b.ne comparison_fail
	.inst 0xc2401bb9 // ldr c25, [x29, #6]
	.inst 0xc2d9a6c1 // chkeq c22, c25
	b.ne comparison_fail
	.inst 0xc2401fb9 // ldr c25, [x29, #7]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000103f
	ldr x1, =check_data0
	ldr x2, =0x00001040
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
	ldr x0, =0x00460002
	ldr x1, =check_data2
	ldr x2, =0x00460004
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
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr ddc_el3, c29
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

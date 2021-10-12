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
	.byte 0xfe, 0xef, 0x5a, 0xe2, 0x22, 0x7c, 0xdf, 0x08, 0x19, 0x63, 0x0e, 0xb0, 0x81, 0x0a, 0xe2, 0xc2
	.byte 0xe7, 0x83, 0xac, 0xaa, 0x09, 0xe8, 0x9d, 0xb8, 0x01, 0x19, 0xd6, 0xc2, 0x5e, 0xb2, 0xc5, 0xc2
	.byte 0x7f, 0x4e, 0x10, 0xe2, 0xe1, 0x7f, 0x3f, 0x42, 0x80, 0x10, 0xc2, 0xc2
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8000000000010005000000000048fc1a
	/* C1 */
	.octa 0x800000000001000500000000004ffffe
	/* C8 */
	.octa 0x8011c04f0000100000000001
	/* C18 */
	.octa 0x80000000040004
	/* C19 */
	.octa 0x5000fa
	/* C20 */
	.octa 0x3fff800000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x8000000000010005000000000048fc1a
	/* C1 */
	.octa 0x8011c04f0000100000000000
	/* C2 */
	.octa 0x0
	/* C8 */
	.octa 0x8011c04f0000100000000001
	/* C9 */
	.octa 0x0
	/* C18 */
	.octa 0x80000000040004
	/* C19 */
	.octa 0x5000fa
	/* C20 */
	.octa 0x3fff800000000000000000000000
	/* C25 */
	.octa 0xc000000000010005000000001cc61000
	/* C30 */
	.octa 0x20008000440000000080000000440004
initial_SP_EL3_value:
	.octa 0x1200
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000440000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword final_cap_values + 0
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe25aeffe // ALDURSH-R.RI-32 Rt:30 Rn:31 op2:11 imm9:110101110 V:0 op1:01 11100010:11100010
	.inst 0x08df7c22 // ldlarb:aarch64/instrs/memory/ordered Rt:2 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xb00e6319 // ADRDP-C.ID-C Rd:25 immhi:000111001100011000 P:0 10000:10000 immlo:01 op:1
	.inst 0xc2e20a81 // ORRFLGS-C.CI-C Cd:1 Cn:20 0:0 01:01 imm8:00010000 11000010111:11000010111
	.inst 0xaaac83e7 // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:7 Rn:31 imm6:100000 Rm:12 N:1 shift:10 01010:01010 opc:01 sf:1
	.inst 0xb89de809 // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:9 Rn:0 10:10 imm9:111011110 0:0 opc:10 111000:111000 size:10
	.inst 0xc2d61901 // ALIGND-C.CI-C Cd:1 Cn:8 0110:0110 U:0 imm6:101100 11000010110:11000010110
	.inst 0xc2c5b25e // CVTP-C.R-C Cd:30 Rn:18 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xe2104e7f // ALDURSB-R.RI-32 Rt:31 Rn:19 op2:11 imm9:100000100 V:0 op1:00 11100010:11100010
	.inst 0x423f7fe1 // ASTLRB-R.R-B Rt:1 Rn:31 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xc2c21080
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
	.inst 0xc24002e0 // ldr c0, [x23, #0]
	.inst 0xc24006e1 // ldr c1, [x23, #1]
	.inst 0xc2400ae8 // ldr c8, [x23, #2]
	.inst 0xc2400ef2 // ldr c18, [x23, #3]
	.inst 0xc24012f3 // ldr c19, [x23, #4]
	.inst 0xc24016f4 // ldr c20, [x23, #5]
	/* Set up flags and system registers */
	mov x23, #0x00000000
	msr nzcv, x23
	ldr x23, =initial_SP_EL3_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2c1d2ff // cpy c31, c23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30850032
	msr SCTLR_EL3, x23
	ldr x23, =0x8
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82603097 // ldr c23, [c4, #3]
	.inst 0xc28b4137 // msr DDC_EL3, c23
	isb
	.inst 0x82601097 // ldr c23, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
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
	.inst 0xc24002e4 // ldr c4, [x23, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc24006e4 // ldr c4, [x23, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400ae4 // ldr c4, [x23, #2]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc2400ee4 // ldr c4, [x23, #3]
	.inst 0xc2c4a501 // chkeq c8, c4
	b.ne comparison_fail
	.inst 0xc24012e4 // ldr c4, [x23, #4]
	.inst 0xc2c4a521 // chkeq c9, c4
	b.ne comparison_fail
	.inst 0xc24016e4 // ldr c4, [x23, #5]
	.inst 0xc2c4a641 // chkeq c18, c4
	b.ne comparison_fail
	.inst 0xc2401ae4 // ldr c4, [x23, #6]
	.inst 0xc2c4a661 // chkeq c19, c4
	b.ne comparison_fail
	.inst 0xc2401ee4 // ldr c4, [x23, #7]
	.inst 0xc2c4a681 // chkeq c20, c4
	b.ne comparison_fail
	.inst 0xc24022e4 // ldr c4, [x23, #8]
	.inst 0xc2c4a721 // chkeq c25, c4
	b.ne comparison_fail
	.inst 0xc24026e4 // ldr c4, [x23, #9]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000011ae
	ldr x1, =check_data0
	ldr x2, =0x000011b0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001200
	ldr x1, =check_data1
	ldr x2, =0x00001201
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
	ldr x0, =0x0048fbf8
	ldr x1, =check_data3
	ldr x2, =0x0048fbfc
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004ffffe
	ldr x1, =check_data4
	ldr x2, =0x004fffff
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

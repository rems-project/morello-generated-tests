.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x4d, 0x00, 0xc0, 0x5a, 0x22, 0x93, 0x26, 0xc2, 0x22, 0x10, 0xc0, 0x5a, 0x00, 0x74, 0x4b, 0x69
	.byte 0x01, 0x10, 0xc1, 0xc2, 0x5e, 0x58, 0xc0, 0xc2, 0xfe, 0x1f, 0x41, 0x4b, 0x21, 0x3a, 0x54, 0x38
	.byte 0x29, 0x10, 0xc0, 0xc2, 0xab, 0x2b, 0x2b, 0x8b, 0xc0, 0x12, 0xc2, 0xc2
.data
check_data2:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000007000f00000000003fffc4
	/* C2 */
	.octa 0x0
	/* C17 */
	.octa 0x800000005004d0070000000000400802
	/* C25 */
	.octa 0x4c00000000030007ffffffffffff8000
final_cap_values:
	/* C0 */
	.octa 0x38543a21
	/* C1 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C17 */
	.octa 0x800000005004d0070000000000400802
	/* C25 */
	.octa 0x4c00000000030007ffffffffffff8000
	/* C29 */
	.octa 0xffffffffc2c01029
	/* C30 */
	.octa 0xfe000001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000455400000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x5ac0004d // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:13 Rn:2 101101011000000000000:101101011000000000000 sf:0
	.inst 0xc2269322 // STR-C.RIB-C Ct:2 Rn:25 imm12:100110100100 L:0 110000100:110000100
	.inst 0x5ac01022 // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:2 Rn:1 op:0 10110101100000000010:10110101100000000010 sf:0
	.inst 0x694b7400 // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:0 Rn:0 Rt2:11101 imm7:0010110 L:1 1010010:1010010 opc:01
	.inst 0xc2c11001 // GCLIM-R.C-C Rd:1 Cn:0 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0xc2c0585e // ALIGNU-C.CI-C Cd:30 Cn:2 0110:0110 U:1 imm6:000000 11000010110:11000010110
	.inst 0x4b411ffe // sub_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:30 Rn:31 imm6:000111 Rm:1 0:0 shift:01 01011:01011 S:0 op:1 sf:0
	.inst 0x38543a21 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:17 10:10 imm9:101000011 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c01029 // GCBASE-R.C-C Rd:9 Cn:1 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0x8b2b2bab // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:11 Rn:29 imm3:010 option:001 Rm:11 01011001:01011001 S:0 op:0 sf:1
	.inst 0xc2c212c0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x10, cptr_el3
	orr x10, x10, #0x200
	msr cptr_el3, x10
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
	ldr x10, =initial_cap_values
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400542 // ldr c2, [x10, #1]
	.inst 0xc2400951 // ldr c17, [x10, #2]
	.inst 0xc2400d59 // ldr c25, [x10, #3]
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826012ca // ldr c10, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400156 // ldr c22, [x10, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400556 // ldr c22, [x10, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400956 // ldr c22, [x10, #2]
	.inst 0xc2d6a521 // chkeq c9, c22
	b.ne comparison_fail
	.inst 0xc2400d56 // ldr c22, [x10, #3]
	.inst 0xc2d6a5a1 // chkeq c13, c22
	b.ne comparison_fail
	.inst 0xc2401156 // ldr c22, [x10, #4]
	.inst 0xc2d6a621 // chkeq c17, c22
	b.ne comparison_fail
	.inst 0xc2401556 // ldr c22, [x10, #5]
	.inst 0xc2d6a721 // chkeq c25, c22
	b.ne comparison_fail
	.inst 0xc2401956 // ldr c22, [x10, #6]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc2401d56 // ldr c22, [x10, #7]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001a40
	ldr x1, =check_data0
	ldr x2, =0x00001a50
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
	ldr x0, =0x00400745
	ldr x1, =check_data2
	ldr x2, =0x00400746
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
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
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

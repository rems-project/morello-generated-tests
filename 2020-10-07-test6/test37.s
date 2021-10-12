.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.byte 0x9a, 0x90, 0xc0, 0xc2, 0x27, 0xd0, 0x42, 0x38, 0x40, 0xb1, 0xc0, 0xc2, 0xf4, 0xf2, 0xc0, 0xc2
	.byte 0xad, 0x4a, 0x79, 0xa2, 0x1f, 0x38, 0xce, 0xc2, 0x02, 0xf0, 0xc5, 0xc2, 0xdc, 0x10, 0xc0, 0xc2
	.byte 0xc1, 0x79, 0x5f, 0xd8, 0x6c, 0x7a, 0x1e, 0xa2, 0x40, 0x12, 0xc2, 0xc2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x80000000402e400f0000000000404000
	/* C4 */
	.octa 0x0
	/* C6 */
	.octa 0x400000000000000000000000
	/* C10 */
	.octa 0x3fff800000000000000000000000
	/* C12 */
	.octa 0x4000000000000000000000000000
	/* C19 */
	.octa 0x48000000000100050000000000002170
	/* C21 */
	.octa 0x901000000005000fffffffffe0000000
	/* C25 */
	.octa 0x20410650
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x80000000402e400f0000000000404000
	/* C2 */
	.octa 0x20008000000080080000000000000001
	/* C4 */
	.octa 0x0
	/* C6 */
	.octa 0x400000000000000000000000
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0x3fff800000000000000000000000
	/* C12 */
	.octa 0x4000000000000000000000000000
	/* C13 */
	.octa 0x0
	/* C19 */
	.octa 0x48000000000100050000000000002170
	/* C21 */
	.octa 0x901000000005000fffffffffe0000000
	/* C25 */
	.octa 0x20410650
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c0909a // GCTAG-R.C-C Rd:26 Cn:4 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0x3842d027 // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:7 Rn:1 00:00 imm9:000101101 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c0b140 // GCSEAL-R.C-C Rd:0 Cn:10 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xc2c0f2f4 // GCTYPE-R.C-C Rd:20 Cn:23 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xa2794aad // LDR-C.RRB-C Ct:13 Rn:21 10:10 S:0 option:010 Rm:25 1:1 opc:01 10100010:10100010
	.inst 0xc2ce381f // SCBNDS-C.CI-C Cd:31 Cn:0 1110:1110 S:0 imm6:011100 11000010110:11000010110
	.inst 0xc2c5f002 // CVTPZ-C.R-C Cd:2 Rn:0 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0xc2c010dc // GCBASE-R.C-C Rd:28 Cn:6 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0xd85f79c1 // prfm_lit:aarch64/instrs/memory/literal/general Rt:1 imm19:0101111101111001110 011000:011000 opc:11
	.inst 0xa21e7a6c // STTR-C.RIB-C Ct:12 Rn:19 10:10 imm9:111100111 0:0 opc:00 10100010:10100010
	.inst 0xc2c21240
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x17, cptr_el3
	orr x17, x17, #0x200
	msr cptr_el3, x17
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
	ldr x17, =initial_cap_values
	.inst 0xc2400221 // ldr c1, [x17, #0]
	.inst 0xc2400624 // ldr c4, [x17, #1]
	.inst 0xc2400a26 // ldr c6, [x17, #2]
	.inst 0xc2400e2a // ldr c10, [x17, #3]
	.inst 0xc240122c // ldr c12, [x17, #4]
	.inst 0xc2401633 // ldr c19, [x17, #5]
	.inst 0xc2401a35 // ldr c21, [x17, #6]
	.inst 0xc2401e39 // ldr c25, [x17, #7]
	/* Set up flags and system registers */
	mov x17, #0x00000000
	msr nzcv, x17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30850032
	msr SCTLR_EL3, x17
	ldr x17, =0x8
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82601251 // ldr c17, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c21220 // br c17
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400232 // ldr c18, [x17, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400632 // ldr c18, [x17, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400a32 // ldr c18, [x17, #2]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400e32 // ldr c18, [x17, #3]
	.inst 0xc2d2a481 // chkeq c4, c18
	b.ne comparison_fail
	.inst 0xc2401232 // ldr c18, [x17, #4]
	.inst 0xc2d2a4c1 // chkeq c6, c18
	b.ne comparison_fail
	.inst 0xc2401632 // ldr c18, [x17, #5]
	.inst 0xc2d2a4e1 // chkeq c7, c18
	b.ne comparison_fail
	.inst 0xc2401a32 // ldr c18, [x17, #6]
	.inst 0xc2d2a541 // chkeq c10, c18
	b.ne comparison_fail
	.inst 0xc2401e32 // ldr c18, [x17, #7]
	.inst 0xc2d2a581 // chkeq c12, c18
	b.ne comparison_fail
	.inst 0xc2402232 // ldr c18, [x17, #8]
	.inst 0xc2d2a5a1 // chkeq c13, c18
	b.ne comparison_fail
	.inst 0xc2402632 // ldr c18, [x17, #9]
	.inst 0xc2d2a661 // chkeq c19, c18
	b.ne comparison_fail
	.inst 0xc2402a32 // ldr c18, [x17, #10]
	.inst 0xc2d2a6a1 // chkeq c21, c18
	b.ne comparison_fail
	.inst 0xc2402e32 // ldr c18, [x17, #11]
	.inst 0xc2d2a721 // chkeq c25, c18
	b.ne comparison_fail
	.inst 0xc2403232 // ldr c18, [x17, #12]
	.inst 0xc2d2a741 // chkeq c26, c18
	b.ne comparison_fail
	.inst 0xc2403632 // ldr c18, [x17, #13]
	.inst 0xc2d2a781 // chkeq c28, c18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001fe0
	ldr x1, =check_data0
	ldr x2, =0x00001ff0
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
	ldr x0, =0x0040402d
	ldr x1, =check_data2
	ldr x2, =0x0040402e
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00410650
	ldr x1, =check_data3
	ldr x2, =0x00410660
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
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
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

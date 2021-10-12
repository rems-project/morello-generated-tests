.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x4d
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xfe, 0x83, 0xde, 0xc2, 0x25, 0x07, 0x1e, 0xe2, 0x41, 0x00, 0xc0, 0x5a, 0xc2, 0x27, 0x8d, 0xda
	.byte 0x5f, 0x00, 0x1f, 0xfa, 0xd4, 0x91, 0xc0, 0xc2, 0x35, 0x7e, 0x7f, 0x42, 0xe7, 0x7f, 0x9f, 0x08
	.byte 0xff, 0x14, 0x6b, 0x82, 0x40, 0x00, 0xd7, 0xc2, 0x80, 0x10, 0xc2, 0xc2
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C7 */
	.octa 0x1f4d
	/* C14 */
	.octa 0x0
	/* C17 */
	.octa 0x4ffdfe
	/* C25 */
	.octa 0x50001e
	/* C30 */
	.octa 0x1
final_cap_values:
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x1f4d
	/* C14 */
	.octa 0x0
	/* C17 */
	.octa 0x4ffdfe
	/* C20 */
	.octa 0x1
	/* C21 */
	.octa 0x0
	/* C25 */
	.octa 0x50001e
	/* C30 */
	.octa 0x40000000000100050000000000001810
initial_csp_value:
	.octa 0x40000000000100050000000000001810
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20808000000100050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2de83fe // SCTAG-C.CR-C Cd:30 Cn:31 000:000 0:0 10:10 Rm:30 11000010110:11000010110
	.inst 0xe21e0725 // ALDURB-R.RI-32 Rt:5 Rn:25 op2:01 imm9:111100000 V:0 op1:00 11100010:11100010
	.inst 0x5ac00041 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:1 Rn:2 101101011000000000000:101101011000000000000 sf:0
	.inst 0xda8d27c2 // csneg:aarch64/instrs/integer/conditional/select Rd:2 Rn:30 o2:1 0:0 cond:0010 Rm:13 011010100:011010100 op:1 sf:1
	.inst 0xfa1f005f // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:31 Rn:2 000000:000000 Rm:31 11010000:11010000 S:1 op:1 sf:1
	.inst 0xc2c091d4 // GCTAG-R.C-C Rd:20 Cn:14 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0x427f7e35 // ALDARB-R.R-B Rt:21 Rn:17 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x089f7fe7 // stllrb:aarch64/instrs/memory/ordered Rt:7 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x826b14ff // ALDRB-R.RI-B Rt:31 Rn:7 op:01 imm9:010110001 L:1 1000001001:1000001001
	.inst 0xc2d70040 // SCBNDS-C.CR-C Cd:0 Cn:2 000:000 opc:00 0:0 Rm:23 11000010110:11000010110
	.inst 0xc2c21080
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x18, cptr_el3
	orr x18, x18, #0x200
	msr cptr_el3, x18
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
	ldr x18, =initial_cap_values
	.inst 0xc2400247 // ldr c7, [x18, #0]
	.inst 0xc240064e // ldr c14, [x18, #1]
	.inst 0xc2400a51 // ldr c17, [x18, #2]
	.inst 0xc2400e59 // ldr c25, [x18, #3]
	.inst 0xc240125e // ldr c30, [x18, #4]
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =initial_csp_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2c1d25f // cpy c31, c18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x3085003a
	msr SCTLR_EL3, x18
	ldr x18, =0x0
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82603092 // ldr c18, [c4, #3]
	.inst 0xc28b4132 // msr ddc_el3, c18
	isb
	.inst 0x82601092 // ldr c18, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr ddc_el3, c18
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc2400244 // ldr c4, [x18, #0]
	.inst 0xc2c4a4a1 // chkeq c5, c4
	b.ne comparison_fail
	.inst 0xc2400644 // ldr c4, [x18, #1]
	.inst 0xc2c4a4e1 // chkeq c7, c4
	b.ne comparison_fail
	.inst 0xc2400a44 // ldr c4, [x18, #2]
	.inst 0xc2c4a5c1 // chkeq c14, c4
	b.ne comparison_fail
	.inst 0xc2400e44 // ldr c4, [x18, #3]
	.inst 0xc2c4a621 // chkeq c17, c4
	b.ne comparison_fail
	.inst 0xc2401244 // ldr c4, [x18, #4]
	.inst 0xc2c4a681 // chkeq c20, c4
	b.ne comparison_fail
	.inst 0xc2401644 // ldr c4, [x18, #5]
	.inst 0xc2c4a6a1 // chkeq c21, c4
	b.ne comparison_fail
	.inst 0xc2401a44 // ldr c4, [x18, #6]
	.inst 0xc2c4a721 // chkeq c25, c4
	b.ne comparison_fail
	.inst 0xc2401e44 // ldr c4, [x18, #7]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001810
	ldr x1, =check_data0
	ldr x2, =0x00001811
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffe
	ldr x1, =check_data1
	ldr x2, =0x00001fff
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
	ldr x0, =0x004ffdfe
	ldr x1, =check_data3
	ldr x2, =0x004ffdff
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
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr ddc_el3, c18
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

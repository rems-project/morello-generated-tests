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
	.byte 0xbe, 0xe8, 0xc3, 0xc2, 0x3f, 0xfc, 0x96, 0x82, 0xf5, 0x67, 0x1d, 0x1b, 0x43, 0x6c, 0x13, 0xca
	.byte 0x1b, 0xbf, 0x3a, 0xd1, 0x60, 0x32, 0x29, 0x8b, 0xfc, 0x30, 0x3e, 0x72, 0xe0, 0xc7, 0xd5, 0x82
	.byte 0x5e, 0xc8, 0x44, 0x02, 0xde, 0x1b, 0xfe, 0xc2, 0x00, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc06341fffff00ffe
	/* C2 */
	.octa 0x6000700fffffffff00001
	/* C7 */
	.octa 0x0
	/* C22 */
	.octa 0x1fce5f0000080003
	/* C25 */
	.octa 0x7ffe0ff8
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xc06341fffff00ffe
	/* C2 */
	.octa 0x6000700fffffffff00001
	/* C7 */
	.octa 0x0
	/* C21 */
	.octa 0x7ffe0ff8
	/* C22 */
	.octa 0x1fce5f0000080003
	/* C25 */
	.octa 0x7ffe0ff8
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x600070100000000032001
initial_csp_value:
	.octa 0xffffffff80020030
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000000071007000000000000c000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c3e8be // CTHI-C.CR-C Cd:30 Cn:5 1010:1010 opc:11 Rm:3 11000010110:11000010110
	.inst 0x8296fc3f // ASTRH-R.RRB-32 Rt:31 Rn:1 opc:11 S:1 option:111 Rm:22 0:0 L:0 100000101:100000101
	.inst 0x1b1d67f5 // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:21 Rn:31 Ra:25 o0:0 Rm:29 0011011000:0011011000 sf:0
	.inst 0xca136c43 // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:3 Rn:2 imm6:011011 Rm:19 N:0 shift:00 01010:01010 opc:10 sf:1
	.inst 0xd13abf1b // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:27 Rn:24 imm12:111010101111 sh:0 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0x8b293260 // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:0 Rn:19 imm3:100 option:001 Rm:9 01011001:01011001 S:0 op:0 sf:1
	.inst 0x723e30fc // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:28 Rn:7 imms:001100 immr:111110 N:0 100100:100100 opc:11 sf:0
	.inst 0x82d5c7e0 // ALDRSB-R.RRB-32 Rt:0 Rn:31 opc:01 S:0 option:110 Rm:21 0:0 L:1 100000101:100000101
	.inst 0x0244c85e // ADD-C.CIS-C Cd:30 Cn:2 imm12:000100110010 sh:1 A:0 00000010:00000010
	.inst 0xc2fe1bde // CVT-C.CR-C Cd:30 Cn:30 0110:0110 0:0 0:0 Rm:30 11000010111:11000010111
	.inst 0xc2c21200
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
	ldr x17, =initial_cap_values
	.inst 0xc2400221 // ldr c1, [x17, #0]
	.inst 0xc2400622 // ldr c2, [x17, #1]
	.inst 0xc2400a27 // ldr c7, [x17, #2]
	.inst 0xc2400e36 // ldr c22, [x17, #3]
	.inst 0xc2401239 // ldr c25, [x17, #4]
	/* Set up flags and system registers */
	mov x17, #0x00000000
	msr nzcv, x17
	ldr x17, =initial_csp_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2c1d23f // cpy c31, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x3085003a
	msr SCTLR_EL3, x17
	ldr x17, =0x0
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82603211 // ldr c17, [c16, #3]
	.inst 0xc28b4131 // msr ddc_el3, c17
	isb
	.inst 0x82601211 // ldr c17, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c21220 // br c17
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr ddc_el3, c17
	isb
	/* Check processor flags */
	mrs x17, nzcv
	ubfx x17, x17, #28, #4
	mov x16, #0xf
	and x17, x17, x16
	cmp x17, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400230 // ldr c16, [x17, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc2400630 // ldr c16, [x17, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400a30 // ldr c16, [x17, #2]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400e30 // ldr c16, [x17, #3]
	.inst 0xc2d0a4e1 // chkeq c7, c16
	b.ne comparison_fail
	.inst 0xc2401230 // ldr c16, [x17, #4]
	.inst 0xc2d0a6a1 // chkeq c21, c16
	b.ne comparison_fail
	.inst 0xc2401630 // ldr c16, [x17, #5]
	.inst 0xc2d0a6c1 // chkeq c22, c16
	b.ne comparison_fail
	.inst 0xc2401a30 // ldr c16, [x17, #6]
	.inst 0xc2d0a721 // chkeq c25, c16
	b.ne comparison_fail
	.inst 0xc2401e30 // ldr c16, [x17, #7]
	.inst 0xc2d0a781 // chkeq c28, c16
	b.ne comparison_fail
	.inst 0xc2402230 // ldr c16, [x17, #8]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001004
	ldr x1, =check_data0
	ldr x2, =0x00001006
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001028
	ldr x1, =check_data1
	ldr x2, =0x00001029
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr ddc_el3, c17
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

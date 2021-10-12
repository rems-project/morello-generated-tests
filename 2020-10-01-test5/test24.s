.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xff, 0xb3, 0xc0, 0xc2, 0xa2, 0x3f, 0x51, 0xa2, 0x7e, 0x66, 0x9f, 0x8a, 0xbe, 0xf8, 0x87, 0x82
	.byte 0xfd, 0x2b, 0xc1, 0x1a, 0x87, 0x67, 0x44, 0xb6, 0x0d, 0x14, 0xd6, 0x38, 0xa1, 0x86, 0xc7, 0xc2
	.byte 0xdf, 0xc6, 0x39, 0xb9, 0x02, 0x3b, 0x9c, 0x90, 0x20, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x17e2
	/* C5 */
	.octa 0x8000000020010005ff0000000044e920
	/* C7 */
	.octa 0x4410e002007fffffffffebee
	/* C21 */
	.octa 0xf7cdc00040120000007fffffffffe000
	/* C22 */
	.octa 0xffffffffffffda38
	/* C29 */
	.octa 0x1f00
final_cap_values:
	/* C0 */
	.octa 0x1743
	/* C2 */
	.octa 0xffffffff38760000
	/* C5 */
	.octa 0x8000000020010005ff0000000044e920
	/* C7 */
	.octa 0x4410e002007fffffffffebee
	/* C13 */
	.octa 0x0
	/* C21 */
	.octa 0xf7cdc00040120000007fffffffffe000
	/* C22 */
	.octa 0xffffffffffffda38
	/* C30 */
	.octa 0x0
initial_csp_value:
	.octa 0x3fff800000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200620060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000580207fc00ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c0b3ff // GCSEAL-R.C-C Rd:31 Cn:31 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xa2513fa2 // LDR-C.RIBW-C Ct:2 Rn:29 11:11 imm9:100010011 0:0 opc:01 10100010:10100010
	.inst 0x8a9f667e // and_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:19 imm6:011001 Rm:31 N:0 shift:10 01010:01010 opc:00 sf:1
	.inst 0x8287f8be // ALDRSH-R.RRB-64 Rt:30 Rn:5 opc:10 S:1 option:111 Rm:7 0:0 L:0 100000101:100000101
	.inst 0x1ac12bfd // asrv:aarch64/instrs/integer/shift/variable Rd:29 Rn:31 op2:10 0010:0010 Rm:1 0011010110:0011010110 sf:0
	.inst 0xb6446787 // tbz:aarch64/instrs/branch/conditional/test Rt:7 imm14:10001100111100 b40:01000 op:0 011011:011011 b5:1
	.inst 0x38d6140d // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:13 Rn:0 01:01 imm9:101100001 0:0 opc:11 111000:111000 size:00
	.inst 0xc2c786a1 // CHKSS-_.CC-C 00001:00001 Cn:21 001:001 opc:00 1:1 Cm:7 11000010110:11000010110
	.inst 0xb939c6df // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:22 imm12:111001110001 opc:00 111001:111001 size:10
	.inst 0x909c3b02 // ADRP-C.IP-C Rd:2 immhi:001110000111011000 P:1 10000:10000 immlo:00 op:1
	.inst 0xc2c21220
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x16, cptr_el3
	orr x16, x16, #0x200
	msr cptr_el3, x16
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400605 // ldr c5, [x16, #1]
	.inst 0xc2400a07 // ldr c7, [x16, #2]
	.inst 0xc2400e15 // ldr c21, [x16, #3]
	.inst 0xc2401216 // ldr c22, [x16, #4]
	.inst 0xc240161d // ldr c29, [x16, #5]
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =initial_csp_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2c1d21f // cpy c31, c16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30850032
	msr SCTLR_EL3, x16
	ldr x16, =0x8
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82603230 // ldr c16, [c17, #3]
	.inst 0xc28b4130 // msr ddc_el3, c16
	isb
	.inst 0x82601230 // ldr c16, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr ddc_el3, c16
	isb
	/* Check processor flags */
	mrs x16, nzcv
	ubfx x16, x16, #28, #4
	mov x17, #0xf
	and x16, x16, x17
	cmp x16, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400211 // ldr c17, [x16, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc2400611 // ldr c17, [x16, #1]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc2400a11 // ldr c17, [x16, #2]
	.inst 0xc2d1a4a1 // chkeq c5, c17
	b.ne comparison_fail
	.inst 0xc2400e11 // ldr c17, [x16, #3]
	.inst 0xc2d1a4e1 // chkeq c7, c17
	b.ne comparison_fail
	.inst 0xc2401211 // ldr c17, [x16, #4]
	.inst 0xc2d1a5a1 // chkeq c13, c17
	b.ne comparison_fail
	.inst 0xc2401611 // ldr c17, [x16, #5]
	.inst 0xc2d1a6a1 // chkeq c21, c17
	b.ne comparison_fail
	.inst 0xc2401a11 // ldr c17, [x16, #6]
	.inst 0xc2d1a6c1 // chkeq c22, c17
	b.ne comparison_fail
	.inst 0xc2401e11 // ldr c17, [x16, #7]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001030
	ldr x1, =check_data0
	ldr x2, =0x00001040
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000013fc
	ldr x1, =check_data1
	ldr x2, =0x00001400
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017e2
	ldr x1, =check_data2
	ldr x2, =0x000017e3
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
	ldr x0, =0x0044c0fc
	ldr x1, =check_data4
	ldr x2, =0x0044c0fe
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
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr ddc_el3, c16
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

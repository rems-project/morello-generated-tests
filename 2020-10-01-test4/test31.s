.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x3e, 0x64, 0xf4, 0x82, 0x61, 0x27, 0xc5, 0xc2, 0x01, 0x6b, 0xc7, 0xc2, 0x80, 0x85, 0xc2, 0xc2
	.byte 0xaa, 0x07, 0x17, 0x1b, 0x9f, 0x2e, 0xca, 0x9a, 0x19, 0xa3, 0xde, 0xc2, 0xe2, 0x07, 0x81, 0x9a
	.byte 0xe0, 0x73, 0xc2, 0xc2, 0x50, 0x04, 0xd9, 0xc2, 0x20, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x4a52068a0400000
	/* C2 */
	.octa 0x400002000000000000000000000000
	/* C5 */
	.octa 0x200000000000000000000000000
	/* C12 */
	.octa 0x20408002000100070000000000400011
	/* C20 */
	.octa 0xfb5adf975fc00000
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x380000000000000000000
final_cap_values:
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x200000000000000000000000000
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x20408002000100070000000000400011
	/* C16 */
	.octa 0x0
	/* C20 */
	.octa 0xfb5adf975fc00000
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C27 */
	.octa 0x380000000000000000000
	/* C29 */
	.octa 0x400000000000000000000000000000
	/* C30 */
	.octa 0xc2c5276182f4643e
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000003c07000700000000003fe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 48
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82f4643e // ALDR-R.RRB-64 Rt:30 Rn:1 opc:01 S:0 option:011 Rm:20 1:1 L:1 100000101:100000101
	.inst 0xc2c52761 // CPYTYPE-C.C-C Cd:1 Cn:27 001:001 opc:01 0:0 Cm:5 11000010110:11000010110
	.inst 0xc2c76b01 // ORRFLGS-C.CR-C Cd:1 Cn:24 1010:1010 opc:01 Rm:7 11000010110:11000010110
	.inst 0xc2c28580 // BRS-C.C-C 00000:00000 Cn:12 001:001 opc:00 1:1 Cm:2 11000010110:11000010110
	.inst 0x1b1707aa // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:10 Rn:29 Ra:1 o0:0 Rm:23 0011011000:0011011000 sf:0
	.inst 0x9aca2e9f // rorv:aarch64/instrs/integer/shift/variable Rd:31 Rn:20 op2:11 0010:0010 Rm:10 0011010110:0011010110 sf:1
	.inst 0xc2dea319 // CLRPERM-C.CR-C Cd:25 Cn:24 000:000 1:1 10:10 Rm:30 11000010110:11000010110
	.inst 0x9a8107e2 // csinc:aarch64/instrs/integer/conditional/select Rd:2 Rn:31 o2:1 0:0 cond:0000 Rm:1 011010100:011010100 op:0 sf:1
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xc2d90450 // BUILD-C.C-C Cd:16 Cn:2 001:001 opc:00 0:0 Cm:25 11000010110:11000010110
	.inst 0xc2c21120
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
	.inst 0xc2400241 // ldr c1, [x18, #0]
	.inst 0xc2400642 // ldr c2, [x18, #1]
	.inst 0xc2400a45 // ldr c5, [x18, #2]
	.inst 0xc2400e4c // ldr c12, [x18, #3]
	.inst 0xc2401254 // ldr c20, [x18, #4]
	.inst 0xc2401657 // ldr c23, [x18, #5]
	.inst 0xc2401a58 // ldr c24, [x18, #6]
	.inst 0xc2401e5b // ldr c27, [x18, #7]
	/* Set up flags and system registers */
	mov x18, #0x40000000
	msr nzcv, x18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	ldr x18, =0x4
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603132 // ldr c18, [c9, #3]
	.inst 0xc28b4132 // msr ddc_el3, c18
	isb
	.inst 0x82601132 // ldr c18, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr ddc_el3, c18
	isb
	/* Check processor flags */
	mrs x18, nzcv
	ubfx x18, x18, #28, #4
	mov x9, #0x4
	and x18, x18, x9
	cmp x18, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc2400249 // ldr c9, [x18, #0]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400649 // ldr c9, [x18, #1]
	.inst 0xc2c9a4a1 // chkeq c5, c9
	b.ne comparison_fail
	.inst 0xc2400a49 // ldr c9, [x18, #2]
	.inst 0xc2c9a541 // chkeq c10, c9
	b.ne comparison_fail
	.inst 0xc2400e49 // ldr c9, [x18, #3]
	.inst 0xc2c9a581 // chkeq c12, c9
	b.ne comparison_fail
	.inst 0xc2401249 // ldr c9, [x18, #4]
	.inst 0xc2c9a601 // chkeq c16, c9
	b.ne comparison_fail
	.inst 0xc2401649 // ldr c9, [x18, #5]
	.inst 0xc2c9a681 // chkeq c20, c9
	b.ne comparison_fail
	.inst 0xc2401a49 // ldr c9, [x18, #6]
	.inst 0xc2c9a6e1 // chkeq c23, c9
	b.ne comparison_fail
	.inst 0xc2401e49 // ldr c9, [x18, #7]
	.inst 0xc2c9a701 // chkeq c24, c9
	b.ne comparison_fail
	.inst 0xc2402249 // ldr c9, [x18, #8]
	.inst 0xc2c9a721 // chkeq c25, c9
	b.ne comparison_fail
	.inst 0xc2402649 // ldr c9, [x18, #9]
	.inst 0xc2c9a761 // chkeq c27, c9
	b.ne comparison_fail
	.inst 0xc2402a49 // ldr c9, [x18, #10]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	.inst 0xc2402e49 // ldr c9, [x18, #11]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00400000
	ldr x1, =check_data0
	ldr x2, =0x0040002c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
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

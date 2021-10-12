.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfe, 0x1f, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xfe, 0x1f
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xc1, 0x87, 0xdd, 0x78, 0xc7, 0x71, 0xc3, 0xc2, 0xde, 0x13, 0xc7, 0xc2, 0x40, 0x1d, 0x25, 0x37
	.byte 0x5f, 0xc9, 0x08, 0x31, 0xf9, 0xd3, 0xc2, 0x82, 0xe0, 0xfb, 0x21, 0x38, 0x76, 0x7f, 0xdf, 0x9b
	.byte 0x01, 0xd0, 0xc0, 0xc2, 0xe5, 0xe3, 0xcc, 0xc2, 0x40, 0x13, 0xc2, 0xc2
.data
check_data3:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x4ffffe
	/* C14 */
	.octa 0x800000000000000000000000
	/* C30 */
	.octa 0x8000000060000084000000000000100c
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x4ffffe
	/* C7 */
	.octa 0x1800000000000000000000000
	/* C14 */
	.octa 0x800000000000000000000000
	/* C22 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0xfe4
initial_SP_EL3_value:
	.octa 0x40000000000100050000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000000c0000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 64
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x78dd87c1 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:30 01:01 imm9:111011000 0:0 opc:11 111000:111000 size:01
	.inst 0xc2c371c7 // SEAL-C.CI-C Cd:7 Cn:14 100:100 form:11 11000010110000110:11000010110000110
	.inst 0xc2c713de // RRLEN-R.R-C Rd:30 Rn:30 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x37251d40 // tbnz:aarch64/instrs/branch/conditional/test Rt:0 imm14:10100011101010 b40:00100 op:1 011011:011011 b5:0
	.inst 0x3108c95f // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:10 imm12:001000110010 sh:0 0:0 10001:10001 S:1 op:0 sf:0
	.inst 0x82c2d3f9 // ALDRB-R.RRB-B Rt:25 Rn:31 opc:00 S:1 option:110 Rm:2 0:0 L:1 100000101:100000101
	.inst 0x3821fbe0 // strb_reg:aarch64/instrs/memory/single/general/register Rt:0 Rn:31 10:10 S:1 option:111 Rm:1 1:1 opc:00 111000:111000 size:00
	.inst 0x9bdf7f76 // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:22 Rn:27 Ra:11111 0:0 Rm:31 10:10 U:1 10011011:10011011
	.inst 0xc2c0d001 // GCPERM-R.C-C Rd:1 Cn:0 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0xc2cce3e5 // SCFLGS-C.CR-C Cd:5 Cn:31 111000:111000 Rm:12 11000010110:11000010110
	.inst 0xc2c21340
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x20, cptr_el3
	orr x20, x20, #0x200
	msr cptr_el3, x20
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
	ldr x20, =initial_cap_values
	.inst 0xc2400280 // ldr c0, [x20, #0]
	.inst 0xc2400682 // ldr c2, [x20, #1]
	.inst 0xc2400a8e // ldr c14, [x20, #2]
	.inst 0xc2400e9e // ldr c30, [x20, #3]
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =initial_SP_EL3_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2c1d29f // cpy c31, c20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x3085003a
	msr SCTLR_EL3, x20
	ldr x20, =0x4
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82603354 // ldr c20, [c26, #3]
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	.inst 0x82601354 // ldr c20, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc240029a // ldr c26, [x20, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240069a // ldr c26, [x20, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc2400a9a // ldr c26, [x20, #2]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400e9a // ldr c26, [x20, #3]
	.inst 0xc2daa4e1 // chkeq c7, c26
	b.ne comparison_fail
	.inst 0xc240129a // ldr c26, [x20, #4]
	.inst 0xc2daa5c1 // chkeq c14, c26
	b.ne comparison_fail
	.inst 0xc240169a // ldr c26, [x20, #5]
	.inst 0xc2daa6c1 // chkeq c22, c26
	b.ne comparison_fail
	.inst 0xc2401a9a // ldr c26, [x20, #6]
	.inst 0xc2daa721 // chkeq c25, c26
	b.ne comparison_fail
	.inst 0xc2401e9a // ldr c26, [x20, #7]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000100c
	ldr x1, =check_data0
	ldr x2, =0x0000100e
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
	ldr x0, =0x004ffffe
	ldr x1, =check_data3
	ldr x2, =0x004fffff
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
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
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

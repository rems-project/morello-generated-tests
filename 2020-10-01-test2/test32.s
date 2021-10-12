.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x20, 0x0c, 0x00, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x07, 0x00, 0xc2, 0xc2, 0x82, 0xd6, 0xd3, 0xb4, 0x48, 0x7c, 0x50, 0x9b, 0x2e, 0x29, 0xdf, 0xc2
	.byte 0x47, 0x14, 0xd2, 0xca, 0x83, 0x71, 0x78, 0x82, 0x81, 0x82, 0x30, 0x31, 0x91, 0xc3, 0x49, 0xb8
	.byte 0xf2, 0x9b, 0xc0, 0xc2, 0x41, 0xa8, 0x0a, 0xb8, 0x40, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000000000000000000000
	/* C2 */
	.octa 0x138e
	/* C9 */
	.octa 0x3fff800000000000000000000000
	/* C12 */
	.octa 0x80100000000100050000000000000000
	/* C20 */
	.octa 0x0
	/* C28 */
	.octa 0x1f5c
final_cap_values:
	/* C0 */
	.octa 0x400000000000000000000000
	/* C1 */
	.octa 0xc20
	/* C2 */
	.octa 0x138e
	/* C3 */
	.octa 0x0
	/* C9 */
	.octa 0x3fff800000000000000000000000
	/* C12 */
	.octa 0x80100000000100050000000000000000
	/* C14 */
	.octa 0x3fff800000000000000000000000
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x180060080000000000002
	/* C20 */
	.octa 0x0
	/* C28 */
	.octa 0x1f5c
initial_csp_value:
	.octa 0x180060080000000000003
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080005000d0040000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000080080000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001870
	.dword initial_cap_values + 48
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c20007 // SCBNDS-C.CR-C Cd:7 Cn:0 000:000 opc:00 0:0 Rm:2 11000010110:11000010110
	.inst 0xb4d3d682 // cbz:aarch64/instrs/branch/conditional/compare Rt:2 imm19:1101001111010110100 op:0 011010:011010 sf:1
	.inst 0x9b507c48 // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:8 Rn:2 Ra:11111 0:0 Rm:16 10:10 U:0 10011011:10011011
	.inst 0xc2df292e // BICFLGS-C.CR-C Cd:14 Cn:9 1010:1010 opc:00 Rm:31 11000010110:11000010110
	.inst 0xcad21447 // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:7 Rn:2 imm6:000101 Rm:18 N:0 shift:11 01010:01010 opc:10 sf:1
	.inst 0x82787183 // ALDR-C.RI-C Ct:3 Rn:12 op:00 imm9:110000111 L:1 1000001001:1000001001
	.inst 0x31308281 // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:1 Rn:20 imm12:110000100000 sh:0 0:0 10001:10001 S:1 op:0 sf:0
	.inst 0xb849c391 // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:17 Rn:28 00:00 imm9:010011100 0:0 opc:01 111000:111000 size:10
	.inst 0xc2c09bf2 // ALIGND-C.CI-C Cd:18 Cn:31 0110:0110 U:0 imm6:000001 11000010110:11000010110
	.inst 0xb80aa841 // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:2 10:10 imm9:010101010 0:0 opc:00 111000:111000 size:10
	.inst 0xc2c21340
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x19, cptr_el3
	orr x19, x19, #0x200
	msr cptr_el3, x19
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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400662 // ldr c2, [x19, #1]
	.inst 0xc2400a69 // ldr c9, [x19, #2]
	.inst 0xc2400e6c // ldr c12, [x19, #3]
	.inst 0xc2401274 // ldr c20, [x19, #4]
	.inst 0xc240167c // ldr c28, [x19, #5]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =initial_csp_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2c1d27f // cpy c31, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	ldr x19, =0x0
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82603353 // ldr c19, [c26, #3]
	.inst 0xc28b4133 // msr ddc_el3, c19
	isb
	.inst 0x82601353 // ldr c19, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr ddc_el3, c19
	isb
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x26, #0xf
	and x19, x19, x26
	cmp x19, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc240027a // ldr c26, [x19, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240067a // ldr c26, [x19, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc2400a7a // ldr c26, [x19, #2]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400e7a // ldr c26, [x19, #3]
	.inst 0xc2daa461 // chkeq c3, c26
	b.ne comparison_fail
	.inst 0xc240127a // ldr c26, [x19, #4]
	.inst 0xc2daa521 // chkeq c9, c26
	b.ne comparison_fail
	.inst 0xc240167a // ldr c26, [x19, #5]
	.inst 0xc2daa581 // chkeq c12, c26
	b.ne comparison_fail
	.inst 0xc2401a7a // ldr c26, [x19, #6]
	.inst 0xc2daa5c1 // chkeq c14, c26
	b.ne comparison_fail
	.inst 0xc2401e7a // ldr c26, [x19, #7]
	.inst 0xc2daa621 // chkeq c17, c26
	b.ne comparison_fail
	.inst 0xc240227a // ldr c26, [x19, #8]
	.inst 0xc2daa641 // chkeq c18, c26
	b.ne comparison_fail
	.inst 0xc240267a // ldr c26, [x19, #9]
	.inst 0xc2daa681 // chkeq c20, c26
	b.ne comparison_fail
	.inst 0xc2402a7a // ldr c26, [x19, #10]
	.inst 0xc2daa781 // chkeq c28, c26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001438
	ldr x1, =check_data0
	ldr x2, =0x0000143c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001870
	ldr x1, =check_data1
	ldr x2, =0x00001880
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff8
	ldr x1, =check_data2
	ldr x2, =0x00001ffc
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr ddc_el3, c19
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

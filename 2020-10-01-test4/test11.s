.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0xfc
.data
check_data2:
	.byte 0xda, 0x7f, 0x9f, 0x08, 0x43, 0x98, 0x20, 0xea, 0x41, 0xe7, 0x52, 0x7c, 0xe8, 0x70, 0x21, 0xcb
	.byte 0xe1, 0x7f, 0x9f, 0x08, 0x00, 0x13, 0xc0, 0xc2, 0x4a, 0xe8, 0x81, 0x82, 0x12, 0x7c, 0xde, 0x82
	.byte 0x7e, 0xe8, 0xd8, 0xc2, 0xe0, 0x7c, 0xab, 0x12, 0xa0, 0x12, 0xc2, 0xc2
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x4ffbfc
	/* C2 */
	.octa 0x0
	/* C24 */
	.octa 0x4001cefc000000000040a000
	/* C26 */
	.octa 0x800000002206200f0000000000400000
	/* C30 */
	.octa 0x40000000400000400000000000001080
final_cap_values:
	/* C0 */
	.octa 0xa418ffff
	/* C1 */
	.octa 0x4ffbfc
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C24 */
	.octa 0x4001cefc000000000040a000
	/* C26 */
	.octa 0x800000002206200f00000000003fff2e
	/* C30 */
	.octa 0x40a0000000000000000000
initial_csp_value:
	.octa 0x40000000000100050000000000001090
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000c0000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 112
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x089f7fda // stllrb:aarch64/instrs/memory/ordered Rt:26 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xea209843 // bics:aarch64/instrs/integer/logical/shiftedreg Rd:3 Rn:2 imm6:100110 Rm:0 N:1 shift:00 01010:01010 opc:11 sf:1
	.inst 0x7c52e741 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:1 Rn:26 01:01 imm9:100101110 0:0 opc:01 111100:111100 size:01
	.inst 0xcb2170e8 // sub_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:8 Rn:7 imm3:100 option:011 Rm:1 01011001:01011001 S:0 op:1 sf:1
	.inst 0x089f7fe1 // stllrb:aarch64/instrs/memory/ordered Rt:1 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2c01300 // GCBASE-R.C-C Rd:0 Cn:24 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0x8281e84a // ALDRSH-R.RRB-64 Rt:10 Rn:2 opc:10 S:0 option:111 Rm:1 0:0 L:0 100000101:100000101
	.inst 0x82de7c12 // ALDRH-R.RRB-32 Rt:18 Rn:0 opc:11 S:1 option:011 Rm:30 0:0 L:1 100000101:100000101
	.inst 0xc2d8e87e // CTHI-C.CR-C Cd:30 Cn:3 1010:1010 opc:11 Rm:24 11000010110:11000010110
	.inst 0x12ab7ce0 // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:0 imm16:0101101111100111 hw:01 100101:100101 opc:00 sf:0
	.inst 0xc2c212a0
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
	.inst 0xc2400601 // ldr c1, [x16, #1]
	.inst 0xc2400a02 // ldr c2, [x16, #2]
	.inst 0xc2400e18 // ldr c24, [x16, #3]
	.inst 0xc240121a // ldr c26, [x16, #4]
	.inst 0xc240161e // ldr c30, [x16, #5]
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =initial_csp_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2c1d21f // cpy c31, c16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x3085003a
	msr SCTLR_EL3, x16
	ldr x16, =0x0
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032b0 // ldr c16, [c21, #3]
	.inst 0xc28b4130 // msr ddc_el3, c16
	isb
	.inst 0x826012b0 // ldr c16, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
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
	mov x21, #0xf
	and x16, x16, x21
	cmp x16, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400215 // ldr c21, [x16, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400615 // ldr c21, [x16, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400a15 // ldr c21, [x16, #2]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400e15 // ldr c21, [x16, #3]
	.inst 0xc2d5a461 // chkeq c3, c21
	b.ne comparison_fail
	.inst 0xc2401215 // ldr c21, [x16, #4]
	.inst 0xc2d5a541 // chkeq c10, c21
	b.ne comparison_fail
	.inst 0xc2401615 // ldr c21, [x16, #5]
	.inst 0xc2d5a641 // chkeq c18, c21
	b.ne comparison_fail
	.inst 0xc2401a15 // ldr c21, [x16, #6]
	.inst 0xc2d5a701 // chkeq c24, c21
	b.ne comparison_fail
	.inst 0xc2401e15 // ldr c21, [x16, #7]
	.inst 0xc2d5a741 // chkeq c26, c21
	b.ne comparison_fail
	.inst 0xc2402215 // ldr c21, [x16, #8]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x7fda
	mov x21, v1.d[0]
	cmp x16, x21
	b.ne comparison_fail
	ldr x16, =0x0
	mov x21, v1.d[1]
	cmp x16, x21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001080
	ldr x1, =check_data0
	ldr x2, =0x00001081
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001090
	ldr x1, =check_data1
	ldr x2, =0x00001091
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
	ldr x0, =0x0040effc
	ldr x1, =check_data3
	ldr x2, =0x0040effe
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004ffbfc
	ldr x1, =check_data4
	ldr x2, =0x004ffbfe
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

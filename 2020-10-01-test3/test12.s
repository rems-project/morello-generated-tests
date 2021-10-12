.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0xe0, 0xfb, 0x22, 0xc2, 0x5f, 0x34, 0x03, 0xd5, 0x5d, 0xd7, 0xe5, 0x82, 0xdf, 0x07, 0xc0, 0x5a
	.byte 0x40, 0xe4, 0xe1, 0x82, 0x36, 0xf4, 0x18, 0x2c, 0x20, 0xa8, 0x64, 0x02, 0xa2, 0xc7, 0x94, 0x9a
	.byte 0xff, 0xf3, 0xc0, 0xc2, 0x9e, 0xf6, 0x95, 0xb8, 0x00, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4000000000000000000000000000
	/* C1 */
	.octa 0x400000120050000000000001a04
	/* C2 */
	.octa 0x8000000054000002fffffffffffff97c
	/* C5 */
	.octa 0x600
	/* C20 */
	.octa 0x1000
	/* C26 */
	.octa 0x8000000051040001ffffffffffffe000
final_cap_values:
	/* C0 */
	.octa 0x40000012005000000000092ba04
	/* C1 */
	.octa 0x400000120050000000000001a04
	/* C2 */
	.octa 0x1001
	/* C5 */
	.octa 0x600
	/* C20 */
	.octa 0xf5f
	/* C26 */
	.octa 0x8000000051040001ffffffffffffe000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_csp_value:
	.octa 0xffffffffffff8c00
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200620070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc80000000003000700ffe00000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc222fbe0 // STR-C.RIB-C Ct:0 Rn:31 imm12:100010111110 L:0 110000100:110000100
	.inst 0xd503345f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:0100 11010101000000110011:11010101000000110011
	.inst 0x82e5d75d // ALDR-R.RRB-64 Rt:29 Rn:26 opc:01 S:1 option:110 Rm:5 1:1 L:1 100000101:100000101
	.inst 0x5ac007df // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:31 Rn:30 opc:01 1011010110000000000:1011010110000000000 sf:0
	.inst 0x82e1e440 // ALDR-R.RRB-64 Rt:0 Rn:2 opc:01 S:0 option:111 Rm:1 1:1 L:1 100000101:100000101
	.inst 0x2c18f436 // stnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:22 Rn:1 Rt2:11101 imm7:0110001 L:0 1011000:1011000 opc:00
	.inst 0x0264a820 // ADD-C.CIS-C Cd:0 Cn:1 imm12:100100101010 sh:1 A:0 00000010:00000010
	.inst 0x9a94c7a2 // csinc:aarch64/instrs/integer/conditional/select Rd:2 Rn:29 o2:1 0:0 cond:1100 Rm:20 011010100:011010100 op:0 sf:1
	.inst 0xc2c0f3ff // GCTYPE-R.C-C Rd:31 Cn:31 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xb895f69e // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:20 01:01 imm9:101011111 0:0 opc:10 111000:111000 size:10
	.inst 0xc2c21300
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x14, cptr_el3
	orr x14, x14, #0x200
	msr cptr_el3, x14
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c1 // ldr c1, [x14, #1]
	.inst 0xc24009c2 // ldr c2, [x14, #2]
	.inst 0xc2400dc5 // ldr c5, [x14, #3]
	.inst 0xc24011d4 // ldr c20, [x14, #4]
	.inst 0xc24015da // ldr c26, [x14, #5]
	/* Vector registers */
	mrs x14, cptr_el3
	bfc x14, #10, #1
	msr cptr_el3, x14
	isb
	ldr q22, =0x0
	ldr q29, =0x0
	/* Set up flags and system registers */
	mov x14, #0x80000000
	msr nzcv, x14
	ldr x14, =initial_csp_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2c1d1df // cpy c31, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30850038
	msr SCTLR_EL3, x14
	ldr x14, =0x0
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x8260330e // ldr c14, [c24, #3]
	.inst 0xc28b412e // msr ddc_el3, c14
	isb
	.inst 0x8260130e // ldr c14, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr ddc_el3, c14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x24, #0x9
	and x14, x14, x24
	cmp x14, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001d8 // ldr c24, [x14, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc24005d8 // ldr c24, [x14, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc24009d8 // ldr c24, [x14, #2]
	.inst 0xc2d8a441 // chkeq c2, c24
	b.ne comparison_fail
	.inst 0xc2400dd8 // ldr c24, [x14, #3]
	.inst 0xc2d8a4a1 // chkeq c5, c24
	b.ne comparison_fail
	.inst 0xc24011d8 // ldr c24, [x14, #4]
	.inst 0xc2d8a681 // chkeq c20, c24
	b.ne comparison_fail
	.inst 0xc24015d8 // ldr c24, [x14, #5]
	.inst 0xc2d8a741 // chkeq c26, c24
	b.ne comparison_fail
	.inst 0xc24019d8 // ldr c24, [x14, #6]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	.inst 0xc2401dd8 // ldr c24, [x14, #7]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0x0
	mov x24, v22.d[0]
	cmp x14, x24
	b.ne comparison_fail
	ldr x14, =0x0
	mov x24, v22.d[1]
	cmp x14, x24
	b.ne comparison_fail
	ldr x14, =0x0
	mov x24, v29.d[0]
	cmp x14, x24
	b.ne comparison_fail
	ldr x14, =0x0
	mov x24, v29.d[1]
	cmp x14, x24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001380
	ldr x1, =check_data1
	ldr x2, =0x00001388
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017e0
	ldr x1, =check_data2
	ldr x2, =0x000017f0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ac8
	ldr x1, =check_data3
	ldr x2, =0x00001ad0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr ddc_el3, c14
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

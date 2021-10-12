.section data0, #alloc, #write
	.zero 224
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3856
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x7f, 0xd9, 0xb3, 0x78, 0x7c, 0xa7, 0xf8, 0x62, 0x82, 0x03, 0xc0, 0x5a, 0xa1, 0x13, 0xc2, 0xc2
	.byte 0x42, 0xf4, 0x59, 0xfc, 0x81, 0xfd, 0x5f, 0x48, 0xe0, 0x4b, 0x5d, 0x28, 0xd6, 0x77, 0x4b, 0x69
	.byte 0x5f, 0x88, 0xaa, 0x02, 0x1f, 0x30, 0x21, 0x38, 0xe0, 0x10, 0xc2, 0xc2
.data
check_data6:
	.zero 2
.data
check_data7:
	.byte 0x00, 0x00, 0x78, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C11 */
	.octa 0x400bfc
	/* C12 */
	.octa 0x1efc
	/* C19 */
	.octa 0x0
	/* C27 */
	.octa 0x4f1030
	/* C29 */
	.octa 0x3fff800000000000000000000000
	/* C30 */
	.octa 0x1e84
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1e8f
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x400bfc
	/* C12 */
	.octa 0x1efc
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C27 */
	.octa 0x4f0f40
	/* C28 */
	.octa 0xf780000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1e84
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000600170000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd01000000006000f0000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x78b3d97f // ldrsh_reg:aarch64/instrs/memory/single/general/register Rt:31 Rn:11 10:10 S:1 option:110 Rm:19 1:1 opc:10 111000:111000 size:01
	.inst 0x62f8a77c // LDP-C.RIBW-C Ct:28 Rn:27 Ct2:01001 imm7:1110001 L:1 011000101:011000101
	.inst 0x5ac00382 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:2 Rn:28 101101011000000000000:101101011000000000000 sf:0
	.inst 0xc2c213a1 // CHKSLD-C-C 00001:00001 Cn:29 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xfc59f442 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:2 Rn:2 01:01 imm9:110011111 0:0 opc:01 111100:111100 size:11
	.inst 0x485ffd81 // ldaxrh:aarch64/instrs/memory/exclusive/single Rt:1 Rn:12 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0x285d4be0 // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:0 Rn:31 Rt2:10010 imm7:0111010 L:1 1010000:1010000 opc:00
	.inst 0x694b77d6 // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:22 Rn:30 Rt2:11101 imm7:0010110 L:1 1010010:1010010 opc:01
	.inst 0x02aa885f // SUB-C.CIS-C Cd:31 Cn:2 imm12:101010100010 sh:0 A:1 00000010:00000010
	.inst 0x3821301f // stsetb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:011 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2c210e0
	.zero 986900
	.inst 0x0f780000
	.zero 61628
.text
.global preamble
preamble:
	/* Ensure Morello is on */
	mov x0, 0x200
	msr cptr_el3, x0
	isb
	/* Set exception handler */
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	mov x0, #0xff
	msr mair_el3, x0
	ldr x0, =0x0d001519
	msr tcr_el3, x0
	isb
	tlbi alle3
	dsb sy
	isb
	/* Write tags to memory */
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
	ldr x25, =initial_cap_values
	.inst 0xc240032b // ldr c11, [x25, #0]
	.inst 0xc240072c // ldr c12, [x25, #1]
	.inst 0xc2400b33 // ldr c19, [x25, #2]
	.inst 0xc2400f3b // ldr c27, [x25, #3]
	.inst 0xc240133d // ldr c29, [x25, #4]
	.inst 0xc240173e // ldr c30, [x25, #5]
	/* Set up flags and system registers */
	mov x25, #0x00000000
	msr nzcv, x25
	ldr x25, =initial_SP_EL3_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2c1d33f // cpy c31, c25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30851037
	msr SCTLR_EL3, x25
	ldr x25, =0x0
	msr S3_6_C1_C2_2, x25 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030f9 // ldr c25, [c7, #3]
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	.inst 0x826010f9 // ldr c25, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c21320 // br c25
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30851035
	msr SCTLR_EL3, x25
	isb
	/* Check processor flags */
	mrs x25, nzcv
	ubfx x25, x25, #28, #4
	mov x7, #0xf
	and x25, x25, x7
	cmp x25, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400327 // ldr c7, [x25, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400727 // ldr c7, [x25, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400b27 // ldr c7, [x25, #2]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400f27 // ldr c7, [x25, #3]
	.inst 0xc2c7a521 // chkeq c9, c7
	b.ne comparison_fail
	.inst 0xc2401327 // ldr c7, [x25, #4]
	.inst 0xc2c7a561 // chkeq c11, c7
	b.ne comparison_fail
	.inst 0xc2401727 // ldr c7, [x25, #5]
	.inst 0xc2c7a581 // chkeq c12, c7
	b.ne comparison_fail
	.inst 0xc2401b27 // ldr c7, [x25, #6]
	.inst 0xc2c7a641 // chkeq c18, c7
	b.ne comparison_fail
	.inst 0xc2401f27 // ldr c7, [x25, #7]
	.inst 0xc2c7a661 // chkeq c19, c7
	b.ne comparison_fail
	.inst 0xc2402327 // ldr c7, [x25, #8]
	.inst 0xc2c7a6c1 // chkeq c22, c7
	b.ne comparison_fail
	.inst 0xc2402727 // ldr c7, [x25, #9]
	.inst 0xc2c7a761 // chkeq c27, c7
	b.ne comparison_fail
	.inst 0xc2402b27 // ldr c7, [x25, #10]
	.inst 0xc2c7a781 // chkeq c28, c7
	b.ne comparison_fail
	.inst 0xc2402f27 // ldr c7, [x25, #11]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2403327 // ldr c7, [x25, #12]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check vector registers */
	ldr x25, =0x0
	mov x7, v2.d[0]
	cmp x25, x7
	b.ne comparison_fail
	ldr x25, =0x0
	mov x7, v2.d[1]
	cmp x25, x7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010e8
	ldr x1, =check_data1
	ldr x2, =0x000010f0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001edc
	ldr x1, =check_data2
	ldr x2, =0x00001ee4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ef0
	ldr x1, =check_data3
	ldr x2, =0x00001ef8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001efc
	ldr x1, =check_data4
	ldr x2, =0x00001efe
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400bfc
	ldr x1, =check_data6
	ldr x2, =0x00400bfe
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004f0f40
	ldr x1, =check_data7
	ldr x2, =0x004f0f60
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
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

.section vector_table, #alloc, #execinstr
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

	/* Translation table, single entry, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000701
	.fill 4088, 1, 0

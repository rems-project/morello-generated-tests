.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x04
.data
check_data3:
	.byte 0x1d, 0x8e, 0x4f, 0x93, 0x33, 0xbf, 0x0c, 0xbc, 0xe2, 0xaa, 0x0d, 0x38, 0xf4, 0x1b, 0xd4, 0x38
	.byte 0x0d, 0x78, 0x83, 0xe2, 0x81, 0x31, 0xc2, 0xc2, 0x9e, 0x64, 0xdf, 0xc2, 0x42, 0x34, 0xe2, 0x2c
	.byte 0x60, 0xd3, 0xc5, 0xc2, 0xfe, 0x0b, 0xc0, 0xc2, 0xc0, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 8
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000e00030000000000001009
	/* C2 */
	.octa 0x404004
	/* C4 */
	.octa 0x800720070080000080000001
	/* C12 */
	.octa 0x0
	/* C23 */
	.octa 0x1f24
	/* C25 */
	.octa 0x1005
	/* C27 */
	.octa 0x40000000000000
final_cap_values:
	/* C0 */
	.octa 0xc0000000000080080040000000000000
	/* C2 */
	.octa 0x403f14
	/* C4 */
	.octa 0x800720070080000080000001
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C23 */
	.octa 0x1f24
	/* C25 */
	.octa 0x10d0
	/* C27 */
	.octa 0x40000000000000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x410020
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000080080000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x934f8e1d // sbfm:aarch64/instrs/integer/bitfield Rd:29 Rn:16 imms:100011 immr:001111 N:1 100110:100110 opc:00 sf:1
	.inst 0xbc0cbf33 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:19 Rn:25 11:11 imm9:011001011 0:0 opc:00 111100:111100 size:10
	.inst 0x380daae2 // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:23 10:10 imm9:011011010 0:0 opc:00 111000:111000 size:00
	.inst 0x38d41bf4 // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:20 Rn:31 10:10 imm9:101000001 0:0 opc:11 111000:111000 size:00
	.inst 0xe283780d // ALDURSW-R.RI-64 Rt:13 Rn:0 op2:10 imm9:000110111 V:0 op1:10 11100010:11100010
	.inst 0xc2c23181 // CHKTGD-C-C 00001:00001 Cn:12 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xc2df649e // CPYVALUE-C.C-C Cd:30 Cn:4 001:001 opc:11 0:0 Cm:31 11000010110:11000010110
	.inst 0x2ce23442 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:2 Rn:2 Rt2:01101 imm7:1000100 L:1 1011001:1011001 opc:00
	.inst 0xc2c5d360 // CVTDZ-C.R-C Cd:0 Rn:27 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0xc2c00bfe // SEAL-C.CC-C Cd:30 Cn:31 0010:0010 opc:00 Cm:0 11000010110:11000010110
	.inst 0xc2c212c0
	.zero 1048532
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
	ldr x10, =initial_cap_values
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400542 // ldr c2, [x10, #1]
	.inst 0xc2400944 // ldr c4, [x10, #2]
	.inst 0xc2400d4c // ldr c12, [x10, #3]
	.inst 0xc2401157 // ldr c23, [x10, #4]
	.inst 0xc2401559 // ldr c25, [x10, #5]
	.inst 0xc240195b // ldr c27, [x10, #6]
	/* Vector registers */
	mrs x10, cptr_el3
	bfc x10, #10, #1
	msr cptr_el3, x10
	isb
	ldr q19, =0x0
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =initial_SP_EL3_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2c1d15f // cpy c31, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x3085103f
	msr SCTLR_EL3, x10
	ldr x10, =0x4
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032ca // ldr c10, [c22, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x826012ca // ldr c10, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x22, #0xf
	and x10, x10, x22
	cmp x10, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400156 // ldr c22, [x10, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400556 // ldr c22, [x10, #1]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400956 // ldr c22, [x10, #2]
	.inst 0xc2d6a481 // chkeq c4, c22
	b.ne comparison_fail
	.inst 0xc2400d56 // ldr c22, [x10, #3]
	.inst 0xc2d6a581 // chkeq c12, c22
	b.ne comparison_fail
	.inst 0xc2401156 // ldr c22, [x10, #4]
	.inst 0xc2d6a5a1 // chkeq c13, c22
	b.ne comparison_fail
	.inst 0xc2401556 // ldr c22, [x10, #5]
	.inst 0xc2d6a681 // chkeq c20, c22
	b.ne comparison_fail
	.inst 0xc2401956 // ldr c22, [x10, #6]
	.inst 0xc2d6a6e1 // chkeq c23, c22
	b.ne comparison_fail
	.inst 0xc2401d56 // ldr c22, [x10, #7]
	.inst 0xc2d6a721 // chkeq c25, c22
	b.ne comparison_fail
	.inst 0xc2402156 // ldr c22, [x10, #8]
	.inst 0xc2d6a761 // chkeq c27, c22
	b.ne comparison_fail
	.inst 0xc2402556 // ldr c22, [x10, #9]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x10, =0x0
	mov x22, v2.d[0]
	cmp x10, x22
	b.ne comparison_fail
	ldr x10, =0x0
	mov x22, v2.d[1]
	cmp x10, x22
	b.ne comparison_fail
	ldr x10, =0x0
	mov x22, v13.d[0]
	cmp x10, x22
	b.ne comparison_fail
	ldr x10, =0x0
	mov x22, v13.d[1]
	cmp x10, x22
	b.ne comparison_fail
	ldr x10, =0x0
	mov x22, v19.d[0]
	cmp x10, x22
	b.ne comparison_fail
	ldr x10, =0x0
	mov x22, v19.d[1]
	cmp x10, x22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001040
	ldr x1, =check_data0
	ldr x2, =0x00001044
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010d0
	ldr x1, =check_data1
	ldr x2, =0x000010d4
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
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
	ldr x0, =0x00404004
	ldr x1, =check_data4
	ldr x2, =0x0040400c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0040ff61
	ldr x1, =check_data5
	ldr x2, =0x0040ff62
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
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

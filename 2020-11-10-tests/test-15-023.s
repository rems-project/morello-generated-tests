.section data0, #alloc, #write
	.zero 1024
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3056
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 16
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0x5e, 0xb0, 0x7f, 0xc8, 0x51, 0x49, 0x64, 0x69, 0x85, 0x61, 0x36, 0x78, 0x00, 0x30, 0x96, 0xb5
	.byte 0xf3, 0x42, 0xec, 0x2d, 0xe2, 0xbb, 0x2d, 0xe2, 0x47, 0xfd, 0x5f, 0x48, 0x06, 0x62, 0xde, 0xc2
	.byte 0x02, 0x52, 0x3e, 0xb8, 0x29, 0x50, 0x1f, 0x78, 0xc0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x2003
	/* C2 */
	.octa 0x1400
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x111c
	/* C16 */
	.octa 0x400100000000000000001400
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x10cc
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x2003
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x400100000080000000001000
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x111c
	/* C12 */
	.octa 0x1000
	/* C16 */
	.octa 0x400100000000000000001400
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x102c
	/* C30 */
	.octa 0x80000000001000
initial_SP_EL3_value:
	.octa 0x40000000600000020000000000001325
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000004640070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000704070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc87fb05e // ldaxp:aarch64/instrs/memory/exclusive/pair Rt:30 Rn:2 Rt2:01100 o0:1 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.inst 0x69644951 // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:17 Rn:10 Rt2:10010 imm7:1001000 L:1 1010010:1010010 opc:01
	.inst 0x78366185 // ldumaxh:aarch64/instrs/memory/atomicops/ld Rt:5 Rn:12 00:00 opc:110 0:0 Rs:22 1:1 R:0 A:0 111000:111000 size:01
	.inst 0xb5963000 // cbnz:aarch64/instrs/branch/conditional/compare Rt:0 imm19:1001011000110000000 op:1 011010:011010 sf:1
	.inst 0x2dec42f3 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:19 Rn:23 Rt2:10000 imm7:1011000 L:1 1011011:1011011 opc:00
	.inst 0xe22dbbe2 // ASTUR-V.RI-Q Rt:2 Rn:31 op2:10 imm9:011011011 V:1 op1:00 11100010:11100010
	.inst 0x485ffd47 // ldaxrh:aarch64/instrs/memory/exclusive/single Rt:7 Rn:10 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0xc2de6206 // SCOFF-C.CR-C Cd:6 Cn:16 000:000 opc:11 0:0 Rm:30 11000010110:11000010110
	.inst 0xb83e5202 // ldsmin:aarch64/instrs/memory/atomicops/ld Rt:2 Rn:16 00:00 opc:101 0:0 Rs:30 1:1 R:0 A:0 111000:111000 size:10
	.inst 0x781f5029 // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:9 Rn:1 00:00 imm9:111110101 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c211c0
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
	ldr x26, =initial_cap_values
	.inst 0xc2400340 // ldr c0, [x26, #0]
	.inst 0xc2400741 // ldr c1, [x26, #1]
	.inst 0xc2400b42 // ldr c2, [x26, #2]
	.inst 0xc2400f49 // ldr c9, [x26, #3]
	.inst 0xc240134a // ldr c10, [x26, #4]
	.inst 0xc2401750 // ldr c16, [x26, #5]
	.inst 0xc2401b56 // ldr c22, [x26, #6]
	.inst 0xc2401f57 // ldr c23, [x26, #7]
	/* Vector registers */
	mrs x26, cptr_el3
	bfc x26, #10, #1
	msr cptr_el3, x26
	isb
	ldr q2, =0x0
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =initial_SP_EL3_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2c1d35f // cpy c31, c26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30851035
	msr SCTLR_EL3, x26
	ldr x26, =0x0
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031da // ldr c26, [c14, #3]
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	.inst 0x826011da // ldr c26, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30851035
	msr SCTLR_EL3, x26
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc240034e // ldr c14, [x26, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc240074e // ldr c14, [x26, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc2400b4e // ldr c14, [x26, #2]
	.inst 0xc2cea441 // chkeq c2, c14
	b.ne comparison_fail
	.inst 0xc2400f4e // ldr c14, [x26, #3]
	.inst 0xc2cea4a1 // chkeq c5, c14
	b.ne comparison_fail
	.inst 0xc240134e // ldr c14, [x26, #4]
	.inst 0xc2cea4c1 // chkeq c6, c14
	b.ne comparison_fail
	.inst 0xc240174e // ldr c14, [x26, #5]
	.inst 0xc2cea4e1 // chkeq c7, c14
	b.ne comparison_fail
	.inst 0xc2401b4e // ldr c14, [x26, #6]
	.inst 0xc2cea521 // chkeq c9, c14
	b.ne comparison_fail
	.inst 0xc2401f4e // ldr c14, [x26, #7]
	.inst 0xc2cea541 // chkeq c10, c14
	b.ne comparison_fail
	.inst 0xc240234e // ldr c14, [x26, #8]
	.inst 0xc2cea581 // chkeq c12, c14
	b.ne comparison_fail
	.inst 0xc240274e // ldr c14, [x26, #9]
	.inst 0xc2cea601 // chkeq c16, c14
	b.ne comparison_fail
	.inst 0xc2402b4e // ldr c14, [x26, #10]
	.inst 0xc2cea621 // chkeq c17, c14
	b.ne comparison_fail
	.inst 0xc2402f4e // ldr c14, [x26, #11]
	.inst 0xc2cea641 // chkeq c18, c14
	b.ne comparison_fail
	.inst 0xc240334e // ldr c14, [x26, #12]
	.inst 0xc2cea6c1 // chkeq c22, c14
	b.ne comparison_fail
	.inst 0xc240374e // ldr c14, [x26, #13]
	.inst 0xc2cea6e1 // chkeq c23, c14
	b.ne comparison_fail
	.inst 0xc2403b4e // ldr c14, [x26, #14]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check vector registers */
	ldr x26, =0x0
	mov x14, v2.d[0]
	cmp x26, x14
	b.ne comparison_fail
	ldr x26, =0x0
	mov x14, v2.d[1]
	cmp x26, x14
	b.ne comparison_fail
	ldr x26, =0x0
	mov x14, v16.d[0]
	cmp x26, x14
	b.ne comparison_fail
	ldr x26, =0x0
	mov x14, v16.d[1]
	cmp x26, x14
	b.ne comparison_fail
	ldr x26, =0x0
	mov x14, v19.d[0]
	cmp x26, x14
	b.ne comparison_fail
	ldr x26, =0x0
	mov x14, v19.d[1]
	cmp x26, x14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000102c
	ldr x1, =check_data1
	ldr x2, =0x00001034
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000103c
	ldr x1, =check_data2
	ldr x2, =0x00001044
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000111c
	ldr x1, =check_data3
	ldr x2, =0x0000111e
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001400
	ldr x1, =check_data4
	ldr x2, =0x00001410
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ff8
	ldr x1, =check_data5
	ldr x2, =0x00001ffa
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
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

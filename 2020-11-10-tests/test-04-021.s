.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x08, 0x40, 0x00, 0x00, 0x00, 0x11, 0x00, 0x01, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x61, 0xf9, 0x19, 0x6c, 0x1f, 0x40, 0x37, 0x78, 0x3f, 0x70, 0x73, 0xb8, 0xa0, 0x43, 0xff, 0x78
	.byte 0xe0, 0x73, 0xc2, 0xc2, 0x3e, 0x00, 0x02, 0xda, 0x24, 0x00, 0xc2, 0x38, 0x00, 0x85, 0xc2, 0xc2
.data
check_data3:
	.byte 0x1f, 0x70, 0xc0, 0xc2, 0x0b, 0xb0, 0x33, 0xb1, 0xa0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x163e
	/* C1 */
	.octa 0x80000000600200110000000000001644
	/* C2 */
	.octa 0x400002000000000000000000000000
	/* C8 */
	.octa 0x204080021007c3fc000000000047fffc
	/* C11 */
	.octa 0x14a0
	/* C19 */
	.octa 0x100
	/* C23 */
	.octa 0xc088
	/* C29 */
	.octa 0x1642
final_cap_values:
	/* C0 */
	.octa 0x1100
	/* C1 */
	.octa 0x80000000600200110000000000001644
	/* C2 */
	.octa 0x400002000000000000000000000000
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x204080021007c3fc000000000047fffc
	/* C11 */
	.octa 0x1dec
	/* C19 */
	.octa 0x100
	/* C23 */
	.octa 0xc088
	/* C29 */
	.octa 0x400000000000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000001780000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x6c19f961 // stnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:1 Rn:11 Rt2:11110 imm7:0110011 L:0 1011000:1011000 opc:01
	.inst 0x7837401f // stsmaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:100 o3:0 Rs:23 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xb873703f // stumin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:111 o3:0 Rs:19 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0x78ff43a0 // ldsmaxh:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:29 00:00 opc:100 0:0 Rs:31 1:1 R:1 A:1 111000:111000 size:01
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xda02003e // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:30 Rn:1 000000:000000 Rm:2 11010000:11010000 S:0 op:1 sf:1
	.inst 0x38c20024 // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:4 Rn:1 00:00 imm9:000100000 0:0 opc:11 111000:111000 size:00
	.inst 0xc2c28500 // BRS-C.C-C 00000:00000 Cn:8 001:001 opc:00 1:1 Cm:2 11000010110:11000010110
	.zero 524252
	.inst 0xc2c0701f // GCOFF-R.C-C Rd:31 Cn:0 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0xb133b00b // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:11 Rn:0 imm12:110011101100 sh:0 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0xc2c212a0
	.zero 524280
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e1 // ldr c1, [x15, #1]
	.inst 0xc24009e2 // ldr c2, [x15, #2]
	.inst 0xc2400de8 // ldr c8, [x15, #3]
	.inst 0xc24011eb // ldr c11, [x15, #4]
	.inst 0xc24015f3 // ldr c19, [x15, #5]
	.inst 0xc24019f7 // ldr c23, [x15, #6]
	.inst 0xc2401dfd // ldr c29, [x15, #7]
	/* Vector registers */
	mrs x15, cptr_el3
	bfc x15, #10, #1
	msr cptr_el3, x15
	isb
	ldr q1, =0x4008200000000000
	ldr q30, =0x8002011000000
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30851037
	msr SCTLR_EL3, x15
	ldr x15, =0x4
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032af // ldr c15, [c21, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x826012af // ldr c15, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	isb
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x21, #0xf
	and x15, x15, x21
	cmp x15, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001f5 // ldr c21, [x15, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc24005f5 // ldr c21, [x15, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc24009f5 // ldr c21, [x15, #2]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400df5 // ldr c21, [x15, #3]
	.inst 0xc2d5a481 // chkeq c4, c21
	b.ne comparison_fail
	.inst 0xc24011f5 // ldr c21, [x15, #4]
	.inst 0xc2d5a501 // chkeq c8, c21
	b.ne comparison_fail
	.inst 0xc24015f5 // ldr c21, [x15, #5]
	.inst 0xc2d5a561 // chkeq c11, c21
	b.ne comparison_fail
	.inst 0xc24019f5 // ldr c21, [x15, #6]
	.inst 0xc2d5a661 // chkeq c19, c21
	b.ne comparison_fail
	.inst 0xc2401df5 // ldr c21, [x15, #7]
	.inst 0xc2d5a6e1 // chkeq c23, c21
	b.ne comparison_fail
	.inst 0xc24021f5 // ldr c21, [x15, #8]
	.inst 0xc2d5a7a1 // chkeq c29, c21
	b.ne comparison_fail
	/* Check vector registers */
	ldr x15, =0x4008200000000000
	mov x21, v1.d[0]
	cmp x15, x21
	b.ne comparison_fail
	ldr x15, =0x0
	mov x21, v1.d[1]
	cmp x15, x21
	b.ne comparison_fail
	ldr x15, =0x8002011000000
	mov x21, v30.d[0]
	cmp x15, x21
	b.ne comparison_fail
	ldr x15, =0x0
	mov x21, v30.d[1]
	cmp x15, x21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001638
	ldr x1, =check_data0
	ldr x2, =0x00001648
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001664
	ldr x1, =check_data1
	ldr x2, =0x00001665
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400020
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0047fffc
	ldr x1, =check_data3
	ldr x2, =0x00480008
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
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

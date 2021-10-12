.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x81, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x5f, 0x30, 0x03, 0xd5, 0xe8, 0x47, 0x5f, 0xf8, 0xc0, 0x21, 0x46, 0x78, 0x81, 0x7c, 0x5f, 0x22
	.byte 0x5f, 0x40, 0x22, 0xf8, 0xc0, 0x23, 0xcd, 0xc2, 0xcf, 0x7b, 0x0a, 0x51, 0x41, 0x15, 0xa3, 0x29
	.byte 0xc2, 0x6b, 0x48, 0x31, 0x00, 0x00, 0x3f, 0xd6
.data
check_data4:
	.byte 0x00, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0xc0000000000700070000000000001000
	/* C4 */
	.octa 0x90000000000700040000000000001000
	/* C5 */
	.octa 0x0
	/* C10 */
	.octa 0x4000000040010f1d0000000000002028
	/* C14 */
	.octa 0x80000000201100050000000000001008
	/* C30 */
	.octa 0x10000700030000000000400400
final_cap_values:
	/* C1 */
	.octa 0x8100000000000000
	/* C2 */
	.octa 0x61a400
	/* C4 */
	.octa 0x90000000000700040000000000001000
	/* C5 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x4000000040010f1d0000000000001f40
	/* C14 */
	.octa 0x80000000201100050000000000001008
	/* C15 */
	.octa 0x400162
	/* C30 */
	.octa 0x20008000ca4100000000000000400029
initial_SP_EL3_value:
	.octa 0x800000000007800f0000000000408020
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004a4100000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd503305f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:0000 11010101000000110011:11010101000000110011
	.inst 0xf85f47e8 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:8 Rn:31 01:01 imm9:111110100 0:0 opc:01 111000:111000 size:11
	.inst 0x784621c0 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:14 00:00 imm9:001100010 0:0 opc:01 111000:111000 size:01
	.inst 0x225f7c81 // LDXR-C.R-C Ct:1 Rn:4 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0xf822405f // stsmax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:2 00:00 opc:100 o3:0 Rs:2 1:1 R:0 A:0 00:00 V:0 111:111 size:11
	.inst 0xc2cd23c0 // SCBNDSE-C.CR-C Cd:0 Cn:30 000:000 opc:01 0:0 Rm:13 11000010110:11000010110
	.inst 0x510a7bcf // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:15 Rn:30 imm12:001010011110 sh:0 0:0 10001:10001 S:0 op:1 sf:0
	.inst 0x29a31541 // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:1 Rn:10 Rt2:00101 imm7:1000110 L:0 1010011:1010011 opc:00
	.inst 0x31486bc2 // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:2 Rn:30 imm12:001000011010 sh:1 0:0 10001:10001 S:1 op:0 sf:0
	.inst 0xd63f0000 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:0 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 984
	.inst 0xc2c21200
	.zero 1047548
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
	ldr x27, =initial_cap_values
	.inst 0xc2400362 // ldr c2, [x27, #0]
	.inst 0xc2400764 // ldr c4, [x27, #1]
	.inst 0xc2400b65 // ldr c5, [x27, #2]
	.inst 0xc2400f6a // ldr c10, [x27, #3]
	.inst 0xc240136e // ldr c14, [x27, #4]
	.inst 0xc240177e // ldr c30, [x27, #5]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =initial_SP_EL3_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2c1d37f // cpy c31, c27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x3085103f
	msr SCTLR_EL3, x27
	ldr x27, =0x80
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x8260121b // ldr c27, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30851035
	msr SCTLR_EL3, x27
	isb
	/* Check processor flags */
	mrs x27, nzcv
	ubfx x27, x27, #28, #4
	mov x16, #0xf
	and x27, x27, x16
	cmp x27, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400370 // ldr c16, [x27, #0]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400770 // ldr c16, [x27, #1]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400b70 // ldr c16, [x27, #2]
	.inst 0xc2d0a481 // chkeq c4, c16
	b.ne comparison_fail
	.inst 0xc2400f70 // ldr c16, [x27, #3]
	.inst 0xc2d0a4a1 // chkeq c5, c16
	b.ne comparison_fail
	.inst 0xc2401370 // ldr c16, [x27, #4]
	.inst 0xc2d0a501 // chkeq c8, c16
	b.ne comparison_fail
	.inst 0xc2401770 // ldr c16, [x27, #5]
	.inst 0xc2d0a541 // chkeq c10, c16
	b.ne comparison_fail
	.inst 0xc2401b70 // ldr c16, [x27, #6]
	.inst 0xc2d0a5c1 // chkeq c14, c16
	b.ne comparison_fail
	.inst 0xc2401f70 // ldr c16, [x27, #7]
	.inst 0xc2d0a5e1 // chkeq c15, c16
	b.ne comparison_fail
	.inst 0xc2402370 // ldr c16, [x27, #8]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000106a
	ldr x1, =check_data1
	ldr x2, =0x0000106c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f40
	ldr x1, =check_data2
	ldr x2, =0x00001f48
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400028
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400400
	ldr x1, =check_data4
	ldr x2, =0x00400404
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00408020
	ldr x1, =check_data5
	ldr x2, =0x00408028
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
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

.section data0, #alloc, #write
	.zero 384
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x81, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3696
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x00, 0x00, 0x01, 0x00
.data
check_data3:
	.byte 0x81
.data
check_data4:
	.byte 0x21, 0x50, 0x2f, 0x38, 0x0d, 0x30, 0x95, 0xe2, 0x5e, 0x68, 0xc1, 0xc2, 0x0c, 0x95, 0x9d, 0xb8
	.byte 0x81, 0x02, 0x7d, 0xb8, 0xe0, 0x2b, 0xd0, 0x78, 0xff, 0x02, 0x22, 0x38, 0xd3, 0xbf, 0x07, 0x78
	.byte 0x0e, 0xda, 0x51, 0x7a, 0x20, 0x7c, 0x44, 0xa2, 0xc0, 0x10, 0xc2, 0xc2
.data
check_data5:
	.zero 16
.data
check_data6:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000300070000000000001231
	/* C1 */
	.octa 0x118a
	/* C2 */
	.octa 0x1001
	/* C8 */
	.octa 0x100c
	/* C13 */
	.octa 0x400000
	/* C15 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C20 */
	.octa 0x1184
	/* C23 */
	.octa 0x1186
	/* C29 */
	.octa 0xffc00000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x400470
	/* C2 */
	.octa 0x1001
	/* C8 */
	.octa 0xfe5
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x400000
	/* C15 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C20 */
	.octa 0x1184
	/* C23 */
	.octa 0x1186
	/* C29 */
	.octa 0xffc00000
	/* C30 */
	.octa 0x107c
initial_SP_EL3_value:
	.octa 0x401000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000047c0070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0100000267300070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x382f5021 // ldsminb:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:1 00:00 opc:101 0:0 Rs:15 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xe295300d // ASTUR-R.RI-32 Rt:13 Rn:0 op2:00 imm9:101010011 V:0 op1:10 11100010:11100010
	.inst 0xc2c1685e // ORRFLGS-C.CR-C Cd:30 Cn:2 1010:1010 opc:01 Rm:1 11000010110:11000010110
	.inst 0xb89d950c // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:12 Rn:8 01:01 imm9:111011001 0:0 opc:10 111000:111000 size:10
	.inst 0xb87d0281 // ldadd:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:20 00:00 opc:000 0:0 Rs:29 1:1 R:1 A:0 111000:111000 size:10
	.inst 0x78d02be0 // ldtrsh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:31 10:10 imm9:100000010 0:0 opc:11 111000:111000 size:01
	.inst 0x382202ff // staddb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:23 00:00 opc:000 o3:0 Rs:2 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x7807bfd3 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:19 Rn:30 11:11 imm9:001111011 0:0 opc:00 111000:111000 size:01
	.inst 0x7a51da0e // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1110 0:0 Rn:16 10:10 cond:1101 imm5:10001 111010010:111010010 op:1 sf:0
	.inst 0xa2447c20 // LDR-C.RIBW-C Ct:0 Rn:1 11:11 imm9:001000111 0:0 opc:01 10100010:10100010
	.inst 0xc2c210c0
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
	ldr x25, =initial_cap_values
	.inst 0xc2400320 // ldr c0, [x25, #0]
	.inst 0xc2400721 // ldr c1, [x25, #1]
	.inst 0xc2400b22 // ldr c2, [x25, #2]
	.inst 0xc2400f28 // ldr c8, [x25, #3]
	.inst 0xc240132d // ldr c13, [x25, #4]
	.inst 0xc240172f // ldr c15, [x25, #5]
	.inst 0xc2401b33 // ldr c19, [x25, #6]
	.inst 0xc2401f34 // ldr c20, [x25, #7]
	.inst 0xc2402337 // ldr c23, [x25, #8]
	.inst 0xc240273d // ldr c29, [x25, #9]
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
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030d9 // ldr c25, [c6, #3]
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	.inst 0x826010d9 // ldr c25, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
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
	mov x6, #0xf
	and x25, x25, x6
	cmp x25, #0xe
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400326 // ldr c6, [x25, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400726 // ldr c6, [x25, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400b26 // ldr c6, [x25, #2]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400f26 // ldr c6, [x25, #3]
	.inst 0xc2c6a501 // chkeq c8, c6
	b.ne comparison_fail
	.inst 0xc2401326 // ldr c6, [x25, #4]
	.inst 0xc2c6a581 // chkeq c12, c6
	b.ne comparison_fail
	.inst 0xc2401726 // ldr c6, [x25, #5]
	.inst 0xc2c6a5a1 // chkeq c13, c6
	b.ne comparison_fail
	.inst 0xc2401b26 // ldr c6, [x25, #6]
	.inst 0xc2c6a5e1 // chkeq c15, c6
	b.ne comparison_fail
	.inst 0xc2401f26 // ldr c6, [x25, #7]
	.inst 0xc2c6a661 // chkeq c19, c6
	b.ne comparison_fail
	.inst 0xc2402326 // ldr c6, [x25, #8]
	.inst 0xc2c6a681 // chkeq c20, c6
	b.ne comparison_fail
	.inst 0xc2402726 // ldr c6, [x25, #9]
	.inst 0xc2c6a6e1 // chkeq c23, c6
	b.ne comparison_fail
	.inst 0xc2402b26 // ldr c6, [x25, #10]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	.inst 0xc2402f26 // ldr c6, [x25, #11]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000100c
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000107c
	ldr x1, =check_data1
	ldr x2, =0x0000107e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001184
	ldr x1, =check_data2
	ldr x2, =0x00001188
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000118a
	ldr x1, =check_data3
	ldr x2, =0x0000118b
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
	ldr x0, =0x00400470
	ldr x1, =check_data5
	ldr x2, =0x00400480
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400f02
	ldr x1, =check_data6
	ldr x2, =0x00400f04
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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

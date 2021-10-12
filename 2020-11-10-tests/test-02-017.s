.section data0, #alloc, #write
	.zero 3072
	.byte 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 816
	.byte 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 176
.data
check_data0:
	.byte 0x00, 0x20
.data
check_data1:
	.byte 0x01
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x3e, 0x60, 0xb8, 0x78, 0x43, 0x50, 0xc2, 0xc2
.data
check_data5:
	.byte 0xd7, 0x1d, 0x36, 0x12, 0xff, 0xc3, 0xbf, 0x78, 0x42, 0xf8, 0xb8, 0x9b, 0xe1, 0x0b, 0xa8, 0x9b
	.byte 0x0c, 0x80, 0x4b, 0x78, 0x7d, 0x56, 0x17, 0x38, 0xf2, 0xd3, 0x0a, 0x82, 0x1f, 0x40, 0x3e, 0x38
	.byte 0xe0, 0x11, 0xc2, 0xc2
.data
check_data6:
	.zero 16
.data
check_data7:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000000100050000000000001f42
	/* C1 */
	.octa 0xc0000000000080080000000000001c00
	/* C2 */
	.octa 0xb000000000a100050000000000400969
	/* C19 */
	.octa 0x40000000000100050000000000001ffe
	/* C24 */
	.octa 0x2000
	/* C29 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xc0000000000100050000000000001f42
	/* C1 */
	.octa 0xfffffff7fed2e100
	/* C2 */
	.octa 0xfffffff7fed2e100
	/* C12 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x40000000000100050000000000001f73
	/* C24 */
	.octa 0x2000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x100
initial_RSP_EL0_value:
	.octa 0x800000000001000500000000004ffffc
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000006000f0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword initial_RSP_EL0_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x78b8603e // ldumaxh:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:1 00:00 opc:110 0:0 Rs:24 1:1 R:0 A:1 111000:111000 size:01
	.inst 0xc2c25043 // RETR-C-C 00011:00011 Cn:2 100:100 opc:10 11000010110000100:11000010110000100
	.zero 2400
	.inst 0x12361dd7 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:23 Rn:14 imms:000111 immr:110110 N:0 100100:100100 opc:00 sf:0
	.inst 0x78bfc3ff // ldaprh:aarch64/instrs/memory/ordered-rcpc Rt:31 Rn:31 110000:110000 Rs:11111 111000101:111000101 size:01
	.inst 0x9bb8f842 // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:2 Rn:2 Ra:30 o0:1 Rm:24 01:01 U:1 10011011:10011011
	.inst 0x9ba80be1 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:1 Rn:31 Ra:2 o0:0 Rm:8 01:01 U:1 10011011:10011011
	.inst 0x784b800c // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:12 Rn:0 00:00 imm9:010111000 0:0 opc:01 111000:111000 size:01
	.inst 0x3817567d // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:19 01:01 imm9:101110101 0:0 opc:00 111000:111000 size:00
	.inst 0x820ad3f2 // LDR-C.I-C Ct:18 imm17:00101011010011111 1000001000:1000001000
	.inst 0x383e401f // stsmaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:100 o3:0 Rs:30 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2c211e0
	.zero 1046132
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c0 // ldr c0, [x22, #0]
	.inst 0xc24006c1 // ldr c1, [x22, #1]
	.inst 0xc2400ac2 // ldr c2, [x22, #2]
	.inst 0xc2400ed3 // ldr c19, [x22, #3]
	.inst 0xc24012d8 // ldr c24, [x22, #4]
	.inst 0xc24016dd // ldr c29, [x22, #5]
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30851035
	msr SCTLR_EL3, x22
	ldr x22, =0x0
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	ldr x22, =initial_RSP_EL0_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc28f4176 // msr RSP_EL0, c22
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826011f6 // ldr c22, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30851035
	msr SCTLR_EL3, x22
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002cf // ldr c15, [x22, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc24006cf // ldr c15, [x22, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc2400acf // ldr c15, [x22, #2]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc2400ecf // ldr c15, [x22, #3]
	.inst 0xc2cfa581 // chkeq c12, c15
	b.ne comparison_fail
	.inst 0xc24012cf // ldr c15, [x22, #4]
	.inst 0xc2cfa641 // chkeq c18, c15
	b.ne comparison_fail
	.inst 0xc24016cf // ldr c15, [x22, #5]
	.inst 0xc2cfa661 // chkeq c19, c15
	b.ne comparison_fail
	.inst 0xc2401acf // ldr c15, [x22, #6]
	.inst 0xc2cfa701 // chkeq c24, c15
	b.ne comparison_fail
	.inst 0xc2401ecf // ldr c15, [x22, #7]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc24022cf // ldr c15, [x22, #8]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001c00
	ldr x1, =check_data0
	ldr x2, =0x00001c02
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001f42
	ldr x1, =check_data1
	ldr x2, =0x00001f43
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffa
	ldr x1, =check_data2
	ldr x2, =0x00001ffc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400008
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400968
	ldr x1, =check_data5
	ldr x2, =0x0040098c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00457370
	ldr x1, =check_data6
	ldr x2, =0x00457380
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004ffffc
	ldr x1, =check_data7
	ldr x2, =0x004ffffe
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
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

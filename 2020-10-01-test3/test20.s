.section data0, #alloc, #write
	.byte 0x00, 0x00, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 304
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 3760
.data
check_data0:
	.byte 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc5, 0x62, 0x92, 0xf8, 0x25, 0xcf, 0x08, 0x82, 0x9a, 0x81, 0xcd, 0xc2, 0xbf, 0x92, 0x4c, 0xa2
	.byte 0xca, 0x23, 0xec, 0xc2, 0x49, 0xe0, 0x90, 0x78, 0x53, 0x34, 0xc0, 0x6a, 0x56, 0xdf, 0xa7, 0xf0
	.byte 0x9e, 0x7f, 0xca, 0x9b, 0x0f, 0x2f, 0xd4, 0xf2, 0x20, 0x12, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20fa000
	/* C2 */
	.octa 0x107f
	/* C13 */
	.octa 0x0
	/* C21 */
	.octa 0x1002
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x20fa000
	/* C2 */
	.octa 0x107f
	/* C5 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C9 */
	.octa 0xffffffffffffc2c2
	/* C10 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C19 */
	.octa 0x107d
	/* C21 */
	.octa 0x1002
	/* C22 */
	.octa 0xffffffff4ffeb000
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xb0108000000100050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x801000006001007500ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf89262c5 // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:5 Rn:22 00:00 imm9:100100110 0:0 opc:10 111000:111000 size:11
	.inst 0x8208cf25 // LDR-C.I-C Ct:5 imm17:00100011001111001 1000001000:1000001000
	.inst 0xc2cd819a // SCTAG-C.CR-C Cd:26 Cn:12 000:000 0:0 10:10 Rm:13 11000010110:11000010110
	.inst 0xa24c92bf // LDUR-C.RI-C Ct:31 Rn:21 00:00 imm9:011001001 0:0 opc:01 10100010:10100010
	.inst 0xc2ec23ca // BICFLGS-C.CI-C Cd:10 Cn:30 0:0 00:00 imm8:01100001 11000010111:11000010111
	.inst 0x7890e049 // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:9 Rn:2 00:00 imm9:100001110 0:0 opc:10 111000:111000 size:01
	.inst 0x6ac03453 // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:19 Rn:2 imm6:001101 Rm:0 N:0 shift:11 01010:01010 opc:11 sf:0
	.inst 0xf0a7df56 // ADRP-C.IP-C Rd:22 immhi:010011111011111010 P:1 10000:10000 immlo:11 op:1
	.inst 0x9bca7f9e // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:30 Rn:28 Ra:11111 0:0 Rm:10 10:10 U:1 10011011:10011011
	.inst 0xf2d42f0f // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:15 imm16:1010000101111000 hw:10 100101:100101 opc:11 sf:1
	.inst 0xc2c21220
	.zero 288612
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 759904
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
	.inst 0xc24005c2 // ldr c2, [x14, #1]
	.inst 0xc24009cd // ldr c13, [x14, #2]
	.inst 0xc2400dd5 // ldr c21, [x14, #3]
	.inst 0xc24011de // ldr c30, [x14, #4]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30850032
	msr SCTLR_EL3, x14
	ldr x14, =0xc
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x8260322e // ldr c14, [c17, #3]
	.inst 0xc28b412e // msr ddc_el3, c14
	isb
	.inst 0x8260122e // ldr c14, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
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
	mov x17, #0xf
	and x14, x14, x17
	cmp x14, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001d1 // ldr c17, [x14, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc24005d1 // ldr c17, [x14, #1]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc24009d1 // ldr c17, [x14, #2]
	.inst 0xc2d1a4a1 // chkeq c5, c17
	b.ne comparison_fail
	.inst 0xc2400dd1 // ldr c17, [x14, #3]
	.inst 0xc2d1a521 // chkeq c9, c17
	b.ne comparison_fail
	.inst 0xc24011d1 // ldr c17, [x14, #4]
	.inst 0xc2d1a541 // chkeq c10, c17
	b.ne comparison_fail
	.inst 0xc24015d1 // ldr c17, [x14, #5]
	.inst 0xc2d1a5a1 // chkeq c13, c17
	b.ne comparison_fail
	.inst 0xc24019d1 // ldr c17, [x14, #6]
	.inst 0xc2d1a661 // chkeq c19, c17
	b.ne comparison_fail
	.inst 0xc2401dd1 // ldr c17, [x14, #7]
	.inst 0xc2d1a6a1 // chkeq c21, c17
	b.ne comparison_fail
	.inst 0xc24021d1 // ldr c17, [x14, #8]
	.inst 0xc2d1a6c1 // chkeq c22, c17
	b.ne comparison_fail
	.inst 0xc24025d1 // ldr c17, [x14, #9]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001002
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001140
	ldr x1, =check_data1
	ldr x2, =0x00001150
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
	ldr x0, =0x00446790
	ldr x1, =check_data3
	ldr x2, =0x004467a0
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

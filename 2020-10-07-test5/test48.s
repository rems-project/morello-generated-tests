.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x09, 0x00
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x33, 0x83, 0xde, 0xc2, 0xc2, 0x93, 0xc1, 0xc2, 0x5f, 0x4e, 0x0b, 0x78, 0xdf, 0xef, 0x0c, 0x29
	.byte 0x01, 0x93, 0x4a, 0x1c, 0xc0, 0x7e, 0xfa, 0xc2, 0xf5, 0xe6, 0x10, 0x02, 0x5f, 0x34, 0x02, 0xaa
	.byte 0x62, 0xf4, 0xd6, 0xb0, 0x18, 0x0a, 0xc0, 0xda, 0x20, 0x10, 0xc2, 0xc2
.data
check_data4:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C18 */
	.octa 0x835
	/* C22 */
	.octa 0x901000005022002a0000000000000000
	/* C23 */
	.octa 0x40002000007ffffffffffc38
	/* C26 */
	.octa 0x100
	/* C27 */
	.octa 0x90000
	/* C30 */
	.octa 0x661
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0xffffffffae28d000
	/* C18 */
	.octa 0x8e9
	/* C21 */
	.octa 0x400020000080000000000071
	/* C22 */
	.octa 0x901000005022002a0000000000000000
	/* C23 */
	.octa 0x40002000007ffffffffffc38
	/* C26 */
	.octa 0x100
	/* C27 */
	.octa 0x90000
	/* C30 */
	.octa 0x661
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0808000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000580109970000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 16
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2de8333 // SCTAG-C.CR-C Cd:19 Cn:25 000:000 0:0 10:10 Rm:30 11000010110:11000010110
	.inst 0xc2c193c2 // CLRTAG-C.C-C Cd:2 Cn:30 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0x780b4e5f // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:18 11:11 imm9:010110100 0:0 opc:00 111000:111000 size:01
	.inst 0x290cefdf // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:31 Rn:30 Rt2:11011 imm7:0011001 L:0 1010010:1010010 opc:00
	.inst 0x1c4a9301 // ldr_lit_fpsimd:aarch64/instrs/memory/literal/simdfp Rt:1 imm19:0100101010010011000 011100:011100 opc:00
	.inst 0xc2fa7ec0 // ALDR-C.RRB-C Ct:0 Rn:22 1:1 L:1 S:1 option:011 Rm:26 11000010111:11000010111
	.inst 0x0210e6f5 // ADD-C.CIS-C Cd:21 Cn:23 imm12:010000111001 sh:0 A:0 00000010:00000010
	.inst 0xaa02345f // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:2 imm6:001101 Rm:2 N:0 shift:00 01010:01010 opc:01 sf:1
	.inst 0xb0d6f462 // ADRP-C.IP-C Rd:2 immhi:101011011110100011 P:1 10000:10000 immlo:01 op:1
	.inst 0xdac00a18 // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:24 Rn:16 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2c21020
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x4, cptr_el3
	orr x4, x4, #0x200
	msr cptr_el3, x4
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
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
	ldr x4, =initial_cap_values
	.inst 0xc2400092 // ldr c18, [x4, #0]
	.inst 0xc2400496 // ldr c22, [x4, #1]
	.inst 0xc2400897 // ldr c23, [x4, #2]
	.inst 0xc2400c9a // ldr c26, [x4, #3]
	.inst 0xc240109b // ldr c27, [x4, #4]
	.inst 0xc240149e // ldr c30, [x4, #5]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	ldr x4, =0xc
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x1, =pcc_return_ddc_capabilities
	.inst 0xc2400021 // ldr c1, [x1, #0]
	.inst 0x82603024 // ldr c4, [c1, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x82601024 // ldr c4, [c1, #1]
	.inst 0x82602021 // ldr c1, [c1, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400081 // ldr c1, [x4, #0]
	.inst 0xc2c1a401 // chkeq c0, c1
	b.ne comparison_fail
	.inst 0xc2400481 // ldr c1, [x4, #1]
	.inst 0xc2c1a441 // chkeq c2, c1
	b.ne comparison_fail
	.inst 0xc2400881 // ldr c1, [x4, #2]
	.inst 0xc2c1a641 // chkeq c18, c1
	b.ne comparison_fail
	.inst 0xc2400c81 // ldr c1, [x4, #3]
	.inst 0xc2c1a6a1 // chkeq c21, c1
	b.ne comparison_fail
	.inst 0xc2401081 // ldr c1, [x4, #4]
	.inst 0xc2c1a6c1 // chkeq c22, c1
	b.ne comparison_fail
	.inst 0xc2401481 // ldr c1, [x4, #5]
	.inst 0xc2c1a6e1 // chkeq c23, c1
	b.ne comparison_fail
	.inst 0xc2401881 // ldr c1, [x4, #6]
	.inst 0xc2c1a741 // chkeq c26, c1
	b.ne comparison_fail
	.inst 0xc2401c81 // ldr c1, [x4, #7]
	.inst 0xc2c1a761 // chkeq c27, c1
	b.ne comparison_fail
	.inst 0xc2402081 // ldr c1, [x4, #8]
	.inst 0xc2c1a7c1 // chkeq c30, c1
	b.ne comparison_fail
	/* Check vector registers */
	ldr x4, =0x0
	mov x1, v1.d[0]
	cmp x4, x1
	b.ne comparison_fail
	ldr x4, =0x0
	mov x1, v1.d[1]
	cmp x4, x1
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
	ldr x0, =0x0000105c
	ldr x1, =check_data1
	ldr x2, =0x00001064
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001280
	ldr x1, =check_data2
	ldr x2, =0x00001282
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
	ldr x0, =0x00495270
	ldr x1, =check_data4
	ldr x2, =0x00495274
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
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
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

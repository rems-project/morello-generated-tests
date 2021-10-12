.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0x02, 0x5c, 0x58, 0x82, 0x80, 0x00, 0x96, 0x02, 0x9f, 0x64, 0x57, 0x82, 0xdd, 0x47, 0x4b, 0xbc
	.byte 0xe1, 0x98, 0xf8, 0xc2, 0x15, 0x88, 0x5f, 0x82, 0x1b, 0x10, 0xc1, 0xc2, 0x02, 0xa0, 0xd4, 0xc2
	.byte 0x3f, 0x1a, 0x81, 0xf0, 0xc3, 0x30, 0x30, 0x54
.data
check_data5:
	.byte 0x40, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xd8
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0xa0072007000000000000000c
	/* C7 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C30 */
	.octa 0x80000000000100070000000000001778
final_cap_values:
	/* C0 */
	.octa 0xa0072007fffffffffffffa8c
	/* C1 */
	.octa 0x3
	/* C2 */
	.octa 0xa0072007fffffffffffffa8c
	/* C4 */
	.octa 0xa0072007000000000000000c
	/* C7 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0xffffffffffff6000
	/* C30 */
	.octa 0x8000000000010007000000000000182c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x2000800012cb00070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000100710070000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82585c02 // ASTR-R.RI-64 Rt:2 Rn:0 op:11 imm9:110000101 L:0 1000001001:1000001001
	.inst 0x02960080 // SUB-C.CIS-C Cd:0 Cn:4 imm12:010110000000 sh:0 A:1 00000010:00000010
	.inst 0x8257649f // ASTRB-R.RI-B Rt:31 Rn:4 op:01 imm9:101110110 L:0 1000001001:1000001001
	.inst 0xbc4b47dd // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:29 Rn:30 01:01 imm9:010110100 0:0 opc:01 111100:111100 size:10
	.inst 0xc2f898e1 // SUBS-R.CC-C Rd:1 Cn:7 100110:100110 Cm:24 11000010111:11000010111
	.inst 0x825f8815 // ASTR-R.RI-32 Rt:21 Rn:0 op:10 imm9:111111000 L:0 1000001001:1000001001
	.inst 0xc2c1101b // GCLIM-R.C-C Rd:27 Cn:0 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0xc2d4a002 // CLRPERM-C.CR-C Cd:2 Cn:0 000:000 1:1 10:10 Rm:20 11000010110:11000010110
	.inst 0xf0811a3f // ADRP-C.IP-C Rd:31 immhi:000000100011010001 P:1 10000:10000 immlo:11 op:1
	.inst 0x543030c3 // b_cond:aarch64/instrs/branch/conditional/cond cond:0011 0:0 imm19:0011000000110000110 01010100:01010100
	.zero 394772
	.inst 0xc2c21140
	.zero 653760
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x22, cptr_el3
	orr x22, x22, #0x200
	msr cptr_el3, x22
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c0 // ldr c0, [x22, #0]
	.inst 0xc24006c2 // ldr c2, [x22, #1]
	.inst 0xc2400ac4 // ldr c4, [x22, #2]
	.inst 0xc2400ec7 // ldr c7, [x22, #3]
	.inst 0xc24012d5 // ldr c21, [x22, #4]
	.inst 0xc24016d8 // ldr c24, [x22, #5]
	.inst 0xc2401ade // ldr c30, [x22, #6]
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
	ldr x22, =0x4
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603156 // ldr c22, [c10, #3]
	.inst 0xc28b4136 // msr ddc_el3, c22
	isb
	.inst 0x82601156 // ldr c22, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr ddc_el3, c22
	isb
	/* Check processor flags */
	mrs x22, nzcv
	ubfx x22, x22, #28, #4
	mov x10, #0xf
	and x22, x22, x10
	cmp x22, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002ca // ldr c10, [x22, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc24006ca // ldr c10, [x22, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400aca // ldr c10, [x22, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400eca // ldr c10, [x22, #3]
	.inst 0xc2caa481 // chkeq c4, c10
	b.ne comparison_fail
	.inst 0xc24012ca // ldr c10, [x22, #4]
	.inst 0xc2caa4e1 // chkeq c7, c10
	b.ne comparison_fail
	.inst 0xc24016ca // ldr c10, [x22, #5]
	.inst 0xc2caa6a1 // chkeq c21, c10
	b.ne comparison_fail
	.inst 0xc2401aca // ldr c10, [x22, #6]
	.inst 0xc2caa701 // chkeq c24, c10
	b.ne comparison_fail
	.inst 0xc2401eca // ldr c10, [x22, #7]
	.inst 0xc2caa761 // chkeq c27, c10
	b.ne comparison_fail
	.inst 0xc24022ca // ldr c10, [x22, #8]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x22, =0x0
	mov x10, v29.d[0]
	cmp x22, x10
	b.ne comparison_fail
	ldr x22, =0x0
	mov x10, v29.d[1]
	cmp x22, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001182
	ldr x1, =check_data0
	ldr x2, =0x00001183
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000126c
	ldr x1, =check_data1
	ldr x2, =0x00001270
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001778
	ldr x1, =check_data2
	ldr x2, =0x0000177c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001d00
	ldr x1, =check_data3
	ldr x2, =0x00001d08
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400028
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0046063c
	ldr x1, =check_data5
	ldr x2, =0x00460640
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr ddc_el3, c22
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

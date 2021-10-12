.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0xf4, 0xfb, 0x95, 0xb8, 0xfe, 0xcb, 0xdd, 0x82, 0x1f, 0x90, 0x01, 0xe2, 0xa0, 0x88, 0x5d, 0xb0
	.byte 0xde, 0x13, 0xc7, 0xc2, 0x30, 0x53, 0x78, 0x82, 0x1f, 0x88, 0xbe, 0x9b, 0x5e, 0x31, 0xc5, 0xc2
	.byte 0x3e, 0xf0, 0xc5, 0xc2, 0x6a, 0x27, 0xdf, 0x9a, 0x20, 0x12, 0xc2, 0xc2
.data
check_data3:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000400100020000000000001000
	/* C1 */
	.octa 0xffffffffffe000
	/* C10 */
	.octa 0x0
	/* C25 */
	.octa 0x9010000000070006ffffffffffffff90
	/* C29 */
	.octa 0x4f3f
final_cap_values:
	/* C0 */
	.octa 0xbb515000
	/* C1 */
	.octa 0xffffffffffe000
	/* C16 */
	.octa 0x0
	/* C20 */
	.octa 0xffffffffc2c5f03e
	/* C25 */
	.octa 0x9010000000070006ffffffffffffff90
	/* C29 */
	.octa 0x4f3f
	/* C30 */
	.octa 0x200080000007000700ffffffffffe000
initial_csp_value:
	.octa 0x800000000000800800000000004000c1
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000004024000500000000003fe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000017e0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb895fbf4 // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:20 Rn:31 10:10 imm9:101011111 0:0 opc:10 111000:111000 size:10
	.inst 0x82ddcbfe // ALDRSH-R.RRB-32 Rt:30 Rn:31 opc:10 S:0 option:110 Rm:29 0:0 L:1 100000101:100000101
	.inst 0xe201901f // ASTURB-R.RI-32 Rt:31 Rn:0 op2:00 imm9:000011001 V:0 op1:00 11100010:11100010
	.inst 0xb05d88a0 // ADRDP-C.ID-C Rd:0 immhi:101110110001000101 P:0 10000:10000 immlo:01 op:1
	.inst 0xc2c713de // RRLEN-R.R-C Rd:30 Rn:30 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x82785330 // ALDR-C.RI-C Ct:16 Rn:25 op:00 imm9:110000101 L:1 1000001001:1000001001
	.inst 0x9bbe881f // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:31 Rn:0 Ra:2 o0:1 Rm:30 01:01 U:1 10011011:10011011
	.inst 0xc2c5315e // CVTP-R.C-C Rd:30 Cn:10 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0xc2c5f03e // CVTPZ-C.R-C Cd:30 Rn:1 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0x9adf276a // lsrv:aarch64/instrs/integer/shift/variable Rd:10 Rn:27 op2:01 0010:0010 Rm:31 0011010110:0011010110 sf:1
	.inst 0xc2c21220
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
	ldr x4, =initial_cap_values
	.inst 0xc2400080 // ldr c0, [x4, #0]
	.inst 0xc2400481 // ldr c1, [x4, #1]
	.inst 0xc240088a // ldr c10, [x4, #2]
	.inst 0xc2400c99 // ldr c25, [x4, #3]
	.inst 0xc240109d // ldr c29, [x4, #4]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =initial_csp_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2c1d09f // cpy c31, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	ldr x4, =0x0
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82603224 // ldr c4, [c17, #3]
	.inst 0xc28b4124 // msr ddc_el3, c4
	isb
	.inst 0x82601224 // ldr c4, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr ddc_el3, c4
	isb
	/* Check processor flags */
	mrs x4, nzcv
	ubfx x4, x4, #28, #4
	mov x17, #0xf
	and x4, x4, x17
	cmp x4, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400091 // ldr c17, [x4, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc2400491 // ldr c17, [x4, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400891 // ldr c17, [x4, #2]
	.inst 0xc2d1a601 // chkeq c16, c17
	b.ne comparison_fail
	.inst 0xc2400c91 // ldr c17, [x4, #3]
	.inst 0xc2d1a681 // chkeq c20, c17
	b.ne comparison_fail
	.inst 0xc2401091 // ldr c17, [x4, #4]
	.inst 0xc2d1a721 // chkeq c25, c17
	b.ne comparison_fail
	.inst 0xc2401491 // ldr c17, [x4, #5]
	.inst 0xc2d1a7a1 // chkeq c29, c17
	b.ne comparison_fail
	.inst 0xc2401891 // ldr c17, [x4, #6]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001019
	ldr x1, =check_data0
	ldr x2, =0x0000101a
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000017e0
	ldr x1, =check_data1
	ldr x2, =0x000017f0
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
	ldr x0, =0x00405000
	ldr x1, =check_data3
	ldr x2, =0x00405002
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
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr ddc_el3, c4
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

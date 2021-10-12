.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x23, 0x60, 0x4b, 0xe2, 0xca, 0x2b, 0xd1, 0xc2, 0x5d, 0x42, 0x2c, 0x70, 0x3f, 0x00, 0x12, 0x3a
	.byte 0xbe, 0x88, 0x42, 0xab, 0x2a, 0x10, 0xc1, 0xc2, 0x81, 0x4a, 0x4b, 0xb2, 0x5f, 0x50, 0xdd, 0x38
	.byte 0x09, 0x48, 0xc0, 0xc2, 0x5c, 0x19, 0xe7, 0xc2, 0x00, 0x12, 0xc2, 0xc2
.data
check_data2:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x100190130000000000001000
	/* C2 */
	.octa 0x80000000104100070000000000500029
	/* C3 */
	.octa 0x0
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x80000000104100070000000000500029
	/* C3 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0xffffffffffffffff
	/* C29 */
	.octa 0x20008000000100050000000000458853
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000510200000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe24b6023 // ASTURH-R.RI-32 Rt:3 Rn:1 op2:00 imm9:010110110 V:0 op1:01 11100010:11100010
	.inst 0xc2d12bca // BICFLGS-C.CR-C Cd:10 Cn:30 1010:1010 opc:00 Rm:17 11000010110:11000010110
	.inst 0x702c425d // ADR-C.I-C Rd:29 immhi:010110001000010010 P:0 10000:10000 immlo:11 op:0
	.inst 0x3a12003f // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:31 Rn:1 000000:000000 Rm:18 11010000:11010000 S:1 op:0 sf:0
	.inst 0xab4288be // adds_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:30 Rn:5 imm6:100010 Rm:2 0:0 shift:01 01011:01011 S:1 op:0 sf:1
	.inst 0xc2c1102a // GCLIM-R.C-C Rd:10 Cn:1 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0xb24b4a81 // orr_log_imm:aarch64/instrs/integer/logical/immediate Rd:1 Rn:20 imms:010010 immr:001011 N:1 100100:100100 opc:01 sf:1
	.inst 0x38dd505f // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:2 00:00 imm9:111010101 0:0 opc:11 111000:111000 size:00
	.inst 0xc2c04809 // UNSEAL-C.CC-C Cd:9 Cn:0 0010:0010 opc:01 Cm:0 11000010110:11000010110
	.inst 0xc2e7195c // CVT-C.CR-C Cd:28 Cn:10 0110:0110 0:0 0:0 Rm:7 11000010111:11000010111
	.inst 0xc2c21200
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x13, cptr_el3
	orr x13, x13, #0x200
	msr cptr_el3, x13
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a1 // ldr c1, [x13, #1]
	.inst 0xc24009a2 // ldr c2, [x13, #2]
	.inst 0xc2400da3 // ldr c3, [x13, #3]
	.inst 0xc24011be // ldr c30, [x13, #4]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30850032
	msr SCTLR_EL3, x13
	ldr x13, =0x4
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x8260320d // ldr c13, [c16, #3]
	.inst 0xc28b412d // msr ddc_el3, c13
	isb
	.inst 0x8260120d // ldr c13, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr ddc_el3, c13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x16, #0x3
	and x13, x13, x16
	cmp x13, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001b0 // ldr c16, [x13, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc24005b0 // ldr c16, [x13, #1]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc24009b0 // ldr c16, [x13, #2]
	.inst 0xc2d0a461 // chkeq c3, c16
	b.ne comparison_fail
	.inst 0xc2400db0 // ldr c16, [x13, #3]
	.inst 0xc2d0a521 // chkeq c9, c16
	b.ne comparison_fail
	.inst 0xc24011b0 // ldr c16, [x13, #4]
	.inst 0xc2d0a541 // chkeq c10, c16
	b.ne comparison_fail
	.inst 0xc24015b0 // ldr c16, [x13, #5]
	.inst 0xc2d0a7a1 // chkeq c29, c16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010b6
	ldr x1, =check_data0
	ldr x2, =0x000010b8
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x004ffffe
	ldr x1, =check_data2
	ldr x2, =0x004fffff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr ddc_el3, c13
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

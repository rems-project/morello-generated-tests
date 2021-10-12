.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x07, 0xa0, 0x02, 0xc0, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data1:
	.byte 0x01, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data2:
	.byte 0x60
.data
check_data3:
	.byte 0x1e, 0x78, 0xd0, 0xc2, 0x21, 0x32, 0xc6, 0xc2, 0xff, 0xb3, 0xc0, 0xc2, 0x5a, 0x33, 0xc7, 0xc2
	.byte 0x46, 0x65, 0xcc, 0xc2, 0x41, 0x6b, 0x21, 0xa2, 0x61, 0x71, 0xb3, 0x02, 0xc1, 0x33, 0x93, 0x22
	.byte 0x01, 0x5c, 0x5b, 0x0a, 0xbe, 0xa2, 0x0a, 0x38, 0xe0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800500070000000000001000
	/* C10 */
	.octa 0x200f400f00ffffffffff2000
	/* C11 */
	.octa 0xc002a0070040000000000ce0
	/* C12 */
	.octa 0x0
	/* C17 */
	.octa 0x4000000000000000000000001801
	/* C21 */
	.octa 0x1f54
	/* C26 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x800500070000000000001000
	/* C1 */
	.octa 0x0
	/* C6 */
	.octa 0x200f400f0000000000000000
	/* C10 */
	.octa 0x200f400f00ffffffffff2000
	/* C11 */
	.octa 0xc002a0070040000000000ce0
	/* C12 */
	.octa 0x0
	/* C17 */
	.octa 0x4000000000000000000000001801
	/* C21 */
	.octa 0x1f54
	/* C26 */
	.octa 0xffffffffffffffff
	/* C30 */
	.octa 0x1260
initial_SP_EL3_value:
	.octa 0x3fff800000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x4c000000000940050080000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d0781e // SCBNDS-C.CI-S Cd:30 Cn:0 1110:1110 S:1 imm6:100000 11000010110:11000010110
	.inst 0xc2c63221 // CLRPERM-C.CI-C Cd:1 Cn:17 100:100 perm:001 1100001011000110:1100001011000110
	.inst 0xc2c0b3ff // GCSEAL-R.C-C Rd:31 Cn:31 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xc2c7335a // RRMASK-R.R-C Rd:26 Rn:26 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0xc2cc6546 // CPYVALUE-C.C-C Cd:6 Cn:10 001:001 opc:11 0:0 Cm:12 11000010110:11000010110
	.inst 0xa2216b41 // STR-C.RRB-C Ct:1 Rn:26 10:10 S:0 option:011 Rm:1 1:1 opc:00 10100010:10100010
	.inst 0x02b37161 // SUB-C.CIS-C Cd:1 Cn:11 imm12:110011011100 sh:0 A:1 00000010:00000010
	.inst 0x229333c1 // STP-CC.RIAW-C Ct:1 Rn:30 Ct2:01100 imm7:0100110 L:0 001000101:001000101
	.inst 0x0a5b5c01 // and_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:0 imm6:010111 Rm:27 N:0 shift:01 01010:01010 opc:00 sf:0
	.inst 0x380aa2be // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:21 00:00 imm9:010101010 0:0 opc:00 111000:111000 size:00
	.inst 0xc2c211e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x19, cptr_el3
	orr x19, x19, #0x200
	msr cptr_el3, x19
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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc240066a // ldr c10, [x19, #1]
	.inst 0xc2400a6b // ldr c11, [x19, #2]
	.inst 0xc2400e6c // ldr c12, [x19, #3]
	.inst 0xc2401271 // ldr c17, [x19, #4]
	.inst 0xc2401675 // ldr c21, [x19, #5]
	.inst 0xc2401a7a // ldr c26, [x19, #6]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =initial_SP_EL3_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2c1d27f // cpy c31, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30850032
	msr SCTLR_EL3, x19
	ldr x19, =0x0
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031f3 // ldr c19, [c15, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x826011f3 // ldr c19, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc240026f // ldr c15, [x19, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240066f // ldr c15, [x19, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc2400a6f // ldr c15, [x19, #2]
	.inst 0xc2cfa4c1 // chkeq c6, c15
	b.ne comparison_fail
	.inst 0xc2400e6f // ldr c15, [x19, #3]
	.inst 0xc2cfa541 // chkeq c10, c15
	b.ne comparison_fail
	.inst 0xc240126f // ldr c15, [x19, #4]
	.inst 0xc2cfa561 // chkeq c11, c15
	b.ne comparison_fail
	.inst 0xc240166f // ldr c15, [x19, #5]
	.inst 0xc2cfa581 // chkeq c12, c15
	b.ne comparison_fail
	.inst 0xc2401a6f // ldr c15, [x19, #6]
	.inst 0xc2cfa621 // chkeq c17, c15
	b.ne comparison_fail
	.inst 0xc2401e6f // ldr c15, [x19, #7]
	.inst 0xc2cfa6a1 // chkeq c21, c15
	b.ne comparison_fail
	.inst 0xc240226f // ldr c15, [x19, #8]
	.inst 0xc2cfa741 // chkeq c26, c15
	b.ne comparison_fail
	.inst 0xc240266f // ldr c15, [x19, #9]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001800
	ldr x1, =check_data1
	ldr x2, =0x00001810
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
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

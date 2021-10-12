.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0xff, 0x8f, 0x5f, 0xf8, 0x62, 0xa1, 0x4e, 0xa2, 0xc4, 0x23, 0x21, 0x2b, 0xe6, 0x0c, 0x22, 0x37
	.byte 0xd6, 0x67, 0x04, 0xa2, 0xa0, 0x69, 0xc0, 0xc2, 0x2d, 0x45, 0xd0, 0x54, 0x1e, 0x22, 0xdf, 0x1a
	.byte 0x62, 0xa3, 0xd0, 0xc2, 0xe0, 0x87, 0x73, 0x79, 0x80, 0x12, 0xc2, 0xc2
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xa27b
	/* C6 */
	.octa 0x0
	/* C11 */
	.octa 0x3fff46
	/* C13 */
	.octa 0x3fff800000000000000000000000
	/* C22 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xa27b
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0xb27b
	/* C6 */
	.octa 0x0
	/* C11 */
	.octa 0x3fff46
	/* C13 */
	.octa 0x3fff800000000000000000000000
	/* C22 */
	.octa 0x0
	/* C27 */
	.octa 0x0
initial_csp_value:
	.octa 0x400800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000008100000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc100000000300070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf85f8fff // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:31 11:11 imm9:111111000 0:0 opc:01 111000:111000 size:11
	.inst 0xa24ea162 // LDUR-C.RI-C Ct:2 Rn:11 00:00 imm9:011101010 0:0 opc:01 10100010:10100010
	.inst 0x2b2123c4 // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:4 Rn:30 imm3:000 option:001 Rm:1 01011001:01011001 S:1 op:0 sf:0
	.inst 0x37220ce6 // tbnz:aarch64/instrs/branch/conditional/test Rt:6 imm14:01000001100111 b40:00100 op:1 011011:011011 b5:0
	.inst 0xa20467d6 // STR-C.RIAW-C Ct:22 Rn:30 01:01 imm9:001000110 0:0 opc:00 10100010:10100010
	.inst 0xc2c069a0 // ORRFLGS-C.CR-C Cd:0 Cn:13 1010:1010 opc:01 Rm:0 11000010110:11000010110
	.inst 0x54d0452d // b_cond:aarch64/instrs/branch/conditional/cond cond:1101 0:0 imm19:1101000001000101001 01010100:01010100
	.inst 0x1adf221e // lslv:aarch64/instrs/integer/shift/variable Rd:30 Rn:16 op2:00 0010:0010 Rm:31 0011010110:0011010110 sf:0
	.inst 0xc2d0a362 // CLRPERM-C.CR-C Cd:2 Cn:27 000:000 1:1 10:10 Rm:16 11000010110:11000010110
	.inst 0x797387e0 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:31 imm12:110011100001 opc:01 111001:111001 size:01
	.inst 0xc2c21280
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
	ldr x19, =initial_cap_values
	.inst 0xc2400261 // ldr c1, [x19, #0]
	.inst 0xc2400666 // ldr c6, [x19, #1]
	.inst 0xc2400a6b // ldr c11, [x19, #2]
	.inst 0xc2400e6d // ldr c13, [x19, #3]
	.inst 0xc2401276 // ldr c22, [x19, #4]
	.inst 0xc240167b // ldr c27, [x19, #5]
	.inst 0xc2401a7e // ldr c30, [x19, #6]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =initial_csp_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2c1d27f // cpy c31, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	ldr x19, =0x0
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82603293 // ldr c19, [c20, #3]
	.inst 0xc28b4133 // msr ddc_el3, c19
	isb
	.inst 0x82601293 // ldr c19, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr ddc_el3, c19
	isb
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x20, #0xf
	and x19, x19, x20
	cmp x19, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400274 // ldr c20, [x19, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400674 // ldr c20, [x19, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400a74 // ldr c20, [x19, #2]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400e74 // ldr c20, [x19, #3]
	.inst 0xc2d4a481 // chkeq c4, c20
	b.ne comparison_fail
	.inst 0xc2401274 // ldr c20, [x19, #4]
	.inst 0xc2d4a4c1 // chkeq c6, c20
	b.ne comparison_fail
	.inst 0xc2401674 // ldr c20, [x19, #5]
	.inst 0xc2d4a561 // chkeq c11, c20
	b.ne comparison_fail
	.inst 0xc2401a74 // ldr c20, [x19, #6]
	.inst 0xc2d4a5a1 // chkeq c13, c20
	b.ne comparison_fail
	.inst 0xc2401e74 // ldr c20, [x19, #7]
	.inst 0xc2d4a6c1 // chkeq c22, c20
	b.ne comparison_fail
	.inst 0xc2402274 // ldr c20, [x19, #8]
	.inst 0xc2d4a761 // chkeq c27, c20
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
	ldr x0, =0x00400030
	ldr x1, =check_data2
	ldr x2, =0x00400040
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004007f8
	ldr x1, =check_data3
	ldr x2, =0x00400800
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004021ba
	ldr x1, =check_data4
	ldr x2, =0x004021bc
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
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr ddc_el3, c19
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

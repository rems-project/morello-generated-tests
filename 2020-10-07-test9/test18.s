.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0xc0, 0x32, 0xc7, 0xc2, 0x28, 0x1f, 0x3e, 0xca, 0x22, 0xc3, 0x91, 0xf8, 0xbe, 0xce, 0x8a, 0x82
	.byte 0x1e, 0x01, 0x0b, 0x5a, 0x9a, 0xca, 0x98, 0xb8, 0x2f, 0x00, 0x18, 0x3a, 0x01, 0xa4, 0xc0, 0xc2
	.byte 0xdb, 0xb7, 0x65, 0xe2, 0x01, 0x7f, 0x7f, 0x31, 0x20, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C10 */
	.octa 0x1b000000
	/* C11 */
	.octa 0xffffe09d
	/* C20 */
	.octa 0x80000000000100050000000000002000
	/* C21 */
	.octa 0xffffffffe5001000
	/* C22 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xffffffffffffffff
	/* C8 */
	.octa 0xffffffffffffffff
	/* C10 */
	.octa 0x1b000000
	/* C11 */
	.octa 0xffffe09d
	/* C20 */
	.octa 0x80000000000100050000000000002000
	/* C21 */
	.octa 0xffffffffe5001000
	/* C22 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x1f61
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000003000500ff800000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c732c0 // RRMASK-R.R-C Rd:0 Rn:22 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0xca3e1f28 // eon:aarch64/instrs/integer/logical/shiftedreg Rd:8 Rn:25 imm6:000111 Rm:30 N:1 shift:00 01010:01010 opc:10 sf:1
	.inst 0xf891c322 // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:25 00:00 imm9:100011100 0:0 opc:10 111000:111000 size:11
	.inst 0x828acebe // ASTRH-R.RRB-32 Rt:30 Rn:21 opc:11 S:0 option:110 Rm:10 0:0 L:0 100000101:100000101
	.inst 0x5a0b011e // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:30 Rn:8 000000:000000 Rm:11 11010000:11010000 S:0 op:1 sf:0
	.inst 0xb898ca9a // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:26 Rn:20 10:10 imm9:110001100 0:0 opc:10 111000:111000 size:10
	.inst 0x3a18002f // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:15 Rn:1 000000:000000 Rm:24 11010000:11010000 S:1 op:0 sf:0
	.inst 0xc2c0a401 // CHKEQ-_.CC-C 00001:00001 Cn:0 001:001 opc:01 1:1 Cm:0 11000010110:11000010110
	.inst 0xe265b7db // ALDUR-V.RI-H Rt:27 Rn:30 op2:01 imm9:001011011 V:1 op1:01 11100010:11100010
	.inst 0x317f7f01 // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:1 Rn:24 imm12:111111011111 sh:1 0:0 10001:10001 S:1 op:0 sf:0
	.inst 0xc2c21120
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x27, cptr_el3
	orr x27, x27, #0x200
	msr cptr_el3, x27
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
	ldr x27, =initial_cap_values
	.inst 0xc240036a // ldr c10, [x27, #0]
	.inst 0xc240076b // ldr c11, [x27, #1]
	.inst 0xc2400b74 // ldr c20, [x27, #2]
	.inst 0xc2400f75 // ldr c21, [x27, #3]
	.inst 0xc2401376 // ldr c22, [x27, #4]
	.inst 0xc2401779 // ldr c25, [x27, #5]
	.inst 0xc2401b7e // ldr c30, [x27, #6]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30850032
	msr SCTLR_EL3, x27
	ldr x27, =0x0
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x8260313b // ldr c27, [c9, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x8260113b // ldr c27, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400369 // ldr c9, [x27, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400769 // ldr c9, [x27, #1]
	.inst 0xc2c9a501 // chkeq c8, c9
	b.ne comparison_fail
	.inst 0xc2400b69 // ldr c9, [x27, #2]
	.inst 0xc2c9a541 // chkeq c10, c9
	b.ne comparison_fail
	.inst 0xc2400f69 // ldr c9, [x27, #3]
	.inst 0xc2c9a561 // chkeq c11, c9
	b.ne comparison_fail
	.inst 0xc2401369 // ldr c9, [x27, #4]
	.inst 0xc2c9a681 // chkeq c20, c9
	b.ne comparison_fail
	.inst 0xc2401769 // ldr c9, [x27, #5]
	.inst 0xc2c9a6a1 // chkeq c21, c9
	b.ne comparison_fail
	.inst 0xc2401b69 // ldr c9, [x27, #6]
	.inst 0xc2c9a6c1 // chkeq c22, c9
	b.ne comparison_fail
	.inst 0xc2401f69 // ldr c9, [x27, #7]
	.inst 0xc2c9a721 // chkeq c25, c9
	b.ne comparison_fail
	.inst 0xc2402369 // ldr c9, [x27, #8]
	.inst 0xc2c9a741 // chkeq c26, c9
	b.ne comparison_fail
	.inst 0xc2402769 // ldr c9, [x27, #9]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check vector registers */
	ldr x27, =0x0
	mov x9, v27.d[0]
	cmp x27, x9
	b.ne comparison_fail
	ldr x27, =0x0
	mov x9, v27.d[1]
	cmp x27, x9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001f8c
	ldr x1, =check_data1
	ldr x2, =0x00001f90
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fbc
	ldr x1, =check_data2
	ldr x2, =0x00001fbe
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
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
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

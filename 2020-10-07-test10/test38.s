.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0xc2, 0x0b, 0xed, 0xc2, 0x4f, 0x32, 0xc5, 0xc2, 0xdb, 0x7f, 0x5a, 0x9b, 0xc0, 0x6b, 0xc2, 0xc2
	.byte 0x22, 0x30, 0xc2, 0xc2
.data
check_data2:
	.byte 0x02, 0x20, 0xc0, 0xc2, 0x1e, 0x60, 0xde, 0xc2, 0x54, 0x99, 0x13, 0x2d, 0x81, 0x00, 0x9b, 0xf8
	.byte 0x21, 0x02, 0xc0, 0xc2, 0x20, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x20008000000100050000000000400019
	/* C10 */
	.octa 0x40000000000100050000000000001000
	/* C17 */
	.octa 0x70000000000000000
	/* C18 */
	.octa 0x0
	/* C30 */
	.octa 0x800120470000000000000000
final_cap_values:
	/* C0 */
	.octa 0x800120476800000000000000
	/* C1 */
	.octa 0x280100070000000000000000
	/* C2 */
	.octa 0x900168076800000000000000
	/* C10 */
	.octa 0x40000000000100050000000000001000
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x70000000000000000
	/* C18 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x800120472040000000400015
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080002000e0000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2ed0bc2 // ORRFLGS-C.CI-C Cd:2 Cn:30 0:0 01:01 imm8:01101000 11000010111:11000010111
	.inst 0xc2c5324f // CVTP-R.C-C Rd:15 Cn:18 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0x9b5a7fdb // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:27 Rn:30 Ra:11111 0:0 Rm:26 10:10 U:0 10011011:10011011
	.inst 0xc2c26bc0 // ORRFLGS-C.CR-C Cd:0 Cn:30 1010:1010 opc:01 Rm:2 11000010110:11000010110
	.inst 0xc2c23022 // BLRS-C-C 00010:00010 Cn:1 100:100 opc:01 11000010110000100:11000010110000100
	.zero 4
	.inst 0xc2c02002 // SCBNDSE-C.CR-C Cd:2 Cn:0 000:000 opc:01 0:0 Rm:0 11000010110:11000010110
	.inst 0xc2de601e // SCOFF-C.CR-C Cd:30 Cn:0 000:000 opc:11 0:0 Rm:30 11000010110:11000010110
	.inst 0x2d139954 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:20 Rn:10 Rt2:00110 imm7:0100111 L:0 1011010:1011010 opc:00
	.inst 0xf89b0081 // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:4 00:00 imm9:110110000 0:0 opc:10 111000:111000 size:11
	.inst 0xc2c00221 // SCBNDS-C.CR-C Cd:1 Cn:17 000:000 opc:00 0:0 Rm:0 11000010110:11000010110
	.inst 0xc2c21320
	.zero 1048528
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x29, cptr_el3
	orr x29, x29, #0x200
	msr cptr_el3, x29
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
	ldr x29, =initial_cap_values
	.inst 0xc24003a1 // ldr c1, [x29, #0]
	.inst 0xc24007aa // ldr c10, [x29, #1]
	.inst 0xc2400bb1 // ldr c17, [x29, #2]
	.inst 0xc2400fb2 // ldr c18, [x29, #3]
	.inst 0xc24013be // ldr c30, [x29, #4]
	/* Vector registers */
	mrs x29, cptr_el3
	bfc x29, #10, #1
	msr cptr_el3, x29
	isb
	ldr q6, =0x0
	ldr q20, =0x0
	/* Set up flags and system registers */
	mov x29, #0x00000000
	msr nzcv, x29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x30850030
	msr SCTLR_EL3, x29
	ldr x29, =0x0
	msr S3_6_C1_C2_2, x29 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x8260133d // ldr c29, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c213a0 // br c29
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	/* Check processor flags */
	mrs x29, nzcv
	ubfx x29, x29, #28, #4
	mov x25, #0xf
	and x29, x29, x25
	cmp x29, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003b9 // ldr c25, [x29, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc24007b9 // ldr c25, [x29, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400bb9 // ldr c25, [x29, #2]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400fb9 // ldr c25, [x29, #3]
	.inst 0xc2d9a541 // chkeq c10, c25
	b.ne comparison_fail
	.inst 0xc24013b9 // ldr c25, [x29, #4]
	.inst 0xc2d9a5e1 // chkeq c15, c25
	b.ne comparison_fail
	.inst 0xc24017b9 // ldr c25, [x29, #5]
	.inst 0xc2d9a621 // chkeq c17, c25
	b.ne comparison_fail
	.inst 0xc2401bb9 // ldr c25, [x29, #6]
	.inst 0xc2d9a641 // chkeq c18, c25
	b.ne comparison_fail
	.inst 0xc2401fb9 // ldr c25, [x29, #7]
	.inst 0xc2d9a761 // chkeq c27, c25
	b.ne comparison_fail
	.inst 0xc24023b9 // ldr c25, [x29, #8]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check vector registers */
	ldr x29, =0x0
	mov x25, v6.d[0]
	cmp x29, x25
	b.ne comparison_fail
	ldr x29, =0x0
	mov x25, v6.d[1]
	cmp x29, x25
	b.ne comparison_fail
	ldr x29, =0x0
	mov x25, v20.d[0]
	cmp x29, x25
	b.ne comparison_fail
	ldr x29, =0x0
	mov x25, v20.d[1]
	cmp x29, x25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000109c
	ldr x1, =check_data0
	ldr x2, =0x000010a4
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x00400014
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400018
	ldr x1, =check_data2
	ldr x2, =0x00400030
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
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
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

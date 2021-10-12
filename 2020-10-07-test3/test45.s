.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x50, 0x18, 0xa1, 0x8a, 0xdc, 0x83, 0xde, 0xc2, 0xea, 0x7f, 0x15, 0x9b, 0xc1, 0x7f, 0x41, 0x9b
	.byte 0x22, 0x13, 0xc5, 0xc2, 0xfe, 0xd3, 0xc1, 0xc2, 0x3f, 0x02, 0xc0, 0x5a, 0x20, 0x68, 0xc1, 0xc2
	.byte 0x37, 0x97, 0x9f, 0xeb, 0x5b, 0x7c, 0x1f, 0x42, 0xe0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C25 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000600170000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000400110000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x8aa11850 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:16 Rn:2 imm6:000110 Rm:1 N:1 shift:10 01010:01010 opc:00 sf:1
	.inst 0xc2de83dc // SCTAG-C.CR-C Cd:28 Cn:30 000:000 0:0 10:10 Rm:30 11000010110:11000010110
	.inst 0x9b157fea // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:10 Rn:31 Ra:31 o0:0 Rm:21 0011011000:0011011000 sf:1
	.inst 0x9b417fc1 // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:1 Rn:30 Ra:11111 0:0 Rm:1 10:10 U:0 10011011:10011011
	.inst 0xc2c51322 // CVTD-R.C-C Rd:2 Cn:25 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0xc2c1d3fe // CPY-C.C-C Cd:30 Cn:31 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0x5ac0023f // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:31 Rn:17 101101011000000000000:101101011000000000000 sf:0
	.inst 0xc2c16820 // ORRFLGS-C.CR-C Cd:0 Cn:1 1010:1010 opc:01 Rm:1 11000010110:11000010110
	.inst 0xeb9f9737 // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:23 Rn:25 imm6:100101 Rm:31 0:0 shift:10 01011:01011 S:1 op:1 sf:1
	.inst 0x421f7c5b // ASTLR-C.R-C Ct:27 Rn:2 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xc2c210e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x20, cptr_el3
	orr x20, x20, #0x200
	msr cptr_el3, x20
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
	ldr x20, =initial_cap_values
	.inst 0xc2400299 // ldr c25, [x20, #0]
	.inst 0xc240069b // ldr c27, [x20, #1]
	.inst 0xc2400a9e // ldr c30, [x20, #2]
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
	ldr x20, =0x4
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030f4 // ldr c20, [c7, #3]
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	.inst 0x826010f4 // ldr c20, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	/* Check processor flags */
	mrs x20, nzcv
	ubfx x20, x20, #28, #4
	mov x7, #0xf
	and x20, x20, x7
	cmp x20, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc2400287 // ldr c7, [x20, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400687 // ldr c7, [x20, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400a87 // ldr c7, [x20, #2]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400e87 // ldr c7, [x20, #3]
	.inst 0xc2c7a541 // chkeq c10, c7
	b.ne comparison_fail
	.inst 0xc2401287 // ldr c7, [x20, #4]
	.inst 0xc2c7a6e1 // chkeq c23, c7
	b.ne comparison_fail
	.inst 0xc2401687 // ldr c7, [x20, #5]
	.inst 0xc2c7a721 // chkeq c25, c7
	b.ne comparison_fail
	.inst 0xc2401a87 // ldr c7, [x20, #6]
	.inst 0xc2c7a761 // chkeq c27, c7
	b.ne comparison_fail
	.inst 0xc2401e87 // ldr c7, [x20, #7]
	.inst 0xc2c7a781 // chkeq c28, c7
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
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

.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x31, 0x71, 0x00, 0x00, 0x00, 0x00, 0x19, 0x00, 0xb9, 0x00, 0x13, 0x42, 0x00
	.byte 0x00, 0x00, 0x50, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x11
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0xd7, 0x0f, 0x43, 0x93, 0x3f, 0xf8, 0x62, 0xa2, 0x4c, 0x54, 0x4c, 0x2a, 0x1c, 0xf0, 0x9e, 0x6c
	.byte 0x7f, 0x7c, 0x47, 0xb8, 0x37, 0x69, 0x4b, 0xb8, 0x30, 0x84, 0x18, 0xf1, 0x60, 0xc2, 0x21, 0x8b
	.byte 0xa0, 0x08, 0x85, 0xac, 0x61, 0x67, 0x5a, 0x39, 0x40, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x5f5b7a1bfb100010
	/* C2 */
	.octa 0xa0a485e404f0180
	/* C3 */
	.octa 0x1001
	/* C5 */
	.octa 0x1000
	/* C9 */
	.octa 0x1006
	/* C27 */
	.octa 0x973
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xa0a485e404f0180
	/* C3 */
	.octa 0x1078
	/* C5 */
	.octa 0x10a0
	/* C9 */
	.octa 0x1006
	/* C16 */
	.octa 0x5f5b7a1bfb0ff9ef
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0x973
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc01000002001400500fd3ff8000e4021
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x93430fd7 // sbfm:aarch64/instrs/integer/bitfield Rd:23 Rn:30 imms:000011 immr:000011 N:1 100110:100110 opc:00 sf:1
	.inst 0xa262f83f // LDR-C.RRB-C Ct:31 Rn:1 10:10 S:1 option:111 Rm:2 1:1 opc:01 10100010:10100010
	.inst 0x2a4c544c // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:12 Rn:2 imm6:010101 Rm:12 N:0 shift:01 01010:01010 opc:01 sf:0
	.inst 0x6c9ef01c // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:28 Rn:0 Rt2:11100 imm7:0111101 L:0 1011001:1011001 opc:01
	.inst 0xb8477c7f // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:3 11:11 imm9:001110111 0:0 opc:01 111000:111000 size:10
	.inst 0xb84b6937 // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:23 Rn:9 10:10 imm9:010110110 0:0 opc:01 111000:111000 size:10
	.inst 0xf1188430 // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:16 Rn:1 imm12:011000100001 sh:0 0:0 10001:10001 S:1 op:1 sf:1
	.inst 0x8b21c260 // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:0 Rn:19 imm3:000 option:110 Rm:1 01011001:01011001 S:0 op:0 sf:1
	.inst 0xac8508a0 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:0 Rn:5 Rt2:00010 imm7:0001010 L:0 1011001:1011001 opc:10
	.inst 0x395a6761 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:27 imm12:011010011001 opc:01 111001:111001 size:00
	.inst 0xc2c21140
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x21, cptr_el3
	orr x21, x21, #0x200
	msr cptr_el3, x21
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a0 // ldr c0, [x21, #0]
	.inst 0xc24006a1 // ldr c1, [x21, #1]
	.inst 0xc2400aa2 // ldr c2, [x21, #2]
	.inst 0xc2400ea3 // ldr c3, [x21, #3]
	.inst 0xc24012a5 // ldr c5, [x21, #4]
	.inst 0xc24016a9 // ldr c9, [x21, #5]
	.inst 0xc2401abb // ldr c27, [x21, #6]
	/* Vector registers */
	mrs x21, cptr_el3
	bfc x21, #10, #1
	msr cptr_el3, x21
	isb
	ldr q0, =0x421300b90019000000007131000000
	ldr q2, =0x11000000000000000000000000500000
	ldr q28, =0x0
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	ldr x21, =0x4
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603155 // ldr c21, [c10, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x82601155 // ldr c21, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	/* Check processor flags */
	mrs x21, nzcv
	ubfx x21, x21, #28, #4
	mov x10, #0xf
	and x21, x21, x10
	cmp x21, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002aa // ldr c10, [x21, #0]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc24006aa // ldr c10, [x21, #1]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400aaa // ldr c10, [x21, #2]
	.inst 0xc2caa461 // chkeq c3, c10
	b.ne comparison_fail
	.inst 0xc2400eaa // ldr c10, [x21, #3]
	.inst 0xc2caa4a1 // chkeq c5, c10
	b.ne comparison_fail
	.inst 0xc24012aa // ldr c10, [x21, #4]
	.inst 0xc2caa521 // chkeq c9, c10
	b.ne comparison_fail
	.inst 0xc24016aa // ldr c10, [x21, #5]
	.inst 0xc2caa601 // chkeq c16, c10
	b.ne comparison_fail
	.inst 0xc2401aaa // ldr c10, [x21, #6]
	.inst 0xc2caa6e1 // chkeq c23, c10
	b.ne comparison_fail
	.inst 0xc2401eaa // ldr c10, [x21, #7]
	.inst 0xc2caa761 // chkeq c27, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x21, =0x7131000000
	mov x10, v0.d[0]
	cmp x21, x10
	b.ne comparison_fail
	ldr x21, =0x421300b9001900
	mov x10, v0.d[1]
	cmp x21, x10
	b.ne comparison_fail
	ldr x21, =0x500000
	mov x10, v2.d[0]
	cmp x21, x10
	b.ne comparison_fail
	ldr x21, =0x1100000000000000
	mov x10, v2.d[1]
	cmp x21, x10
	b.ne comparison_fail
	ldr x21, =0x0
	mov x10, v28.d[0]
	cmp x21, x10
	b.ne comparison_fail
	ldr x21, =0x0
	mov x10, v28.d[1]
	cmp x21, x10
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
	ldr x0, =0x00001078
	ldr x1, =check_data1
	ldr x2, =0x0000107c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010bc
	ldr x1, =check_data2
	ldr x2, =0x000010c0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001810
	ldr x1, =check_data3
	ldr x2, =0x00001820
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
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

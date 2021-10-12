.section data0, #alloc, #write
	.zero 256
	.byte 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3824
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0xff, 0xff
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xd1, 0x0b, 0xb7, 0x9b, 0xdb, 0xfb, 0x7e, 0x38, 0x04, 0x12, 0xa2, 0x78, 0x60, 0xe0, 0xdc, 0xc2
	.byte 0x1d, 0x29, 0xc1, 0xc2, 0x1f, 0xc1, 0x44, 0x69, 0x34, 0x74, 0x16, 0xe2, 0x01, 0x28, 0x3b, 0x9b
	.byte 0xe5, 0x7f, 0xe6, 0xa2, 0x81, 0x28, 0xde, 0xc2, 0x40, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x80000000000100050000000000002097
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0xffffffffffffffffffffffffffffffff
	/* C8 */
	.octa 0x1010
	/* C16 */
	.octa 0x1100
	/* C30 */
	.octa 0x800
final_cap_values:
	/* C1 */
	.octa 0xffff
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0xffff
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C8 */
	.octa 0x1010
	/* C16 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x1010
	/* C30 */
	.octa 0x800
initial_SP_EL3_value:
	.octa 0x4fffe0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0100000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9bb70bd1 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:17 Rn:30 Ra:2 o0:0 Rm:23 01:01 U:1 10011011:10011011
	.inst 0x387efbdb // ldrb_reg:aarch64/instrs/memory/single/general/register Rt:27 Rn:30 10:10 S:1 option:111 Rm:30 1:1 opc:01 111000:111000 size:00
	.inst 0x78a21204 // ldclrh:aarch64/instrs/memory/atomicops/ld Rt:4 Rn:16 00:00 opc:001 0:0 Rs:2 1:1 R:0 A:1 111000:111000 size:01
	.inst 0xc2dce060 // SCFLGS-C.CR-C Cd:0 Cn:3 111000:111000 Rm:28 11000010110:11000010110
	.inst 0xc2c1291d // BICFLGS-C.CR-C Cd:29 Cn:8 1010:1010 opc:00 Rm:1 11000010110:11000010110
	.inst 0x6944c11f // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:31 Rn:8 Rt2:10000 imm7:0001001 L:1 1010010:1010010 opc:01
	.inst 0xe2167434 // ALDURB-R.RI-32 Rt:20 Rn:1 op2:01 imm9:101100111 V:0 op1:00 11100010:11100010
	.inst 0x9b3b2801 // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:1 Rn:0 Ra:10 o0:0 Rm:27 01:01 U:0 10011011:10011011
	.inst 0xa2e67fe5 // CASA-C.R-C Ct:5 Rn:31 11111:11111 R:0 Cs:6 1:1 L:1 1:1 10100010:10100010
	.inst 0xc2de2881 // BICFLGS-C.CR-C Cd:1 Cn:4 1010:1010 opc:00 Rm:30 11000010110:11000010110
	.inst 0xc2c21240
	.zero 1048532
.text
.global preamble
preamble:
	/* Ensure Morello is on */
	mov x0, 0x200
	msr cptr_el3, x0
	isb
	/* Set exception handler */
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	mov x0, #0xff
	msr mair_el3, x0
	ldr x0, =0x0d001519
	msr tcr_el3, x0
	isb
	tlbi alle3
	dsb sy
	isb
	/* Write tags to memory */
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
	ldr x25, =initial_cap_values
	.inst 0xc2400321 // ldr c1, [x25, #0]
	.inst 0xc2400722 // ldr c2, [x25, #1]
	.inst 0xc2400b23 // ldr c3, [x25, #2]
	.inst 0xc2400f25 // ldr c5, [x25, #3]
	.inst 0xc2401326 // ldr c6, [x25, #4]
	.inst 0xc2401728 // ldr c8, [x25, #5]
	.inst 0xc2401b30 // ldr c16, [x25, #6]
	.inst 0xc2401f3e // ldr c30, [x25, #7]
	/* Set up flags and system registers */
	mov x25, #0x00000000
	msr nzcv, x25
	ldr x25, =initial_SP_EL3_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2c1d33f // cpy c31, c25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x3085103d
	msr SCTLR_EL3, x25
	ldr x25, =0x0
	msr S3_6_C1_C2_2, x25 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82603259 // ldr c25, [c18, #3]
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	.inst 0x82601259 // ldr c25, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c21320 // br c25
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30851035
	msr SCTLR_EL3, x25
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400332 // ldr c18, [x25, #0]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400732 // ldr c18, [x25, #1]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400b32 // ldr c18, [x25, #2]
	.inst 0xc2d2a461 // chkeq c3, c18
	b.ne comparison_fail
	.inst 0xc2400f32 // ldr c18, [x25, #3]
	.inst 0xc2d2a481 // chkeq c4, c18
	b.ne comparison_fail
	.inst 0xc2401332 // ldr c18, [x25, #4]
	.inst 0xc2d2a4a1 // chkeq c5, c18
	b.ne comparison_fail
	.inst 0xc2401732 // ldr c18, [x25, #5]
	.inst 0xc2d2a4c1 // chkeq c6, c18
	b.ne comparison_fail
	.inst 0xc2401b32 // ldr c18, [x25, #6]
	.inst 0xc2d2a501 // chkeq c8, c18
	b.ne comparison_fail
	.inst 0xc2401f32 // ldr c18, [x25, #7]
	.inst 0xc2d2a601 // chkeq c16, c18
	b.ne comparison_fail
	.inst 0xc2402332 // ldr c18, [x25, #8]
	.inst 0xc2d2a681 // chkeq c20, c18
	b.ne comparison_fail
	.inst 0xc2402732 // ldr c18, [x25, #9]
	.inst 0xc2d2a761 // chkeq c27, c18
	b.ne comparison_fail
	.inst 0xc2402b32 // ldr c18, [x25, #10]
	.inst 0xc2d2a7a1 // chkeq c29, c18
	b.ne comparison_fail
	.inst 0xc2402f32 // ldr c18, [x25, #11]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001034
	ldr x1, =check_data1
	ldr x2, =0x0000103c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001102
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
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
	ldr x0, =0x004fffe0
	ldr x1, =check_data5
	ldr x2, =0x004ffff0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
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

.section vector_table, #alloc, #execinstr
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

	/* Translation table, single entry, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000701
	.fill 4088, 1, 0

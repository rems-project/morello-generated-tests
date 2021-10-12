.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x4d, 0x0e
.data
check_data3:
	.byte 0x4d, 0x0e, 0x00, 0x00
.data
check_data4:
	.byte 0xd3, 0x7f, 0x5f, 0x22, 0xde, 0x67, 0xcd, 0xc2, 0x14, 0x1c, 0x76, 0xea, 0x1e, 0xdc, 0x81, 0x82
	.byte 0xc2, 0x33, 0x0f, 0x78, 0xfe, 0xab, 0x4b, 0x82, 0x7c, 0x11, 0xc5, 0xc2, 0xce, 0x27, 0xde, 0x1a
	.byte 0x60, 0x53, 0xc1, 0xc2, 0x58, 0x20, 0xc1, 0xc2, 0xe0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000300070000000000000c90
	/* C1 */
	.octa 0x208
	/* C2 */
	.octa 0x1000000070000000000000000
	/* C11 */
	.octa 0x100
	/* C13 */
	.octa 0xe4d
	/* C22 */
	.octa 0x0
	/* C30 */
	.octa 0x2801200e0000000000000f20
final_cap_values:
	/* C1 */
	.octa 0x208
	/* C2 */
	.octa 0x1000000070000000000000000
	/* C11 */
	.octa 0x100
	/* C13 */
	.octa 0xe4d
	/* C14 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C20 */
	.octa 0xc90
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0x1420800000000000000000000
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x2801200e0000000000000e4d
initial_SP_EL3_value:
	.octa 0x400000000a0140050000000000001c10
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd00000000007010700ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword final_cap_values + 32
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x225f7fd3 // LDXR-C.R-C Ct:19 Rn:30 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0xc2cd67de // CPYVALUE-C.C-C Cd:30 Cn:30 001:001 opc:11 0:0 Cm:13 11000010110:11000010110
	.inst 0xea761c14 // bics:aarch64/instrs/integer/logical/shiftedreg Rd:20 Rn:0 imm6:000111 Rm:22 N:1 shift:01 01010:01010 opc:11 sf:1
	.inst 0x8281dc1e // ASTRH-R.RRB-32 Rt:30 Rn:0 opc:11 S:1 option:110 Rm:1 0:0 L:0 100000101:100000101
	.inst 0x780f33c2 // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:30 00:00 imm9:011110011 0:0 opc:00 111000:111000 size:01
	.inst 0x824babfe // ASTR-R.RI-32 Rt:30 Rn:31 op:10 imm9:010111010 L:0 1000001001:1000001001
	.inst 0xc2c5117c // CVTD-R.C-C Rd:28 Cn:11 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0x1ade27ce // lsrv:aarch64/instrs/integer/shift/variable Rd:14 Rn:30 op2:01 0010:0010 Rm:30 0011010110:0011010110 sf:0
	.inst 0xc2c15360 // CFHI-R.C-C Rd:0 Cn:27 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xc2c12058 // SCBNDSE-C.CR-C Cd:24 Cn:2 000:000 opc:01 0:0 Rm:1 11000010110:11000010110
	.inst 0xc2c210e0
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
	ldr x18, =initial_cap_values
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc2400641 // ldr c1, [x18, #1]
	.inst 0xc2400a42 // ldr c2, [x18, #2]
	.inst 0xc2400e4b // ldr c11, [x18, #3]
	.inst 0xc240124d // ldr c13, [x18, #4]
	.inst 0xc2401656 // ldr c22, [x18, #5]
	.inst 0xc2401a5e // ldr c30, [x18, #6]
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =initial_SP_EL3_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2c1d25f // cpy c31, c18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x3085103f
	msr SCTLR_EL3, x18
	ldr x18, =0x4
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030f2 // ldr c18, [c7, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x826010f2 // ldr c18, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	isb
	/* Check processor flags */
	mrs x18, nzcv
	ubfx x18, x18, #28, #4
	mov x7, #0xf
	and x18, x18, x7
	cmp x18, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc2400247 // ldr c7, [x18, #0]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400647 // ldr c7, [x18, #1]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400a47 // ldr c7, [x18, #2]
	.inst 0xc2c7a561 // chkeq c11, c7
	b.ne comparison_fail
	.inst 0xc2400e47 // ldr c7, [x18, #3]
	.inst 0xc2c7a5a1 // chkeq c13, c7
	b.ne comparison_fail
	.inst 0xc2401247 // ldr c7, [x18, #4]
	.inst 0xc2c7a5c1 // chkeq c14, c7
	b.ne comparison_fail
	.inst 0xc2401647 // ldr c7, [x18, #5]
	.inst 0xc2c7a661 // chkeq c19, c7
	b.ne comparison_fail
	.inst 0xc2401a47 // ldr c7, [x18, #6]
	.inst 0xc2c7a681 // chkeq c20, c7
	b.ne comparison_fail
	.inst 0xc2401e47 // ldr c7, [x18, #7]
	.inst 0xc2c7a6c1 // chkeq c22, c7
	b.ne comparison_fail
	.inst 0xc2402247 // ldr c7, [x18, #8]
	.inst 0xc2c7a701 // chkeq c24, c7
	b.ne comparison_fail
	.inst 0xc2402647 // ldr c7, [x18, #9]
	.inst 0xc2c7a781 // chkeq c28, c7
	b.ne comparison_fail
	.inst 0xc2402a47 // ldr c7, [x18, #10]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001020
	ldr x1, =check_data0
	ldr x2, =0x00001030
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001042
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010a0
	ldr x1, =check_data2
	ldr x2, =0x000010a2
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ef8
	ldr x1, =check_data3
	ldr x2, =0x00001efc
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
	/* Done print message */
	/* turn off MMU */
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
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

.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x68
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0xde, 0x33, 0xb8, 0xf8, 0x4a, 0x30, 0x25, 0x22, 0x02, 0xc8, 0x89, 0xb8, 0x15, 0x00, 0xc0, 0x5a
	.byte 0x20, 0x4f, 0x0b, 0x38, 0xa2, 0xef, 0x5a, 0xe2, 0x7e, 0x53, 0xc1, 0xc2, 0x01, 0x00, 0x1d, 0x3a
	.byte 0x7f, 0x7a, 0xcd, 0xc2, 0xc6, 0x8e, 0x64, 0x82, 0x60, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000007080700000000004f0768
	/* C2 */
	.octa 0x480000004000000400000000000013c0
	/* C10 */
	.octa 0x4000000000000000000000000000
	/* C12 */
	.octa 0x0
	/* C19 */
	.octa 0x1400000000000000000000000
	/* C22 */
	.octa 0x1000
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0x40000000540410800000000000001000
	/* C29 */
	.octa 0x107e
	/* C30 */
	.octa 0xc0000000720400240000000000001a20
final_cap_values:
	/* C0 */
	.octa 0x800000000007080700000000004f0768
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x1
	/* C6 */
	.octa 0x0
	/* C10 */
	.octa 0x4000000000000000000000000000
	/* C12 */
	.octa 0x0
	/* C19 */
	.octa 0x1400000000000000000000000
	/* C21 */
	.octa 0x16e0f200
	/* C22 */
	.octa 0x1000
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0x400000005404108000000000000010b4
	/* C29 */
	.octa 0x107e
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000408000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000002006000f0000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 112
	.dword initial_cap_values + 144
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf8b833de // ldset:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:30 00:00 opc:011 0:0 Rs:24 1:1 R:0 A:1 111000:111000 size:11
	.inst 0x2225304a // STXP-R.CR-C Ct:10 Rn:2 Ct2:01100 0:0 Rs:5 1:1 L:0 001000100:001000100
	.inst 0xb889c802 // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:0 10:10 imm9:010011100 0:0 opc:10 111000:111000 size:10
	.inst 0x5ac00015 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:21 Rn:0 101101011000000000000:101101011000000000000 sf:0
	.inst 0x380b4f20 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:25 11:11 imm9:010110100 0:0 opc:00 111000:111000 size:00
	.inst 0xe25aefa2 // ALDURSH-R.RI-32 Rt:2 Rn:29 op2:11 imm9:110101110 V:0 op1:01 11100010:11100010
	.inst 0xc2c1537e // CFHI-R.C-C Rd:30 Cn:27 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0x3a1d0001 // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:0 000000:000000 Rm:29 11010000:11010000 S:1 op:0 sf:0
	.inst 0xc2cd7a7f // SCBNDS-C.CI-S Cd:31 Cn:19 1110:1110 S:1 imm6:011010 11000010110:11000010110
	.inst 0x82648ec6 // ALDR-R.RI-64 Rt:6 Rn:22 op:11 imm9:001001000 L:1 1000001001:1000001001
	.inst 0xc2c21160
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
	ldr x4, =initial_cap_values
	.inst 0xc2400080 // ldr c0, [x4, #0]
	.inst 0xc2400482 // ldr c2, [x4, #1]
	.inst 0xc240088a // ldr c10, [x4, #2]
	.inst 0xc2400c8c // ldr c12, [x4, #3]
	.inst 0xc2401093 // ldr c19, [x4, #4]
	.inst 0xc2401496 // ldr c22, [x4, #5]
	.inst 0xc2401898 // ldr c24, [x4, #6]
	.inst 0xc2401c99 // ldr c25, [x4, #7]
	.inst 0xc240209d // ldr c29, [x4, #8]
	.inst 0xc240249e // ldr c30, [x4, #9]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	ldr x4, =0x0
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82603164 // ldr c4, [c11, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x82601164 // ldr c4, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	isb
	/* Check processor flags */
	mrs x4, nzcv
	ubfx x4, x4, #28, #4
	mov x11, #0xf
	and x4, x4, x11
	cmp x4, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc240008b // ldr c11, [x4, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc240048b // ldr c11, [x4, #1]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc240088b // ldr c11, [x4, #2]
	.inst 0xc2cba4a1 // chkeq c5, c11
	b.ne comparison_fail
	.inst 0xc2400c8b // ldr c11, [x4, #3]
	.inst 0xc2cba4c1 // chkeq c6, c11
	b.ne comparison_fail
	.inst 0xc240108b // ldr c11, [x4, #4]
	.inst 0xc2cba541 // chkeq c10, c11
	b.ne comparison_fail
	.inst 0xc240148b // ldr c11, [x4, #5]
	.inst 0xc2cba581 // chkeq c12, c11
	b.ne comparison_fail
	.inst 0xc240188b // ldr c11, [x4, #6]
	.inst 0xc2cba661 // chkeq c19, c11
	b.ne comparison_fail
	.inst 0xc2401c8b // ldr c11, [x4, #7]
	.inst 0xc2cba6a1 // chkeq c21, c11
	b.ne comparison_fail
	.inst 0xc240208b // ldr c11, [x4, #8]
	.inst 0xc2cba6c1 // chkeq c22, c11
	b.ne comparison_fail
	.inst 0xc240248b // ldr c11, [x4, #9]
	.inst 0xc2cba701 // chkeq c24, c11
	b.ne comparison_fail
	.inst 0xc240288b // ldr c11, [x4, #10]
	.inst 0xc2cba721 // chkeq c25, c11
	b.ne comparison_fail
	.inst 0xc2402c8b // ldr c11, [x4, #11]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000102c
	ldr x1, =check_data0
	ldr x2, =0x0000102e
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010b4
	ldr x1, =check_data1
	ldr x2, =0x000010b5
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001240
	ldr x1, =check_data2
	ldr x2, =0x00001248
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001a20
	ldr x1, =check_data3
	ldr x2, =0x00001a28
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
	ldr x0, =0x004f0804
	ldr x1, =check_data5
	ldr x2, =0x004f0808
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
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

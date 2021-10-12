.section data0, #alloc, #write
	.zero 4080
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x80
.data
check_data1:
	.byte 0xe0, 0x49, 0xb7, 0x79, 0xe0, 0xf3, 0xc0, 0xc2, 0xcd, 0x7d, 0xc0, 0x9b, 0xca, 0x51, 0x9d, 0x78
	.byte 0xc8, 0xb3, 0x5b, 0xba, 0xdd, 0xea, 0x3d, 0x4b, 0x3e, 0x04, 0xc0, 0xda, 0xe4, 0x2b, 0xd4, 0xc2
	.byte 0x7f, 0x52, 0x7f, 0xb8, 0xc0, 0x0f, 0xc0, 0xda, 0x40, 0x12, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc0, 0xc0
.data
check_data3:
	.byte 0xc0, 0xc0
.data
.balign 16
initial_cap_values:
	/* C14 */
	.octa 0x80000000000100050000000000400081
	/* C15 */
	.octa 0x80000000000180050000000000400820
	/* C19 */
	.octa 0xc0000000000100050000000000001ff8
final_cap_values:
	/* C4 */
	.octa 0x3fff800000000000000000000000
	/* C10 */
	.octa 0xffffffffffffc0c0
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x80000000000100050000000000400081
	/* C15 */
	.octa 0x80000000000180050000000000400820
	/* C19 */
	.octa 0xc0000000000100050000000000001ff8
initial_SP_EL3_value:
	.octa 0x3fff800000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x79b749e0 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:15 imm12:110111010010 opc:10 111001:111001 size:01
	.inst 0xc2c0f3e0 // GCTYPE-R.C-C Rd:0 Cn:31 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0x9bc07dcd // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:13 Rn:14 Ra:11111 0:0 Rm:0 10:10 U:1 10011011:10011011
	.inst 0x789d51ca // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:10 Rn:14 00:00 imm9:111010101 0:0 opc:10 111000:111000 size:01
	.inst 0xba5bb3c8 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1000 0:0 Rn:30 00:00 cond:1011 Rm:27 111010010:111010010 op:0 sf:1
	.inst 0x4b3deadd // sub_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:29 Rn:22 imm3:010 option:111 Rm:29 01011001:01011001 S:0 op:1 sf:0
	.inst 0xdac0043e // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:30 Rn:1 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2d42be4 // BICFLGS-C.CR-C Cd:4 Cn:31 1010:1010 opc:00 Rm:20 11000010110:11000010110
	.inst 0xb87f527f // stsmin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:19 00:00 opc:101 o3:0 Rs:31 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0xdac00fc0 // rev:aarch64/instrs/integer/arithmetic/rev Rd:0 Rn:30 opc:11 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2c21240
	.zero 40
	.inst 0xc0c00000
	.zero 9068
	.inst 0x0000c0c0
	.zero 1039416
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
	ldr x8, =initial_cap_values
	.inst 0xc240010e // ldr c14, [x8, #0]
	.inst 0xc240050f // ldr c15, [x8, #1]
	.inst 0xc2400913 // ldr c19, [x8, #2]
	/* Set up flags and system registers */
	mov x8, #0x80000000
	msr nzcv, x8
	ldr x8, =initial_SP_EL3_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2c1d11f // cpy c31, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30851037
	msr SCTLR_EL3, x8
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82601248 // ldr c8, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400112 // ldr c18, [x8, #0]
	.inst 0xc2d2a481 // chkeq c4, c18
	b.ne comparison_fail
	.inst 0xc2400512 // ldr c18, [x8, #1]
	.inst 0xc2d2a541 // chkeq c10, c18
	b.ne comparison_fail
	.inst 0xc2400912 // ldr c18, [x8, #2]
	.inst 0xc2d2a5a1 // chkeq c13, c18
	b.ne comparison_fail
	.inst 0xc2400d12 // ldr c18, [x8, #3]
	.inst 0xc2d2a5c1 // chkeq c14, c18
	b.ne comparison_fail
	.inst 0xc2401112 // ldr c18, [x8, #4]
	.inst 0xc2d2a5e1 // chkeq c15, c18
	b.ne comparison_fail
	.inst 0xc2401512 // ldr c18, [x8, #5]
	.inst 0xc2d2a661 // chkeq c19, c18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001ff8
	ldr x1, =check_data0
	ldr x2, =0x00001ffc
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
	ldr x0, =0x00400056
	ldr x1, =check_data2
	ldr x2, =0x00400058
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004023c4
	ldr x1, =check_data3
	ldr x2, =0x004023c6
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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

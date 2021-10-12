.section data0, #alloc, #write
	.zero 16
	.byte 0x08, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0xc0, 0x0f, 0x10, 0x00, 0x80, 0x00, 0x20
	.zero 4064
.data
check_data0:
	.zero 32
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x21, 0x48, 0x15, 0x38, 0xff, 0x13, 0xc4, 0xc2, 0x5f, 0x21, 0xb9, 0x2c, 0xff, 0x93, 0xc6, 0xc2
	.byte 0xf0, 0xd1, 0x17, 0x2d, 0x5f, 0xd8, 0x6c, 0xb2, 0x52, 0x08, 0xc1, 0xc2, 0xb3, 0x93, 0xe5, 0xc2
	.byte 0x0f, 0x69, 0xd8, 0xc2, 0x60, 0x07, 0x07, 0xa2, 0x80, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x4000000058000c040000000000001800
	/* C2 */
	.octa 0x800000000000000000000000
	/* C8 */
	.octa 0x3fff800000000000000000000000
	/* C10 */
	.octa 0xff8
	/* C15 */
	.octa 0xf78
	/* C27 */
	.octa 0x1008
	/* C29 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x4000000058000c040000000000001800
	/* C2 */
	.octa 0x800000000000000000000000
	/* C8 */
	.octa 0x3fff800000000000000000000000
	/* C10 */
	.octa 0xfc0
	/* C18 */
	.octa 0xc00000000000000000000000000
	/* C19 */
	.octa 0x2c00000000000000
	/* C27 */
	.octa 0x1708
	/* C29 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x90000000000500070000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000000207000f00fffffffffffc00
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x38154821 // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:1 10:10 imm9:101010100 0:0 opc:00 111000:111000 size:00
	.inst 0xc2c413ff // LDPBR-C.C-C Ct:31 Cn:31 100:100 opc:00 11000010110001000:11000010110001000
	.inst 0x2cb9215f // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:31 Rn:10 Rt2:01000 imm7:1110010 L:0 1011001:1011001 opc:00
	.inst 0xc2c693ff // CLRPERM-C.CI-C Cd:31 Cn:31 100:100 perm:100 1100001011000110:1100001011000110
	.inst 0x2d17d1f0 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:16 Rn:15 Rt2:10100 imm7:0101111 L:0 1011010:1011010 opc:00
	.inst 0xb26cd85f // orr_log_imm:aarch64/instrs/integer/logical/immediate Rd:31 Rn:2 imms:110110 immr:101100 N:1 100100:100100 opc:01 sf:1
	.inst 0xc2c10852 // SEAL-C.CC-C Cd:18 Cn:2 0010:0010 opc:00 Cm:1 11000010110:11000010110
	.inst 0xc2e593b3 // EORFLGS-C.CI-C Cd:19 Cn:29 0:0 10:10 imm8:00101100 11000010111:11000010111
	.inst 0xc2d8690f // ORRFLGS-C.CR-C Cd:15 Cn:8 1010:1010 opc:01 Rm:24 11000010110:11000010110
	.inst 0xa2070760 // STR-C.RIAW-C Ct:0 Rn:27 01:01 imm9:001110000 0:0 opc:00 10100010:10100010
	.inst 0xc2c21280
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x16, cptr_el3
	orr x16, x16, #0x200
	msr cptr_el3, x16
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400601 // ldr c1, [x16, #1]
	.inst 0xc2400a02 // ldr c2, [x16, #2]
	.inst 0xc2400e08 // ldr c8, [x16, #3]
	.inst 0xc240120a // ldr c10, [x16, #4]
	.inst 0xc240160f // ldr c15, [x16, #5]
	.inst 0xc2401a1b // ldr c27, [x16, #6]
	.inst 0xc2401e1d // ldr c29, [x16, #7]
	/* Vector registers */
	mrs x16, cptr_el3
	bfc x16, #10, #1
	msr cptr_el3, x16
	isb
	ldr q8, =0x0
	ldr q16, =0x0
	ldr q20, =0x700
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =initial_SP_EL3_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2c1d21f // cpy c31, c16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30850032
	msr SCTLR_EL3, x16
	ldr x16, =0x4
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82603290 // ldr c16, [c20, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x82601290 // ldr c16, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400214 // ldr c20, [x16, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400614 // ldr c20, [x16, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400a14 // ldr c20, [x16, #2]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400e14 // ldr c20, [x16, #3]
	.inst 0xc2d4a501 // chkeq c8, c20
	b.ne comparison_fail
	.inst 0xc2401214 // ldr c20, [x16, #4]
	.inst 0xc2d4a541 // chkeq c10, c20
	b.ne comparison_fail
	.inst 0xc2401614 // ldr c20, [x16, #5]
	.inst 0xc2d4a641 // chkeq c18, c20
	b.ne comparison_fail
	.inst 0xc2401a14 // ldr c20, [x16, #6]
	.inst 0xc2d4a661 // chkeq c19, c20
	b.ne comparison_fail
	.inst 0xc2401e14 // ldr c20, [x16, #7]
	.inst 0xc2d4a761 // chkeq c27, c20
	b.ne comparison_fail
	.inst 0xc2402214 // ldr c20, [x16, #8]
	.inst 0xc2d4a7a1 // chkeq c29, c20
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x0
	mov x20, v8.d[0]
	cmp x16, x20
	b.ne comparison_fail
	ldr x16, =0x0
	mov x20, v8.d[1]
	cmp x16, x20
	b.ne comparison_fail
	ldr x16, =0x0
	mov x20, v16.d[0]
	cmp x16, x20
	b.ne comparison_fail
	ldr x16, =0x0
	mov x20, v16.d[1]
	cmp x16, x20
	b.ne comparison_fail
	ldr x16, =0x700
	mov x20, v20.d[0]
	cmp x16, x20
	b.ne comparison_fail
	ldr x16, =0x0
	mov x20, v20.d[1]
	cmp x16, x20
	b.ne comparison_fail
	ldr x16, =0x0
	mov x20, v31.d[0]
	cmp x16, x20
	b.ne comparison_fail
	ldr x16, =0x0
	mov x20, v31.d[1]
	cmp x16, x20
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
	ldr x0, =0x0000103c
	ldr x1, =check_data1
	ldr x2, =0x00001044
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001754
	ldr x1, =check_data2
	ldr x2, =0x00001755
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
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
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

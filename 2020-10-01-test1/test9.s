.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00
	.zero 1552
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00
	.zero 2512
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x00, 0x10
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x02, 0xb9, 0x20, 0x40, 0x00, 0x10
.data
check_data3:
	.byte 0x00, 0x10, 0x00, 0x00
.data
check_data4:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data5:
	.byte 0xd4, 0xa7, 0x4d, 0xb8, 0xc1, 0xd3, 0xc5, 0xc2, 0x9e, 0xaa, 0xdf, 0xc2, 0x02, 0x6c, 0x55, 0x82
	.byte 0xcf, 0x53, 0xc6, 0xc2, 0x40, 0x54, 0x4c, 0x79, 0xfe, 0x9c, 0x43, 0xa2, 0x02, 0x21, 0xc0, 0xc2
	.byte 0x10, 0xa8, 0x07, 0xa2, 0x00, 0x7e, 0x1a, 0xb9, 0x20, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000600000020000000000001000
	/* C2 */
	.octa 0x1000
	/* C7 */
	.octa 0xc70
	/* C8 */
	.octa 0x300070000000000000000
	/* C16 */
	.octa 0x10004020b90202000000000000000000
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0xd80000003ada000500000000000010da
	/* C2 */
	.octa 0x500000000000000000000000
	/* C7 */
	.octa 0x1000
	/* C8 */
	.octa 0x300070000000000000000
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x10004020b90202000000000000000000
	/* C20 */
	.octa 0x0
	/* C30 */
	.octa 0x40000000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000041700070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd80000003ada00050080000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb84da7d4 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:20 Rn:30 01:01 imm9:011011010 0:0 opc:01 111000:111000 size:10
	.inst 0xc2c5d3c1 // CVTDZ-C.R-C Cd:1 Rn:30 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0xc2dfaa9e // EORFLGS-C.CR-C Cd:30 Cn:20 1010:1010 opc:10 Rm:31 11000010110:11000010110
	.inst 0x82556c02 // ASTR-R.RI-64 Rt:2 Rn:0 op:11 imm9:101010110 L:0 1000001001:1000001001
	.inst 0xc2c653cf // CLRPERM-C.CI-C Cd:15 Cn:30 100:100 perm:010 1100001011000110:1100001011000110
	.inst 0x794c5440 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:2 imm12:001100010101 opc:01 111001:111001 size:01
	.inst 0xa2439cfe // LDR-C.RIBW-C Ct:30 Rn:7 11:11 imm9:000111001 0:0 opc:01 10100010:10100010
	.inst 0xc2c02102 // SCBNDSE-C.CR-C Cd:2 Cn:8 000:000 opc:01 0:0 Rm:0 11000010110:11000010110
	.inst 0xa207a810 // STTR-C.RIB-C Ct:16 Rn:0 10:10 imm9:001111010 0:0 opc:00 10100010:10100010
	.inst 0xb91a7e00 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:16 imm12:011010011111 opc:00 111001:111001 size:10
	.inst 0xc2c21120
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x14, cptr_el3
	orr x14, x14, #0x200
	msr cptr_el3, x14
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c2 // ldr c2, [x14, #1]
	.inst 0xc24009c7 // ldr c7, [x14, #2]
	.inst 0xc2400dc8 // ldr c8, [x14, #3]
	.inst 0xc24011d0 // ldr c16, [x14, #4]
	.inst 0xc24015de // ldr c30, [x14, #5]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30850032
	msr SCTLR_EL3, x14
	ldr x14, =0x4
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x8260312e // ldr c14, [c9, #3]
	.inst 0xc28b412e // msr ddc_el3, c14
	isb
	.inst 0x8260112e // ldr c14, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr ddc_el3, c14
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001c9 // ldr c9, [x14, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc24005c9 // ldr c9, [x14, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc24009c9 // ldr c9, [x14, #2]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400dc9 // ldr c9, [x14, #3]
	.inst 0xc2c9a4e1 // chkeq c7, c9
	b.ne comparison_fail
	.inst 0xc24011c9 // ldr c9, [x14, #4]
	.inst 0xc2c9a501 // chkeq c8, c9
	b.ne comparison_fail
	.inst 0xc24015c9 // ldr c9, [x14, #5]
	.inst 0xc2c9a5e1 // chkeq c15, c9
	b.ne comparison_fail
	.inst 0xc24019c9 // ldr c9, [x14, #6]
	.inst 0xc2c9a601 // chkeq c16, c9
	b.ne comparison_fail
	.inst 0xc2401dc9 // ldr c9, [x14, #7]
	.inst 0xc2c9a681 // chkeq c20, c9
	b.ne comparison_fail
	.inst 0xc24021c9 // ldr c9, [x14, #8]
	.inst 0xc2c9a7c1 // chkeq c30, c9
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
	ldr x0, =0x0000162a
	ldr x1, =check_data1
	ldr x2, =0x0000162c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017a0
	ldr x1, =check_data2
	ldr x2, =0x000017b0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001a7c
	ldr x1, =check_data3
	ldr x2, =0x00001a80
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ab0
	ldr x1, =check_data4
	ldr x2, =0x00001ab8
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr ddc_el3, c14
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

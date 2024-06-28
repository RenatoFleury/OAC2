onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Fetch Input}
add wave -noupdate -label clock /tb_fd_if_id/fetch/clock
add wave -noupdate -label id_hd_hazard /tb_fd_if_id/fetch/id_hd_hazard
add wave -noupdate -label id_branch_nop /tb_fd_if_id/fetch/id_Branch_nop
add wave -noupdate -label id_pc_src /tb_fd_if_id/fetch/id_PC_Src
add wave -noupdate -label id_jump_pc -radix hexadecimal /tb_fd_if_id/fetch/id_Jump_PC
add wave -noupdate -label keep_simulating /tb_fd_if_id/fetch/keep_simulating
add wave -noupdate -divider {Fetch Output and Signals}
add wave -noupdate -label BID -radix hexadecimal /tb_fd_if_id/fetch/BID
add wave -noupdate -label PC_if -radix hexadecimal /tb_fd_if_id/fetch/PC_if
add wave -noupdate -label ri_if -radix hexadecimal /tb_fd_if_id/fetch/ri_if
add wave -noupdate -label PC_selected -radix hexadecimal /tb_fd_if_id/fetch/PC_selected
add wave -noupdate -label PC_plus_4 -radix hexadecimal /tb_fd_if_id/fetch/PC_plus_4
add wave -noupdate -label data_out -radix hexadecimal /tb_fd_if_id/fetch/data_out
add wave -noupdate -label halt_sig /tb_fd_if_id/fetch/halt_sig
add wave -noupdate -divider {Decode Input}
add wave -noupdate -label clock /tb_fd_if_id/decode/clock
add wave -noupdate -label MemRead_ex /tb_fd_if_id/decode/MemRead_ex
add wave -noupdate -label rd_ex -radix decimal /tb_fd_if_id/decode/rd_ex
add wave -noupdate -label rd_mem -radix decimal /tb_fd_if_id/decode/rd_mem
add wave -noupdate -label ula_ex -radix hexadecimal /tb_fd_if_id/decode/ula_ex
add wave -noupdate -label MemRead_mem /tb_fd_if_id/decode/MemRead_mem
add wave -noupdate -label ula_mem -radix hexadecimal /tb_fd_if_id/decode/ula_mem
add wave -noupdate -label NPC_mem -radix hexadecimal /tb_fd_if_id/decode/NPC_mem
add wave -noupdate -label RegWrite_wb /tb_fd_if_id/decode/RegWrite_wb
add wave -noupdate -label writedata_wb -radix hexadecimal /tb_fd_if_id/decode/writedata_wb
add wave -noupdate -label rd_wb /tb_fd_if_id/decode/rd_wb
add wave -noupdate -label ex_fw_A_Branch /tb_fd_if_id/decode/ex_fw_A_Branch
add wave -noupdate -label ex_fw_B_Branch /tb_fd_if_id/decode/ex_fw_B_Branch
add wave -noupdate -label BID -radix hexadecimal /tb_fd_if_id/decode/BID
add wave -noupdate -divider {Decode Output}
add wave -noupdate -label id_jump_pc -radix hexadecimal /tb_fd_if_id/decode/id_Jump_PC
add wave -noupdate -label id_pc_src /tb_fd_if_id/decode/id_PC_src
add wave -noupdate -label id_hd_hazard /tb_fd_if_id/decode/id_hd_hazard
add wave -noupdate -label id_branch_nop /tb_fd_if_id/decode/id_Branch_nop
add wave -noupdate -label COP_if /tb_fd_if_id/fetch/COP_if
add wave -noupdate -label COP_id /tb_fd_if_id/decode/COP_id
add wave -noupdate -label COP_ex /tb_fd_if_id/decode/COP_ex
add wave -noupdate -divider {Decode Signals}
add wave -noupdate -label op /tb_fd_if_id/decode/op
add wave -noupdate -label BEX -radix hexadecimal /tb_fd_if_id/decode/BEX
add wave -noupdate -label RA_id -radix hexadecimal /tb_fd_if_id/decode/RA_id
add wave -noupdate -label RB_id -radix hexadecimal /tb_fd_if_id/decode/RB_id
add wave -noupdate -label immext -radix hexadecimal /tb_fd_if_id/decode/immext
add wave -noupdate -label PC_plus4 -radix hexadecimal /tb_fd_if_id/decode/PC_plus4
add wave -noupdate -label rs1_id_ex -radix decimal /tb_fd_if_id/decode/rs1_id_ex
add wave -noupdate -label rs2_id_ex -radix decimal /tb_fd_if_id/decode/rs2_id_ex
add wave -noupdate -label rd_id -radix decimal /tb_fd_if_id/decode/rd
add wave -noupdate -label data_out_a -radix hexadecimal /tb_fd_if_id/decode/data_out_a
add wave -noupdate -label data_out_b -radix hexadecimal /tb_fd_if_id/decode/data_out_b
add wave -noupdate -label ImmSrcD /tb_fd_if_id/decode/ImmSrcD
add wave -noupdate -label invalid_instr /tb_fd_if_id/decode/invalid_instr
add wave -noupdate -label funct7 /tb_fd_if_id/decode/funct7
add wave -noupdate -label funct3 /tb_fd_if_id/decode/funct3
add wave -noupdate -label AluOp /tb_fd_if_id/decode/AluOp
add wave -noupdate -label stallD /tb_fd_if_id/decode/stallD
add wave -noupdate -label AluSrcD /tb_fd_if_id/decode/ALUSrcD
add wave -noupdate -label MemWrite_id /tb_fd_if_id/decode/MemWrite_id
add wave -noupdate -label MemRead_id /tb_fd_if_id/decode/MemRead_id
add wave -noupdate -label RegWrite_id /tb_fd_if_id/decode/RegWrite_id
add wave -noupdate -label MemtoReg_id /tb_fd_if_id/decode/MemtoReg_id
add wave -noupdate /tb_fd_if_id/decode/is_jal
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {133401 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 272
configure wave -valuecolwidth 189
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {68151 ps}

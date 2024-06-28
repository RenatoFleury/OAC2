onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -height 20 -label clock /tb_fd_if_id/decode/clock
add wave -noupdate -height 20 -label COP_if /tb_fd_if_id/fetch/COP_if
add wave -noupdate -height 20 -label COP_id /tb_fd_if_id/decode/COP_id
add wave -noupdate -height 20 -label COP_ex /tb_fd_if_id/decode/COP_ex
add wave -noupdate -color Red -height 20 -label BID -radix hexadecimal /tb_fd_if_id/fetch/BID
add wave -noupdate -color Red -height 20 -label ri_if -radix hexadecimal /tb_fd_if_id/fetch/ri_if
add wave -noupdate -color Red -height 20 -label PC_if -radix hexadecimal /tb_fd_if_id/fetch/PC_if
add wave -noupdate -color Goldenrod -height 20 -label BEX -radix hexadecimal /tb_fd_if_id/decode/BEX
add wave -noupdate -color Goldenrod -height 20 -label MemtoReg /tb_fd_if_id/decode/MemtoReg_id
add wave -noupdate -color Goldenrod -height 20 -label RegWrite /tb_fd_if_id/decode/RegWrite_id
add wave -noupdate -color Goldenrod -height 20 -label MemWrite /tb_fd_if_id/decode/MemWrite_id
add wave -noupdate -color Goldenrod -height 20 -label MemRead /tb_fd_if_id/decode/MemRead_id
add wave -noupdate -color Goldenrod -height 20 -label AluSrc /tb_fd_if_id/decode/ALUSrcD
add wave -noupdate -color Goldenrod -height 20 -label AluOp /tb_fd_if_id/decode/AluOp
add wave -noupdate -color Goldenrod -height 20 -label reg_rs1 -radix decimal /tb_fd_if_id/decode/rs1_id_ex
add wave -noupdate -color Goldenrod -height 20 -label reg_rs2 -radix decimal /tb_fd_if_id/decode/rs2_id_ex
add wave -noupdate -color Goldenrod -height 20 -label reg_rd -radix decimal /tb_fd_if_id/decode/rd
add wave -noupdate -color Goldenrod -height 20 -label PC_id -radix hexadecimal /tb_fd_if_id/decode/PC_plus4
add wave -noupdate -color Goldenrod -height 20 -label Imed -radix hexadecimal /tb_fd_if_id/decode/immext
add wave -noupdate -color Goldenrod -height 20 -label RB -radix hexadecimal /tb_fd_if_id/decode/RB_id
add wave -noupdate -color Goldenrod -height 20 -label RA -radix hexadecimal /tb_fd_if_id/decode/RA_id
add wave -noupdate -color {Medium Blue} -height 20 -label id_hd_hazard /tb_fd_if_id/decode/id_hd_hazard
add wave -noupdate -color {Medium Blue} -height 20 -label id_hd_branch_nop /tb_fd_if_id/decode/id_Branch_nop
add wave -noupdate -color {Medium Blue} -height 20 -label Pare_if /tb_fd_if_id/fetch/halt_sig
add wave -noupdate -color {Medium Blue} -height 20 -label keep_simulating /tb_fd_if_id/fetch/keep_simulating
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5043 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 272
configure wave -valuecolwidth 242
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
WaveRestoreZoom {0 ps} {64634 ps}

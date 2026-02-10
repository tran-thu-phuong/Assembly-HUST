.eqv RED 0x00C00000
.eqv LIGHT_RED 0x00FF0000
.eqv GREEN 0x0000C000
.eqv LIGHT_GREEN 0x0000FF00
.eqv BLUE 0x000000C0
.eqv LIGHT_BLUE 0x000000FF
.eqv YELLOW 0x00FFD700
.eqv LIGHT_YELLOW 0x00FFFF00
.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012  	# Địa chỉ vào của bàn phím ma trận
.eqv OUT_ADDRESS_HEXA_KEYBOARD 0xFFFF0014	# Địa chỉ vào của bàn phím ma trận
.eqv SEVENSEG_LEFT 0xFFFF0011 			# Địa chỉ LED 7 đoạn bên trái
.eqv SEVENSEG_RIGHT 0xFFFF0010 			# Địa chỉ LED 7 đoạn bên phải

.data
    array: .space 100           # Vùng nhớ lưu dãy số ngẫu nhiên
    times: .byte 0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x6f   # Giá trị hiển thị số trên LED 7 đoạn
    introduction: .asciz "Choose number corresponding to color of highlighted square in order:\n(1) red\n(2) green\n(3) blue\n(4) yellow"
                                # Thông báo giới thiệu trò chơi
    endgame: .asciz "Game over" # Thông báo kết thúc trò chơi

.text
    li s2, 0                  # Số vòng chơi đã hoàn thành
    li a7, 55                 # In chuỗi introduction
    la a0, introduction       
    li a1, 1                  
    ecall                     

# Vẽ ô màu đỏ
square1:
    li s0, 0x10000000         # Địa chỉ ô vuông đỏ đầu tiên
    addi s1, s0, 12           # Địa chỉ ô cuối hàng đầu ô đỏ
    addi t1, s0, 108          # Địa chỉ ô cuối cùng ô đỏ
    li t0, RED                

loop1:
    sw t0, 0(s0)              # Gán màu cho ô hiện hành
    addi s0, s0, 4            # Chuyển sang ô bên cạnh
    bgt s0, s1, row1          # Nếu vượt quá hàng, sang row1
    j loop1                   # Quay lại đánh màu ô kế

row1:
    addi s0, s0, 16           # Chuyển xuống hàng tiếp theo
    addi s1, s1, 32           # Cập nhật s1 cho hàng mới
    bgt s0, t1, square2       # Nếu đã xong ô đỏ, sang square2 để vẽ ô tiếp theo
    j loop1                   # Ngược lại tiếp tục loop1

# Vẽ ô màu xanh lục
square2:
    li s0, 0x10000010         # Địa chỉ ô vuông xanh lục đầu
    addi s1, s0, 12           # Ô cuối hàng đầu ô xanh lục
    addi t1, s0, 108          # Ô cuối cùng ô xanh lục
    li t0, GREEN              

loop2:
    sw t0, 0(s0)              # Gán màu cho ô
    addi s0, s0, 4            # Chuyển sang ô bên cạnh
    bgt s0, s1, row2          # Nếu xong hàng, sang row2
    j loop2

row2:
    addi s0, s0, 16           # Chuyển xuống hàng tiếp
    addi s1, s1, 32           # Cập nhật địa chỉ ô cuối hàng
    bgt s0, t1, square3       # Nếu xong ô xanh lục, sang square3 để vẽ ô tiếp theo
    j loop2

# Vẽ ô màu xanh dương
square3:
    li s0, 0x10000080         # Địa chỉ ô vuông xanh dương đầu
    addi s1, s0, 12           # Ô cuối hàng đầu ô xanh dương
    addi t1, s0, 108          # Ô cuối cùng ô xanh dương
    li t0, BLUE               

loop3:
    sw t0, 0(s0)              # Gán màu cho ô
    addi s0, s0, 4            # Chuyển ô kế
    bgt s0, s1, row3          # Nếu xong hàng, sang row3
    j loop3

row3:
    addi s0, s0, 16           # Chuyển hàng mới
    addi s1, s1, 32           # Cập nhật ô cuối hàng
    bgt s0, t1, square4       # Nếu xong ô xanh dương, sang square4 để vẽ ô tiếp theo
    j loop3

# Vẽ ô màu vàng
square4:
    li s0, 0x10000090         # Địa chỉ ô vuông vàng đầu
    addi s1, s0, 12           # Ô cuối hàng đầu ô vàng
    addi t1, s0, 108          # Ô cuối cùng ô vàng
    li t0, YELLOW             

loop4:
    sw t0, 0(s0)              # Gán màu cho ô
    addi s0, s0, 4            # Chuyển ô kế
    bgt s0, s1, row4          # Nếu xong hàng, sang row4
    j loop4

row4:
    addi s0, s0, 16           # Chuyển xuống hàng tiếp
    addi s1, s1, 32           # Cập nhật ô cuối hàng
    bgt s0, t1, start         # Nếu xong ô vàng, chuyển sang start
    j loop4

#====================Khởi động trò chơi==================
start:
    # Tắt ngắt bàn phím ma trận trong Digital Lab Sim
    li t1, IN_ADDRESS_HEXA_KEYBOARD
    sb zero, 0(t1)            # Ghi 0 để vô hiệu ngắt

    addi s2, s2, 1            # Tăng số vòng chơi đã hoàn thành
    mv s3, s2                 # Gán số màu cần hiển thị = số vòng hiện tại
    la t2, array              # t2 trỏ vào mảng lưu kết quả
    jal rest                  # Chờ 1 giây trước lượt ngẫu nhiên

# Tạo màu ngẫu nhiên
random_phase:
    beqz s3, select_phase     # Nếu đã random đủ s2 lần, qua chọn người chơi
    li a7, 42                 # syscall sinh số ngẫu nhiên
    li a1, 4                  # Tạo số ngẫu nhiên
    ecall
    addi s3, s3, -1           # Giảm số lượt random còn lại
    addi a0, a0, 1            # ID của ô vuông
    sw a0, 0(t2)              # Lưu vào mảng
    addi t2, t2, 4            # Tăng chỉ số mảng

    # Kiểm tra giá trị a0 để sang nhánh highlight tương ứng
    li s0, 1
    beq a0, s0, light_red     # Nếu là 1, làm sáng ô đỏ
    li s0, 2
    beq a0, s0, light_green   # Nếu là 2, làm sáng ô xanh lục
    li s0, 3
    beq a0, s0, light_blue    # Nếu là 3, làm sáng ô xanh dương
    li s0, 4
    beq a0, s0, light_yellow  # Nếu là 4, làm sáng ô vàng

light_red:
    li t3, 1                  # t3 = 1 chưa highlight
initialize1:
    li s0, 0x10000000         # Địa chỉ ô đỏ
    addi s1, s0, 12
    addi t1, s0, 108
    beqz t3, return_red       # Nếu đã highlight, trả màu gốc
    li t0, LIGHT_RED          # Màu đỏ sáng
    j loop11

return_red:
    li t0, RED                # Trả về màu đỏ gốc

loop11:
    sw t0, 0(s0)              # Gán màu hiện hành
    addi s0, s0, 4
    bgt s0, s1, row11
    j loop11

row11:
    addi s0, s0, 16
    addi s1, s1, 32
    ble s0, t1, loop11
    jal rest                  # Chờ 1s trước khi trả về màu gốc
    beqz t3, random_phase     # Nếu đã xong highlight, quay random
    li t3, 0                  # t3 = 0 đánh dấu highlight xong
    j initialize1

light_green:
    li t3, 1                  # t3 = 1 chưa highlight
initialize2:
    li s0, 0x10000010         # Địa chỉ ô xanh lục
    addi s1, s0, 12
    addi t1, s0, 108
    beqz t3, return_green
    li t0, LIGHT_GREEN        # Màu xanh lục sáng
    j loop22

return_green:
    li t0, GREEN              # Màu xanh lục gốc

loop22:
    sw t0, 0(s0)
    addi s0, s0, 4
    bgt s0, s1, row22
    j loop22

row22:
    addi s0, s0, 16
    addi s1, s1, 32
    ble s0, t1, loop22
    jal rest                  # Chờ 1s
    beqz t3, random_phase
    li t3, 0
    j initialize2

light_blue:
    li t3, 1
initialize3:
    li s0, 0x10000080         # Địa chỉ ô xanh dương
    addi s1, s0, 12
    addi t1, s0, 108
    beqz t3, return_blue
    li t0, LIGHT_BLUE         # Màu xanh dương sáng
    j loop33

return_blue:
    li t0, BLUE               # Màu xanh dương gốc

loop33:
    sw t0, 0(s0)
    addi s0, s0, 4
    bgt s0, s1, row33
    j loop33

row33:
    addi s0, s0, 16
    addi s1, s1, 32
    ble s0, t1, loop33
    jal rest
    beqz t3, random_phase
    li t3, 0
    j initialize3

light_yellow:
    li t3, 1
initialize4:
    li s0, 0x10000090         # Địa chỉ ô vàng
    addi s1, s0, 12
    addi t1, s0, 108
    beqz t3, return_yellow
    li t0, LIGHT_YELLOW       # Màu vàng sáng
    j loop44

return_yellow:
    li t0, YELLOW             # Màu vàng gốc

loop44:
    sw t0, 0(s0)
    addi s0, s0, 4
    bgt s0, s1, row44
    j loop44

row44:
    addi s0, s0, 16
    addi s1, s1, 32
    ble s0, t1, loop44
    jal rest
    beqz t3, random_phase
    li t3, 0
    j initialize4

#=============Lưu số vòng chơi=============
select_phase:
    # Nạp địa chỉ handler vào CSR UTVEC
    la t0, handler 
    csrrs zero, utvec, t0 

    # Thiết lập bit UEIE trong CSR UIE để bật ngắt ngoại vi
    li t1, 0x100 
    csrrs zero, uie, t1      

    # Cho phép ngắt bàn phím ma trận
    li t1, IN_ADDRESS_HEXA_KEYBOARD 
    li t2, 0x80             # bit 7 = 1 để bật ngắt
    sb t2, 0(t1)

    mv s3, s2               # s3 = số lần người chơi cần nhấn phím

seven_segment:
    li s0, 10               # Cơ số hiển thị
    la t2, times            # Địa chỉ bảng giá trị 7-seg
    rem t0, s3, s0          # t0 = đơn vị của s3
    div t1, s3, s0          # t1 = hàng chục của s3
    add t0, t0, t2          # Địa chỉ mã 7-seg đơn vị
    add t1, t1, t2          # Địa chỉ mã 7-seg chục
    lb t0, 0(t0)            # Lấy giá trị hiển thị đơn vị
    lb t1, 0(t1)            # Lấy giá trị hiển thị chục
    li s1, SEVENSEG_LEFT
    li s0, SEVENSEG_RIGHT
    sb t0, 0(s0)            # Hiển thị đơn vị lên LED phải
    sb t1, 0(s1)            # Hiển thị chục lên LED trái

end_seven_segment:
    la t3, array            # t3 trỏ mảng array[0]

wait_to_press:
    # Bật global interrupt (UIE) để chờ ngắt
    csrrsi zero, ustatus, 0x1 
    beqz s3, start          # Nếu người chơi đã nhấn đủ lần, qua start
    addi a7, zero, 32       # syscall sleep
    li a0, 300              # Chờ 300 ms
    ecall 
    j wait_to_press

handler:                    # Hàm xử lý ngắt bàn phím
    li t1, IN_ADDRESS_HEXA_KEYBOARD 
    li t2, 0x81             # Chọn hàng 1, bật lại bit interrupt
    sb t2, 0(t1)            # Ghi lại hàng cần kiểm tra
    li t1, OUT_ADDRESS_HEXA_KEYBOARD 
    lb a0, 0(t1)            # Đọc cột bàn phím
    bnez a0, check_row1     # Nếu khác 0, nút thuộc hàng 1

    li t1, IN_ADDRESS_HEXA_KEYBOARD 
    li t2, 0x82             # Chọn hàng 2, bật lại bit interrupt
    sb t2, 0(t1)
    li t1, OUT_ADDRESS_HEXA_KEYBOARD 
    lb a0, 0(t1)            # Đọc cột hàng 2
    bnez a0, check_row2     # Nếu khác 0, nút thuộc hàng 2

check_correct:
    lw t0, 0(t3)            # t0 = giá trị array[i]
    bne a0, t0, exit        # Nếu nhập sai, kết thúc trò chơi
    addi s3, s3, -1         # Giảm số lần còn phải nhấn
seven_segment1:             # Hiển thị còn bao nhiêu lần phải nhấn
    li s0, 10
    la t2, times
    rem t0, s3, s0
    div t1, s3, s0
    add t0, t0, t2
    add t1, t1, t2
    lb t0, 0(t0)
    lb t1, 0(t1)
    li s1, SEVENSEG_LEFT
    li s0, SEVENSEG_RIGHT
    sb t0, 0(s0)
    sb t1, 0(s1)

end_seven_segment1:
    addi t3, t3, 4          # i = i + 1
    uret                    # Trả về từ ngắt

check_row1:
    li t0, 0x21             # Mã phím 1
    beq a0, t0, button_1
    li t0, 0x41             # Mã phím 2
    beq a0, t0, button_2
    li t0, 0xffffff81       # Mã phím 3
    beq a0, t0, button_3
    j exit                  # Nút khác, kết thúc trò chơi

button_1:
    li a0, 1                # Ghi lại người chơi nhấn phím 1
    j check_correct

button_2:
    li a0, 2                # Ghi lại người chơi nhấn phím 2
    j check_correct

button_3:
    li a0, 3                # Ghi lại người chơi nhấn phím 3
    j check_correct

check_row2:
    li t0, 0x12             # Mã phím 4
    beq a0, t0, button_4
    j exit                  # Phím khác, kết thúc

button_4:
    li a0, 4                # Ghi lại người chơi nhấn phím 4
    j check_correct

rest:
    li a7, 32               # syscall sleep
    li a0, 1000             # Chờ 1 giây
    ecall
    jr ra                   # Về điểm gọi

exit:
    li a7, 55               # syscall in chuỗi endgame
    la a0, endgame
    li a1, 1
    ecall
    li a7, 10               # syscall exit
    ecall

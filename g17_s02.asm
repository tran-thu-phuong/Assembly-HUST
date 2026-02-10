.eqv   SEVENSEG_LEFT,   0xFFFF0011 # Địa chỉ LED 7 đoạn bên trái
.eqv   SEVENSEG_RIGHT,  0xFFFF0010 # Địa chỉ LED 7 đoạn bên phải
.eqv   KEY_READY,       0xFFFF0000 # Địa chỉ kiểm tra trạng thái phím
.eqv   KEY_CODE,        0xFFFF0004 # Địa chỉ chứa mã phím vừa nhấn
.eqv   TIMER_NOW,       0xFFFF0018 # Địa chỉ lấy thời gian hiện tại (ms)
.data
prompt: .asciz  "Type exactly: "
string:        .asciz  "bo mon ky thuat may tinh"
#input_buf:     .space  200 

mask:       .word   0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F # Giá trị hiển thị số trên LED 7 đoạn
 
msg_time:   .asciz  "\nTime (s): "
msg_corr:   .asciz  "\nCorrect chars: "
msg_speed:  .asciz  "\nSpeed (words/min): "

.text
.globl  main
main:
    # Hiển thị chuỗi mẫu cần gõ theo
    li      a7, 4
    la      a0, prompt
    ecall
    li      a7, 4
    la      a0, string
    ecall

    # Khởi tạo các biến
    li      s1, 0          # số kí tự đúng
    li      s2, 0          # tổng số kí tự đã nhập
    li      s5, 0          # chỉ số kí tự hiện tại trong string mẫu
    li      s4, 0          # thời gian bắt đầu (ms)
    li      s6, 0          # thời gian kết thúc (ms)
#    la      s0, input_buf  # con trỏ của input_buf 

    # Tính độ dài string
    la      t0, string
    li      t1, 0
count_len:
    lb      t2, 0(t0)
    beq     t2,zero,count_len_done
    addi    t0, t0, 1
    addi    t1, t1, 1
    j       count_len
count_len_done:
    mv      s3, t1      # s3 = độ dài chuỗi mẫu

poll_loop:
    # Kiểm tra xem có ký tự mới chưa:
    li      t0, KEY_READY      
    lb      t1, 0(t0)          
    beq     t1, zero, poll_loop # nếu t1 == 0 tức chưa có ký tự thì quay lại poll_loop

    # Đọc mã ASCII của phím vừa gõ:
    li      t0, KEY_CODE       
    lb      t2, 0(t0)          

#    sb      t2, 0(s0)
#    addi    s0, s0, 1          # s0 = s0 + 1 (di chuyển tới ô kế tiếp)

    # Nếu đây là ký tự đầu tiên (s5 = 0), ghi thời điểm bắt đầu:
    beq     s5, zero, mark_start

no_mark:
    # Tăng tổng số ký tự đã gõ:
    addi    s2, s2, 1          # s2 = s2 + 1

    # Lấy ký tự mẫu tại vị trí s5 để so sánh:
    la      t0, string         # t0 là địa chỉ đầu của string
    add     t0, t0, s5         # t0 là string + s5
    lb      t3, 0(t0)          # t3 = string[s5]

    # Nếu ký tự nhập (t2) == ký tự mẫu (t3), tăng số ký tự đúng:
    beq     t2, t3, inc_corr

next_idx:
    # Chưa đủ độ dài mẫu, tăng chỉ số và quay lại poll:
    addi    s5, s5, 1          # s5 = s5 + 1
    beq     s5, s3, mark_end   # nếu s5 = length (hết chuỗi mẫu) thì qua mark_end
    j       poll_loop

inc_corr:
    # Ký tự đúng, tăng counter:
    addi    s1, s1, 1
    j       next_idx

mark_start:
    # Lần gõ đầu tiên: lấy thời gian bắt đầu:
    li      t0, TIMER_NOW      
    lw      s4, 0(t0)          # s4 = thời gian bắt đầu (ms)
    j       no_mark

mark_end:
    # Khi gõ đủ độ dài mẫu thì lấy thời gian kết thúc
    li      t0, TIMER_NOW
    lw      s6, 0(t0)          # s6 = thời gian kết thúc (ms)
    j       finish

# Kết thúc và hiển thị kết quả
finish:
    # thời gian thực hiện (s) = [thời gian kết thúc (ms) - thời gian bắt đầu (ms)] / 1000 
    sub     s6, s6, s4
    li      t0, 1000
    div     s4, s6, t0

    # Hiển thị số kí tự đúng trên LED 7 đoạn (2 chữ số)
    li      t0, 10
    div     t2, s1, t0 # hàng chục
    rem     t3, s1, t0 # hàng đơn vị
    # Hàng chục
    la      t0, mask
    slli    t1, t2, 2
    add     t0, t0, t1
    lw      t6, 0(t0)
    li      t0, SEVENSEG_LEFT
    sb      t6, 0(t0)
    # Hàng đơn vị
    la      t0, mask
    slli    t1, t3, 2
    add     t0, t0, t1
    lw      t6, 0(t0)
    li      t0, SEVENSEG_RIGHT
    sb      t6, 0(t0)

    # In thời gian (s)
    li      a7, 4
    la      a0, msg_time
    ecall
    li      a7, 1
    mv      a0, s4
    ecall

    # In số kí tự đúng
    li      a7, 4
    la      a0, msg_corr
    ecall
    li      a7, 1
    mv      a0, s1
    ecall

    # Đếm số từ
    la      a0, string
    jal     count_word

    # Tính tốc độ gõ (từ/phút) = s0*60 / s4
    li      t0, 60
    mul     a6, s0, t0
    div     a6, a6, s4

    li      a7, 4
    la      a0, msg_speed
    ecall
    li      a7, 1
    mv      a0, a6
    ecall

    li      a7, 10
    ecall

#=========================================================
# Chương trình con đếm số từ của chuỗi đầu vào (input_buf)
#=========================================================
count_word:
    li t0, 0          # đếm số từ
    mv t1, a0         # con trỏ tới input_buf
    li t2, 0          # in_word = false
    li t3, ' '
loop_count_word:
    lb    t4, 0(t1)           # Đọc ký tự hiện tại từ chuỗi
    addi  t1, t1, 1           # Tăng con trỏ chuỗi lên 1

    beq   t4, t3, got_space   # Nếu ký tự là dấu cách thì nhảy đến got_space
    beqz  t4, last_word_check # Nếu ký tự là 0 (Kết thúc chuỗi), nhảy đến last_word_check
    li    t2, 1               # Đang trong từ (in_word = true)
    j     loop_count_word     # Tiếp tục vòng lặp

got_space:
    beqz  t2, loop_count_word # Nếu trước đó không ở trong từ (in_word == false), bỏ qua
    li    t2, 0               # Kết thúc từ, đặt in_word = false
    addi  t0, t0, 1           # Tăng bộ đếm từ lên 1
    j     loop_count_word     # Tiếp tục vòng lặp

last_word_check:
    beqz  t2, done_count_word # Nếu không đang trong từ (in_word == false), không thêm từ cuối
    addi  t0, t0, 1           # Nếu đang trong từ, thêm từ cuối vào đếm

done_count_word:
    mv    s0, t0              # s0 = tổng số từ đếm được
    jr    ra                 

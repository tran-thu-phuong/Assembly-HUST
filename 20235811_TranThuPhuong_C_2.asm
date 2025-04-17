.data
string: .space 400 # Vùng nhớ để lưu xâu người dùng nhập (tối đa 400 byte)
dem: .space 400 # Mảng để đánh dấu các ký tự đã xuất hiện
msg1: .asciz "Nhap xau: "
msg2: .asciz "Cac ki tu khac nhau trong xau la: "
msg3: .asciz "Xau rong."
daucach: .asciz " "

.text
# Nhập xâu
li a7, 4
la a0, msg1 # in thông báo "Nhap xau: "
ecall
li a7, 8 
la a0, string 
li a1, 400	
ecall
# Kiểm tra xem xâu có rỗng không
la s0, string # s0 trỏ đến đầu xâu
lb t6, 0(a0) # Lấy ký tự đầu tiên của xâu
beq t6, zero, rong  # Nếu là '\0' thì xâu rỗng
li x3, 10 # mã ASCII của '\n'
beq t6, x3, rong # Nếu là ký tự xuống dòng thì xâu rỗng

li a7, 4
la a0, msg2 # in thông báo "Cac ki tu khac nhau trong xau la: "
ecall
 
la s1, dem # địa chỉ mảng dem

loop:
lb s2, 0(s0) # s2 = string[i]
beq s2, zero, exit # Nếu là ký tự NULL thì thoát
li x2, 32 # mã ASCII của dấu cách
beq s2, x2, continue # Nếu là dấu cách thì bỏ qua
beq s2, x3, continue # Nếu là ký tự xuống dòng thì bỏ qua

add t5, s1, s2 # địa chỉ của dem[string[i]]
lb t3, 0(t5) # dem[string[i]]
bne t3, zero, continue # Nếu ký tự đã xuất hiện thì bỏ qua

li t4, 1 # Đánh dấu ký tự s2 đã xuất hiện
sb t4, 0(t5) # dem[string[i]]=1
# In ra kí tự khác nhau
li a7, 11
mv a0, s2
ecall
li a7, 4
la a0, daucach # in dấu cách
ecall 

continue:
addi s0, s0, 1 # i++
j loop
exit:
li a7, 10 # exit
ecall
# Nếu xâu rỗng
rong:
li a7, 4
la a0, msg3
ecall
li a7, 10
ecall

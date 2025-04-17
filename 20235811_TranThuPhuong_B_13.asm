.data
array: .space 400 # Cấp phát 400 byte để lưu mảng (tối đa 100 phần tử số nguyên 4 byte)
msg1: .asciz "Nhap do dai mang n: "
msg2: .asciz "Nhap mang: \n"
msg3: .asciz " so khac nhau trong mang."
msg4: .asciz "Vui long nhap lai n (n>=0).\n"  
msg5: .asciz "Mang khong co phan tu nao."                         

.text
nhapn: # Nhập số phần tử của mảng
li a7, 4                 
la a0, msg1 # in thông báo "Nhap do dai mang n: "
ecall	
li a7, 5 
ecall
mv s0, a0 # s0 = n
blt s0, zero, nhaplai # n<0 thì nhập lại
j continue

nhaplai:  # Nhập lại n
li a7, 4
la a0, msg4
ecall
j nhapn

continue:
beq s0, zero, thoat # n=0 thì nhảy đến thoát
la s1, array # địa chỉ mảng array
li t0, 0 # i=0
li a7, 4
la a0, msg2  # in thông báo "Nhap mang"
ecall

nhapmang: # Nhập các phần tử của mảng
bge t0, s0, nhapxong    # i >= n thì nhập xong
li a7, 5	# nhập giá trị
ecall
sw a0, 0(s1) # lưu giá trị vào mảng
addi s1, s1, 4 # tăng địa chỉ tới phần tử tiếp theo
addi t0, t0, 1 # i++
j nhapmang
nhapxong:

# Sắp xếp mảng
li t1, 0 # i=0
loopsapxep:
la s1, array
addi t2, s0, -1 # n-1
bge t1, t2, done # i>=n-1 thì kết thúc sắp xếp
li t3, 0 #j

loopdoicho:
sub t4, t2, t1 # n-1-i
bge t3, t4, exit # nếu j>n-1-i thì kết thúc lặp
slli t5, t3, 2 # t5=j*4
add t6, s1, t5 # địa chỉ của array[j]
lw s7, 0(t6) # array[j]
lw s8, 4(t6) # array[j+1]
ble s7, s8, khongdoicho # array[j]<array[j+1] thì không đổi chỗ
sw s8, 0(t6)# ngược lại thì đổi chỗ
sw s7, 4(t6) 
khongdoicho:
addi t3, t3, 1 # j++
j loopdoicho
exit:
addi t1, t1, 1 # i++
j loopsapxep
done:

# đếm số phần tử khác nhau trong mảng
la t0, array # t0=địa chỉ mảng
li s6, 1 # số phần tử khác nhau
li t1, 1 #i=1
loopdem:
beq t1, s0, print # i==n thì print
slli t2, t1, 2 # t2=4*i
add t3, t0, t2 # địa chỉ của array[i]
lw t4, 0(t3) #array[i]
addi t5, t3, -4 # địa chỉ của array[i-1]
lw t6, 0(t5) #array[i-1]
beq t4, t6, khongtang # nếu giống nhau thì không tăng 
addi s6, s6, 1 # nếu khác thì tăng đếm
khongtang:
addi t1, t1, 1 # i++
j loopdem

print:
# in đếm
li a7, 1 
add a0, zero, s6
ecall
# in dòng " so khac nhau trong mang.\n"
li a7, 4
la a0, msg3
ecall
li a7, 10
ecall

# trường hợp n=0
thoat:
li a7, 4
la a0, msg5 # in thông báo "Mang khong co phan tu nao."
ecall

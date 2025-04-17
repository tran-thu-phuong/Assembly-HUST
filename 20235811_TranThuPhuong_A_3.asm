#-	Đề bài: Viết hàm kiểm tra một số có phải là số nguyên tố không. Sau đó nhập 2 số nguyên dương M và N từ bàn phím, in ra tất cả các số nguyên tố trong đoạn từ M đến N.
.data
nhapm: .asciz "Nhap so nguyen M: "
nhapn: .asciz "Nhap so nguyen N: "
ketqua: .asciz "Cac so nguyen to trong doan tu M den N: "
ketqua1: .asciz "Khong co so nguyen to nao trong doan tu M den N."
loi1: .asciz "Vui long nhap so nguyen duong.\n"
loi2: .asciz "Vui long nhap lai, M khong duoc lon hon N.\n"
daucach: .asciz " "

.text 
# Nhập đầu vào
nhapM:
li a7, 4
la a0, nhapm
ecall
li a7, 5
ecall
bge zero, a0, nhaplaim # nếu M < 0 thì nhập lại
mv s2, a0 # M
nhapN:
li a7, 4
la a0, nhapn
ecall
li a7, 5
ecall
bge zero, a0, nhaplain # nếu N<0 thì nhập lại
mv s3, a0 # N 
blt s3, s2, nhaplai # nếu M>N thì nhập lại
j hople 

#khi đầu vào không hợp lệ
nhaplaim:
li a7, 4
la a0, loi1
ecall
j nhapM

nhaplain:
li a7, 4
la a0, loi1
ecall
j nhapN

nhaplai:
li a7, 4
la a0, loi2
ecall
j nhapN

#khi đầu vào hợp lệ
hople:
li a7, 4
la a0, ketqua
ecall

addi s3, s3, 1 # N+1
j loop

loop:
beq s2, s3, exits # i=M, nếu i=N+1 thì kết thúc vòng lặp
add t4, s2, zero # gán t4=M
jal kiemtrasnt # bắt đầu vào chương trình con để kiểm tra số nguyên tố
bne s1, zero, print # là số nguyên tố thì print
continue: 
addi s2, s2, 1 #i++
j loop

# Hàm kiểm tra số nguyên tố
kiemtrasnt:
li t3, 2 # gán 2 vào t3 để tính t4/2
blt t4, t3, exit1  # t4<2 thì t4 không là số nguyên tố
div t5, t4, t3
addi t5, t5, 1 # t5=t4/2 + 1
li t6, 2 # j=2
loopsonguyento:
beq t6, t5, thoat # j=t5 thì kết thúc vòng lặp kiểm tra số nguyên tố
rem s0, t4, t6 #s0=t4%j
beq s0, zero, exit1 # nếu s0=0 thì t4 không là số nguyên tố
addi t6, t6, 1 # j++
j loopsonguyento
thoat: 
li s1, 1         # t4 là số nguyên tố
addi t0, t0, 1 # t0 đếm số lượng số nguyên tố
j exit2
exit1:
li s1, 0            # t4 không là số nguyên tố
exit2:
jr ra # nhảy đến caller
exits:
beq t0, zero, tiep # nếu không có số nguyên tố nào trong đoạn từ M đến N
j ketthuc
tiep:
li a7, 4
la a0, ketqua1 # in thông điệp "Khong co so nguyen to nao trong doan tu M den N."
ecall
ketthuc:
li a7, 10  #exit         
ecall
# in kết quả
print:
li a7, 1
mv a0, s2 # in số nguyên tố
ecall
li a7, 4
la a0, daucach # in dấu cách
ecall
j continue 

-- =============================================
-- 1. THIẾT LẬP MÔI TRƯỜNG & RESET DATABASE
-- =============================================
USE master;
GO

-- Xóa DB cũ nếu tồn tại để tạo lại mới
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'QuanLyLinhKienPCDB')
BEGIN
    ALTER DATABASE QuanLyLinhKienPCDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE QuanLyLinhKienPCDB;
END
GO

CREATE DATABASE QuanLyLinhKienPCDB;
GO

USE QuanLyLinhKienPCDB;
GO

-- =============================================
-- 2. TẠO CẤU TRÚC BẢNG (TABLES)
-- =============================================

-- Bảng VaiTro
CREATE TABLE VaiTro (
    MaVaiTro INT IDENTITY(1,1) PRIMARY KEY,
    TenVaiTro NVARCHAR(50) NOT NULL UNIQUE -- Admin, Staff, Customer
);
GO

-- Bảng NguoiDung
CREATE TABLE NguoiDung (
    MaNguoiDung INT IDENTITY(1,1) PRIMARY KEY,
    TenDangNhap VARCHAR(50) NOT NULL UNIQUE,
    MatKhauHash VARCHAR(255) NOT NULL,
    HoTen NVARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    SoDienThoai VARCHAR(15),
    DiaChi NVARCHAR(255),
    MaVaiTro INT NOT NULL,
    NgayTao DATETIME DEFAULT GETDATE(),
    TrangThai BIT DEFAULT 1,
    CONSTRAINT FK_NguoiDung_VaiTro FOREIGN KEY (MaVaiTro) REFERENCES VaiTro(MaVaiTro)
);
GO

-- Bảng DanhMuc (Phân cấp: Phần cứng, Phụ kiện -> RAM, CPU, Chuột...)
CREATE TABLE DanhMuc (
    MaDanhMuc INT IDENTITY(1,1) PRIMARY KEY,
    TenDanhMuc NVARCHAR(100) NOT NULL,
    MaDanhMucCha INT NULL, 
    MoTa NVARCHAR(500),
    CONSTRAINT FK_DanhMuc_Cha FOREIGN KEY (MaDanhMucCha) REFERENCES DanhMuc(MaDanhMuc)
);
GO

-- Bảng NhaCungCap (Thương hiệu: Intel, AMD, Kingston...)
CREATE TABLE NhaCungCap (
    MaNCC INT IDENTITY(1,1) PRIMARY KEY,
    TenNCC NVARCHAR(100) NOT NULL,
    QuocGia NVARCHAR(50),
    Website VARCHAR(100)
);
GO

-- Bảng SanPham
CREATE TABLE SanPham (
    MaSP INT IDENTITY(1,1) PRIMARY KEY,
    TenSP NVARCHAR(200) NOT NULL,
    MaSKU VARCHAR(50) UNIQUE, -- Mã quản lý kho
    MaDanhMuc INT NOT NULL,
    MaNCC INT,
    GiaBan DECIMAL(18, 0) NOT NULL CHECK (GiaBan >= 0),
    SoLuongTon INT DEFAULT 0 CHECK (SoLuongTon >= 0),
    HinhAnh VARCHAR(MAX),
    -- Với linh kiện PC, ThongSoKyThuat rất quan trọng (lưu dạng JSON hoặc text mô tả)
    ThongSoKyThuat NVARCHAR(MAX), 
    ThoiGianBaoHanh INT DEFAULT 12, -- Tháng (PC thường bảo hành 12-36 tháng)
    NgayTao DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_SanPham_DanhMuc FOREIGN KEY (MaDanhMuc) REFERENCES DanhMuc(MaDanhMuc),
    CONSTRAINT FK_SanPham_NhaCungCap FOREIGN KEY (MaNCC) REFERENCES NhaCungCap(MaNCC)
);
GO

-- Bảng DonHang
CREATE TABLE DonHang (
    MaDonHang INT IDENTITY(1,1) PRIMARY KEY,
    MaNguoiDung INT NOT NULL,
    NgayDat DATETIME DEFAULT GETDATE(),
    TongTien DECIMAL(18, 0) DEFAULT 0,
    TrangThai NVARCHAR(50) DEFAULT N'Mới', -- Đơn giản hóa trạng thái thành text hoặc dùng bảng riêng nếu muốn
    DiaChiGiaoHang NVARCHAR(255) NOT NULL,
    GhiChu NVARCHAR(500),
    CONSTRAINT FK_DonHang_NguoiDung FOREIGN KEY (MaNguoiDung) REFERENCES NguoiDung(MaNguoiDung)
);
GO

-- Bảng ChiTietDonHang
CREATE TABLE ChiTietDonHang (
    MaCTDH INT IDENTITY(1,1) PRIMARY KEY,
    MaDonHang INT NOT NULL,
    MaSP INT NOT NULL,
    SoLuong INT NOT NULL CHECK (SoLuong > 0),
    DonGia DECIMAL(18, 0) NOT NULL,
    CONSTRAINT FK_ChiTiet_DonHang FOREIGN KEY (MaDonHang) REFERENCES DonHang(MaDonHang) ON DELETE CASCADE,
    CONSTRAINT FK_ChiTiet_SanPham FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
);
GO

-- =============================================
-- 3. CHÈN DỮ LIỆU MẪU (DÀNH CHO PC/LAPTOP)
-- =============================================

-- 3.1. Vai Trò
INSERT INTO VaiTro (TenVaiTro) VALUES (N'Quản trị viên'), (N'Khách hàng');

-- 3.2. Người dùng
INSERT INTO NguoiDung (TenDangNhap, MatKhauHash, HoTen, Email, SoDienThoai, MaVaiTro, DiaChi) VALUES
('admin', 'hash_pass_admin', N'Admin Shop PC', 'admin@pcshop.com', '0909000111', 1, N'TP.HCM'),
('user1', 'hash_pass_user', N'Nguyễn Văn Gamer', 'gamer@gmail.com', '0912345678', 2, N'Hà Nội');

-- 3.3. Danh mục (Cấu trúc cây cho PC)
-- Cấp 1
INSERT INTO DanhMuc (TenDanhMuc, MaDanhMucCha) VALUES 
(N'Linh kiện Máy tính', NULL),      -- ID 1
(N'Lưu trữ (Storage)', NULL),       -- ID 2
(N'Thiết bị ngoại vi', NULL);       -- ID 3

-- Cấp 2 (Con của ID 1 - Linh kiện)
INSERT INTO DanhMuc (TenDanhMuc, MaDanhMucCha) VALUES 
(N'CPU - Vi xử lý', 1),             -- ID 4
(N'RAM - Bộ nhớ trong', 1),         -- ID 5
(N'Mainboard - Bo mạch chủ', 1),    -- ID 6
(N'VGA - Card màn hình', 1);        -- ID 7

-- Cấp 2 (Con của ID 2 - Lưu trữ)
INSERT INTO DanhMuc (TenDanhMuc, MaDanhMucCha) VALUES 
(N'SSD', 2),                        -- ID 8
(N'HDD', 2);                        -- ID 9

-- Cấp 2 (Con của ID 3 - Ngoại vi)
INSERT INTO DanhMuc (TenDanhMuc, MaDanhMucCha) VALUES 
(N'Màn hình (Monitor)', 3),         -- ID 10
(N'Bàn phím (Keyboard)', 3),        -- ID 11
(N'Chuột (Mouse)', 3);              -- ID 12

-- 3.4. Nhà cung cấp (Thương hiệu nổi tiếng)
INSERT INTO NhaCungCap (TenNCC, QuocGia) VALUES 
(N'Intel', N'USA'),       -- ID 1
(N'AMD', N'USA'),         -- ID 2
(N'Kingston', N'USA'),    -- ID 3
(N'Samsung', N'Korea'),   -- ID 4
(N'Logitech', N'Swiss'),  -- ID 5
(N'Gigabyte', N'Taiwan'), -- ID 6
(N'Dell', N'USA');        -- ID 7

-- 3.5. Sản phẩm (Dữ liệu thực tế)
INSERT INTO SanPham (TenSP, MaSKU, MaDanhMuc, MaNCC, GiaBan, SoLuongTon, ThongSoKyThuat, ThoiGianBaoHanh) VALUES
-- CPU
(N'CPU Intel Core i5-12400F', 'CPU-INT-12400F', 4, 1, 3500000, 20, N'Socket: LGA1700, 6 Cores, 12 Threads, Clock: 2.5GHz', 36),
(N'CPU AMD Ryzen 5 5600X', 'CPU-AMD-5600X', 4, 2, 3900000, 15, N'Socket: AM4, 6 Cores, 12 Threads, Clock: 3.7GHz', 36),

-- RAM
(N'RAM Kingston Fury Beast 8GB DDR4 3200MHz', 'RAM-KIN-D4-8G', 5, 3, 650000, 100, N'Bus: 3200MHz, CL16, DDR4', 36),
(N'RAM Samsung 16GB DDR5 4800MHz (Laptop)', 'RAM-SAM-D5-16G', 5, 4, 1200000, 50, N'Bus: 4800MHz, DDR5, SODIMM (Laptop)', 36),

-- SSD/HDD
(N'SSD Samsung 980 Pro 1TB NVMe M.2', 'SSD-SAM-980-1T', 8, 4, 2500000, 30, N'Tốc độ đọc: 7000MB/s, Ghi: 5000MB/s', 60),
(N'HDD WD Blue 1TB 3.5"', 'HDD-WD-1T', 9, 3, 950000, 40, N'7200RPM, SATA 3', 24),

-- Màn hình
(N'Màn hình Dell UltraSharp U2422H 24"', 'MON-DELL-U24', 10, 7, 5500000, 10, N'Panel: IPS, Độ phân giải: FHD, 60Hz', 36),

-- Phím Chuột
(N'Chuột Logitech G Pro X Superlight', 'MOU-LOG-GPX', 12, 5, 2900000, 25, N'Không dây, Cảm biến HERO 25K', 24),
(N'Bàn phím cơ Logitech G512 Carbon', 'KEY-LOG-G512', 11, 5, 1800000, 20, N'Switch: GX Brown, Led RGB', 24);

-- 3.6. Đơn hàng mẫu
INSERT INTO DonHang (MaNguoiDung, TongTien, TrangThai, DiaChiGiaoHang) VALUES
(2, 4150000, N'Đã giao', N'Số 1 Đại Cồ Việt, Hà Nội'); -- User 1 mua CPU + RAM

-- 3.7. Chi tiết đơn (User mua 1 CPU i5 + 1 RAM 8GB)
INSERT INTO ChiTietDonHang (MaDonHang, MaSP, SoLuong, DonGia) VALUES
(1, 1, 1, 3500000), -- i5 12400F
(1, 3, 1, 650000);  -- RAM Kingston

GO

-- =============================================
-- 4. TRUY VẤN KIỂM TRA (TEST)
-- =============================================

-- Lấy tất cả sản phẩm kèm tên danh mục và nhà cung cấp
SELECT sp.TenSP, dm.TenDanhMuc, ncc.TenNCC, sp.GiaBan, sp.ThongSoKyThuat
FROM SanPham sp
JOIN DanhMuc dm ON sp.MaDanhMuc = dm.MaDanhMuc
JOIN NhaCungCap ncc ON sp.MaNCC = ncc.MaNCC;

-- Lấy danh sách sản phẩm thuộc nhóm "Lưu trữ" (SSD + HDD)
-- Sử dụng đệ quy hoặc subquery đơn giản
SELECT * FROM SanPham 
WHERE MaDanhMuc IN (SELECT MaDanhMuc FROM DanhMuc WHERE MaDanhMucCha = 2);
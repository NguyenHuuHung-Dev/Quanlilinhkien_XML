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
('admin', 'ad12345', N'Admin Shop PC', 'admin@pcshop.com', '0909000111', 1, N'TP.HCM'),
('user1', 'pass_user', N'Nguyễn Văn Gamer', 'gamer@gmail.com', '0912345678', 2, N'Hà Nội'),
('hhvt05', 'blue123', N'Nguyễn Thành Công', 'thanhcong123@gmail.com', '0909000287', 2, N'TP.Đà Nẵng');

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
SET IDENTITY_INSERT SanPham ON;
GO
INSERT INTO SanPham (MaSP, TenSP, MaSKU, MaDanhMuc, MaNCC, GiaBan, SoLuongTon, HinhAnh, ThongSoKyThuat, ThoiGianBaoHanh, NgayTao) VALUES 
(1, N'CPU Intel Core i5-12400F', 'CPU-INT-12400F', 4, 1, 3500000, 20, '639002862632270729_core5.jpg', N'Socket: LGA1700, 6 Cores, 12 Threads, Clock: 2.5GHz', 36, '2025-12-01 20:50:21.153'),
(2, N'CPU AMD Ryzen 5 5600X', 'CPU-AMD-5600X', 4, 2, 3900000, 15, '639002862527166772_cpuAMD.jpg', N'Socket: AM4, 6 Cores, 12 Threads, Clock: 3.7GHz', 36, '2025-12-01 20:50:21.153'),
(3, N'RAM Kingston Fury Beast 8GB DDR4 3200MHz', 'RAM-KIN-D4-8G', 5, 3, 650000, 100, '639002870292510337_Ram.png', N'Bus: 3200MHz, CL16, DDR4', 36, '2025-12-01 20:50:21.153'),
(4, N'RAM Samsung 16GB DDR5 4800MHz (Laptop)', 'RAM-SAM-D5-16G', 5, 4, 1200000, 50, '639002862409282244_RamSS.jpg', N'Bus: 4800MHz, DDR5, SODIMM (Laptop)', 36, '2025-12-01 20:50:21.153'),
(5, N'SSD Samsung 980 Pro 1TB NVMe M.2', 'SSD-SAM-980-1T', 8, 4, 2500000, 30, '639002862283090025_SSDSamSung.jpg', N'Tốc độ đọc: 7000MB/s, Ghi: 5000MB/s', 60, '2025-12-01 20:50:21.153'),
(6, N'HDD WD Blue 1TB 3.5"', 'HDD-WD-1T', 9, 3, 950000, 40, '639002862119341564_HHD.jpg', N'7200RPM, SATA 3', 24, '2025-12-01 20:50:21.153'),
(7, N'Màn hình Dell UltraSharp U2422H 24"', 'MON-DELL-U24', 10, 7, 5500000, 9, '639002861867664403_manhinhDellUltra.jpg', N'Panel: IPS, Độ phân giải: FHD, 60Hz', 36, '2025-12-01 20:50:21.153'),
(8, N'Chuột Logitech G Pro X Superlight', 'MOU-LOG-GPX', 12, 5, 2900000, 25, '639002861612959109_chuotLGT.jpg', N'Không dây, Cảm biến HERO 25K', 24, '2025-12-01 20:50:21.153'),
(9, N'Bàn phím cơ Logitech G512 Carbon', 'KEY-LOG-G512', 11, 5, 1800000, 20, '639002861772755219_bpco.jpg', N'Switch: GX Brown, Led RGB', 24, '2025-12-01 20:50:21.153'),
(12, N'Bàn phím cơ gaming Logitech G512', 'KEY-LOG-G513', 11, 5, 3500000, 15, '639002863700042436_bpco.jpg', N'Romer-G Tactile, Romer-G Linear, và một switch mới có tên là GX Blue', 12, '2025-12-02 15:32:50.020'),
(14, N'Màn hình máy tính Dell Ultrasharp U2422H', 'MON-DELL-U25', 10, 7, 6540000, 5, '639002865429397109_manHinhDELL.jpg', N'Dell Ultrasharp U2422H /23.8 inch/ FHD (1920 x 1080) 60Hz', 12, '2025-12-02 15:34:59.000'),
(15, N'CPU INTEL CORE i5 12400F BOX CHÍNH HÃNG', 'CPU-INT-12400S', 4, 1, 3570000, 8, '639002866628994407_corei5.jpg', N'6 NHÂN 12 LUỒNG / Turbo 4.4 GHz / 18MB', 12, '2025-12-02 15:37:42.910');
GO

SET IDENTITY_INSERT SanPham OFF;
GO

-- 3.6. Đơn hàng 
SET IDENTITY_INSERT DonHang ON;
GO

INSERT INTO DonHang (MaDonHang, MaNguoiDung, NgayDat, TongTien, TrangThai, DiaChiGiaoHang, GhiChu) VALUES 
(1, 2, '2025-12-01 20:50:21.157', 4150000, N'Đã giao', N'Số 1 Đại Cồ Việt, Hà Nội', NULL),
(2, 2, '2025-12-02 14:45:19.283', 3600000, N'Đã giao', N'117 Lê Thiết Hùng, Hòa Xuân, Đà Nẵng - SĐT: 0372575316', N'Giao ngoài giờ hành chính'),
(3, 2, '2025-12-02 15:39:18.980', 5500000, N'Đã hủy', N'297 Diên Hồng, Hòa Xuân, Đà Nẵng - SĐT: 0372575316', NULL),
(4, 2, '2025-12-02 15:47:18.473', 5500000, N'Đã hủy', N'48 Cao Thắng, Hải Châu, Đà Nẵng - SĐT: 0372575316', NULL),
(5, 2, '2025-12-02 15:50:44.430', 7140000, N'Đã giao', N'127 Đống Đa, Hải Châu, Đà Nẵng - SĐT: 0372575316', NULL),
(6, 3, '2025-12-03 09:30:00', 4150000, N'Đã giao', N'Số 23, quận 7, TP.HCM - SĐT: 0372575987', N'Giao giờ hành chính'),
(7, 3, '2025-12-04 14:15:00', 4700000, N'Đã giao', N'60 Cao Thắng, Đà Nẵng - SĐT: 0372574567', N'Giao cho bảo vệ');
GO

SET IDENTITY_INSERT DonHang OFF;
GO

-- 3.7. Chi tiết đơn hàng
SET IDENTITY_INSERT ChiTietDonHang ON;
GO

INSERT INTO ChiTietDonHang (MaCTDH, MaDonHang, MaSP, SoLuong, DonGia) VALUES 
(1, 1, 1, 1, 3500000),
(2, 1, 3, 1, 650000),
(3, 2, 9, 2, 1800000),
(4, 3, 7, 1, 5500000),
(5, 4, 7, 1, 5500000),
(6, 5, 15, 2, 3570000),
(7, 6, 1, 1, 3500000),
(8, 6, 2, 1, 3900000);
GO

SET IDENTITY_INSERT ChiTietDonHang OFF;
GO

-- 4. TRUY VẤN KIỂM TRA (TEST)

-- Lấy tất cả sản phẩm kèm tên danh mục và nhà cung cấp
SELECT sp.TenSP, dm.TenDanhMuc, ncc.TenNCC, sp.GiaBan, sp.ThongSoKyThuat
FROM SanPham sp
JOIN DanhMuc dm ON sp.MaDanhMuc = dm.MaDanhMuc
JOIN NhaCungCap ncc ON sp.MaNCC = ncc.MaNCC;

-- Lấy danh sách sản phẩm thuộc nhóm "Lưu trữ" (SSD + HDD)
-- Sử dụng đệ quy hoặc subquery đơn giản
SELECT * FROM SanPham 
WHERE MaDanhMuc IN (SELECT MaDanhMuc FROM DanhMuc WHERE MaDanhMucCha = 2);
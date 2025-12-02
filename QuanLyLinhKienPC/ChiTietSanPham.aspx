<%@ Page Title="Chi Tiết Sản Phẩm" Language="C#" MasterPageFile="~/Site.User.Master" AutoEventWireup="true" CodeBehind="ChiTietSanPham.aspx.cs" Inherits="QuanLyLinhKienPC.ChiTietSanPham" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <style>
        /* --- PRODUCT DETAIL STYLES --- */
        .product-container { background-color: #f8fafc; min-height: 100vh; }
        
        /* Image Box */
        .img-card {
            background: white; border-radius: 12px; padding: 20px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.05); overflow: hidden;
            display: flex; align-items: center; justify-content: center;
            border: 1px solid #e2e8f0;
        }
        .product-img {
            transition: transform 0.3s ease; max-height: 450px; object-fit: contain;
        }
        .img-card:hover .product-img { transform: scale(1.05); } /* Zoom nhẹ khi di chuột */

        /* Info Section */
        .product-title { font-size: 1.8rem; font-weight: 800; color: #1e293b; line-height: 1.3; }
        
        .price-tag {
            color: #dc2626; font-size: 2rem; font-weight: 700;
            background: #fef2f2; display: inline-block; padding: 5px 15px;
            border-radius: 8px; border: 1px dashed #fca5a5;
        }

        .meta-badge {
            font-size: 0.85rem; padding: 6px 12px; border-radius: 20px; font-weight: 600;
        }
        .badge-brand { background-color: #e2e8f0; color: #475569; }
        .badge-cat { background-color: #dbeafe; color: #2563eb; }

        /* Specs List */
        .specs-list li {
            margin-bottom: 12px; display: flex; align-items: center;
            color: #475569; font-size: 0.95rem; border-bottom: 1px dashed #e2e8f0; padding-bottom: 8px;
        }
        .specs-list li i { width: 25px; color: #2563eb; }
        .specs-list li strong { color: #0f172a; margin-left: auto; }

        /* Quantity & Button */
        .qty-input {
            width: 70px; text-align: center; border: 2px solid #e2e8f0;
            border-radius: 8px; font-weight: bold; color: #334155; height: 50px;
        }
        .qty-input:focus { border-color: #2563eb; outline: none; }

        .btn-buy {
            background: linear-gradient(45deg, #2563eb, #1d4ed8);
            color: white; border: none; font-weight: 700; text-transform: uppercase;
            letter-spacing: 0.5px; height: 50px; border-radius: 8px;
            box-shadow: 0 4px 10px rgba(37, 99, 235, 0.3); transition: 0.3s;
        }
        .btn-buy:hover {
            transform: translateY(-2px); box-shadow: 0 6px 15px rgba(37, 99, 235, 0.4); color: white;
        }

        /* Description Box */
        .desc-card {
            background: white; border-radius: 12px; border: none;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
        }
        .desc-header {
            background-color: #f8fafc; border-bottom: 1px solid #e2e8f0;
            padding: 15px 25px; font-weight: 700; color: #334155; text-transform: uppercase;
            border-radius: 12px 12px 0 0;
        }
        .desc-content { padding: 25px; color: #4b5563; line-height: 1.7; font-size: 0.95rem; }
    </style>

    <div class="product-container py-5">
        <div class="container">
            <nav aria-label="breadcrumb" class="mb-4">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="Default.aspx" class="text-decoration-none text-muted"><i class="fas fa-home"></i> Trang chủ</a></li>
                    <li class="breadcrumb-item"><a href="#" class="text-decoration-none text-muted">Sản phẩm</a></li>
                    <li class="breadcrumb-item active text-primary fw-bold" aria-current="page">Chi tiết</li>
                </ol>
            </nav>

            <div class="row g-5">
                <div class="col-lg-5">
                    <div class="img-card sticky-top" style="top: 20px;">
                        <asp:Image ID="imgSP" runat="server" CssClass="img-fluid w-100 product-img" />
                    </div>
                </div>

                <div class="col-lg-7">
                    <h1 class="product-title mb-3"><asp:Label ID="lblTenSP" runat="server"></asp:Label></h1>
                    
                    <div class="d-flex gap-2 mb-4">
                        <span class="meta-badge badge-cat">
                            <i class="fas fa-folder-open me-1"></i> <asp:Label ID="lblDanhMuc" runat="server"></asp:Label>
                        </span>
                        <span class="meta-badge badge-brand">
                            <i class="fas fa-tag me-1"></i> <asp:Label ID="lblNCC" runat="server"></asp:Label>
                        </span>
                        <span class="meta-badge bg-success bg-opacity-10 text-success border border-success border-opacity-25">
                            <i class="fas fa-check-circle me-1"></i> Chính hãng
                        </span>
                    </div>

                    <div class="mb-4">
                        <span class="text-muted text-decoration-line-through me-2 fs-5">
                            <%-- Giả lập giá gốc (cao hơn 10%) để tạo cảm giác giảm giá --%>
                            <asp:Label ID="lblGiaGoc" runat="server" Visible="false"></asp:Label> 
                        </span>
                        <div class="price-tag">
                            <asp:Label ID="lblGia" runat="server"></asp:Label>
                        </div>
                    </div>

                    <div class="card bg-white border-0 shadow-sm mb-4">
                        <div class="card-body">
                            <ul class="list-unstyled specs-list mb-0">
                                <li>
                                    <i class="fas fa-barcode"></i> Mã sản phẩm (SKU)
                                    <strong><asp:Label ID="lblSKU" runat="server"></asp:Label></strong>
                                </li>
                                <li>
                                    <i class="fas fa-box-open"></i> Tình trạng kho
                                    <asp:Label ID="lblTinhTrang" runat="server" CssClass="fw-bold text-success"></asp:Label>
                                </li>
                                <li>
                                    <i class="fas fa-shield-alt"></i> Bảo hành
                                    <strong>12 Tháng (Chính hãng)</strong>
                                </li>
                                <li>
                                    <i class="fas fa-shipping-fast"></i> Vận chuyển
                                    <strong>Miễn phí nội thành</strong>
                                </li>
                            </ul>
                        </div>
                    </div>

                    <hr class="text-muted opacity-25 my-4" />

                    <div class="d-flex align-items-end gap-3 mb-3">
                        <div>
                            <label class="form-label fw-bold small text-muted text-uppercase">Số lượng</label>
                            <asp:TextBox ID="txtSoLuong" runat="server" TextMode="Number" Text="1" min="1" CssClass="qty-input form-control"></asp:TextBox>
                        </div>
                        <div class="flex-grow-1">
                            <asp:Button ID="btnMua" runat="server" Text="Thêm Vào Giỏ Hàng" OnClick="btnMua_Click" CssClass="btn btn-buy w-100" />
                        </div>
                    </div>
                    
                    <asp:Label ID="lblMsg" runat="server" CssClass="d-block mb-3 fw-bold"></asp:Label>

                    <div class="d-flex gap-3 text-muted small">
                        <span><i class="fas fa-lock me-1"></i>Thanh toán bảo mật</span>
                        <span><i class="fas fa-sync me-1"></i>Đổi trả trong 7 ngày</span>
                    </div>
                </div>
            </div>

            <div class="row mt-5">
                <div class="col-12">
                    <div class="desc-card">
                        <div class="desc-header">
                            <i class="fas fa-file-alt me-2 text-primary"></i> Mô Tả Chi Tiết & Thông Số Kỹ Thuật
                        </div>
                        <div class="desc-content">
                            <asp:Label ID="lblMoTa" runat="server" style="white-space: pre-line;"></asp:Label>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="mt-5 text-center">
                <h5 class="fw-bold text-secondary text-uppercase mb-4">Sản Phẩm Cùng Danh Mục</h5>
                </div>

        </div>
    </div>

</asp:Content>
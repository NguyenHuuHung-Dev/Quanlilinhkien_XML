<%@ Page Title="Cập Nhật Sản Phẩm" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="ThemSuaSanPham.aspx.cs" Inherits="QuanLyLinhKienPC.ThemSuaSanPham" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    
    <style>
        /* --- TECH FORM STYLES --- */
        .tech-card {
            background: white; border: none; border-radius: 12px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            overflow: hidden;
        }

        .tech-header {
            background-color: #f8fafc; border-bottom: 1px solid #e2e8f0; padding: 20px 30px;
        }

        /* Form Controls */
        .form-label { font-weight: 600; color: #475569; font-size: 0.9rem; margin-bottom: 8px; }
        .form-control, .form-select {
            border: 1px solid #cbd5e1; border-radius: 8px; padding: 10px 15px;
            font-size: 0.95rem; color: #334155; transition: 0.2s;
        }
        .form-control:focus, .form-select:focus {
            border-color: #2563eb; box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
        }

        /* Input Group (Giá tiền) */
        .input-group-text { background-color: #f1f5f9; border-color: #cbd5e1; color: #64748b; font-weight: 600; }

        /* Button Styles */
        .btn-tech-primary {
            background-color: #2563eb; color: white; border: none; padding: 10px 25px;
            border-radius: 8px; font-weight: 600; transition: 0.2s;
        }
        .btn-tech-primary:hover { background-color: #1d4ed8; color: white; transform: translateY(-1px); box-shadow: 0 4px 10px rgba(37, 99, 235, 0.3); }

        .btn-tech-secondary {
            background-color: #f1f5f9; color: #475569; border: 1px solid #e2e8f0; padding: 10px 25px;
            border-radius: 8px; font-weight: 600; transition: 0.2s; text-decoration: none; display: inline-block;
        }
        .btn-tech-secondary:hover { background-color: #e2e8f0; color: #1e293b; }

        /* Image Preview Area */
        .img-preview-box {
            border: 2px dashed #cbd5e1; border-radius: 10px; padding: 10px;
            text-align: center; background-color: #f8fafc; min-height: 150px;
            display: flex; align-items: center; justify-content: center; flex-direction: column;
        }
    </style>

    <div class="container py-3">
        <nav aria-label="breadcrumb" class="mb-4">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="QuanLySanPham.aspx" class="text-decoration-none text-muted">Kho Sản Phẩm</a></li>
                <li class="breadcrumb-item active text-primary fw-bold" aria-current="page">Cập Nhật Thông Tin</li>
            </ol>
        </nav>

        <div class="row justify-content-center">
            <div class="col-lg-10">
                <div class="tech-card">
                    <div class="tech-header d-flex justify-content-between align-items-center">
                        <h5 class="m-0 fw-bold text-dark text-uppercase">
                            <i class="fas fa-edit text-primary me-2"></i>Thông Tin Sản Phẩm
                        </h5>
                        <span class="badge bg-primary bg-opacity-10 text-primary px-3 py-2 rounded-pill">Tech Inventory</span>
                    </div>
                    
                    <div class="card-body p-4 p-md-5">
                        <asp:HiddenField ID="hdfID" runat="server" />

                        <div class="row mb-4">
                            <div class="col-md-8">
                                <label class="form-label">Tên Sản Phẩm <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <span class="input-group-text bg-white"><i class="fas fa-box"></i></span>
                                    <asp:TextBox ID="txtTen" runat="server" CssClass="form-control border-start-0 ps-0" placeholder="Ví dụ: RAM Kingston 8GB DDR4..."></asp:TextBox>
                                </div>
                            </div>
                            <div class="col-md-4 mt-3 mt-md-0">
                                <label class="form-label">Mã SKU (Mã kho)</label>
                                <asp:TextBox ID="txtSKU" runat="server" CssClass="form-control" placeholder="Mã tự động hoặc nhập tay"></asp:TextBox>
                            </div>
                        </div>

                        <div class="row mb-4">
                            <div class="col-md-6">
                                <label class="form-label">Phân Loại (Danh Mục)</label>
                                <asp:DropDownList ID="ddlDanhMuc" runat="server" CssClass="form-select"></asp:DropDownList>
                            </div>
                            <div class="col-md-6 mt-3 mt-md-0">
                                <label class="form-label">Nhà Sản Xuất (Thương Hiệu)</label>
                                <asp:DropDownList ID="ddlNCC" runat="server" CssClass="form-select"></asp:DropDownList>
                            </div>
                        </div>

                        <div class="row mb-4">
                            <div class="col-md-6">
                                <label class="form-label">Giá Bán Niêm Yết</label>
                                <div class="input-group">
                                    <asp:TextBox ID="txtGia" runat="server" CssClass="form-control fw-bold text-primary" TextMode="Number" min="0"></asp:TextBox>
                                    <span class="input-group-text">VNĐ</span>
                                </div>
                                <div class="form-text small">Giá bán lẻ đề xuất cho khách hàng.</div>
                            </div>
                            <div class="col-md-6 mt-3 mt-md-0">
                                <label class="form-label">Số Lượng Nhập Kho</label>
                                <asp:TextBox ID="txtSL" runat="server" CssClass="form-control" TextMode="Number" min="0"></asp:TextBox>
                                <div class="form-text small">Cảnh báo khi số lượng dưới 10.</div>
                            </div>
                        </div>

                        <div class="row mb-4">
                            <div class="col-md-4">
                                <label class="form-label">Hình Ảnh Minh Họa</label>
                                <div class="img-preview-box mb-2">
                                    <asp:Image ID="imgCurrent" runat="server" CssClass="img-fluid rounded shadow-sm" style="max-height: 140px;" Visible="false" />
                                    <asp:Label ID="lblNoImage" runat="server" Text="Chưa có ảnh" CssClass="text-muted small fst-italic" Visible="false"></asp:Label>
                                </div>
                                <asp:FileUpload ID="fUpload" runat="server" CssClass="form-control form-control-sm" />
                                <asp:Label ID="lblAnhCu" runat="server" Visible="false"></asp:Label>
                            </div>
                            <div class="col-md-8 mt-3 mt-md-0">
                                <label class="form-label">Thông Số Kỹ Thuật / Mô Tả Chi Tiết</label>
                                <asp:TextBox ID="txtMoTa" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="6" placeholder="- Dung lượng: 8GB&#10;- Bus: 3200MHz&#10;- Bảo hành: 36 tháng..."></asp:TextBox>
                            </div>
                        </div>

                        <div class="d-flex justify-content-end align-items-center gap-3 border-top pt-4 mt-2">
                            <a href="QuanLySanPham.aspx" class="btn-tech-secondary">
                                <i class="fas fa-arrow-left me-1"></i> Hủy Bỏ
                            </a>
                            <asp:Button ID="btnLuu" runat="server" Text="Lưu Dữ Liệu" OnClick="btnLuu_Click" CssClass="btn-tech-primary shadow-sm" />
                        </div>
                        
                        <asp:Label ID="lblMsg" runat="server" CssClass="d-block mt-3 text-center fw-bold small"></asp:Label>
                    </div>
                </div>
            </div>
        </div>
    </div>

</asp:Content>
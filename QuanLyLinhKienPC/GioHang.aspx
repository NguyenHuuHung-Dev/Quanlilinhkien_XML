<%@ Page Title="Giỏ Hàng Của Bạn" Language="C#" MasterPageFile="~/Site.User.Master" AutoEventWireup="true" CodeBehind="GioHang.aspx.cs" Inherits="QuanLyLinhKienPC.GioHang" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <style>
        /* CSS Riêng cho trang Giỏ hàng theo Ocean Theme */
        :root {
            --primary: #0ea5e9;
            --primary-dark: #0284c7;
            --bg-soft: #f0f9ff;
            --text-dark: #0f172a;
        }

        .cart-container {
            padding: 60px 0;
            min-height: 80vh;
        }

        .page-title {
            font-size: 2rem;
            font-weight: 800;
            color: var(--text-dark);
            margin-bottom: 30px;
            position: relative;
            display: inline-block;
        }
        .page-title::after {
            content: '';
            position: absolute;
            bottom: -5px; left: 0;
            width: 50%; height: 4px;
            background: var(--primary);
            border-radius: 2px;
        }

        /* Bảng giỏ hàng Custom */
        .cart-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0 15px; /* Khoảng cách giữa các hàng */
        }
        
        .cart-table thead th {
            border: none;
            background: transparent;
            color: #64748b;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 0.85rem;
            padding-bottom: 10px;
        }

        .cart-row {
            background: white;
            box-shadow: 0 5px 20px rgba(0,0,0,0.05);
            transition: transform 0.2s;
            border-radius: 12px;
        }
        .cart-row:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 25px rgba(14, 165, 233, 0.15);
        }

        .cart-row td {
            padding: 20px;
            vertical-align: middle;
            border-top: 1px solid #f1f5f9;
            border-bottom: 1px solid #f1f5f9;
        }
        .cart-row td:first-child {
            border-left: 1px solid #f1f5f9;
            border-top-left-radius: 12px;
            border-bottom-left-radius: 12px;
        }
        .cart-row td:last-child {
            border-right: 1px solid #f1f5f9;
            border-top-right-radius: 12px;
            border-bottom-right-radius: 12px;
        }

        .cart-img {
            width: 80px; height: 80px;
            object-fit: contain;
            border-radius: 10px;
            background: #f8fafc;
            padding: 5px;
            border: 1px solid #e2e8f0;
        }

        /* Input số lượng */
        .qty-input {
            width: 60px;
            text-align: center;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            padding: 5px;
            font-weight: 600;
            color: var(--text-dark);
            outline: none;
        }
        .qty-input:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(14, 165, 233, 0.1);
        }

        /* Summary Card */
        .summary-card {
            background: white;
            border-radius: 20px;
            padding: 30px;
            border: 1px solid #e2e8f0;
            box-shadow: 0 10px 30px rgba(0,0,0,0.05);
            position: sticky;
            top: 100px;
        }
        
        .summary-header {
            font-size: 1.2rem;
            font-weight: 700;
            margin-bottom: 20px;
            color: var(--text-dark);
            padding-bottom: 15px;
            border-bottom: 2px dashed #e2e8f0;
        }

        .summary-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 15px;
            font-size: 0.95rem;
            color: #64748b;
        }

        .total-row {
            display: flex;
            justify-content: space-between;
            margin-top: 20px;
            padding-top: 20px;
            border-top: 1px solid #e2e8f0;
            font-size: 1.25rem;
            font-weight: 800;
            color: var(--text-dark);
        }

        /* Buttons */
        .btn-gradient {
            background: linear-gradient(to right, var(--primary), #3b82f6);
            color: white;
            border: none;
            padding: 15px;
            border-radius: 12px;
            font-weight: 700;
            width: 100%;
            transition: all 0.3s;
            box-shadow: 0 10px 20px -5px rgba(14, 165, 233, 0.4);
        }
        .btn-gradient:hover {
            transform: translateY(-2px);
            box-shadow: 0 15px 30px -5px rgba(14, 165, 233, 0.6);
            color: white;
        }

        .btn-update {
            background: white;
            color: var(--primary);
            border: 2px solid #e2e8f0;
            padding: 10px 20px;
            border-radius: 10px;
            font-weight: 600;
            transition: all 0.2s;
        }
        .btn-update:hover {
            border-color: var(--primary);
            background: var(--bg-soft);
        }

        .btn-trash {
            color: #94a3b8;
            transition: 0.2s;
            font-size: 1.1rem;
        }
        .btn-trash:hover { color: #ef4444; transform: scale(1.1); }

    </style>

    <div class="container cart-container">
        
        <div class="d-flex justify-content-between align-items-end mb-5">
            <div>
                <h2 class="page-title">Giỏ Hàng</h2>
                <p class="text-muted m-0">Kiểm tra lại các sản phẩm trước khi thanh toán</p>
            </div>
            <a href="Default.aspx" class="btn btn-link text-decoration-none fw-bold" style="color: var(--primary)">
                <i class="fas fa-arrow-left me-1"></i> Tiếp tục mua sắm
            </a>
        </div>

        <asp:Panel ID="pnlGioRong" runat="server" Visible="false" CssClass="text-center py-5 animate__animated animate__fadeIn">
            <div class="mb-4">
                <div style="width: 120px; height: 120px; background: var(--bg-soft); border-radius: 50%; display: inline-flex; align-items: center; justify-content: center;">
                    <i class="fas fa-shopping-basket" style="font-size: 50px; color: var(--primary);"></i>
                </div>
            </div>
            <h3 class="fw-bold text-dark">Giỏ hàng của bạn đang trống</h3>
            <p class="text-muted mb-4">Hãy dạo một vòng và chọn những món linh kiện ưng ý nhé!</p>
            <a href="Default.aspx" class="btn btn-gradient" style="width: auto; padding: 12px 40px;">
                Khám phá ngay
            </a>
        </asp:Panel>

        <asp:Panel ID="pnlCoHang" runat="server">
            <div class="row g-5">
                <div class="col-lg-8">
                    <div class="table-responsive">
                        <asp:GridView ID="gvGioHang" runat="server" AutoGenerateColumns="False" 
                            CssClass="cart-table" GridLines="None"
                            DataKeyNames="MaSP" OnRowDeleting="gvGioHang_RowDeleting">
                            <Columns>
                                <%-- Cột Sản Phẩm --%>
                                <asp:TemplateField HeaderText="Sản phẩm">
                                    <ItemTemplate>
                                        <div class="d-flex align-items-center">
                                            <img src='<%# "Images/Products/" + (string.IsNullOrEmpty(Eval("HinhAnh").ToString()) ? "no_image.png" : Eval("HinhAnh")) %>' 
                                                 class="cart-img shadow-sm" alt="Product">
                                            <div class="ms-3">
                                                <h6 class="fw-bold mb-1 text-dark"><%# Eval("TenSP") %></h6>
                                                <small class="text-muted">Mã: #<%# Eval("MaSP") %></small>
                                            </div>
                                        </div>
                                    </ItemTemplate>
                                    <ItemStyle CssClass="cart-row-item" />
                                </asp:TemplateField>

                                <%-- Cột Đơn Giá --%>
                                <asp:TemplateField HeaderText="Đơn giá">
                                    <ItemTemplate>
                                        <span class="fw-semibold text-muted">
                                            <%# string.Format("{0:N0} đ", Eval("GiaBan")) %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <%-- Cột Số Lượng --%>
                                <asp:TemplateField HeaderText="Số lượng" ItemStyle-Width="100px">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtSoLuong" runat="server" Text='<%# Eval("SoLuong") %>' 
                                            TextMode="Number" min="1" CssClass="qty-input"></asp:TextBox>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <%-- Cột Thành Tiền --%>
                                <asp:TemplateField HeaderText="Tạm tính">
                                    <ItemTemplate>
                                        <span class="fw-bold" style="color: var(--primary-dark)">
                                            <%# string.Format("{0:N0} đ", Convert.ToDecimal(Eval("GiaBan")) * Convert.ToInt32(Eval("SoLuong"))) %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <%-- Cột Xóa --%>
                                <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnXoa" runat="server" CommandName="Delete" 
                                            CssClass="btn-trash" ToolTip="Xóa khỏi giỏ">
                                            <i class="fas fa-trash-alt"></i>
                                        </asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            
                            <RowStyle CssClass="cart-row" />
                        </asp:GridView>
                    </div>

                    <div class="d-flex justify-content-between align-items-center mt-4">
                        <asp:Label ID="lblMsg" runat="server" CssClass="fw-bold"></asp:Label>
                        <asp:Button ID="btnCapNhat" runat="server" Text="Cập nhật giỏ hàng" 
                            OnClick="btnCapNhat_Click" CssClass="btn-update" />
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="summary-card">
                        <div class="summary-header">Tóm tắt đơn hàng</div>
                        
                        <div class="summary-row">
                            <span>Tạm tính</span>
                            <span class="fw-bold text-dark"><asp:Label ID="lblTamTinh" runat="server"></asp:Label></span>
                        </div>
                        <div class="summary-row">
                            <span>Giảm giá</span>
                            <span class="text-success">- 0 đ</span>
                        </div>
                        <div class="summary-row">
                            <span>Phí vận chuyển</span>
                            <span class="text-muted">Tính khi thanh toán</span>
                        </div>

                        <div class="total-row">
                            <span>Tổng cộng</span>
                            <span style="color: var(--primary)"><asp:Label ID="lblTongTien" runat="server"></asp:Label></span>
                        </div>

                        <div class="mt-4">
                            <asp:Button ID="btnThanhToan" runat="server" Text="THANH TOÁN NGAY" 
                                OnClick="btnThanhToan_Click" CssClass="btn-gradient" />
                        </div>

                        <div class="mt-3 text-center">
                            <small class="text-muted"><i class="fas fa-shield-alt me-1"></i> Bảo mật thanh toán 100%</small>
                        </div>
                    </div>
                </div>
            </div>
        </asp:Panel>
    </div>

</asp:Content>
<%@ Page Title="Chi Tiết Đơn Hàng" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="ChiTietDonHang.aspx.cs" Inherits="QuanLyLinhKienPC.ChiTietDonHang" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid" style="max-width: 1000px;">
        <div class="d-flex align-items-center justify-content-between mb-4">
            <h4 class="fw-bold text-dark mb-0">
                <i class="fas fa-file-invoice-dollar text-primary me-2"></i>ĐƠN HÀNG #<asp:Label ID="lblMaDonHang" runat="server"></asp:Label>
            </h4>
            <a href="QuanLyDonHang.aspx" class="btn btn-outline-secondary btn-sm">
                <i class="fas fa-arrow-left me-1"></i>Quay lại danh sách
            </a>
        </div>

        <div class="row g-4">
            <div class="col-lg-8">
                <div class="card border-0 shadow-sm rounded-4 h-100">
                    <div class="card-header bg-white py-3 border-bottom">
                        <h6 class="fw-bold m-0 text-primary"><i class="fas fa-box-open me-2"></i>Danh sách sản phẩm</h6>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <asp:GridView ID="gvChiTiet" runat="server" AutoGenerateColumns="False" 
                                CssClass="table table-hover align-middle mb-0" GridLines="None" ShowHeaderWhenEmpty="true">
                                <Columns>
                                    <asp:TemplateField HeaderText="Sản phẩm">
                                        <ItemTemplate>
                                            <div class="fw-bold"><%# Eval("TenSP") %></div>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                   <asp:BoundField DataField="SoLuong" HeaderText="SL" ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center" />
                                    <asp:BoundField DataField="DonGia" HeaderText="Đơn giá" DataFormatString="{0:N0} đ" ItemStyle-CssClass="text-end" HeaderStyle-CssClass="text-end" />
                                    <asp:BoundField DataField="ThanhTien" HeaderText="Thành tiền" DataFormatString="{0:N0} đ" ItemStyle-CssClass="fw-bold text-primary text-end" HeaderStyle-CssClass="text-end" />
                                </Columns>
                                <EmptyDataTemplate>
                                    <div class="p-3 text-center text-muted">Không có dữ liệu sản phẩm.</div>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </div>
                    </div>
                    <div class="card-footer bg-light text-end py-3">
                        <span class="text-muted me-2">Tổng tiền:</span>
                        <asp:Label ID="lblTongTien" runat="server" CssClass="fs-4 fw-bold text-danger"></asp:Label>
                    </div>
                </div>
            </div>

            <div class="col-lg-4">
                <div class="card border-0 shadow-sm rounded-4 mb-4">
                    <div class="card-body">
                        <h6 class="fw-bold text-dark border-bottom pb-2 mb-3"><i class="fas fa-user-circle me-2"></i>Khách hàng</h6>
                        <div class="mb-2">
                            <span class="d-block small text-muted">Họ tên:</span>
                            <span class="fw-bold"><asp:Label ID="lblKhachHang" runat="server"></asp:Label></span>
                        </div>
                        <div class="mb-2">
                            <span class="d-block small text-muted">Ngày đặt:</span>
                            <span class="fw-bold"><i class="far fa-clock me-1"></i><asp:Label ID="lblNgayDat" runat="server"></asp:Label></span>
                        </div>
                        <div class="mb-2">
                            <span class="d-block small text-muted">Địa chỉ giao:</span>
                            <span class="fw-bold"><asp:Label ID="lblDiaChi" runat="server"></asp:Label></span>
                        </div>
                        <div>
                            <span class="d-block small text-muted">Ghi chú:</span>
                            <span class="fst-italic text-secondary"><asp:Label ID="lblGhiChu" runat="server"></asp:Label></span>
                        </div>
                    </div>
                </div>

                <div class="card border-0 shadow-sm rounded-4 bg-primary bg-opacity-10">
                    <div class="card-body">
                        <h6 class="fw-bold text-primary border-bottom border-primary border-opacity-25 pb-2 mb-3">
                            <i class="fas fa-tasks me-2"></i>Cập nhật trạng thái
                        </h6>
                        
                        <asp:Label ID="lblMsg" runat="server" CssClass="d-block mb-2 small fw-bold"></asp:Label>

                        <div class="mb-3">
                            <label class="form-label small fw-bold">Trạng thái hiện tại:</label>
                            <asp:DropDownList ID="ddlTrangThai" runat="server" CssClass="form-select fw-bold">
                                <asp:ListItem Value="Mới">⏳ Chờ duyệt</asp:ListItem>
                                <asp:ListItem Value="Đang giao hàng">🚚 Đang giao</asp:ListItem>
                                <asp:ListItem Value="Đã giao">✅ Đã giao</asp:ListItem>
                                <asp:ListItem Value="Đã hủy">❌ Đã hủy</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="d-grid">
                            <asp:Button ID="btnUpdateStatus" runat="server" Text="Lưu Thay Đổi" OnClick="btnUpdateStatus_Click" CssClass="btn btn-primary fw-bold" />
                        </div>
                        <div class="mt-2 text-center">
                            <small class="text-muted fst-italic">* Nếu chọn "Đã hủy", số lượng sẽ được hoàn trả vào kho.</small>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
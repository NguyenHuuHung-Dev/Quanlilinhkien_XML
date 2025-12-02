<%@ Page Title="Thanh Toán" Language="C#" MasterPageFile="~/Site.User.Master" AutoEventWireup="true" CodeBehind="ThanhToan.aspx.cs" Inherits="QuanLyLinhKienPC.ThanhToan" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    
    <div class="container py-5">
        <h2 class="mb-4 fw-bold text-success"><i class="fas fa-money-check-alt me-2"></i>THANH TOÁN</h2>

        <div class="row">
            <div class="col-md-7">
                <div class="card shadow-sm border-0 mb-4">
                    <div class="card-header bg-white">
                        <h5 class="mb-0 fw-bold">Thông tin giao hàng</h5>
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <label class="form-label">Họ tên người nhận (*)</label>
                            <asp:TextBox ID="txtHoTen" runat="server" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvTen" runat="server" ControlToValidate="txtHoTen" ErrorMessage="Vui lòng nhập họ tên" CssClass="text-danger small" Display="Dynamic"></asp:RequiredFieldValidator>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Số điện thoại (*)</label>
                            <asp:TextBox ID="txtSDT" runat="server" CssClass="form-control"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvSDT" runat="server" ControlToValidate="txtSDT" ErrorMessage="Vui lòng nhập số điện thoại" CssClass="text-danger small" Display="Dynamic"></asp:RequiredFieldValidator>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Địa chỉ nhận hàng (*)</label>
                            <asp:TextBox ID="txtDiaChi" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvDiaChi" runat="server" ControlToValidate="txtDiaChi" ErrorMessage="Vui lòng nhập địa chỉ" CssClass="text-danger small" Display="Dynamic"></asp:RequiredFieldValidator>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Ghi chú đơn hàng</label>
                            <asp:TextBox ID="txtGhiChu" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" placeholder="Ví dụ: Giao giờ hành chính..."></asp:TextBox>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-md-5">
                <div class="card shadow-sm border-0 bg-light">
                    <div class="card-header bg-success text-white">
                        <h5 class="mb-0 fw-bold">Đơn hàng của bạn</h5>
                    </div>
                    <div class="card-body">
                        <asp:Repeater ID="rptDonHang" runat="server">
                            <ItemTemplate>
                                <div class="d-flex justify-content-between mb-2 border-bottom pb-2">
                                    <span>
                                        <strong><%# Eval("SoLuong") %>x</strong> <%# Eval("TenSP") %>
                                    </span>
                                    <span class="fw-bold">
                                        <%# string.Format("{0:N0} đ", Convert.ToDecimal(Eval("GiaBan")) * Convert.ToInt32(Eval("SoLuong"))) %>
                                    </span>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                        
                        <div class="d-flex justify-content-between mt-3">
                            <span class="h5">Tổng cộng:</span>
                            <span class="h4 text-danger fw-bold"><asp:Label ID="lblTongTien" runat="server"></asp:Label></span>
                        </div>

                        <hr />
                        
                        <div class="form-check mb-3">
                            <input class="form-check-input" type="radio" name="paymentMethod" id="cod" checked>
                            <label class="form-check-label" for="cod">
                                Thanh toán khi nhận hàng (COD)
                            </label>
                        </div>

                        <div class="d-grid">
                            <asp:Button ID="btnDatHang" runat="server" Text="XÁC NHẬN ĐẶT HÀNG" OnClick="btnDatHang_Click" CssClass="btn btn-danger btn-lg fw-bold" />
                        </div>
                        
                        <asp:Label ID="lblLoi" runat="server" CssClass="d-block mt-2 text-danger text-center fw-bold"></asp:Label>
                    </div>
                </div>
            </div>
        </div>
    </div>

</asp:Content>
<%@ Page Title="Cập Nhật Tài Khoản" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="CapNhatTaiKhoan.aspx.cs" Inherits="QuanLyLinhKienPC.CapNhatTaiKhoan" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid" style="max-width: 800px;">
        <div class="d-flex align-items-center justify-content-between mb-4">
            <h4 class="fw-bold text-dark mb-0"><i class="fas fa-user-edit text-primary me-2"></i>CẬP NHẬT TÀI KHOẢN</h4>
            <a href="QuanLyKhachHang.aspx" class="btn btn-outline-secondary btn-sm"><i class="fas fa-arrow-left me-1"></i>Quay lại</a>
        </div>

        <div class="card border-0 shadow-sm rounded-4">
            <div class="card-body p-4">
                <asp:Label ID="lblMsg" runat="server" CssClass="d-block mb-3 text-center fw-bold"></asp:Label>
                
                <div class="row g-3">
                    <div class="col-md-4 text-center border-end">
                        <div class="mb-3">
                            <div class="d-inline-flex align-items-center justify-content-center bg-light text-primary rounded-circle fw-bold border" style="width: 80px; height: 80px; font-size: 2rem;">
                                <asp:Label ID="lblAvatar" runat="server">A</asp:Label>
                            </div>
                        </div>
                        <div class="mb-3 text-start">
                            <label class="small text-muted fw-bold">Tên đăng nhập</label>
                            <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control bg-light" ReadOnly="true"></asp:TextBox>
                        </div>
                        <div class="mb-3 text-start">
                            <label class="small text-muted fw-bold">Email</label>
                            <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control bg-light" ReadOnly="true"></asp:TextBox>
                        </div>
                        <div class="mb-3 text-start">
                             <label class="small text-muted fw-bold">Mật khẩu (Mã hóa)</label>
                             <div class="input-group">
                                 <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control bg-light" TextMode="Password" ReadOnly="true"></asp:TextBox>
                                 <button type="button" class="btn btn-outline-secondary" onclick="togglePass()"><i class="fas fa-eye"></i></button>
                             </div>
                        </div>
                    </div>

                    <div class="col-md-8 ps-md-4">
                        <div class="row g-3">
                            <div class="col-12">
                                <label class="form-label fw-bold">Họ và tên (*)</label>
                                <asp:TextBox ID="txtHoTen" runat="server" CssClass="form-control"></asp:TextBox>
                            </div>
                            
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Số điện thoại</label>
                                <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control"></asp:TextBox>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-bold text-primary">Vai trò</label>
                                <asp:DropDownList ID="ddlRole" runat="server" CssClass="form-select fw-bold"></asp:DropDownList>
                            </div>

                            <div class="col-12">
                                <label class="form-label fw-bold">Địa chỉ</label>
                                <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2"></asp:TextBox>
                            </div>

                            <div class="col-12">
                                <div class="form-check form-switch p-0 mt-2">
                                    <label class="form-check-label fw-bold me-3" for="chkActive">Trạng thái hoạt động:</label>
                                    <asp:CheckBox ID="chkActive" runat="server" CssClass="form-check-input ms-0" style="margin-left: 10px !important; float: none;" />
                                </div>
                            </div>

                            <div class="col-12 mt-4">
                                <asp:Button ID="btnSave" runat="server" Text="Lưu Thay Đổi" OnClick="btnSave_Click" CssClass="btn btn-primary px-4 fw-bold" />
                                <a href="QuanLyKhachHang.aspx" class="btn btn-secondary px-4">Hủy</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        function togglePass() {
            var x = document.getElementById('<%= txtPassword.ClientID %>');
            if (x.type === "password") x.type = "text"; else x.type = "password";
        }
    </script>
</asp:Content>